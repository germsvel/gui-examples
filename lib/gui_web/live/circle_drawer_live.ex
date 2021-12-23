defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <h1>CircleDraw</h1>

    <canvas phx-hook="CircleDrawer" class="border-2 border-gray-800" id="circle-drawer" width="300" height="300">
      Circle Drawer Canvas
    </canvas>

    <button class="mt-10" phx-click={JS.dispatch("reset", to: "#circle-drawer")} type="button">Reset</button>
    """
  end
end
