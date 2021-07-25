defmodule GuiWeb.CRUDLive do
  use GuiWeb, :live_view

  alias Gui.CRUD

  def render(assigns) do
    ~L"""
    <h1>CRUD</h1>

    <div id="user-list">
      <ul>
        <%= for user <- @users do %>
          <li><%= user.first_name %> <%= user.last_name %></li>
        <% end %>
      </ul>
    </div>

    <form id="new-user" phx-submit="create">
      <div>
        <label for="user[first_name]">Name:</label>
        <input type="text" name="user[first_name]" id="first_name">

        <label for="user[last_name]">Surname:</label>
        <input type="text" name="user[last_name]" id="last_name">
      </div>

      <button type="submit">Create</button>
    </form>
    """
  end

  def mount(_, _, socket) do
    {:ok, assign(socket, users: [])}
  end

  def handle_event("create", %{"user" => params}, socket) do
    user = CRUD.create_user(params)

    socket
    |> update(:users, fn users -> [user | users] end)
    |> noreply()
  end

  def noreply(socket), do: {:noreply, socket}
end
