# Receiving webhooks

Verify the original request body before parsing or processing an event.
Use the `secret_key` returned when creating or rotating the webhook, not
the API key. Preserve the raw bytes at your HTTP boundary:

```elixir
case Raims.Webhook.construct_event(raw_body, signing_headers, webhook_secret) do
  {:ok, event} -> MyApp.store_webhook(event)
  {:error, error} -> MyApp.reject_webhook(error)
end
```

`raw_body` is the unchanged binary received by your framework.
`signing_headers` contains `webhook-id`, `webhook-timestamp`, and
`webhook-signature`. Keep duplicate headers visible to the verifier so it
can reject ambiguous signing input. Do not reconstruct or reserialize the
body: whitespace, Unicode, and line breaks are part of the signed bytes.

Pass a map of header names to strings or a list of `{name, value}` tuples.
A list preserves duplicates so the verifier can reject them. Names are
case-insensitive; each signing header must contain exactly one value.
`Raims.Webhook.verify_signature/4` returns `:ok` or `{:error, error}` without
parsing JSON. Both functions accept optional `tolerance:` and `now:` values
in seconds, where `now` is the current Unix timestamp for an injected clock.

The verifier decodes the Raims `whsec_` secret and checks HMAC-SHA256 for
`webhook-id.webhook-timestamp.body` with constant-time comparison. A
comma-separated signature list permits overlapping `v1=` signatures during
rotation. Coordinate secret changes with `previous_secret_expires_at` and
keep all secrets outside logs.

The default tolerance is 300 seconds into the past or future. A tolerance
of zero requires the same second; it does not disable time protection.
Keep your server's clock synchronized. The signing timestamp uses Unix
seconds; event `created_at` fields use ISO 8601.

A valid signature authenticates the body and does not validate its business
meaning. Before acknowledging successful delivery:

1. Check the event type, environment, and resource for your integration.
2. Deduplicate the body's event `id` in durable storage. The `webhook-id`
   header identifies a delivery and does not replace the event ID.
3. Store the work atomically and apply business effects idempotently.
   Return an HTTP failure if durable storage fails.

See the [receiving guide](https://docs.raims.com/en/integracoes/webhooks/receber-eventos)
for delivery conditions.
