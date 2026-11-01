# Configuration and responses

## Client

Create a client once and pass it to resource functions:

```elixir
client =
  Raims.Client.new(System.fetch_env!("RAIMS_API_KEY"),
    timeout: 30_000,
    max_network_retries: 0
  )

{:ok, response} = Raims.Balances.retrieve(client)
```

Timeouts use milliseconds. The client is immutable and has no process to
stop. Each HTTP attempt owns its connection and closes it on completion or
failure. Keep certificate and hostname verification enabled.

The default base URL is `https://api.raims.com`. A custom HTTPS `api_base`
can route requests through your infrastructure. Plain HTTP is restricted
to loopback for local integration checks. Do not point a client containing
a real key at an untrusted server.

`timeout` defaults to 80,000 milliseconds and `connect_timeout` to 10,000.
Timeout settings must be positive integers of at most 300,000 milliseconds.
`max_network_retries` accepts zero to five and defaults to zero.

Request options may override `api_key`, `timeout`, and `max_network_retries`.
Use `idempotency_key` only for operations that support it. The SDK accepts
API keys; it does not expose OAuth, arbitrary headers, or an environment
selector. The server validates the key's company, environment, and permissions.

## Parameters

Parameter maps accept string or atom keys using the API's JSON names:

```elixir
Raims.Customers.update(client, customer_id, %{external_reference: nil})
Raims.Customers.update(client, customer_id, %{"external_reference" => nil})
```

Omitting a field preserves its value when the endpoint supports partial
updates. Explicit `nil` sends JSON `null`, which clears a value only when
the contract permits it. Do not use `nil` to mean omission.

Use integer cents for money and UTC Unix seconds for resource dates.
The SDK checks declared request constraints before sending HTTP. The API
also validates permissions and business rules. See the
[generated reference](reference.md) for each operation's accepted fields.

Resource IDs passed to retrieval, update, and other resource functions must
match the operation's published format and length. The SDK validates these
route arguments before HTTP and raises a sanitized `ArgumentError` when they
do not match. Copy IDs from the corresponding resource response.

Customer and charge `metadata` maps must fit within the contract's serialized
UTF-8 JSON byte limit, including keys and JSON punctuation. The SDK checks
this before sending the request. The API also validates the result of merging
a partial metadata update with the resource's existing values.

## Response models

A successful call returns `{:ok, %Raims.Response{}}`. The response carries
`data`, `status_code`, and `request_id`. Its generated models support
read-only access by JSON field name and generated getter functions:

```elixir
{:ok, response} = Raims.Customers.retrieve(client, customer_id)
customer = response.data

id = customer["id"]
raw_fields = Raims.Model.to_map(customer)
```

`Raims.Model.to_map/1` recursively returns ordinary maps and lists, preserving
unknown response fields. Use `Access.fetch/2` to distinguish an absent key
from a present key containing `nil`. Inspection hides response contents;
explicitly extracting a field or map exposes its data to your application.
Avoid logging payloads, credentials, or document links.

Numeric response enums use open numeric types so a new API value remains
representable. Handle values you do not recognize in your application.
Request enum values remain constrained to the published contract.

HTTP `202` is successful acceptance with a pending result. Check
`response.status_code` and retrieve the resource to follow its outcome.
Do not treat acceptance as payment, refund, cancellation, or delivery confirmation.

## Documents and upload authorizations

Document endpoints return their API response, including any authorized URL.
The SDK does not follow document URLs, download their contents, or upload
files. Checkout asset authorization endpoints return instructions for your
application's upload flow. Treat signed URLs as secrets and respect their
expiry and content requirements.

## Simulations

Use `Raims.Simulations.Charges` and `Raims.Simulations.Refunds` only with a
Sandbox key. A Production key remains a Production credential on a local
host. The SDK does not change its environment to make a simulation succeed.
