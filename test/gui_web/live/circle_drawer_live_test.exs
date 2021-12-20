defmodule GuiWeb.CircleDrawerLiveTest do
  use GuiWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders circle drawer screen", %{conn: conn} do
    {:ok, _, html} = live(conn, "/circle_drawer")

    assert html =~ "CircleDraw"
  end
end
