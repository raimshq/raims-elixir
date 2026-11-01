defmodule Raims.Transport do
  @moduledoc false

  def execute(request) do
    uri = URI.parse(request.url)
    scheme = if uri.scheme == "https", do: :https, else: :http
    deadline = System.monotonic_time(:millisecond) + request.timeout

    transport_opts = [
      timeout: min(request.timeout, request.connect_timeout),
      send_timeout: request.timeout,
      send_timeout_close: true
    ]

    transport_opts =
      if scheme == :https do
        transport_opts ++
          [
            verify: :verify_peer,
            cacerts: :public_key.cacerts_get(),
            versions: [:"tlsv1.3", :"tlsv1.2"]
          ]
      else
        transport_opts
      end

    case Mint.HTTP.connect(scheme, uri.host, uri.port,
           mode: :passive,
           protocols: [:http1],
           transport_opts: transport_opts
         ) do
      {:ok, connection} ->
        try do
          target = (uri.path || "/") <> if(uri.query, do: "?" <> uri.query, else: "")

          with :ok <- send_deadline(connection, scheme, deadline),
               {:ok, next, reference} <-
                 Mint.HTTP.request(
                   connection,
                   request.method |> Atom.to_string() |> String.upcase(),
                   target,
                   request.headers,
                   request.body
                 ) do
            receive_response(
              next,
              reference,
              %{status: nil, headers: [], chunks: [], bytes: 0, done: false},
              deadline,
              request.max_response_bytes
            )
          else
            _ ->
              {:error, :connection_error}
          end
        after
          Mint.HTTP.close(connection)
        end

      {:error, _} ->
        {:error, :connection_error}
    end
  rescue
    _ -> {:error, :connection_error}
  catch
    :exit, _ -> {:error, :connection_error}
  end

  defp send_deadline(connection, scheme, deadline) do
    remaining = deadline - System.monotonic_time(:millisecond)

    if remaining > 0 do
      socket = Mint.HTTP.get_socket(connection)

      if scheme == :https,
        do: :ssl.setopts(socket, send_timeout: remaining, send_timeout_close: true),
        else: :inet.setopts(socket, send_timeout: remaining, send_timeout_close: true)
    else
      {:error, :timeout}
    end
  end

  defp receive_response(connection, reference, state, deadline, limit) do
    remaining = deadline - System.monotonic_time(:millisecond)

    if remaining <= 0 do
      {:error, :connection_error}
    else
      case Mint.HTTP.recv(connection, 0, remaining) do
        {:ok, next, events} ->
          case consume(events, reference, state, limit) do
            {:ok, %{done: true} = result} ->
              {:ok,
               %{
                 status: result.status,
                 headers: result.headers,
                 body: result.chunks |> Enum.reverse() |> IO.iodata_to_binary()
               }}

            {:ok, result} ->
              receive_response(next, reference, result, deadline, limit)

            {:error, _} = error ->
              error
          end

        {:error, _, _, _} ->
          {:error, :connection_error}
      end
    end
  end

  defp consume(events, reference, state, limit) do
    Enum.reduce_while(events, {:ok, state}, fn
      {:status, ^reference, status}, {:ok, acc} when status >= 200 ->
        {:cont, {:ok, %{acc | status: status, headers: []}}}

      {:headers, ^reference, headers}, {:ok, %{status: status} = acc} when is_integer(status) ->
        {:cont, {:ok, %{acc | headers: acc.headers ++ headers}}}

      {:data, ^reference, chunk}, {:ok, acc} ->
        size = acc.bytes + byte_size(chunk)

        if size > limit,
          do: {:halt, {:error, :unexpected_response}},
          else: {:cont, {:ok, %{acc | chunks: [chunk | acc.chunks], bytes: size}}}

      {:done, ^reference}, {:ok, acc} ->
        {:cont, {:ok, %{acc | done: true}}}

      _, result ->
        {:cont, result}
    end)
  end
end
