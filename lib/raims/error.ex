defmodule Raims.Error do
  @moduledoc "An SDK failure with structured details and a safe default message."
  @derive {Inspect, only: [:kind, :status_code]}
  defexception kind: :api_error,
               message: "The Raims request failed.",
               status_code: nil,
               request_id: nil,
               retry_after: nil,
               code: nil,
               param: nil,
               errors: nil,
               api_error: nil,
               response: nil

  @type t :: %__MODULE__{}

  @doc false
  def new(kind, fields \\ []) do
    struct!(__MODULE__, Keyword.merge([kind: kind, message: message_for(kind)], fields))
  end

  defp message_for(:connection_error), do: "The Raims connection failed or timed out."

  defp message_for(:unexpected_response),
    do: "The Raims response is not compatible with the public contract."

  defp message_for(:signature_verification_error), do: "The webhook could not be authenticated."
  defp message_for(:authentication_error), do: "The Raims request was not authenticated."
  defp message_for(:permission_error), do: "The Raims request was not permitted."
  defp message_for(:not_found_error), do: "The Raims resource was not found."
  defp message_for(:conflict_error), do: "The Raims request conflicts with the resource state."
  defp message_for(:rate_limit_error), do: "The Raims request exceeded a rate limit."
  defp message_for(:invalid_request_error), do: "The Raims request was rejected."
  defp message_for(_), do: "The Raims API request failed."
end
