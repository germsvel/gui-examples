defmodule GuiWeb.CRUDLive do
  use GuiWeb, :live_view

  alias Gui.CRUD
  alias Gui.CRUD.User

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
          <%= render_inputs(assigns) %>
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
    </div>
    """
  end

  def render_inputs(assigns) do
    case assigns[:user_changes] do
      {:invalid_changes, changes, errors} ->
        render_invalid_inputs(assigns, changes, errors)

      {_, changes} ->
        render_valid_inputs(assigns, changes)
    end
  end

  def render_valid_inputs(assigns, changes) do
    ~L"""
      <div class="grid grid-cols-3 items-baseline gap-4">
        <label for="first_name">Name:</label>
        <div class="col-span-2">
          <input phx-blur="set-first-name" type="text" name="first_name" id="first_name" value="<%= changes.first_name %>">
        </div>
      </div>

      <div class="grid grid-cols-3 items-baseline gap-4">
        <label for="last_name">Surname:</label>

        <div class="col-span-2">
          <input phx-blur="set-last-name" type="text" name="last_name" id="last_name" value="<%= changes.last_name %>">
        </div>
      </div>
    """
  end

  def render_invalid_inputs(assigns, changes, errors) do
    ~L"""
      <div class="grid grid-cols-3 items-baseline gap-4">
        <label for="first_name">Name:</label>
        <div class="col-span-2">
          <input phx-blur="set-first-name" type="text" name="first_name" id="first_name" value="<%= changes.first_name %>">
          <%= if errors[:first_name] do %>
            <span class="invalid-feedback"><%= translate_error(errors[:first_name]) %></span>
          <% end %>
        </div>
      </div>

      <div class="grid grid-cols-3 items-baseline gap-4">
        <label for="last_name">Surname:</label>

        <div class="col-span-2">
          <input phx-blur="set-last-name" type="text" name="last_name" id="last_name" value="<%= changes.last_name %>">
          <%= if errors[:last_name] do %>
            <span class="invalid-feedback"><%= translate_error(errors[:last_name]) %></span>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(_, _, socket) do
    users = CRUD.list_users()

    {:ok,
     assign(socket,
       users: users,
       filter: "",
       current_user: nil,
       user_changes: CRUD.new_user() |> Map.from_struct() |> new_changes()
     )}
  end

  def handle_event("select-user", %{"value" => user_id}, socket) do
    user_id = String.to_integer(user_id)
    user = find_user(socket.assigns.users, user_id)

    socket
    |> assign(:current_user, user)
    |> assign(:user_changes, valid_changes(Map.from_struct(user)))
    |> noreply()
  end

  def handle_event("set-first-name", %{"value" => name}, socket) do
    socket
    |> update(:user_changes, fn changes -> put_change(changes, :first_name, name) end)
    |> noreply()
  end

  def handle_event("set-last-name", %{"value" => name}, socket) do
    socket
    |> update(:user_changes, fn changes -> put_change(changes, :last_name, name) end)
    |> noreply()
  end

  def handle_event("create", _, socket) do
    with {:valid_changes, changes} <- validate_changes(socket.assigns.user_changes),
         {:ok, user} <- CRUD.create_user(changes) do
      socket
      |> update(:users, fn users -> [user | users] end)
      |> noreply()
    else
      {:invalid_changes, changes, errors} ->
        socket
        |> assign(:user_changes, {:invalid_changes, changes, errors})
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:user_changes, {:invalid_changes, changeset.data, changeset.errors})
        |> noreply()
    end
  end

  def handle_event("update", _, socket) do
    selected_user = find_user(socket.assigns.users, socket.assigns.current_user.id)

    with {:valid_changes, changes} <- validate_changes(socket.assigns.user_changes),
         {:ok, updated_user} <- CRUD.update_user(selected_user, changes) do
      socket
      |> update(:users, &replace_updated_user(&1, updated_user))
      |> noreply()
    else
      {:invalid_changes, changes, errors} ->
        socket
        |> assign(:user_changes, {:invalid_changes, changes, errors})
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:user_changes, {:invalid_changes, changeset.data, changeset.errors})
        |> noreply()
    end
  end

  def handle_event("delete", _, socket) do
    {:ok, deleted_user} = CRUD.delete_user(socket.assigns.current_user)

    socket
    |> update(:users, &remove_deleted_user(&1, deleted_user))
    |> assign(:current_user, nil)
    |> noreply()
  end

  def handle_event("filter-list", %{"filter" => text}, socket) do
    socket
    |> assign(:filter, text)
    |> noreply()
  end

  defp validate_changes({:valid_changes, _changes} = user_changes), do: user_changes
  defp validate_changes({:invalid_changes, _changes, _errors} = user_changes), do: user_changes

  defp validate_changes({:new_changes, changes}) do
    changeset = %User{} |> User.changeset(changes)

    if changeset.valid? do
      valid_changes(changes)
    else
      invalid_changes(changes, changeset.errors)
    end
  end

  defp new_changes(changes), do: {:new_changes, changes}
  defp valid_changes(changes), do: {:valid_changes, changes}
  defp invalid_changes(changes, errors), do: {:invalid_changes, changes, errors}

  defp put_change({_type, changes}, key, value), do: {:new_changes, Map.put(changes, key, value)}

  defp put_change({_type, changes, _errors}, key, value),
    do: {:new_changes, Map.put(changes, key, value)}

  defp user_selected?(%{id: id}) when not is_nil(id), do: true
  defp user_selected?(_), do: false

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
