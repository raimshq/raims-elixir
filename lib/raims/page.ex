defmodule Raims.Page do
  @moduledoc "Explicit cursor navigation and lazy iteration across list responses."

  @spec next_page(Raims.Response.t()) ::
          {:ok, Raims.Response.t() | nil} | {:error, Raims.Error.t()}
  def next_page(response), do: load(response, true)

  @spec previous_page(Raims.Response.t()) ::
          {:ok, Raims.Response.t() | nil} | {:error, Raims.Error.t()}
  def previous_page(response), do: load(response, false)

  @spec stream(Raims.Response.t()) :: Enumerable.t()
  def stream(%Raims.Response{page_context: context} = response) when is_map(context) do
    seen =
      if context.params["after"], do: MapSet.new([context.params["after"]]), else: MapSet.new()

    Stream.resource(fn -> {:page, response, seen} end, &emit/1, fn _ -> :ok end)
  end

  def stream(_response), do: invalid!()

  @spec to_list(Raims.Response.t(), non_neg_integer()) :: list()
  def to_list(response, limit) when is_integer(limit) and limit >= 0 do
    response |> stream() |> Enum.take(limit)
  end

  def to_list(_response, _limit),
    do: raise(ArgumentError, "The pagination limit must be a non-negative integer.")

  defp emit({:page, response, seen}) do
    case response.data["list"] do
      items when is_list(items) and items != [] -> {items, {:next, response, seen}}
      [] -> emit({:next, response, seen})
      _ -> raise(Raims.Error.new(:unexpected_response))
    end
  end

  defp emit({:next, response, seen}) do
    case navigation(response, true) do
      {:ok, nil} ->
        {:halt, nil}

      {:ok, params} ->
        cursor = params["after"]
        if MapSet.member?(seen, cursor), do: raise(Raims.Error.new(:unexpected_response))
        context = response.page_context

        case Raims.Client.request(
               context.client,
               context.operation_id,
               context.path_params,
               params,
               context.options
             ) do
          {:ok, next} -> emit({:page, next, MapSet.put(seen, cursor)})
          {:error, error} -> raise(error)
        end

      {:error, error} ->
        raise(error)
    end
  end

  defp load(response, forward) do
    case navigation(response, forward) do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, params} ->
        context = response.page_context

        Raims.Client.request(
          context.client,
          context.operation_id,
          context.path_params,
          params,
          context.options
        )

      error ->
        error
    end
  end

  defp navigation(%Raims.Response{page_context: context} = response, forward)
       when is_map(context) do
    {flag, cursor_field, key, opposite} =
      if forward,
        do: {"has_next", "next_after", "after", "before"},
        else: {"has_previous", "previous_before", "before", "after"}

    page = response.data["page"]

    if page[flag] do
      cursor = page[cursor_field]

      if is_binary(cursor) and cursor != "" and cursor != context.params[key] do
        {:ok, context.params |> Map.delete(opposite) |> Map.put(key, cursor)}
      else
        {:error,
         Raims.Error.new(:unexpected_response,
           status_code: response.status_code,
           request_id: response.request_id,
           response: response
         )}
      end
    else
      {:ok, nil}
    end
  end

  defp navigation(_response, _forward), do: invalid!()
  defp invalid!, do: raise(ArgumentError, "Pagination requires a list response from this SDK.")
end
