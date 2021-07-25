defmodule GuiWeb.CrudLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders a CRUD interface", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/crud")

    assert html =~ "CRUD"
  end
end
