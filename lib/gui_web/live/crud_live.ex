defmodule GuiWeb.CRUDLive do
  use GuiWeb, :live_view

  alias Gui.CRUD

  def render(assigns) do
    ~L"""
    <style>
      select {
        height: 100%;
      }
    </style>

    <h1>CRUD</h1>

    <form id="new-user" phx-submit="create">
      <div >
        <select name="user[selected_user]" id="user-list" size="<%= length(@users) %>">
          <%= for user <- @users do %>
            <option value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>
          <% end %>
        </select>
      </div>

      <div>
        <label for="user[first_name]">Name:</label>
        <input type="text" name="user[first_name]" id="first_name">

        <label for="user[last_name]">Surname:</label>
        <input type="text" name="user[last_name]" id="last_name">
      </div>

      <button type="submit">Create</button>
      <button id="update" type="button" disabled>Update</button>
      <button id="delete" type="button" disabled>Delete</button>
    </form>
    """
  end

  def mount(_, _, socket) do
    users = CRUD.list_users()

    {:ok, assign(socket, users: users)}
  end

  def handle_event("create", %{"user" => params}, socket) do
    {:ok, user} = CRUD.create_user(params)

    socket
    |> update(:users, fn users -> [user | users] end)
    |> noreply()
  end

  def noreply(socket), do: {:noreply, socket}
end
