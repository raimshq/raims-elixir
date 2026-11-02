# Contributing

Report bugs through this repository's GitHub issues. Include:

- The SDK version or source commit.
- The runtime version and operating system.
- Expected and actual behavior.
- A minimal reproduction using synthetic data.

Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md).
Keep API keys, webhook secrets, customer data, and URLs that grant access to
resources out of public reports and examples.

## Working with the source

Use Elixir 1.18 or later, Erlang/OTP 27 or later, and Python.

From the SDK root:

```sh
python scripts/generate.py --check
mix deps.get
mix compile --warnings-as-errors
mix run scripts/check-compatibility.exs
```

Keep changes focused and preserve public API compatibility. Regenerate
contract-derived files instead of editing them by hand. Preserve license
notices and attribution in contributions.
