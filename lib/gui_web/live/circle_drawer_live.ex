defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>CircleDraw</h1>

    <canvas class="border-2 border-gray-800" id="circle-drawer" width="300" height="300">
      Circle Drawer Canvas
    </canvas>

    <script>
      let canvas = document.getElementById('circle-drawer');
      let ctx = canvas.getContext('2d');
    </script>
    """
  end
end
