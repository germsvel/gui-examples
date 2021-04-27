defmodule Gui.Booking do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :flight_type, :string, default: "one-way flight"
    field :departure, :date
    field :return, :date
  end

  def flight_types, do: ["one-way flight", "return flight"]

  def changeset(booking, changes) do
    case changes["flight_type"] do
      "one-way flight" -> one_way_changeset(booking, changes)
      "return flight" -> two_way_changeset(booking, changes)
    end
  end

  def one_way_changeset(booking, changes \\ %{}) do
    booking
    |> cast(changes, [:flight_type, :departure])
    |> validate_required([:flight_type, :departure])
    |> validate_inclusion(:flight_type, ["one-way flight"])
  end

  def two_way_changeset(booking, changes \\ %{}) do
    booking
    |> cast(changes, [:flight_type, :departure, :return])
    |> validate_required([:flight_type, :departure, :return])
    |> validate_inclusion(:flight_type, ["return flight"])
    |> validate_return_and_departure()
  end

  defp validate_return_and_departure(changeset) do
    departure = get_field(changeset, :departure)
    return = get_field(changeset, :return)

    if departure && return && Date.compare(departure, return) != :lt do
      add_date_mismatch_if_last_error(changeset)
    else
      changeset
    end
  end

  defp add_date_mismatch_if_last_error(changeset) do
    if Enum.empty?(changeset.errors) do
      add_error(changeset, :date_mismatch, "must be after departure date")
    else
      changeset
    end
  end
end
