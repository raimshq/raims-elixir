# The baseline is independent of generation. Review intentional updates.
args = Enum.reject(System.argv(), &(&1 == "--"))

unless args in [[], ["--write"]],
  do: raise("Usage: mix run scripts/check-compatibility.exs [-- --write]")

{:ok, modules} = :application.get_key(:raims, :modules)
excluded = [Raims.Contract, Raims.Schema, Raims.Transport]

symbols =
  modules
  |> Enum.filter(
    &(String.starts_with?(Atom.to_string(&1), "Elixir.Raims") and &1 not in excluded)
  )
  |> Enum.reduce(%{}, fn module, result ->
    Code.ensure_loaded!(module)

    functions =
      module.__info__(:functions)
      |> Enum.map(fn {name, arity} -> [Atom.to_string(name), arity] end)
      |> Enum.sort()

    macros =
      module.__info__(:macros)
      |> Enum.map(fn {name, arity} -> [Atom.to_string(name), arity] end)
      |> Enum.sort()

    fields =
      if function_exported?(module, :__struct__, 0),
        do: module.__struct__() |> Map.keys() |> Enum.map(&Atom.to_string/1) |> Enum.sort(),
        else: []

    enforced_fields =
      if function_exported?(module, :__struct__, 0) do
        defaults = module.__struct__() |> Map.from_struct()

        accepts_fields = fn entries ->
          try do
            module.__struct__(entries)
            true
          rescue
            ArgumentError -> false
          end
        end

        if accepts_fields.([]) do
          []
        else
          unless accepts_fields.(Map.to_list(defaults)),
            do: raise("Cannot inspect public struct construction: #{module}")

          defaults
          |> Map.keys()
          |> Enum.reject(&accepts_fields.(defaults |> Map.delete(&1) |> Map.to_list()))
          |> Enum.map(&Atom.to_string/1)
          |> Enum.sort()
        end
      else
        []
      end

    specs =
      case Code.Typespec.fetch_specs(module) do
        {:ok, values} ->
          Map.new(values, fn {{name, arity}, clauses} ->
            {Atom.to_string(name) <> "/" <> Integer.to_string(arity),
             Enum.map(clauses, &(Code.Typespec.spec_to_quoted(name, &1) |> Macro.to_string()))}
          end)

        :error ->
          %{}
      end

    types =
      case Code.Typespec.fetch_types(module) do
        {:ok, values} ->
          values
          |> Enum.filter(fn {kind, _} -> kind in [:type, :opaque] end)
          |> Map.new(fn {kind, value} ->
            {value |> elem(0) |> Atom.to_string(),
             [Atom.to_string(kind), Code.Typespec.type_to_quoted(value) |> Macro.to_string()]}
          end)

        :error ->
          %{}
      end

    values =
      if module == Raims.EnumValues do
        module.__info__(:functions)
        |> Enum.filter(fn {_name, arity} -> arity == 0 end)
        |> Map.new(fn {name, 0} -> {Atom.to_string(name), apply(module, name, [])} end)
      else
        %{}
      end

    Map.put(result, Atom.to_string(module), %{
      "functions" => functions,
      "macros" => macros,
      "struct_fields" => fields,
      "enforced_struct_keys" => enforced_fields,
      "specs" => specs,
      "types" => types,
      "values" => values
    })
  end)

current = %{"format" => 2, "symbols" => symbols}
path = Path.expand("../contracts/elixir-api.json", __DIR__)

if args == ["--write"] do
  File.write!(path, JSON.encode!(current) <> "\n")
  IO.puts("Wrote #{map_size(symbols)} public Elixir definitions. Review the baseline diff.")
else
  baseline = path |> File.read!() |> JSON.decode!()

  unless baseline["format"] == 2 and is_map(baseline["symbols"]),
    do: raise("Unsupported Elixir API baseline.")

  Enum.each(baseline["symbols"], fn {name, previous} ->
    actual = Map.get(symbols, name) || raise("Missing public Elixir module: #{name}")

    for kind <- ["functions", "macros", "struct_fields"] do
      unless Enum.all?(previous[kind], &(&1 in actual[kind])),
        do: raise("Public Elixir API changed: #{name}.#{kind}")
    end

    unless is_list(previous["enforced_struct_keys"]) and
             Enum.all?(actual["enforced_struct_keys"], &(&1 in previous["enforced_struct_keys"])),
           do: raise("Public Elixir API changed: #{name}.enforced_struct_keys")

    for kind <- ["specs", "types", "values"], {member, value} <- previous[kind] do
      unless actual[kind][member] == value,
        do: raise("Public Elixir API changed: #{name}.#{kind}.#{member}")
    end
  end)

  IO.puts("Checked #{map_size(baseline["symbols"])} public Elixir definitions.")
end
