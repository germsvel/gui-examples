defmodule GuiWeb.FlightBookerLive do
  use GuiWeb, :live_view

  alias Gui.FlightBooker

  def render(assigns) do
    ~L"""
    <h1>Book Flight</h1>

    <form url="#" id="flight-booker" phx-submit="book" phx-change="update-booking">

      <%= case @booker do %>
        <% {:one_way, departure} -> %>
          <%= select :booking, :flight_type, [[key: "One-way", value: "one-way", selected: true], [key: "Two-way", value: "two-way"]], id: "flight-type" %>

          <%= case departure do %>
            <% {:error, value} -> %>
              <%= text_input :booking, :departure, value: value, id: "departure-date", class: "invalid" %>
              <span class="invalid-feedback">Invalid date</span>

            <% value -> %>
              <%= text_input :booking, :departure, value: value, id: "departure-date" %>
          <% end %>

          <%= text_input :booking, :return, id: "return-date", disabled: true %>

        <% {:two_way, departure, return} -> %>
          <%= select :booking, :flight_type, [[key: "One-way", value: "one-way"], [key: "Two-way", value: "two-way", selected: true]], id: "flight-type" %>

          <%= case departure do %>
            <% {:error, value} -> %>
              <%= text_input :booking, :departure, value: value, id: "departure-date", class: "invalid" %>
              <span class="invalid-feedback">Invalid date</span>

            <% value -> %>
              <%= text_input :booking, :departure, value: value, id: "departure-date" %>
          <% end %>

          <%= case return do %>
            <% {:error, value} -> %>
              <%= text_input :booking, :return, value: value, id: "return-date", class: "invalid" %>
              <span class="invalid-feedback">Invalid date</span>

            <% value -> %>
              <%= text_input :booking, :return, value: value, id: "return-date" %>
          <% end %>
      <% end %>

      <%= submit "Book", id: "book-flight" %>
    </form>
    """
  end

  def mount(_, _, socket) do
    today = Date.utc_today()
    booker = FlightBooker.one_way(today)

    {:ok, assign(socket, booker: booker)}
  end

  def handle_event("update-booking", %{"booking" => params}, socket) do
    booker =
      params
      |> parse_params_into_booking()

    socket
    |> assign(:booker, booker)
    |> noreply()
  end

  def handle_event("book", %{"booking" => params}, socket) do
    {:ok, message} =
      params
      |> parse_params_into_booking()
      |> FlightBooker.book_trip()

    socket
    |> put_flash(:info, message)
    |> noreply()
  end

  defp parse_params_into_booking(params) do
    case params do
      %{"flight_type" => "one-way", "departure" => departure} ->
        FlightBooker.parse_one_way(departure)

      %{"flight_type" => "two-way", "departure" => departure, "return" => return} ->
        FlightBooker.parse_two_way(departure, return)

      %{"flight_type" => "two-way", "departure" => departure} ->
        return = Date.utc_today() |> Date.to_string()
        FlightBooker.parse_two_way(departure, return)
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
