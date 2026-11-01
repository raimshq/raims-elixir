# Raims Elixir SDK

Read README.md, CONTRIBUTING.md, and docs/maintenance.md before editing.

- Keep descriptions, documentation, comments, and examples in English.
- Keep internal TODOs, backlogs, and roadmaps outside this public source and
  its packages. Do not publish the private tracker's contents or location.
- Use only the pinned public OpenAPI in contracts. Verify its immutable
  revision and SHA-256. Do not import private API code or contracts.
- Generate resource services, models, enum values, runtime HTTP metadata, and
  docs/reference.md with scripts/generate.py. Do not hand-edit these outputs.
- Preserve JSON names, integer cents, Unix seconds, omission, explicit null,
  unknown response fields, and pending results. Never create idempotency keys
  or retry writes automatically. Configurable retries apply only to reads.
- API keys determine company, environment, and permissions. Do not offer
  environment selection, OAuth, arbitrary headers, redirects, uploads, or
  downloads from response URLs. Keep TLS verification enabled.
- Default inspection, exceptions, and diagnostics must hide credentials,
  resource identifiers, query strings, and payloads.
- Tests, simulators, dependencies, builds, and evidence belong exclusively in
  the workspace temporary directory, under raims-elixir-sdk. Do not track or
  package them. Never call the financial API during validation.
- The canonical validation launcher is scripts/check.py. Check all operations,
  success variants, transport, pagination, webhooks, public compatibility, and
  an independently installed package. Stop temporary processes afterwards.
- Leave changes uncommitted and unstaged. Remote creation, push, tags,
  releases, Hex publication, and public guides need separate authorization.
- Keep CI as a template until runner access and activation are authorized.
- Apply the workspace humanizer skill to prose. Describe Raims features
  directly and preserve required dependency attribution and licenses.
