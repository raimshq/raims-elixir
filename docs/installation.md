# Installation and updates

Requires Elixir 1.18 or later with Erlang/OTP 27 or later. Source code and
releases are distributed through
[GitHub](https://github.com/raimshq/raims-elixir/releases). The package is not
published on Hex. Consumers need the declared Elixir dependencies; Python
and the engineering Toolkit are not runtime requirements.

## Install from GitHub

With Git installed, add this entry to your application's dependencies:

```elixir
defp deps do
  [{:raims, github: "raimshq/raims-elixir"}]
end
```

Then fetch the dependency and compile your application:

```sh
mix deps.get
mix compile
```

The Git dependency initially resolves the repository's default `main`
branch, which may contain changes newer than the latest release. Your
application's `mix.lock` records the selected commit. Keep that lockfile
with your application so subsequent builds use the same revision until
you update it.

## Install a release from source

Download the source archive from the
[current release](https://github.com/raimshq/raims-elixir/releases/latest),
extract it, and add its directory as a Mix path dependency:

```elixir
defp deps do
  [{:raims, path: "/path/to/Raims-Elixir"}]
end
```

Run `mix deps.get` and `mix compile` in your application. A path dependency
uses the files in that directory and does not download future releases.

The release also includes `raims.tar` and `SHA256SUMS`. Verify the archive
against its checksum before using it. `raims.tar` uses the Hex package
format: unpack the outer archive, then extract its `contents.tar.gz` into
the SDK directory. Use that directory as the path dependency above. The
archive format does not imply publication to the Hex registry.

## Keep credentials on the server

Keep the API key in your server's environment or secret store:

```elixir
client = Raims.Client.new(System.fetch_env!("RAIMS_API_KEY"))
```

Do not put keys into browser code, mobile applications, source control, or
logs. The same API hostname serves Sandbox and Production; your key selects
the company and environment.

## Update an existing installation

For a GitHub dependency, update the locked revision and compile:

```sh
mix deps.update raims
mix compile
```

Run your application's checks before deploying. This updates from `main`;
it does not select a GitHub release automatically.

For a path dependency, download and extract the source you intend to use,
replace the dependency directory, and run `mix deps.get` and
`mix deps.compile raims --force`. Run your application's checks before
deployment. Future updates require another explicit update.
