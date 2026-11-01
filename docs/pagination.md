# Cursor pagination

A list call returns one page in `response.data["list"]` and cursor metadata
in `response.data["page"]`:

```elixir
{:ok, first_page} =
  Raims.Customers.list(client, %{page_size: 50, external_reference: reference})

Enum.each(first_page.data["list"], fn customer ->
  MyApp.process_customer(customer["id"])
end)
```

Enumerating the list reads only the received page. Explicit navigation
returns the same result tuples as resource functions:

```elixir
case Raims.Page.next_page(first_page) do
  {:ok, nil} -> :done
  {:ok, next_page} -> MyApp.process_page(next_page)
  {:error, error} -> MyApp.handle_raims_error(error.kind, error.request_id)
end
```

Navigation returns `{:ok, nil}` when there is no page in that direction.
Use `Raims.Page.previous_page/1` for the opposite direction. The page keeps
the operation, path, original filters, and request options. Navigation replaces
only the cursor and removes the opposite cursor. The original response remains
available after a failed fetch, so the same navigation can be attempted again.

## Lazy iteration

```elixir
first_page
|> Raims.Page.stream()
|> Stream.map(fn customer -> customer["id"] end)
|> Enum.take(100)
```

The stream requests subsequent pages only when needed. It raises `Raims.Error`
if a page cannot be fetched. Stopping enumeration stops further requests.
Use `Raims.Page.to_list(first_page, 100)` to collect at most 100 items.
Do not collect an unbounded account history in memory.
