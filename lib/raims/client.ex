defmodule Raims.Client do
  @moduledoc "An immutable client whose API key determines company, permissions, and environment."
  @derive {Inspect, only: [:timeout, :max_network_retries]}
  defstruct api_key: nil,
            api_base: "https://api.raims.com",
            timeout: 80_000,
            connect_timeout: 10_000,
            max_network_retries: 0,
            request_observer: nil,
            transport: nil

  @type t :: %__MODULE__{}
  @max_response_bytes 16 * 1024 * 1024
  @retry_statuses [408, 429, 500, 502, 503, 504]
  @client_options [
    :api_base,
    :timeout,
    :connect_timeout,
    :max_network_retries,
    :request_observer,
    :transport
  ]
  @request_options [:api_key, :idempotency_key, :timeout, :max_network_retries]

  @spec new(String.t(), keyword()) :: t()
  def new(api_key, options \\ []) do
    options = options!(options, @client_options)
    key = header_value!(api_key, 4096)
    base = base!(Keyword.get(options, :api_base, "https://api.raims.com"))
    timeout = timeout!(Keyword.get(options, :timeout, 80_000))
    connect = timeout!(Keyword.get(options, :connect_timeout, 10_000))
    retries = retries!(Keyword.get(options, :max_network_retries, 0))
    observer = Keyword.get(options, :request_observer)
    transport = Keyword.get(options, :transport)

    if not is_nil(observer) and not is_function(observer, 1),
      do: invalid!("The request observer must be a function of one argument.")

    if not is_nil(transport) and not is_function(transport, 1),
      do: invalid!("The transport must be a function of one argument.")

    %__MODULE__{
      api_key: key,
      api_base: base,
      timeout: timeout,
      connect_timeout: min(connect, timeout),
      max_network_retries: retries,
      request_observer: observer,
      transport: transport
    }
  end

  @doc false
  @spec unwrap!({:ok, term()} | {:error, Raims.Error.t()}) :: term()
  def unwrap!({:ok, response}), do: response
  def unwrap!({:error, %Raims.Error{} = error}), do: raise(error)

  @doc false
  def request(%__MODULE__{} = client, operation_id, path_params, params, options) do
    operation = operation!(operation_id)
    unless is_map(operation), do: invalid!("Unknown SDK operation.")
    options = request_options!(options, operation)
    paths = Raims.Schema.normalize(path_params)

    unless is_map(paths) and Enum.sort(Map.keys(paths)) == Enum.sort(operation["pathParams"]),
      do: invalid!("Invalid operation path parameters.")

    unless Raims.Schema.valid?(paths, operation["path_params_schema"], :request),
      do: invalid!("Path parameters do not match the public operation contract.")

    path =
      Enum.reduce(paths, operation["path"], fn {name, value}, result ->
        unless is_binary(value) and Regex.match?(~r/\A[A-Za-z0-9_-]+\z/, value),
          do: invalid!("Resource identifiers must be non-empty URL-safe strings.")

        String.replace(result, "{" <> name <> "}", value)
      end)

    values = Raims.Schema.normalize(params)
    unless is_map(values), do: invalid!("Parameters must be a map.")

    if operation["paginated"] && values["after"] && values["before"],
      do: invalid!("The after and before cursors cannot be combined.")

    unless Raims.Schema.valid?(values, operation["params_schema"], :request),
      do: invalid!("Parameters do not match the public operation contract.")

    timeout = Keyword.get(options, :timeout, client.timeout)

    headers = [
      {"authorization", "Bearer " <> Keyword.get(options, :api_key, client.api_key)},
      {"accept", "application/json"},
      {"accept-encoding", "identity"},
      {"user-agent", "raims-elixir/" <> Raims.version()}
    ]

    headers =
      if key = options[:idempotency_key], do: headers ++ [{"idempotency-key", key}], else: headers

    {url, body, headers} =
      if operation["body"] do
        body = encode!(values)

        if operation["maxBodyBytes"] && byte_size(body) > operation["maxBodyBytes"],
          do: invalid!("The request exceeds the public body size limit.")

        {client.api_base <> path, body, headers ++ [{"content-type", "application/json"}]}
      else
        query = query!(values, operation["query"])
        {client.api_base <> path <> if(query == "", do: "", else: "?" <> query), nil, headers}
      end

    method = method(operation["method"])

    retries =
      if method in [:get, :head],
        do: Keyword.get(options, :max_network_retries, client.max_network_retries),
        else: 0

    wire = %{
      method: method,
      url: url,
      headers: headers,
      body: body,
      timeout: timeout,
      connect_timeout: min(timeout, client.connect_timeout),
      max_response_bytes: @max_response_bytes
    }

    context =
      if operation["paginated"],
        do: %{
          client: client,
          operation_id: operation_id,
          path_params: paths,
          params: values,
          options: options
        },
        else: nil

    deadline = System.monotonic_time(:millisecond) + timeout
    attempt(client, operation, wire, context, retries, 1, deadline)
  end

  def request(_client, _operation_id, _path_params, _params, _options),
    do: invalid!("Create a Raims.Client before calling resource functions.")

  defp attempt(client, operation, wire, context, retries, attempt_number, deadline) do
    started = System.monotonic_time(:millisecond)
    remaining = deadline - started

    result =
      if remaining > 0 do
        current_wire = %{
          wire
          | timeout: remaining,
            connect_timeout: min(wire.connect_timeout, remaining)
        }

        send_request(client, current_wire) |> decode(operation, context)
      else
        {:error, Raims.Error.new(:connection_error)}
      end

    result =
      if System.monotonic_time(:millisecond) > deadline,
        do: {:error, Raims.Error.new(:connection_error)},
        else: result

    proposed_delay = retry_delay(result, retries, attempt_number)

    delay =
      if is_integer(proposed_delay) and
           proposed_delay < deadline - System.monotonic_time(:millisecond),
         do: proposed_delay,
         else: nil

    observe(client, %{
      operation_id: operation["id"],
      method: operation["method"],
      path_template: operation["path"],
      attempt: attempt_number,
      duration_ms: System.monotonic_time(:millisecond) - started,
      status_code: status(result),
      request_id: request_id(result),
      retry_delay_ms: delay
    })

    if is_integer(delay) do
      Process.sleep(delay)
      attempt(client, operation, wire, context, retries - 1, attempt_number + 1, deadline)
    else
      result
    end
  end

  defp send_request(client, wire) do
    result = if client.transport, do: client.transport.(wire), else: Raims.Transport.execute(wire)

    case result do
      {:ok, %{status: status, headers: headers, body: body} = response}
      when is_integer(status) and is_list(headers) and is_binary(body) ->
        if byte_size(body) <= @max_response_bytes and valid_headers?(headers),
          do: {:ok, response},
          else: {:error, :unexpected_response}

      {:error, :unexpected_response} ->
        {:error, :unexpected_response}

      _ ->
        {:error, :connection_error}
    end
  rescue
    _ -> {:error, :connection_error}
  catch
    _, _ -> {:error, :connection_error}
  end

  defp decode({:error, kind}, _operation, _context), do: {:error, Raims.Error.new(kind)}

  defp decode({:ok, raw}, operation, context) do
    response = %Raims.Response{
      status_code: raw.status,
      headers: raw.headers,
      request_id: header(raw.headers, "request-id"),
      retry_after: header(raw.headers, "retry-after"),
      idempotency_replayed?: header(raw.headers, "idempotency-replayed") == "true",
      page_context: context
    }

    cond do
      raw.status in 300..399 -> unexpected(response)
      header(raw.headers, "content-encoding") not in [nil, "identity"] -> unexpected(response)
      raw.status in 200..299 -> decode_success(raw, operation, response)
      true -> decode_error(raw, response)
    end
  rescue
    _ -> {:error, Raims.Error.new(:unexpected_response)}
  end

  defp decode_success(raw, operation, response) do
    case Map.fetch(operation["responses"], Integer.to_string(raw.status)) do
      :error ->
        unexpected(response)

      {:ok, nil} ->
        if raw.body == "", do: {:ok, response}, else: unexpected(response)

      {:ok, schema} ->
        with {:ok, value} <- json(raw.body), true <- Raims.Schema.valid?(value, schema) do
          {:ok, %{response | data: Raims.Schema.hydrate(value, schema)}}
        else
          _ -> unexpected(response)
        end
    end
  end

  defp decode_error(raw, response) do
    api_error =
      case json(raw.body) do
        {:ok, %{"error" => value}} when is_map(value) -> value
        _ -> nil
      end

    error =
      Raims.Error.new(error_kind(raw.status),
        status_code: raw.status,
        request_id: response.request_id,
        retry_after: response.retry_after,
        code: api_error && api_error["code"],
        api_message: api_message(api_error),
        details: api_details(api_error),
        api_error: api_error,
        response: response
      )

    {:error, error}
  end

  defp api_message(%{"message" => message}) when is_binary(message), do: message
  defp api_message(_), do: nil

  defp api_details(%{"details" => details}) when is_list(details), do: details
  defp api_details(_), do: nil

  defp unexpected(response),
    do:
      {:error,
       Raims.Error.new(:unexpected_response,
         status_code: response.status_code,
         request_id: response.request_id,
         retry_after: response.retry_after,
         response: response
       )}

  defp error_kind(401), do: :authentication_error
  defp error_kind(403), do: :permission_error
  defp error_kind(404), do: :not_found_error
  defp error_kind(409), do: :conflict_error
  defp error_kind(429), do: :rate_limit_error
  defp error_kind(status) when status in [400, 405, 413, 415, 422], do: :invalid_request_error
  defp error_kind(_), do: :api_error

  defp retry_delay({:error, error}, retries, attempt) when retries > 0 do
    if error.kind == :connection_error or error.status_code in @retry_statuses do
      hint = retry_after_ms(error.retry_after)

      if hint != :stop,
        do: max(hint, min(2_000, trunc(500 * :math.pow(2, attempt - 1)) + :rand.uniform(250))),
        else: nil
    end
  end

  defp retry_delay(_result, _retries, _attempt), do: nil

  defp retry_after_ms(nil), do: 0

  defp retry_after_ms(value) do
    milliseconds =
      case Integer.parse(String.trim(value)) do
        {seconds, ""} when seconds >= 0 -> seconds * 1000
        _ -> http_date_delay(value)
      end

    if milliseconds > 30_000, do: :stop, else: max(0, milliseconds)
  end

  defp http_date_delay(value) do
    with [_, day, month, year, hour, minute, second] <-
           Regex.run(
             ~r/\A[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT\z/,
             value
           ),
         month_number when is_integer(month_number) <-
           Enum.find_index(~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec), &(&1 == month)),
         {:ok, date} <-
           Date.new(String.to_integer(year), month_number + 1, String.to_integer(day)),
         {:ok, time} <-
           Time.new(String.to_integer(hour), String.to_integer(minute), String.to_integer(second)),
         {:ok, datetime} <- DateTime.new(date, time, "Etc/UTC") do
      max(0, DateTime.to_unix(datetime, :millisecond) - System.system_time(:millisecond))
    else
      _ -> 0
    end
  end

  defp observe(%{request_observer: nil}, _event), do: :ok

  defp observe(client, event) do
    unless Process.get({__MODULE__, :observing}, false) do
      Process.put({__MODULE__, :observing}, true)

      try do
        client.request_observer.(event)
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      after
        Process.delete({__MODULE__, :observing})
      end
    end

    :ok
  end

  defp status({:ok, response}), do: response.status_code
  defp status({:error, error}), do: error.status_code
  defp request_id({:ok, response}), do: response.request_id
  defp request_id({:error, error}), do: error.request_id

  defp request_options!(options, operation) do
    options = options!(options, @request_options)
    if Keyword.has_key?(options, :api_key), do: header_value!(options[:api_key], 4096)

    if Keyword.has_key?(options, :idempotency_key) do
      unless operation["idempotency"],
        do: invalid!("This operation does not accept an idempotency key.")

      header_value!(options[:idempotency_key], 255)
    end

    if Keyword.has_key?(options, :timeout), do: timeout!(options[:timeout])

    if Keyword.has_key?(options, :max_network_retries),
      do: retries!(options[:max_network_retries])

    options
  end

  defp options!(options, allowed) do
    unless Keyword.keyword?(options) and
             length(Keyword.keys(options)) == length(Enum.uniq(Keyword.keys(options))) and
             Enum.all?(Keyword.keys(options), &(&1 in allowed)),
           do: invalid!("Options must be unique supported keyword entries.")

    options
  end

  defp header_value!(value, maximum) do
    unless is_binary(value) and byte_size(value) in 1..maximum and
             Regex.match?(~r/\A[\x21-\x7E]+\z/, value),
           do: invalid!("Credential and idempotency values must be non-empty visible ASCII.")

    value
  end

  defp timeout!(value) when is_integer(value) and value > 0 and value <= 300_000, do: value

  defp timeout!(_value),
    do: invalid!("Timeouts must be positive integers of at most 300000 milliseconds.")

  defp retries!(value) when is_integer(value) and value in 0..5, do: value
  defp retries!(_value), do: invalid!("Read retries must be integers from zero to five.")

  defp base!(value) when is_binary(value) do
    uri = URI.parse(value)
    loopback = uri.host in ["localhost", "127.0.0.1", "::1"]

    unless uri.scheme == "https" or (uri.scheme == "http" and loopback),
      do: invalid!("API bases require HTTPS, or HTTP on loopback.")

    unless is_binary(uri.host) and uri.host != "" and uri.userinfo == nil and
             uri.path in [nil, ""] and uri.query == nil and uri.fragment == nil and
             is_integer(uri.port) and uri.port in 1..65535,
           do:
             invalid!(
               "The API base must be an origin without credentials, path, query, or fragment."
             )

    value
  rescue
    _ -> invalid!("The API base must be a valid HTTPS origin, or HTTP on loopback.")
  end

  defp base!(_value), do: invalid!("The API base must be a string.")

  defp query!(params, declared) do
    params
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.flat_map(fn {key, value} ->
      unless Map.has_key?(declared, key), do: invalid!("Unknown public query parameter.")

      if is_nil(value),
        do: [],
        else: Enum.map(if(is_list(value), do: value, else: [value]), &{key, query_scalar!(&1)})
    end)
    |> URI.encode_query()
  end

  defp query_scalar!(value) when is_binary(value) or is_number(value) or is_boolean(value),
    do: to_string(value)

  defp query_scalar!(_value),
    do: invalid!("Query parameters must be scalar values or lists of scalars.")

  defp encode!(value) do
    JSON.encode!(value)
  rescue
    _ -> invalid!("Parameters must be valid JSON values.")
  end

  defp json(body) do
    JSON.decode(body)
  rescue
    _ -> {:error, :invalid_json}
  end

  defp header(headers, name) do
    case Enum.filter(headers, fn {key, _} -> String.downcase(key) == name end) do
      [{_, value}] -> value
      _ -> nil
    end
  end

  defp valid_headers?(headers),
    do:
      Enum.all?(headers, fn
        {key, value} when is_binary(key) and is_binary(value) ->
          String.valid?(key) and String.valid?(value)

        _ ->
          false
      end)

  defp method("GET"), do: :get
  defp method("HEAD"), do: :head
  defp method("POST"), do: :post
  defp method("PUT"), do: :put
  defp method("PATCH"), do: :patch
  defp method("DELETE"), do: :delete

  defp operation!(id) do
    Raims.Contract.operation(id)
  rescue
    _ -> invalid!("Unknown SDK operation.")
  end

  defp invalid!(message), do: raise(ArgumentError, message)
end
