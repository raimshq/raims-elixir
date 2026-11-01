# Raims Elixir

Official Elixir SDK for the Raims public API.

Use resource modules, response models, cursor pagination, structured errors,
and webhook signature verification in server applications. Requires Elixir
1.18 or later with Erlang/OTP 27 or later.

## Install from GitHub

Source code and release notes are available on
[GitHub](https://github.com/raimshq/raims-elixir/releases). The package is not
published on Hex. With Git installed, add the SDK to your application's
dependencies:

```elixir
defp deps do
  [{:raims, github: "raimshq/raims-elixir"}]
end
```

Run `mix deps.get` and `mix compile`. Mix resolves the repository's default
`main` branch and records the selected revision in your application's
`mix.lock`. To update, run `mix deps.update raims`, compile, and run your
application's checks. Updates are not applied automatically.

You can also download the source archive from the
[current release](https://github.com/raimshq/raims-elixir/releases/latest),
extract it, and use a local path dependency. See
[installation and updates](docs/installation.md) for this option and the
`raims.tar` release artifact.

## First request

```elixir
client = Raims.Client.new(System.fetch_env!("RAIMS_API_KEY"))

case Raims.Customers.list(client, %{page_size: 20}) do
  {:ok, response} ->
    Enum.each(response.data["list"], fn customer ->
      MyApp.process_customer(customer["id"])
    end)

  {:error, error} ->
    MyApp.handle_raims_error(error.kind, error.request_id)
end
```

`MyApp` represents your application's processing. The base URL is
`https://api.raims.com` for both Sandbox and Production. The key determines
the company, environment, and permissions. Keep it on the server, outside
source control and logs.

## Create a charge

Persist `customer_id`, `due_date`, and `order_idempotency_key` for the order
before sending the request. Amounts use integer cents: `15000` represents
BRL 150.00. The due date uses UTC Unix seconds.

```elixir
{:ok, response} =
  Raims.Charges.create(
    client,
    %{
      customer_id: customer_id,
      amount_cents: 15000,
      due_date: due_date,
      title: "Order 1234"
    },
    idempotency_key: order_idempotency_key
  )

charge_id = response.data["id"]
request_id = response.request_id
```

The SDK does not generate idempotency keys or retry writes automatically.
After losing a response, preserve the key and parameters and follow the
endpoint's recovery rules. HTTP `202` means processing is pending; retrieve
the resource to follow its result.

## Pagination

```elixir
{:ok, first_page} = Raims.Customers.list(client, %{page_size: 50})

first_page
|> Raims.Page.stream()
|> Enum.each(fn customer -> MyApp.process_customer(customer["id"]) end)
```

The stream fetches further pages as needed and preserves filters and request
options. `Raims.Page.next_page/1` and `previous_page/1` provide explicit
navigation. Use `Raims.Page.to_list/2` to collect a bounded number of items.

## Resource modules

| Module | Resources |
| --- | --- |
| `Raims.Accounts` | Account context, number, fees, and checkout settings |
| `Raims.Balances` | Balance and forecast |
| `Raims.Customers` | Customer creation, retrieval, updates, and deletion |
| `Raims.Charges` | Charges, payment details, documents, and charge refunds |
| `Raims.PaymentLinks` | Payment links and email delivery requests |
| `Raims.Refunds` | Refunds and receipts |
| `Raims.Disputes` | Disputes |
| `Raims.Statements` | Account statements |
| `Raims.Withdrawals` | Withdrawals, limits, summary, and automatic settings |
| `Raims.WithdrawalDestinations` | Withdrawal destinations |
| `Raims.Webhooks` | Registration, health, pause, test, and secret rotation |
| `Raims.WebhookEventTypes` | Available event types |
| `Raims.Simulations.Charges` | Charge simulations with a Sandbox key |
| `Raims.Simulations.Refunds` | Refund simulations with a Sandbox key |

Resource modules expose functions such as `create`, `retrieve`, `update`,
`delete`, and `list` according to the public contract. Every operation has
a `!` variant that raises `Raims.Error` on an API or transport failure.
See the [method reference](docs/reference.md).

## Documentation

- [Installation and updates](docs/installation.md)
- [Configuration, responses, and documents](docs/usage.md)
- [Pagination](docs/pagination.md)
- [Errors, idempotency, and retries](docs/errors-and-retries.md)
- [Receiving webhooks](docs/webhooks.md)
- [Maintenance and contract](docs/maintenance.md)
- [Contributing](CONTRIBUTING.md) and [security](SECURITY.md)
- [Public API](https://docs.raims.com/en/api)

Distributed under the [MIT license](LICENSE).
