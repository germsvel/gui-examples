defmodule GuiWeb.FlightBookerLive do
  use GuiWeb, :live_view

  alias Gui.FlightBooker

  def render(assigns) do
    ~L"""
    <h1>Book Flight</h1>

    <%= f = form_for @changeset, "#", id: "flight-booker", phx_submit: "book", phx_change: "validate" %>
      <%= select f, :flight_type, @flight_types, id: "flight-type" %>
      <%= text_input f, :departure, id: "departure-date", class: date_class(@changeset, :departure) %>
      <%= error_tag f, :departure %>

      <%= text_input f, :return, id: "return-date", class: date_class(@changeset, :return), disabled: one_way_flight?(@changeset) %>
      <%= error_tag f, :return %>
      <%= error_tag f, :date_mismatch %>

      <%= submit "Book", id: "book-flight", disabled: !@changeset.valid? %>
    </form>
    """
  end

  def mount(_, _, socket) do
    changeset = FlightBooker.new_booking_changes()
    flight_types = FlightBooker.flight_types()

    {:ok, assign(socket, changeset: changeset, flight_types: flight_types)}
  end

  def handle_event("validate", %{"booking" => params}, socket) do
    changeset = FlightBooker.change_booking(socket.assigns.changeset, params)

    socket
    |> assign(:changeset, changeset)
    |> noreply()
  end

  def handle_event("book", %{"booking" => params}, socket) do
    {:ok, message} =
      socket.assigns.changeset
      |> FlightBooker.change_booking(params)
      |> FlightBooker.book_trip()

    socket
    |> put_flash(:info, message)
    |> noreply()
  end

  defp date_class(changeset, field) do
    if changeset.errors[field] do
      "invalid"
    end
  end

  defp one_way_flight?(changeset) do
    FlightBooker.one_way?(changeset.changes)
  end

  defp noreply(socket), do: {:noreply, socket}
end
