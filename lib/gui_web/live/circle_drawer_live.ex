defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  alias Phoenix.LiveView.JS

  @beginning_radius 10

  def render(assigns) do
    ~H"""
    <h1 class="font-semibold">CircleDraw</h1>

    <div class="mx-auto">
      <canvas phx-hook="CircleDrawer" class="border-2 border-gray-800" id="circle-drawer" width="500" height="500">
        Circle Drawer Canvas
      </canvas>

      <button class="mt-10" phx-click={JS.dispatch("reset", to: "#circle-drawer")} type="button">Reset</button>
    </div>
    """
  end

  @impl true
  def handle_event("canvas-click", %{"x" => x, "y" => y}, socket) do
    {:noreply, push_event(socket, "draw-circle", %{x: x, y: y, radius: @beginning_radius})}
  end
end
