defmodule GuiWeb.CircleDrawerLiveTest do
  use GuiWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders circle drawer screen", %{conn: conn} do
    {:ok, _, html} = live(conn, "/circle_drawer")

    assert html =~ "CircleDraw"
  end

  test "clicking on canvas draws a new circle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})

    assert_reply view, %{action: "draw-circle", x: 2, y: 4, radius: 10}
  end

  test "clicking on the same circle (exactly), fills the original circle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "canvas-click", %{x: 2, y: 4})

    assert_reply view, %{action: "fill-circle", x: 2, y: 4, radius: 10}
  end

  test "clicking within an existing circle, fills the original circle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "canvas-click", %{x: 3, y: 5})

    assert_reply view, %{action: "fill-circle", x: 2, y: 4, radius: 10}
  end
end
