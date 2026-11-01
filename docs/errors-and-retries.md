# Errors, idempotency, and retries

Resource functions return `{:error, %Raims.Error{}}` for API and transport
failures. Use the error's kind, HTTP status, code, and request ID to choose
the next action. Invalid local arguments raise a sanitized `ArgumentError`
before HTTP. A function ending in `!` raises the structured `Raims.Error`:

```elixir
try do
  Raims.Customers.retrieve!(client, customer_id)
rescue
  error in Raims.Error ->
    MyApp.handle_raims_error(error.kind, error.request_id)
end
```

| Kind | Meaning |
| --- | --- |
| `:authentication_error` | The credential was not accepted |
| `:permission_error` | The credential does not permit the request |
| `:not_found_error` | The resource was not found in the credential's scope |
| `:conflict_error` | The request conflicts with the resource state |
| `:rate_limit_error` | A request rate limit was reached |
| `:invalid_request_error` | The API rejected the input |
| `:connection_error` | The connection failed or the deadline expired |
| `:unexpected_response` | The reply did not match the declared response shape |
| `:api_error` | Another API failure |

Default exception messages and inspection omit credentials, resource IDs,
query strings, and payloads. Error fields accessed explicitly may contain
information from the API; keep them out of unrestricted logs.

Resource functions require the client returned by `Raims.Client.new/2`.
Passing a key directly in place of that client raises a sanitized
`ArgumentError` before any HTTP request.

Parameter arrays must be proper Elixir lists of JSON values. An invalid list
tail raises the same sanitized `ArgumentError` before HTTP, including when
the list is nested inside another parameter.

## Recovering writes

Persist one idempotency key for the same business intention and pass it in
`idempotency_key:` when the endpoint supports the header. Keep the key and
parameters for retries after a lost response. A different key represents
another intention and may cause another financial operation.

The SDK never generates keys or retries POST, PUT, PATCH, or DELETE
automatically, including after a connection failure, `429`, or `5xx`.
An unknown write outcome requires the endpoint's retrieval and recovery
procedure. HTTP `202` remains pending. A response to a request that asks for
email delivery does not prove the message was delivered.

## Read retries and deadlines

Retries default to zero. Set `max_network_retries` on the client or request
to opt into retries for eligible GET and HEAD failures. The transport itself
does not retry requests or follow redirects. Retry waits and HTTP attempts
share the request's timeout budget. The SDK respects a valid `Retry-After`
without waiting beyond that budget.

Use the final request ID when contacting support. Do not disable TLS checks,
switch credentials, or change the data environment to bypass an error.
