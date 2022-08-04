defmodule GuiWeb.CellsLiveTest do
  use GuiWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders cells screen", %{conn: conn} do
    {:ok, _, html} = live(conn, "/cells")

    assert html =~ "Cells"
  end

  test "renders columns [A-Z] and rows [0-99]", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/cells")

    assert has_element?(view, col_title(), "A")
    assert has_element?(view, col_title(), "G")
    assert has_element?(view, col_title(), "Z")
    assert has_element?(view, row_title(), "0")
    assert has_element?(view, row_title(), "50")
    assert has_element?(view, row_title(), "99")
  end

  defp col_title, do: "th[scope=col]"
  defp row_title, do: "th[scope=row]"
end
