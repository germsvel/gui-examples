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
    |> set_first_name("Frodo")
    |> set_last_name("Baggins")
    |> submit_create()

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
    |> select_user(id)
    |> set_first_name("Bilbo")
    |> submit_update()

    assert has_element?(view, "#user-list", "Baggins, Bilbo")
  end

  test "user can delete a selected user", %{conn: conn} do
    {:ok, %{id: id}} = Gui.CRUD.create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> select_user(id)
    |> submit_delete()

    refute has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "user can filter list of users by Surname prefix (starts with)", %{conn: conn} do
    {:ok, _} = Gui.CRUD.create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})
    {:ok, _} = Gui.CRUD.create_user(%{"first_name" => "Merry", "last_name" => "Brandybuck"})
    {:ok, view, _html} = live(conn, "/crud")

    view
    |> form("#list-filter", %{filter: "Brand"})
    |> render_change()

    assert has_element?(view, "#user-list", "Brandybuck, Merry")
    refute has_element?(view, "#user-list", "Baggins, Frodo")
  end

  test "user can remove filter and see all users again", %{conn: conn} do
    {:ok, _} = Gui.CRUD.create_user(%{"first_name" => "Frodo", "last_name" => "Baggins"})
    {:ok, _} = Gui.CRUD.create_user(%{"first_name" => "Merry", "last_name" => "Brandybuck"})
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

  defp set_first_name(view, name) do
    view
    |> element("[name='user[first_name]']")
    |> render_blur(%{value: name})

    view
  end

  defp set_last_name(view, name) do
    view
    |> element("[name='user[last_name]']")
    |> render_blur(%{value: name})

    view
  end

  defp submit_create(view) do
    view |> element("#create") |> render_click()
  end

  defp submit_update(view) do
    view |> element("#update") |> render_click()
  end

  defp submit_delete(view) do
    view |> element("#delete") |> render_click()
  end
end
