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

  test "a user can input text in a cell", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/cells")

    view
    |> element(cell("A0"))
    |> render_click()

    view
    |> form(edit_cell("A0"), %{cell: %{value: "Hello"}})
    |> render_submit()

    assert has_element?(view, cell("A0"), "Hello")
  end

  defp edit_cell(id), do: "##{id} form"
  defp cell(id), do: "##{id}"

  defp col_title, do: "th[scope=col]"
  defp row_title, do: "th[scope=row]"
end
