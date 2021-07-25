defmodule GuiWeb.CrudLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Gui.CRUD

  test "renders a CRUD interface", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/crud")

    assert html =~ "CRUD"
  end

  test "update and delete buttons are disabled when no user is selected", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/crud")

    assert has_element?(view, "button#update:disabled", "Update")
    assert has_element?(view, "button#delete:disabled", "Delete")
  end

  test "user sees errors with invalid name", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/crud")

    html =
      view
      |> enter_new_name("Frodo", "")
      |> render_submit()

    assert html =~ "can&#39;t be blank"
  end

  test "user can enter a new name into user list", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> enter_new_name("Frodo", "Baggins")
    |> render_submit()

    assert has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "user can update a selected user", %{conn: conn} do
    {:ok, %{id: id}} = create_user(%{"first_name" => "Frod", "last_name" => "Bagginses"})

    {:ok, view, _html} = live(conn, "/crud")

    view
    |> select_user(id)
    |> update_fields("Frodo", "Baggins")
    |> render_submit()

    assert has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "user sees errors with invalid name when updating name", %{conn: conn} do
    {:ok, %{id: id}} = create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})

    {:ok, view, _html} = live(conn, "/crud")

    html =
      view
      |> select_user(id)
      |> update_fields("", "Baggins")
      |> render_submit()

    assert html =~ "can&#39;t be blank"
  end

  test "user can delete a selected user", %{conn: conn} do
    {:ok, %{id: id}} = create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})

    {:ok, view, _html} = live(conn, "/crud")

    view
    |> select_user(id)
    |> submit_delete()

    refute has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "user can filter list of users by Surname prefix (starts with)", %{conn: conn} do
    {:ok, _} = create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})
    {:ok, _} = create_user(%{"first_name" => "Merry", "last_name" => "Brandybuck"})
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> form("#list-filter", %{filter: "Brand"})
    |> render_change()

    assert has_element?(view, "#user-list", "Brandybuck, Merry")
    refute has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "user can remove filter and see all users again", %{conn: conn} do
    {:ok, _} = create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})
    {:ok, _} = create_user(%{"first_name" => "Merry", "last_name" => "Brandybuck"})
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> filter_list("Brand")
    |> filter_list("")

    assert has_element?(view, "#user-list", "Brandybuck, Merry")
    assert has_element?(view, "#user-list", "Baggins, Frodo")
  end

  defp filter_list(view, text) do
    view
    |> form("#list-filter", %{filter: text})
    |> render_change()

    view
  end

  defp select_user(view, id) do
    view
    |> element("select #user-#{id}")
    |> render_click()

    view
  end

  defp submit_delete(view) do
    view |> element("#delete") |> render_click()
  end

  defp enter_new_name(view, first, last) do
    view
    |> form("#new-user", user: %{first_name: first, last_name: last})
    |> render_change()

    view
    |> form("#new-user", user: %{first_name: first, last_name: last})
  end

  defp update_fields(view, first, last) do
    view
    |> form("#update-user", user: %{first_name: first, last_name: last})
    |> render_change()

    view
    |> form("#update-user", user: %{first_name: first, last_name: last})
  end

  defp create_user(params) do
    %CRUD.User{}
    |> CRUD.User.changeset(params)
    |> Gui.Repo.insert()
  end
end
