# Contract and maintenance

## Contract source

`contracts/source.json` identifies the published public contract's immutable
revision, SHA-256, and source URL. `contracts/openapi.json` preserves its exact
bytes. The offline generator verifies the checksum and requires every
published operation to appear exactly once in `contracts/service-map.json`.

```sh
python scripts/generate.py
python scripts/generate.py --check
```

Generated outputs include resource modules and their bang variants, response
models, named enum values, compiled runtime metadata, and the English method
reference. Keep editorial translations in `docs/reference.en.json`. Missing
English text fails generation instead of silently changing the pinned source
or omitting a description.

Runtime metadata retains each operation's path parameter schemas, including
patterns and length limits. Validate IDs against these schemas before URL
construction. Validation fixtures must derive valid route IDs from the public
contract and cover invalid prefixes, lengths, and numeric forms before HTTP.

The SDK consumes the public contract and does not change Public API behavior
or other consumers. Adding this library does not require regenerating the
CLI's contract. Public API changes follow the workspace's consumer impact
procedure before being consumed by the SDK.

## Local validation

```sh
python scripts/check.py
```

The launcher calls the canonical Elixir adapter in the sibling Developer
Toolkit. It checks deterministic generation, public compatibility, every
operation and success variant, HTTP transport, validation, errors, pagination,
webhook signatures, dependency advisories, and a packaged independent consumer.
It uses fake transports and loopback receivers without calling the financial
API. Missing tools and incomplete checks are failures.

Tests, simulators, dependencies, caches, builds, and reports belong exclusively
in `C:\server\raims\.tmp\raims-elixir-sdk`. Never include them in this checkout
or the package. Stop temporary processes after validation and preserve
existing user processes.

`contracts/elixir-api.json` is an independent public API compatibility baseline.
Format 2 records public functions, macros, struct fields, enforced struct keys,
types, specifications, and named values. New enforced keys are incompatible
because they make previously valid struct construction fail. Generation does
not update the baseline. Check it with:

```sh
mix run scripts/check-compatibility.exs
```

Review intentional compatibility changes before accepting a new baseline with
`mix run scripts/check-compatibility.exs -- --write`. Keep exports, fields,
and named values intact when correcting response specifications. Numeric
response enums remain open to future values; request enums stay constrained.

Use the workspace preflight's Commit stage before an authorized delivery
commit and Deploy before an authorized publication. Freeze the reviewed SDK
and Toolkit inputs while the gate runs. Changes invalidate affected evidence.
Keep SAST and dependency auditing enabled.

## Distribution

The package uses an explicit public-source allowlist. Verify its contents and
a clean consumer using only declared dependencies. Include the public
contribution, security, and agent instructions linked by the packaged Markdown.
Consumers need no Python or private engineering Toolkit.

The source distribution uses `raimshq/raims-elixir`, with source on `main`
and versioned GitHub releases. Release assets include the Hex-format
`raims.tar` archive and `SHA256SUMS`. Verify downloaded checksums, archive
contents, and a clean installation from the published source. The package
is not published on the Hex registry.

The source-publication profile has no executable workflows and does not
change infrastructure. The CI recipe remains a template until runner
access and activation are authorized. Run the Commit and Deploy gates
before committing and publishing, preserving source verification, SAST,
and dependency auditing. GitHub publication does not authorize Hex
registry publication, CI activation, or public guide deployment. Those
destinations retain their separate authorization and validation steps.
