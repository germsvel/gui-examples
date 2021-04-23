defmodule GuiWeb.CounterLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders Counter title", %{conn: conn} do
    {:ok, view, html} = live(conn, "/counter")

    assert html =~ "Counter"
    assert render(view) =~ "Counter"
  end

  test "renders inital counter value of 0", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/counter")

    assert has_element?(view, "#counter", "0")
  end

  test "clicking on Count button increases the counter", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/counter")

    view
    |> element("#count")
    |> render_click()

    assert has_element?(view, "#counter", "1")
  end

  test "clicking on count many times increates counter every time", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/counter")

    view
    |> click_count()
    |> click_count()
    |> click_count()

    assert has_element?(view, "#counter", "3")
  end

  defp click_count(view) do
    view
    |> element("#count")
    |> render_click()

    view
  end
end
