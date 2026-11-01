# Security

Report suspected vulnerabilities to [security@raims.com](mailto:security@raims.com).
Include the SDK version, affected function, expected behavior, and a minimal
reproduction using synthetic values. Do not include API keys, webhook secrets,
customer information, or financial data. Avoid publishing exploit details
before the report has been reviewed.

Keep credentials in server configuration. The API key determines the company,
environment, and permissions. Use a Sandbox key for simulations and preserve
the same idempotency key when recovering the same write intention.

Verify webhook signatures against the original request body and deduplicate
events durably before applying business effects. See
[receiving webhooks](docs/webhooks.md).
