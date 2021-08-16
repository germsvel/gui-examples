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

    <div id="new-user">
      <div >
        <select name="user[selected_user]" id="user-list" size="<%= length(@users) %>">
          <%= for user <- @users do %>
            <option phx-click="select-user" id="user-<%= user.id %>" value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>
          <% end %>
        </select>
      </div>

      <div>
        <label for="user[first_name]">Name:</label>
        <input phx-blur="set-first-name" type="text" name="user[first_name]" id="first_name" value="<%= @first_name %>">

        <label for="user[last_name]">Surname:</label>
        <input phx-blur="set-last-name" type="text" name="user[last_name]" id="last_name" value="<%= @last_name %>">
      </div>

      <button id="create" type="button" phx-click="create">Create</button>

      <%= if !!@current_user_id do %>
        <button id="update" type="button" phx-click="update">Update</button>
        <button id="delete" type="button" disabled>Delete</button>
      <% else %>
        <button id="update" type="button" disabled>Update</button>
        <button id="delete" type="button" disabled>Delete</button>
      <% end %>
    </div>
    """
  end

  def mount(_, _, socket) do
    users = CRUD.list_users()

    {:ok, assign(socket, users: users, current_user_id: nil, first_name: "", last_name: "")}
  end

  def handle_event("select-user", %{"value" => user_id}, socket) do
    user_id = String.to_integer(user_id)
    user = find_user(socket.assigns.users, user_id)

    socket
    |> assign(:current_user_id, user_id)
    |> assign(:first_name, user.first_name)
    |> assign(:last_name, user.last_name)
    |> noreply()
  end

  def handle_event("set-first-name", %{"value" => name}, socket) do
    socket
    |> assign(:first_name, name)
    |> noreply()
  end

  def handle_event("set-last-name", %{"value" => name}, socket) do
    socket
    |> assign(:last_name, name)
    |> noreply()
  end

  def handle_event("create", _, socket) do
    params = user_params(socket)
    {:ok, user} = CRUD.create_user(params)

    socket
    |> update(:users, fn users -> [user | users] end)
    |> noreply()
  end

  def handle_event("update", _, socket) do
    user = find_user(socket.assigns.users, socket.assigns.current_user_id)
    params = user_params(socket)
    {:ok, updated_user} = CRUD.update_user(user, params)

    socket
    |> update(:users, fn users ->
      Enum.map(users, fn
        user when user.id == updated_user.id ->
          updated_user

        user ->
          user
      end)
    end)
    |> noreply()
  end

  defp find_user(users, id) do
    Enum.find(users, fn user -> user.id == id end)
  end

  defp user_params(socket) do
    %{"first_name" => socket.assigns.first_name, "last_name" => socket.assigns.last_name}
  end

  def noreply(socket), do: {:noreply, socket}
end
