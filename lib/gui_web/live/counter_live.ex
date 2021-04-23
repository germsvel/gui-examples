defmodule GuiWeb.CounterLive do
  use GuiWeb, :live_view

  def render(assigns) do
    ~L"""
    <h1>Counter</h1>

    <label id="counter"><%= @count %></label>
    <button phx-click="count" id="count">Count</button>
    """
  end

  def mount(_, _, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  def handle_event("count", _, socket) do
    socket
    |> update(:count, fn count -> count + 1 end)
    |> no_reply()
  end

  defp no_reply(socket), do: {:noreply, socket}
end
