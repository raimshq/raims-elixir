# Installation and updates

Requires Elixir 1.18 or later with Erlang/OTP 27 or later. Use the Hex package
[`raims`](https://hex.pm/packages/raims) in server applications. Source code
and release archives are also distributed through
[GitHub](https://github.com/raimshq/raims-elixir/releases/latest).

## Install with Hex

Ask Hex for the current package information:

If Hex is not installed, run `mix local.hex` first.

```sh
mix hex.info raims
```

Copy the dependency tuple shown on the `Config:` line into `deps/0` in your
application's `mix.exs`. Then fetch and compile your dependencies:

```sh
mix deps.get
mix compile
```

Hex provides the current dependency requirement. Mix selects a compatible
release and records its exact version and checksums in the application's
`mix.lock`. Keep that lockfile under version control so later builds retain
the resolved versions until you update them.

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
the SDK directory. Use that directory as the path dependency above.

## Keep credentials on the server

Keep the API key in your server's environment or secret store:

```elixir
client = Raims.Client.new(System.fetch_env!("RAIMS_API_KEY"))
```

Do not put keys into browser code, mobile applications, source control, or
logs. The same API hostname serves Sandbox and Production; your key selects
the company and environment.

## Update an existing installation

For a Hex dependency, update within its configured requirement and compile:

```sh
mix deps.update raims
mix compile
```

Check `mix hex.info raims` when you want to adopt a newer release outside
that requirement. Update the dependency in `mix.exs` if needed, then run
the commands above. Review the changes to `mix.lock` and run your
application's checks before deploying. Installing a package does not apply
future updates automatically.

### Migrate from Git or a local directory to Hex

Run `mix hex.info raims` and replace the existing `:raims` dependency with
the current `Config:` entry. Remove its `github:`, `git:`, `path:`, `ref:`,
`branch:`, or `tag:` options so Mix uses Hex. Then run:

```sh
mix deps.update raims
mix compile
```

Keep the application's lockfile and review its changes. Do not delete the
whole lockfile to change one dependency. Run the integration checks used by
your application before deploying the new build.

### Git and local path dependencies

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
