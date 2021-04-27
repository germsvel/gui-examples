defmodule Gui.BookingTest do
  use Gui.DataCase, async: true

  alias Gui.Booking

  describe "one_way_changeset/2" do
    test "builds a changeset" do
      booking = %Booking{}

      assert %Ecto.Changeset{} = Booking.one_way_changeset(booking)
    end

    test "validates that flight type and departure are required" do
      booking = %Booking{flight_type: nil}
      changes = %{flight_type: nil, departure: nil}

      changeset = Booking.one_way_changeset(booking, changes)

      assert errors = errors_on(changeset)
      assert errors.flight_type == ["can't be blank"]
      assert errors.departure == ["can't be blank"]
    end

    test "validates that flight type is one-way flight" do
      booking = %Booking{}
      changes = %{flight_type: "Random flight", departure: to_string(Date.utc_today())}

      changeset = Booking.one_way_changeset(booking, changes)

      assert ["is invalid"] = errors_on(changeset).flight_type
    end

    test "validates that departure date is valid" do
      booking = %Booking{}
      invalid_date = to_string(Date.utc_today()) <> "x"
      changes = %{departure: invalid_date}

      changeset = Booking.one_way_changeset(booking, changes)

      assert errors = errors_on(changeset)
      assert ["is invalid"] = errors.departure
    end
  end

  describe "two_way_changeset/2" do
    test "validates that flight type is return flight" do
      booking = %Booking{}
      date = Date.utc_today() |> to_string()
      changes = %{flight_type: "Random flight", departure: date, return: date}

      changeset = Booking.one_way_changeset(booking, changes)

      assert ["is invalid"] = errors_on(changeset).flight_type
    end

    test "validates departure and return can't be blank" do
      booking = %Booking{}

      changes = %{
        flight_type: "return flight",
        departure: nil,
        return: nil
      }

      changeset = Booking.two_way_changeset(booking, changes)

      assert ["can't be blank"] = errors_on(changeset).departure
      assert ["can't be blank"] = errors_on(changeset).return
    end

    test "validates departure and return dates are valid" do
      booking = %Booking{}
      invalid_date = to_string(Date.utc_today()) <> "x"
      changes = %{departure: invalid_date, return: invalid_date}

      changeset = Booking.two_way_changeset(booking, changes)

      assert errors = errors_on(changeset)
      assert ["is invalid"] = errors.departure
      assert ["is invalid"] = errors.return
    end

    test "validates return date is after departure for return flights" do
      departure = Date.utc_today() |> to_string()
      return = Date.utc_today() |> Date.add(-1) |> to_string()
      booking = %Booking{}
      changes = %{flight_type: "return flight", departure: departure, return: return}

      changeset = Booking.two_way_changeset(booking, changes)

      assert ["must be after departure date"] = errors_on(changeset).date_mismatch
    end
  end
end
