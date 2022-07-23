defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  alias Phoenix.LiveView.JS

  @beginning_radius 2

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-semibold">CircleDraw</h1>

    <div class="mx-auto">
      <div>
        <button class="text-white bg-gray-500 border border-gray-500 hover:bg-gray-900" phx-click="undo">Undo</button>
        <button class="text-white bg-gray-500 border border-gray-500 hover:bg-gray-900" phx-click="redo">Redo</button>
      </div>

      <svg id="circle-drawer" phx-hook="CircleDrawer" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <%= for {{x, y}, r} <- @circles do %>
          <circle cx={x} cy={y} r={r} fill="#ddd" />
        <% end %>

        <%= case @selected_circle do %>
          <% {{x, y}, r} -> %>
            <circle id="selected-circle" cx={x} cy={y} r={r} fill="#deg"/>
          <% _ -> %>
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
          <%= case @selected_circle do %>
            <% {{x, y}, r} -> %>
              <h3 class="text-2xl leading-6 font-medium text-gray-900" id="modal-title">
                Adjust diameter of circle at (<%= Float.floor(x) %>, <%= Float.floor(y) %>)
              </h3>
              <div class="mt-2">
                <input phx-hook="CircleDiameterSlider" type="range" value={r} id="diameter-slider" name="diameter-slider" min="0" max="10" step="1">
              </div>
            <% _ -> %>
          <% end %>
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
    |> JS.dispatch("update-selected-radius", to: "#diameter-slider")
    |> JS.hide(transition: "fade-out", to: "#modal")
    |> JS.hide(transition: "fade-out-scale", to: "#modal-content")
  end

  @impl true
  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:circles, %{})
      |> assign(:selected_circle, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("canvas-click", %{"x" => x, "y" => y}, socket) do
    circles = socket.assigns.circles
    x = to_number(x)
    y = to_number(y)
    r = @beginning_radius

    case existing_circle(circles, {x, y}) do
      {{_x, _y}, _r} = circle ->
        socket
        |> assign(:selected_circle, circle)
        |> noreply()

      _ ->
        updated_circles = add_circle(circles, {{x, y}, r})

        socket
        |> assign(:circles, updated_circles)
        |> noreply()
    end
  end

  @impl true
  def handle_event("selected-circle-radius-updated", %{"r" => r}, socket) do
    circles = socket.assigns.circles
    {{x, y}, _} = socket.assigns.selected_circle
    r = to_number(r)

    case existing_circle(circles, {x, y}) do
      {{cx, cy}, _r} = circle ->
        updated_circle = {{cx, cy}, r}
        updated_circles = add_circle(circles, updated_circle)

        socket
        |> assign(:selected_circle, updated_circle)
        |> assign(:circles, updated_circles)
        |> noreply()

      _ ->
        socket
        |> noreply()
    end
  end

  @impl true
  def handle_event("reset", _, socket) do
    socket
    |> assign(:circles, %{})
    |> assign(:selected_circle, nil)
    |> noreply()
  end

  defp to_number(number) when is_binary(number), do: Float.parse(number) |> elem(0)
  defp to_number(number), do: number

  defp noreply(socket), do: {:noreply, socket}

  defp add_circle(circles, {{x, y}, radius}) do
    Map.put(circles, {x, y}, radius)
  end

  defp existing_circle(circles, coordinates) do
    Enum.find(circles, &within_circle?(&1, coordinates))
  end

  defp within_circle?({{circle_x, circle_y}, radius}, {x, y}) do
    :math.pow(x - circle_x, 2) + :math.pow(y - circle_y, 2) <= :math.pow(radius, 2)
  end
end
