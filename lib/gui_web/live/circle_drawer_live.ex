defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  alias Phoenix.LiveView.JS

  @beginning_radius 1

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-semibold">CircleDraw</h1>

    <div class="mx-auto">
      <svg id="circle-drawer" phx-hook="CircleDrawer" viewBox="0 0 100 100">
        <%= for {{x, y}, r} <- @circles do %>
          <circle cx={x} cy={y} r={r} fill="#ddd"></circle>
        <% end %>
      </svg>

      <button class="mt-10" phx-click="reset" type="button">Reset</button>
    </div>

    <div id="modal" class="phx-modal hidden" phx-remove={hide_modal()}>
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
        # SELECTED circle
        # response = %{action: "fill-circle", x: original_x, y: original_y, radius: radius}
        {:noreply, socket}

      nil ->
        updated_circles = add_circle(circles, {x, y, @beginning_radius})

        {:noreply, assign(socket, :circles, updated_circles)}
    end
  end

  @impl true
  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, :circles, %{})}
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
