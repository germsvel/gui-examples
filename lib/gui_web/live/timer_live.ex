defmodule GuiWeb.TimerLive do
  use GuiWeb, :live_view

  def render(assigns) do
    ~L"""
    <h1>Timer</h1>

    <div>
      <label for="elapsed-time-gauge">Elapsed Time:</label>
      <meter id="elapsed-time-gauge" name="elapsed-time-gauge" min="0" value="<%= @elapsed_time %>" max="<%= @duration %>"><%= @elapsed_time %></meter>
    </div>

    <div id="elapsed-time">
      <%= @elapsed_time %> s
    </div>

    <div>
      <label for="duration-slider">Duration:</label>
      <input phx-hook="Slider" type="range" id="duration-slider" name="duration-slider" min="0" max="100" step="1">
    </div>

    <div>
      <button phx-click="reset" type="button" id="reset">Reset</button>
    </div>
    """
  end

  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:elapsed_time, 0)
      |> assign(:duration, 50)

    if connected?(socket), do: schedule_timer()

    {:ok, socket}
  end

  def schedule_timer do
    :timer.send_interval(1_000, :tick)
  end

  def tick(pid) do
    send(pid, :tick)
  end

  def handle_info(:tick, socket) do
    elapsed_time = socket.assigns.elapsed_time
    duration = socket.assigns.duration

    if elapsed_time < duration do
      socket
      |> update(:elapsed_time, fn time -> time + 1 end)
      |> noreply()
    else
      noreply(socket)
    end
  end

  def handle_event("update-duration", %{"value" => value}, socket) do
    socket
    |> assign(:duration, String.to_integer(value))
    |> noreply()
  end

  def handle_event("reset", _, socket) do
    socket
    |> assign(:elapsed_time, 0)
    |> noreply()
  end

  defp noreply(socket), do: {:noreply, socket}
end
