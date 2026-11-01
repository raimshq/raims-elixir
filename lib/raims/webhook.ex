defmodule Raims.Webhook do
  @moduledoc "Authenticate original webhook bytes before parsing or processing an event."
  @alphabet "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  @spec verify_signature(binary(), map() | list(), String.t(), keyword()) ::
          :ok | {:error, Raims.Error.t()}
  def verify_signature(payload, headers, secret, options \\ []) do
    {tolerance, now} = options!(options)

    try do
      unless is_binary(payload), do: fail!()
      delivery = header!(headers, "webhook-id")
      timestamp = header!(headers, "webhook-timestamp")
      signatures = header!(headers, "webhook-signature")

      unless Regex.match?(~r/\A[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}\z/, delivery),
        do: fail!()

      unless Regex.match?(~r/\A[0-9]{1,12}\z/, timestamp) and
               abs(String.to_integer(timestamp) - now) <= tolerance,
             do: fail!()

      key = secret!(secret)
      expected = :crypto.mac(:hmac, :sha256, key, delivery <> "." <> timestamp <> "." <> payload)

      matches =
        Enum.reduce(String.split(signatures, ","), false, fn candidate, found ->
          valid =
            case Regex.run(~r/\Av1=([0-9a-fA-F]{64})\z/i, String.trim(candidate)) do
              [_, value] -> :crypto.hash_equals(expected, Base.decode16!(value, case: :mixed))
              _ -> false
            end

          found or valid
        end)

      if matches, do: :ok, else: fail!()
    rescue
      _ -> {:error, Raims.Error.new(:signature_verification_error)}
    end
  end

  @spec construct_event(binary(), map() | list(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Raims.Error.t()}
  def construct_event(payload, headers, secret, options \\ []) do
    with :ok <- verify_signature(payload, headers, secret, options),
         {:ok, event} when is_map(event) <- decode(payload) do
      {:ok, event}
    else
      _ -> {:error, Raims.Error.new(:signature_verification_error)}
    end
  end

  defp options!(options) do
    unless Keyword.keyword?(options) and
             Enum.all?(Keyword.keys(options), &(&1 in [:tolerance, :now])) and
             length(Keyword.keys(options)) == length(Enum.uniq(Keyword.keys(options))),
           do:
             raise(
               ArgumentError,
               "Webhook options must be unique tolerance and now keyword entries."
             )

    tolerance = Keyword.get(options, :tolerance, 300)
    now = Keyword.get(options, :now, System.system_time(:second))

    unless is_integer(tolerance) and tolerance >= 0 and is_integer(now) and now >= 0,
      do:
        raise(ArgumentError, "Webhook tolerance and current time must be non-negative integers.")

    {tolerance, now}
  end

  defp header!(headers, name) do
    entries =
      cond do
        is_map(headers) -> Map.to_list(headers)
        is_list(headers) -> headers
        true -> fail!()
      end

    values =
      Enum.flat_map(entries, fn
        {key, value} when is_binary(key) -> if String.downcase(key) == name, do: [value], else: []
        _ -> fail!()
      end)

    value =
      case values do
        [[single]] when is_binary(single) -> single
        [single] when is_binary(single) -> single
        _ -> fail!()
      end

    unless byte_size(value) > 0 and Regex.match?(~r/\A[\x09\x20-\x7E]+\z/, value), do: fail!()
    value
  end

  defp secret!(secret) do
    unless is_binary(secret) and Regex.match?(~r/\Awhsec_[0-9A-Za-z]{1,43}\z/, secret),
      do: fail!()

    encoded = binary_part(secret, 6, byte_size(secret) - 6)
    if byte_size(encoded) > 1 and String.starts_with?(encoded, "0"), do: fail!()

    number =
      encoded
      |> String.to_charlist()
      |> Enum.reduce(0, fn character, value ->
        {position, 1} = :binary.match(@alphabet, <<character>>)
        value * 62 + position
      end)

    if number >= Bitwise.bsl(1, 256), do: fail!()
    <<number::little-unsigned-integer-size(256)>>
  end

  defp decode(payload) do
    JSON.decode(payload)
  rescue
    _ -> {:error, :invalid_json}
  end

  defp fail!, do: raise(Raims.Error.new(:signature_verification_error))
end
