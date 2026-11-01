defmodule Raims.Model do
  @moduledoc "Read-only response models with string-key access and unknown-field preservation."

  defmacro __using__(_options) do
    quote do
      @behaviour Access
      @derive {Inspect, only: []}
      defstruct data: %{}
      @type t :: %__MODULE__{data: map()}

      @impl Access
      def fetch(%__MODULE__{data: data}, key) when is_atom(key),
        do: Map.fetch(data, Atom.to_string(key))

      def fetch(%__MODULE__{data: data}, key), do: Map.fetch(data, key)

      @impl Access
      def get_and_update(_model, _key, _function),
        do: raise(ArgumentError, "Raims response models are read-only.")

      @impl Access
      def pop(_model, _key), do: raise(ArgumentError, "Raims response models are read-only.")

      @spec to_map(t()) :: map()
      def to_map(model), do: Raims.Model.to_map(model)
    end
  end

  @spec to_map(term()) :: term()
  def to_map(%{__struct__: module, data: data}) when is_map(data) do
    if function_exported?(module, :fetch, 2),
      do: to_map(data),
      else: raise(ArgumentError, "Expected a Raims model.")
  end

  def to_map(value) when is_map(value),
    do: Map.new(value, fn {key, child} -> {key, to_map(child)} end)

  def to_map(value) when is_list(value), do: Enum.map(value, &to_map/1)
  def to_map(value), do: value
end
