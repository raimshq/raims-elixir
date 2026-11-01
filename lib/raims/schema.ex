defmodule Raims.Schema do
  @moduledoc false
  @max_depth 100

  def normalize(value), do: normalize(value, 0)
  defp normalize(_value, depth) when depth > @max_depth, do: invalid!()

  defp normalize(value, _depth) when is_binary(value) do
    if String.valid?(value), do: value, else: invalid!()
  end

  defp normalize(value, _depth) when is_integer(value) or is_float(value), do: value
  defp normalize(value, _depth) when value in [nil, true, false], do: value
  defp normalize(value, depth) when is_list(value), do: normalize_list(value, depth, [])
  defp normalize(%{__struct__: _}, _depth), do: invalid!()

  defp normalize(value, depth) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, child}, result ->
      name =
        cond do
          is_atom(key) -> Atom.to_string(key)
          is_binary(key) and String.valid?(key) -> key
          true -> invalid!()
        end

      if Map.has_key?(result, name), do: invalid!()
      Map.put(result, name, normalize(child, depth + 1))
    end)
  end

  defp normalize(_value, _depth), do: invalid!()

  defp normalize_list([], _depth, normalized), do: Enum.reverse(normalized)

  defp normalize_list([value | tail], depth, normalized),
    do: normalize_list(tail, depth, [normalize(value, depth + 1) | normalized])

  defp normalize_list(_tail, _depth, _normalized), do: invalid!()

  def valid?(value, schema, mode \\ :response) do
    validate(value, schema, mode, 0)
  rescue
    _ -> false
  end

  defp validate(_value, _schema, _mode, depth) when depth > @max_depth, do: false

  defp validate(value, %{"$ref" => reference}, mode, depth),
    do: validate(value, resolve(reference), mode, depth + 1)

  defp validate(value, schema, mode, depth) when is_map(schema) do
    variants = schema["anyOf"] || schema["oneOf"]

    cond do
      is_list(variants) ->
        Enum.any?(variants, &validate(value, &1, mode, depth + 1))

      Map.has_key?(schema, "allOf") ->
        Enum.all?(schema["allOf"], &validate(value, &1, mode, depth + 1))

      is_nil(value) ->
        (is_nil(schema["type"]) or schema["nullable"] == true or
           "null" in List.wrap(schema["type"])) and constraints?(value, schema, mode)

      true ->
        typed?(value, schema, mode, depth) and constraints?(value, schema, mode)
    end
  end

  defp validate(_value, _schema, _mode, _depth), do: false

  defp typed?(value, schema, mode, depth) do
    kind = schema["type"] |> List.wrap() |> Enum.find(&(&1 != "null"))

    case kind do
      "object" ->
        object?(value, schema, mode, depth)

      "array" ->
        is_list(value) and
          Enum.all?(value, &validate(&1, schema["items"] || %{}, mode, depth + 1))

      "integer" ->
        is_integer(value)

      "number" ->
        is_integer(value) or is_float(value)

      "boolean" ->
        is_boolean(value)

      "string" ->
        is_binary(value) and String.valid?(value)

      "null" ->
        false

      nil ->
        not Map.has_key?(schema, "properties") or object?(value, schema, mode, depth)

      _ ->
        false
    end
  end

  defp object?(value, schema, mode, depth) when is_map(value) do
    properties = schema["properties"] || %{}
    additional = schema["additionalProperties"]

    Enum.all?(schema["required"] || [], &Map.has_key?(value, &1)) and
      Enum.all?(value, fn {key, child} ->
        is_binary(key) and
          (mode != :request or not is_map(schema["propertyNames"]) or
             validate(key, schema["propertyNames"], mode, depth + 1)) and
          case Map.fetch(properties, key) do
            {:ok, child_schema} -> validate(child, child_schema, mode, depth + 1)
            :error when mode == :request and additional == false -> false
            :error when is_map(additional) -> validate(child, additional, mode, depth + 1)
            :error -> true
          end
      end)
  end

  defp object?(_value, _schema, _mode, _depth), do: false

  defp constraints?(_value, _schema, :response), do: true

  defp constraints?(value, schema, :request) do
    (not Map.has_key?(schema, "enum") or value in schema["enum"]) and
      (not Map.has_key?(schema, "const") or value == schema["const"]) and
      bounds?(value, schema)
  end

  defp bounds?(value, schema) when is_number(value) do
    (is_nil(schema["minimum"]) or value >= schema["minimum"]) and
      (is_nil(schema["maximum"]) or value <= schema["maximum"]) and
      (is_nil(schema["exclusiveMinimum"]) or value > schema["exclusiveMinimum"]) and
      (is_nil(schema["exclusiveMaximum"]) or value < schema["exclusiveMaximum"])
  end

  defp bounds?(value, schema) when is_binary(value) do
    length = value |> String.codepoints() |> length()

    (is_nil(schema["minLength"]) or length >= schema["minLength"]) and
      (is_nil(schema["maxLength"]) or length <= schema["maxLength"]) and
      (is_nil(schema["x-raims-max-utf8-bytes"]) or
         byte_size(value) <= schema["x-raims-max-utf8-bytes"]) and
      (is_nil(schema["pattern"]) or Regex.match?(Regex.compile!(schema["pattern"]), value))
  end

  defp bounds?(value, schema) when is_list(value) do
    (is_nil(schema["minItems"]) or length(value) >= schema["minItems"]) and
      (is_nil(schema["maxItems"]) or length(value) <= schema["maxItems"]) and
      (schema["uniqueItems"] != true or length(Enum.uniq(value)) == length(value))
  end

  defp bounds?(value, schema) when is_map(value) do
    (is_nil(schema["minProperties"]) or map_size(value) >= schema["minProperties"]) and
      (is_nil(schema["maxProperties"]) or map_size(value) <= schema["maxProperties"]) and
      (is_nil(schema["x-raims-max-utf8-bytes"]) or
         byte_size(JSON.encode!(value)) <= schema["x-raims-max-utf8-bytes"])
  end

  defp bounds?(_value, _schema), do: true

  def hydrate(value, schema), do: hydrate(value, schema, 0)

  defp hydrate(_value, _schema, depth) when depth > @max_depth,
    do: raise(Raims.Error.new(:unexpected_response))

  defp hydrate(value, schema, depth) do
    reference = schema["$ref"]
    resolved = if reference, do: resolve(reference), else: schema
    variants = resolved["anyOf"] || resolved["oneOf"]

    cond do
      Map.has_key?(resolved, "$ref") ->
        hydrate(value, resolved, depth + 1)

      is_list(variants) ->
        child = Enum.find(variants, &valid?(value, &1)) || %{}
        hydrate(value, child, depth + 1)

      is_map(value) ->
        properties = resolved["properties"] || %{}

        additional =
          if is_map(resolved["additionalProperties"]),
            do: resolved["additionalProperties"],
            else: %{}

        data =
          Map.new(value, fn {key, child} ->
            {key, hydrate(child, properties[key] || additional, depth + 1)}
          end)

        module =
          if reference, do: Raims.Contract.model(reference_name(reference)), else: Raims.Object

        struct(module || Raims.Object, data: data)

      is_list(value) ->
        Enum.map(value, &hydrate(&1, resolved["items"] || %{}, depth + 1))

      true ->
        value
    end
  end

  defp resolve(reference), do: Map.fetch!(Raims.Contract.schemas(), reference_name(reference))

  defp reference_name(reference),
    do:
      reference
      |> String.split("/")
      |> List.last()
      |> String.replace("~1", "/")
      |> String.replace("~0", "~")

  defp invalid!,
    do: raise(ArgumentError, "Parameters must contain valid JSON values with unique field names.")
end
