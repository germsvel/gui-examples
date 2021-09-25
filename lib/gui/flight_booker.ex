defmodule Gui.FlightBooker do
  alias Gui.Booking

  def one_way(date) do
    {:one_way, date}
  end

  def two_way(departure, return) do
    {:two_way, departure, return}
  end

  def parse_one_way(date) do
    date
    |> parse_date()
    |> one_way()
  end

  def parse_two_way(departure_value, return_value) do
    departure = parse_date(departure_value)
    return = parse_date(return_value)

    case {departure, return} do
      {%Date{}, %Date{}} ->
        if Date.compare(departure, return) == :gt do
          two_way(departure, error(return))
        else
          two_way(departure, return)
        end

      _ ->
        two_way(departure, return)
    end
  end

  defp parse_date(string_date) when is_binary(string_date) do
    case Date.from_iso8601(string_date) do
      {:ok, date} -> date
      {:error, _} -> error(string_date)
    end
  end

  defp error(value), do: {:error, value}

  def book_trip({:one_way, departure}) do
    {:ok, "You have booked a one-way flight on #{departure}"}
  end

  def book_trip({:two_way, departure, return}) do
    {:ok, "You have booked a return flight departing #{departure} and returning #{return}"}
  end
end
