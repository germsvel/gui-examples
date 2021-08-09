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

    assert has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "update and delete buttons are disabled when no user is selected", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/crud")

    assert has_element?(view, "button#update:disabled", "Update")
    assert has_element?(view, "button#delete:disabled", "Delete")
  end

  test "user can update a selected user", %{conn: conn} do
    {:ok, %{id: id}} = Gui.CRUD.create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> form("#new-user", user: %{selected_user: id, first_name: "Bilbo"})
    |> render_submit()

    assert has_element?(view, "#user-list", "Baggins, Bilbo")
  end

  test "user can delete a selected user"
  test "user can filter list of users by Surname prefix (starts with)"
end
