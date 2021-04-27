defmodule Gui.FlightBooker do
  alias Gui.Booking

  def flight_types, do: Booking.flight_types()

  def new_booking_changes do
    today = Date.utc_today()
    booking = %Booking{departure: today, return: today}

    Booking.one_way_changeset(booking)
  end

  def change_booking(changeset, params) do
    changeset.data
    |> Booking.changeset(params)
    |> Map.put(:action, :insert)
  end

  def one_way?(%{flight_type: "one-way flight"}), do: true
  def one_way?(%{flight_type: "return flight"}), do: false
  def one_way?(_), do: true

  def book_trip(booking) do
    booking = Ecto.Changeset.apply_changes(booking)
    {:ok, booking_message(booking)}
  end

  defp booking_message(booking) do
    case booking.flight_type do
      "one-way flight" ->
        "You have booked a one-way flight on #{booking.departure}"

      "return flight" ->
        "You have booked a return flight departing #{booking.departure} and returning #{
          booking.return
        }"
    end
  end
end
