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

    <div>
      <form phx-change="filter-list" id="list-filter">
        <div class="flex flex-row items-baseline space-x-4">
          <label for="filter">Filter prefix:</label>
          <input class="max-w-sm" type="text" name="filter" value="<%= @filter %>">
        </div>
      </form>

      <div class="flex flex-row flex-wrap space-x-8 items-top">
        <div>
          <select class="appearance-none" name="selected_user" id="user-list" size="<%= length(@users) %>">
            <%= for user <- filter_users(@users, @filter) do %>
              <%= case @user_changes do %>
                <% {:new_user, _changeset} -> %>
                  <option phx-click="select-user" id="user-<%= user.id %>" value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>

                <% {:selected_user, selected_user, _changeset} -> %>
                  <%= if selected_user.id == user.id do %>
                    <option selected phx-click="select-user" id="user-<%= user.id %>" value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>
                  <% else %>
                    <option phx-click="select-user" id="user-<%= user.id %>" value="<%= user.id %>"><%= user.last_name %>, <%= user.first_name %></option>
                  <% end %>
              <% end %>
            <% end %>
          </select>
        </div>

        <div>
          <%= render_inputs(assigns) %>
        </div>
      </div>

      <div class="mt-10 space-x-2">
      </div>
    </div>
    """
  end

  def render_inputs(assigns) do
    ~L"""
    <%= case @user_changes do %>
      <% {:new_user, changeset} -> %>
        <%= f = form_for changeset, "#", [id: "new-user", phx_change: :update_params, phx_submit: "create-user"] %>
          <%= text_input f, :first_name %>
          <%= error_tag f, :first_name %>

          <%= text_input f, :last_name %>
          <%= error_tag f, :last_name %>

          <div class="mt-10 space-x-2">
            <%= submit "Create" %>
            <button id="update" type="button" disabled>Update</button>
            <button id="delete" type="button" disabled>Delete</button>
          </div>
        </form>


      <% {:selected_user, _user, changeset} -> %>
        <%= f = form_for changeset, "#", [id: "update-user", phx_change: :update_params, phx_submit: "update-user"] %>
          <%= text_input f, :first_name %>
          <%= error_tag f, :first_name %>

          <%= text_input f, :last_name %>
          <%= error_tag f, :last_name %>

          <div class="mt-10 space-x-2">
            <button id="create" type="button" disabled>Create</button>
            <%= submit "Update" %>
            <button id="delete" type="button" phx-click="delete-user">Delete</button>
          </div>
        </form>

    <% end %>
    """
  end

  def mount(_, _, socket) do
    users = CRUD.list_users()

    {:ok,
     assign(socket,
       users: users,
       filter: "",
       user_changes: CRUD.new_user_changes()
     )}
  end

  def handle_event("select-user", %{"value" => user_id}, socket) do
    user_id = String.to_integer(user_id)
    user = find_user(socket.assigns.users, user_id)

    socket
    |> assign(:user_changes, CRUD.selected_user_changes(user))
    |> noreply()
  end

  def handle_event("update_params", %{"user" => params}, socket) do
    socket
    |> assign(:user_changes, CRUD.user_changes(socket.assigns.user_changes, params))
    |> noreply()
  end

  def handle_event("create-user", _, socket) do
    case CRUD.create_user(socket.assigns.user_changes) do
      {:ok, user} ->
        socket
        |> update(:users, fn users -> [user | users] end)
        |> assign(:user_changes, CRUD.new_user_changes())
        |> noreply()

      {:error, user_changes} ->
        socket
        |> assign(:user_changes, user_changes)
        |> noreply()
    end
  end

  def handle_event("update-user", _, socket) do
    case CRUD.update_user(socket.assigns.user_changes) do
      {:ok, updated_user} ->
        socket
        |> update(:users, &replace_updated_user(&1, updated_user))
        |> assign(:user_changes, CRUD.new_user_changes())
        |> noreply()

      {:error, user_changes} ->
        socket
        |> assign(:user_changes, user_changes)
        |> noreply()
    end
  end

  def handle_event("delete-user", _, socket) do
    {:ok, deleted_user} = CRUD.delete_user(socket.assigns.user_changes)

    socket
    |> update(:users, &remove_deleted_user(&1, deleted_user))
    |> assign(:user_changes, CRUD.new_user_changes())
    |> noreply()
  end

  def handle_event("filter-list", %{"filter" => text}, socket) do
    socket
    |> assign(:filter, text)
    |> noreply()
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
