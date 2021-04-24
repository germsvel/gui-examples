defmodule GuiWeb.TemperatureLive do
  use GuiWeb, :live_view

  alias Gui.Temperature

  def render(assigns) do
    ~L"""
    <h1>Temperature Converter</h1>

    <div>
      <form action="#" id="celsius" phx-change="to_fahrenheit">
        <label for="celsius">Celsius</label>
        <%= text_input :temp, :celsius, value: @celsius %>
      </form>
      <form action="#" id="fahrenheit" phx-change="to_celsius">
        <label for="fahrenheit">Fahrenheit</label>
        <%= text_input :temp, :fahrenheit, value: @fahrenheit %>
      </form>
    </div>
    """
  end

  def mount(_, _, socket) do
    {:ok, assign_temperatures(socket, C: 0, F: 32)}
  end

  def handle_event("to_fahrenheit", %{"temp" => %{"celsius" => celsius}}, socket) do
    case Integer.parse(celsius) do
      {celsius, ""} ->
        fahrenheit = Temperature.to_fahrenheit(celsius)

        socket
        |> assign_temperatures(C: celsius, F: fahrenheit)
        |> put_flash(:error, nil)
        |> noreply()

      :error ->
        socket
        |> put_flash(:error, "Celsius must be a number")
        |> noreply()
    end
  end

  def handle_event("to_celsius", %{"temp" => %{"fahrenheit" => fahrenheit}}, socket) do
    case Integer.parse(fahrenheit) do
      {fahrenheit, ""} ->
        celsius = Temperature.to_celsius(fahrenheit)

        socket
        |> assign_temperatures(C: celsius, F: fahrenheit)
        |> put_flash(:error, nil)
        |> noreply()

      :error ->
        socket
        |> put_flash(:error, "Fahrenheit must be a number")
        |> noreply()
    end
  end

  defp assign_temperatures(socket, temps) do
    socket
    |> assign(:celsius, Keyword.fetch!(temps, :C))
    |> assign(:fahrenheit, Keyword.fetch!(temps, :F))
  end

  defp noreply(socket), do: {:noreply, socket}
end
