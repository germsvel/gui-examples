defmodule GuiWeb.FlightBookerLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders Book Flight title", %{conn: conn} do
    {:ok, view, html} = live(conn, "/flight_booker")

    assert html =~ "Book Flight"
    assert render(view) =~ "Book Flight"
  end

  test "user starts with one-way flight with today's dates", %{conn: conn} do
    date = Date.utc_today() |> to_string()

    {:ok, view, _html} = live(conn, "/flight_booker")

    assert has_element?(view, "#flight-type", "one-way flight")
    assert has_element?(view, "#departure-date[value='#{date}']")
    assert has_element?(view, "#return-date[value='#{date}']")
  end

  test "return date is disabled if one-way flight is chosen", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/flight_booker")

    assert has_element?(view, "#flight-type", "one-way flight")
    assert has_element?(view, "#return-date:disabled")
  end

  test "user can book a one-way flight", %{conn: conn} do
    date = Date.utc_today() |> to_string()
    {:ok, view, _html} = live(conn, "/flight_booker")

    html =
      view
      |> form("#flight-booker", booking: %{flight_type: "one-way flight", departure: date})
      |> render_submit()

    assert html =~ "You have booked a one-way flight on #{date}"
  end

  test "user can toggle flight type", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/flight_booker")

    view
    |> form("#flight-booker", booking: %{flight_type: "return flight"})
    |> render_change()

    assert has_element?(view, "#flight-type", "return flight")
  end

  test "user can book a return (two-way) flight", %{conn: conn} do
    today = Date.utc_today() |> to_string()
    tomorrow = Date.utc_today() |> Date.add(1) |> to_string()
    {:ok, view, _html} = live(conn, "/flight_booker")

    html =
      view
      |> set_return_flight(%{departure: today, return: tomorrow})
      |> render_submit()

    assert html =~ "You have booked a return flight departing #{today} and returning #{tomorrow}"
  end

  test "departure date field is red if date is invalid", %{conn: conn} do
    date = Date.utc_today() |> to_string()
    invalid_date = date <> "x"
    {:ok, view, _html} = live(conn, "/flight_booker")

    view
    |> form("#flight-booker", booking: %{flight_type: "one-way flight", departure: invalid_date})
    |> render_change()

    assert has_element?(view, "#departure-date.invalid")
  end

  test "return date field is red if date is invalid", %{conn: conn} do
    today = Date.utc_today() |> to_string()
    tomorrow = Date.utc_today() |> Date.add(1) |> to_string()
    invalid_date = tomorrow <> "x"
    {:ok, view, _html} = live(conn, "/flight_booker")

    view
    |> set_return_flight(%{departure: today, return: invalid_date})
    |> render_change()

    assert has_element?(view, "#return-date.invalid")
  end

  test "user cannot book flight (button is disabled) if return date is before departure date", %{
    conn: conn
  } do
    depart = Date.utc_today() |> to_string()
    return = Date.utc_today() |> Date.add(-1) |> to_string()
    {:ok, view, _html} = live(conn, "/flight_booker")

    view
    |> set_return_flight(%{departure: depart, return: return})
    |> render_change()

    assert has_element?(view, "#book-flight:disabled")
  end

  defp set_return_flight(view, dates) do
    flight_data = Map.merge(%{flight_type: "return flight"}, dates)

    view
    |> change_flight_type("return flight")
    |> form("#flight-booker", booking: flight_data)
  end

  defp change_flight_type(view, flight_type) do
    view
    |> form("#flight-booker", booking: %{flight_type: flight_type})
    |> render_change()

    view
  end
end
