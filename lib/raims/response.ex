defmodule Raims.Response do
  @moduledoc "A response body together with its HTTP metadata."
  @derive {Inspect, only: [:status_code, :idempotency_replayed?]}
  defstruct data: nil,
            status_code: nil,
            request_id: nil,
            retry_after: nil,
            idempotency_replayed?: false,
            headers: [],
            page_context: nil

  @type t :: %__MODULE__{}

  @spec pending?(t()) :: boolean()
  def pending?(%__MODULE__{status_code: status}), do: status == 202
end
