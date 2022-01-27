defmodule GuiWeb.CircleDrawerLiveTest do
  use GuiWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders circle drawer screen", %{conn: conn} do
    {:ok, _, html} = live(conn, "/circle_drawer")

    assert html =~ "CircleDraw"
  end

  test "calls for drawing a circle when the canvas is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})

    assert_reply view, %{action: "draw-circle", x: 2, y: 4, radius: 10}
  end
end
