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
      <form phx-change="filter-list" id="list-filter">
        <div class="flex flex-row items-baseline space-x-4">
          <label for="filter">Filter prefix:</label>
          <input class="max-w-sm" type="text" name="filter">
        </div>
      </form>

    <div class="flex flex-row flex-wrap space-x-8 items-top">
      <div>
        <select class="appearance-none" name="selected_user" id="user-list" size="<%= length(@users) %>">
          <%= for user <- filter_users(@users, @filter) do %>
            <option phx-click="select-user" id="user-<%= user.id %>" value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>
          <% end %>
        </select>
      </div>

      <div>
        <div class="grid grid-cols-3 items-baseline gap-4">
          <label for="first_name">Name:</label>

          <div class="col-span-2">
            <input phx-blur="set-first-name" type="text" name="first_name" id="first_name" value="<%= @current_user.first_name %>">
            <%= if @errors[:first_name] do %>
              <span class="invalid-feedback"><%= translate_error(@errors[:first_name]) %></span>
            <% end %>
          </div>
        </div>

        <div class="grid grid-cols-3 items-baseline gap-4">
          <label for="last_name">Surname:</label>

          <div class="col-span-2">
            <input phx-blur="set-last-name" type="text" name="last_name" id="last_name" value="<%= @current_user.last_name %>">
            <%= if @errors[:last_name] do %>
              <span class="invalid-feedback"><%= translate_error(@errors[:last_name]) %></span>
            <% end %>
          </div>
        </div>
      </div>
    </div>

    <div class="mt-10 space-x-2">
      <button id="create" type="button" phx-click="create">Create</button>

      <%= if user_selected?(@current_user) do %>
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
       filter: "",
       current_user: CRUD.new_user()
     )}
  end

  def handle_event("select-user", %{"value" => user_id}, socket) do
    user_id = String.to_integer(user_id)
    user = find_user(socket.assigns.users, user_id)

    socket
    |> assign(:current_user, user)
    |> noreply()
  end

  def handle_event("set-first-name", %{"value" => name}, socket) do
    socket
    |> update(:current_user, fn current_user -> %{current_user | first_name: name} end)
    |> noreply()
  end

  def handle_event("set-last-name", %{"value" => name}, socket) do
    socket
    |> update(:current_user, fn current_user -> %{current_user | last_name: name} end)
    |> noreply()
  end

  def handle_event("create", _, socket) do
    case CRUD.create_user(current_user_params(socket)) do
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
    selected_user = find_user(socket.assigns.users, socket.assigns.current_user.id)
    params = current_user_params(socket)

    case CRUD.update_user(selected_user, params) do
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
    {:ok, deleted_user} = CRUD.delete_user(socket.assigns.current_user)

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

  defp current_user_params(socket), do: Map.from_struct(socket.assigns.current_user)

  defp user_selected?(%{id: id}) when not is_nil(id), do: true
  defp user_selected?(_), do: false

  defp reset_selected_user(socket) do
    socket
    |> assign(:current_user, CRUD.new_user())
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
