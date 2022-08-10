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

  test "user can input text in a cell", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/cells")

    view
    |> edit_cell("A0", "Hello")

    assert has_element?(view, cell("A0"), "Hello")
  end

  test "user can input formulas", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/cells")

    view
    |> edit_cell("A0", "10")
    |> edit_cell("A1", "20")
    |> edit_cell("A2", "=sum(A0:A1)")

    assert has_element?(view, cell("A2"), "30")
  end

  defp edit_cell(view, cell_id, value) do
    view
    |> element(cell(cell_id))
    |> render_click()

    view
    |> form(editable_cell(cell_id), %{cell: %{value: value}})
    |> render_submit()

    view
  end

  defp editable_cell(id), do: "##{id} form"
  defp cell(id), do: "##{id}"

  defp col_title, do: "th[scope=col]"
  defp row_title, do: "th[scope=row]"
end
