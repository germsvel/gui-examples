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
      <div>
        <form phx-change="filter-list" id="list-filter">
          <label for="filter">Filter prefix:</label>
          <input type="text" name="filter">
        </form>

        <select name="selected_user" id="user-list" size="<%= length(@users) %>">
          <%= for user <- filter_users(@users, @filter) do %>
            <option phx-click="select-user" id="user-<%= user.id %>" value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>
          <% end %>
        </select>
      </div>

      <div>
        <label for="first_name">Name:</label>
        <input phx-blur="set-first-name" type="text" name="first_name" id="first_name" value="<%= @user_params.first_name %>">
        <%= if @errors[:first_name] do %>
          <span class="invalid-feedback"><%= translate_error(@errors[:first_name]) %></span>
        <% end %>

        <label for="last_name">Surname:</label>
        <input phx-blur="set-last-name" type="text" name="last_name" id="last_name" value="<%= @user_params.last_name %>">
        <%= if @errors[:last_name] do %>
          <span class="invalid-feedback"><%= translate_error(@errors[:last_name]) %></span>
        <% end %>
      </div>

      <button id="create" type="button" phx-click="create">Create</button>

      <%= if @selected_user do %>
        <button id="update" type="button" phx-click="update">Update</button>
        <button id="delete" type="button" phx-click="delete">Delete</button>
      <% else %>
        <button id="update" type="button" disabled>Update</button>
        <button id="delete" type="button" disabled>Delete</button>
      <% end %>
    </div>
    """
  end

  def mount(_, _, socket) do
    users = CRUD.list_users()

    {:ok,
     assign(socket,
       users: users,
       errors: %{},
       selected_user: nil,
       filter: "",
       user_params: %{
         first_name: "",
         last_name: ""
       }
     )}
  end

  def handle_event("select-user", %{"value" => user_id}, socket) do
    user_id = String.to_integer(user_id)
    user = find_user(socket.assigns.users, user_id)

    socket
    |> assign(:selected_user, user)
    |> assign(
      :user_params,
      %{first_name: user.first_name, last_name: user.last_name}
    )
    |> noreply()
  end

  def handle_event("set-first-name", %{"value" => name}, socket) do
    socket
    |> update(:user_params, fn user_params -> %{user_params | first_name: name} end)
    |> noreply()
  end

  def handle_event("set-last-name", %{"value" => name}, socket) do
    socket
    |> update(:user_params, fn user_params -> %{user_params | last_name: name} end)
    |> noreply()
  end

  def handle_event("create", _, socket) do
    case CRUD.create_user(socket.assigns.user_params) do
      {:ok, user} ->
        socket
        |> update(:users, fn users -> [user | users] end)
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:errors, changeset.errors)
        |> noreply()
    end
  end

  def handle_event("update", _, socket) do
    selected_user = socket.assigns.selected_user
    user_params = socket.assigns.user_params

    case CRUD.update_user(selected_user, user_params) do
      {:ok, updated_user} ->
        socket
        |> update(:users, &replace_updated_user(&1, updated_user))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:errors, changeset.errors)
        |> noreply()
    end
  end

  def handle_event("delete", _, socket) do
    {:ok, deleted_user} = CRUD.delete_user(socket.assigns.selected_user)

    socket
    |> update(:users, &remove_deleted_user(&1, deleted_user))
    |> reset_selected_user()
    |> noreply()
  end

  def handle_event("filter-list", %{"filter" => text}, socket) do
    socket
    |> assign(:filter, text)
    |> noreply()
  end

  defp reset_selected_user(socket) do
    socket
    |> assign(:selected_user, nil)
    |> assign(:user_params, %{first_name: "", last_name: ""})
  end

  defp filter_users(users, filter) do
    Enum.filter(users, fn user -> String.starts_with?(user.last_name, filter) end)
  end

  defp find_user(users, id) do
    Enum.find(users, fn user -> user.id == id end)
  end

  defp replace_updated_user(users, updated_user) do
    Enum.map(users, fn
      user when user.id == updated_user.id ->
        updated_user

      user ->
        user
    end)
  end

  defp remove_deleted_user(users, deleted_user) do
    Enum.filter(users, fn user -> user.id != deleted_user.id end)
  end

  def noreply(socket), do: {:noreply, socket}
end
