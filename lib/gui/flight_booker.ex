defmodule Gui.FlightBooker do
  alias Gui.Booking

  def parse_one_way(date) do
    date
    |> parse_date()
    |> one_way()
  end

  def parse_two_way(departure_value, return_value) do
    departure = parse_date(departure_value)
    return = parse_date(return_value)
    two_way(departure, return)
  end

  defp parse_date(string_date) when is_binary(string_date) do
    case Date.from_iso8601(string_date) do
      {:ok, date} -> date
      {:error, _} -> error(string_date)
    end
  end

  defp error(value), do: {:error, value}

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
