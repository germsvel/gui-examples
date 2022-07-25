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

    assert has_element?(view, circle(2, 4))
  end

  test "clicking on the same circle (exactly), fills the original circle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "canvas-click", %{x: 2, y: 4})

    assert has_element?(view, selected_circle(2, 4))
  end

  test "clicking within an existing circle, fills the original circle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "canvas-click", %{x: 3, y: 5})

    assert has_element?(view, selected_circle(2, 4))
  end

  test "user can change the radius of a selected circle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "selected-circle-radius-updated", %{r: 10})

    assert has_element?(view, selected_circle(2, 4, 10))
  end

  test "clicking undo goes back one step", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_hook(view, "canvas-click", %{x: 5, y: 6})
    render_click(element(view, "#undo"))

    refute has_element?(view, circle(5, 6))
  end

  test "clicking redo goes forward one step", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/circle_drawer")

    render_hook(view, "canvas-click", %{x: 2, y: 4})
    render_click(element(view, "#undo"))
    render_click(element(view, "#redo"))

    assert has_element?(view, circle(2, 4))
  end

  defp circle(x, y) do
    "circle[cx=#{x}][cy=#{y}]"
  end

  defp selected_circle(x, y) do
    "circle[cx=#{x}][cy=#{y}][fill='#deg']"
  end

  defp selected_circle(x, y, r) do
    "circle[cx=#{x}][cy=#{y}][r=#{r}][fill='#deg']"
  end
end
