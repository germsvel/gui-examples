defmodule GuiWeb.CellsLiveTest do
  use GuiWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders cells screen", %{conn: conn} do
    {:ok, _, html} = live(conn, "/cells")

    assert html =~ "Cells"
  end
end
