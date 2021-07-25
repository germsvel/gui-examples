defmodule GuiWeb.CrudLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders a CRUD interface", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/crud")

    assert html =~ "CRUD"
  end

  test "user can enter a new name into user list", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> form("#new-user", user: %{first_name: "Frodo", last_name: "Baggins"})
    |> render_submit()

    assert has_element?(view, "#user-list", "Frodo Baggins")
  end
end
