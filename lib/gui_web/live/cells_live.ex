defmodule GuiWeb.CellsLive do
  use GuiWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1 class="font-semibold">Cells</h1>

    <table>
      <tbody>
        <tr>
          <td></td>
          <%= for col_title <- @col_titles do %>
            <th scope="col"><%= col_title %></th>
          <% end %>
        </tr>

        <%= for row_title <- @row_titles do %>
          <tr>
            <th scope="row"><%= row_title %></th>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  @col_titles ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  @row_titles for i <- 0..99, do: to_string(i)

  def mount(_, _, socket) do
    socket
    |> assign(:col_titles, @col_titles)
    |> assign(:row_titles, @row_titles)
    |> ok()
  end

  defp ok(socket), do: {:ok, socket}
end
