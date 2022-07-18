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

    <div class="mx-auto">
      <svg>
        <circle cx={6} cy={4} r={10} fill="#ccc" />
        <%= for circle <- @circles do %>
          <circle cx={circle.cx} cy={circle.cy} r={circle.r}
            phx-click='select(circle, event)'
            fill='{circle === selected ? "#ccc": "white"}'
          />
        <% end %>
      </svg>
    </div>

    <div id="menu" hidden class="absolute z-10 left-1/2 transform -translate-x-1/2 mt-3 px-2 w-screen max-w-xs sm:px-0">
      <div class="rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 overflow-hidden">
        <div class="relative grid gap-6 bg-white px-5 py-6 sm:gap-8 sm:p-8">
          <a href="#" phx-click={hide_menu_and_show_modal()} class="-m-3 p-3 block rounded-md hover:bg-gray-50 transition ease-in-out duration-150">
            <p class="text-base font-medium text-gray-900">
              Adjust diameter ...
            </p>
          </a>
        </div>
      </div>
    </div>

    <div id="modal" hidden class="phx-modal" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content"
        phx-click-away={hide_modal()}
        phx-window-keydown={hide_modal()}
        phx-key="escape"
      >
        <button class="phx-modal-close bg-white border-none hover:bg-gray-100 hover:border-gray-100" phx-click={hide_modal()}>✖</button>

        <div class="mt-3 text-center sm:mt-5">
          <h3 class="text-2xl leading-6 font-medium text-gray-900" id="modal-title">
            Adjust diameter of circle at (x, y)
          </h3>
          <div class="mt-2">
            <input type="range" id="diameter-slider" name="diameter-slider" min="0" max="100" step="1">
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp hide_menu_and_show_modal() do
    %JS{}
    |> JS.hide(transition: "fade-out", to: "#menu")
    |> show_modal()
  end

  defp show_modal(js \\ %JS{}) do
    js
    |> JS.show(transition: "fade-in", to: "#modal")
    |> JS.show(transition: "fade-in-scale", to: "#modal-content")
  end

  defp hide_modal do
    %JS{}
    |> JS.hide(transition: "fade-out", to: "#modal")
    |> JS.hide(transition: "fade-out-scale", to: "#modal-content")
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
