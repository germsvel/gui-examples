defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  alias Phoenix.LiveView.JS

  @beginning_radius 10

  @impl true
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
  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:circles, %{})

    {:ok, socket}
  end

  @impl true
  def handle_event("canvas-click", %{"x" => x, "y" => y}, socket) do
    circles = socket.assigns.circles

    case existing_circle(circles, {x, y}) do
      {{original_x, original_y}, radius} ->
        response = %{action: "fill-circle", x: original_x, y: original_y, radius: radius}
        {:reply, response, socket}

      nil ->
        response = %{action: "draw-circle", x: x, y: y, radius: @beginning_radius}
        updated_circles = add_circle(circles, {x, y, @beginning_radius})

        {:reply, response, assign(socket, :circles, updated_circles)}
    end
  end

  defp add_circle(circles, {x, y, radius}) do
    Map.put(circles, {x, y}, radius)
  end

  defp existing_circle(circles, coordinates) do
    Enum.find(circles, fn circle ->
      within_circle?(circle, coordinates)
    end)
  end

  defp within_circle?({{circle_x, circle_y}, radius}, {x, y}) do
    :math.pow(x - circle_x, 2) + :math.pow(y - circle_y, 2) <= :math.pow(radius, 2)
  end
end
