defmodule Raims.MixProject do
  use Mix.Project

  def project do
    [
      app: :raims,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: [{:mint, "~> 1.11.0"}],
      description: "Official Elixir SDK for the Raims public API.",
      source_url: "https://github.com/raimshq/raims-elixir",
      homepage_url: "https://docs.raims.com/en/api",
      package: [
        name: "raims",
        licenses: ["MIT"],
        links: %{"Documentation" => "https://docs.raims.com/en/api"},
        files: [
          "lib",
          "priv/contract.json",
          "mix.exs",
          "README.md",
          "LICENSE",
          "CONTRIBUTING.md",
          "SECURITY.md",
          "docs/installation.md",
          "docs/usage.md",
          "docs/pagination.md",
          "docs/errors-and-retries.md",
          "docs/webhooks.md",
          "docs/reference.md"
        ]
      ]
    ]
    |> engineering_paths()
  end

  def application, do: [extra_applications: [:logger, :crypto, :ssl, :public_key]]

  defp engineering_paths(config) do
    Enum.reduce(
      [{"RAIMS_ELIXIR_BUILD_PATH", :build_path}, {"RAIMS_ELIXIR_DEPS_PATH", :deps_path}],
      config,
      fn {name, key}, result ->
        case System.get_env(name) do
          nil -> result
          path -> Keyword.put(result, key, path)
        end
      end
    )
  end
end
