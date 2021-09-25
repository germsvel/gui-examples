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
          <%= text_input :booking, :departure, value: departure, id: "departure-date" %>
          <%= text_input :booking, :return, id: "return-date", disabled: true %>

        <% {:two_way, departure, return} -> %>
          <%= select :booking, :flight_type, [[key: "One-way", value: "one-way"], [key: "Two-way", value: "two-way", selected: true]], id: "flight-type" %>
          <%= text_input :booking, :departure, value: departure, id: "departure-date" %>
          <%= text_input :booking, :return, value: return, id: "return-date" %>
      <% end %>

      <%= submit "Book", phx_click: "book", id: "book-flight" %>
    </form>
    """
  end

  def mount(_, _, socket) do
    today = Date.utc_today()
    booker = FlightBooker.one_way(today)
    flight_types = FlightBooker.flight_types()

    {:ok, assign(socket, booker: booker, flight_types: flight_types)}
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
        departure
        |> Date.from_iso8601!()
        |> FlightBooker.one_way()

      %{"flight_type" => "two-way", "departure" => departure, "return" => return} ->
        departure_date = departure |> Date.from_iso8601!()
        return_date = return |> Date.from_iso8601!()
        FlightBooker.two_way(departure_date, return_date)

      %{"flight_type" => "two-way", "departure" => departure} ->
        departure_date = departure |> Date.from_iso8601!()
        return_date = Date.utc_today()
        FlightBooker.two_way(departure_date, return_date)
    end
  end

  defp date_class(changeset, field) do
    if changeset.errors[field] do
      "invalid"
    end
  end

  defp one_way_flight?({:one_way, _}), do: true
  defp one_way_flight?(_), do: false

  defp noreply(socket), do: {:noreply, socket}
end
