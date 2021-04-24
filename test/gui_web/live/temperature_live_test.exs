defmodule GuiWeb.TemperatureLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders Temperature Converter title", %{conn: conn} do
    {:ok, view, html} = live(conn, "/temperature")

    assert html =~ "Temperature Converter"
    assert render(view) =~ "Temperature Converter"
  end

  test "user converts temp from Celsius to Fahrenheit", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/temperature")

    view
    |> form("#celsius", temp: %{celsius: 5})
    |> render_change()

    assert view |> fahrenheit_field(41.0) |> has_element?()
  end

  test "user converts temp from Fahrenheit to Celsius", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/temperature")

    view
    |> form("#fahrenheit", temp: %{fahrenheit: 41})
    |> render_change()

    assert view |> celsius_field(5.0) |> has_element?()
  end

  test "validates against invalid celsius input", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/temperature")

    html =
      view
      |> form("#celsius", temp: %{celsius: "hello"})
      |> render_change()

    assert html =~ "Celsius must be a number"
  end

  test "validates against invalid fahrenheit input", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/temperature")

    html =
      view
      |> form("#fahrenheit", temp: %{fahrenheit: "hello"})
      |> render_change()

    assert html =~ "Fahrenheit must be a number"
  end

  defp fahrenheit_field(view, value) do
    element(view, "#temp_fahrenheit[value='#{value}']")
  end

  defp celsius_field(view, value) do
    element(view, "#temp_celsius[value='#{value}']")
  end
end
