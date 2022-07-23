defmodule GuiWeb.CircleDrawerLive do
  use GuiWeb, :live_view

  alias Gui.CircleDrawer
  alias Phoenix.LiveView.JS

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
        <%= for %{x: x, y: y, r: r} <- @canvas.circles do %>
          <circle cx={x} cy={y} r={r} fill="#ddd" />
        <% end %>

        <%= if selected = @canvas.selected do %>
          <circle id="selected-circle" cx={selected.x} cy={selected.y} r={selected.r} fill="#deg"/>
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
          <%= if selected = @canvas.selected do %>
            <h3 class="text-2xl leading-6 font-medium text-gray-900" id="modal-title">
              Adjust diameter of circle at (<%= Float.floor(selected.x) %>, <%= Float.floor(selected.y) %>)
            </h3>
            <div class="mt-2">
              <input phx-hook="CircleDiameterSlider" type="range" value={selected.r} id="diameter-slider" name="diameter-slider" min="0" max="10" step="1">
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
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
    socket
    |> assign(:canvas, CircleDrawer.new_canvas())
    |> ok()
  end

  @impl true
  def handle_event("canvas-click", %{"x" => x, "y" => y}, socket) do
    canvas = socket.assigns.canvas
    x = to_number(x)
    y = to_number(y)

    case CircleDrawer.existing_circle(canvas, {x, y}) do
      %{x: _x, y: _y} = circle ->
        updated_canvas = CircleDrawer.select_circle(canvas, circle)

        socket
        |> assign(:canvas, updated_canvas)
        |> noreply()

      _ ->
        circle = CircleDrawer.new_circle(x, y)
        updated_canvas = CircleDrawer.add_circle(canvas, circle)

        socket
        |> assign(:canvas, updated_canvas)
        |> noreply()
    end
  end

  @impl true
  def handle_event("selected-circle-radius-updated", %{"r" => r}, socket) do
    canvas = socket.assigns.canvas
    r = to_number(r)

    updated_circle = CircleDrawer.update_radius(canvas.selected, r)
    updated_canvas = CircleDrawer.update_selected(canvas, updated_circle)

    socket
    |> assign(:canvas, updated_canvas)
    |> noreply()
  end

  @impl true
  def handle_event("reset", _, socket) do
    socket
    |> assign(:canvas, CircleDrawer.new_canvas())
    |> noreply()
  end

  defp to_number(number) when is_binary(number), do: Float.parse(number) |> elem(0)
  defp to_number(number), do: number

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}
end
