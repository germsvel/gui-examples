defmodule Gui.FlightBooker do
  alias Gui.Booking

  def one_way(date) do
    {:one_way, date}
  end

  def two_way(departure, return) do
    {:two_way, departure, return}
  end

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

  def book_trip({:one_way, departure}) do
    {:ok, "You have booked a one-way flight on #{departure}"}
  end

  def book_trip({:two_way, departure, return}) do
    {:ok, "You have booked a return flight departing #{departure} and returning #{return}"}
  end
end
