defmodule GuiWeb.CellsLive do
  use GuiWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1 class="font-semibold">Cells</h1>

    <table class="border border-slate-500 border-collapse">
      <thead>
        <tr>
          <td></td>
          <%= for col <- @cols do %>
            <th class="border border-slate-500" scope="col"><%= col %></th>
          <% end %>
        </tr>
      </thead>
      <tbody>
        <%= for row <- @rows do %>
          <tr>
            <th class="border border-slate-500" scope="row"><%= row %></th>
            <%= for cell <- row_cells(@cells, row) do %>
              <%= if @edit_cell == cell.id do %>
                <td id={cell.id} phx-click="edit-cell" phx-value-cell={cell.id} class="border border-slate-500">
                  <.form let={f} for={:cell} phx-submit="save-cell" %>
                    <%= text_input f, :value, value: cell.value %>
                  </.form>
                </td>
              <% else %>
                <td id={cell.id} phx-click="edit-cell" phx-value-cell={cell.id} class="border border-slate-500"><%= cell.value %></td>
              <% end %>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  defp row_cells(cells, row), do: Enum.filter(cells, fn %{row: cell_row} -> cell_row == row end)

  # @cols ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  @cols ~w(A B C D E F)
  # @rows for i <- 0..99, do: to_string(i)
  @rows for i <- 0..9, do: to_string(i)

  defmodule Cell do
    defstruct [:id, :col, :row, :value]

    def build(col, row), do: %__MODULE__{id: col <> row, col: col, row: row}
  end

  def mount(_, _, socket) do
    cells =
      for row <- @rows, col <- @cols do
        Cell.build(col, row)
      end

    socket
    |> assign(:cols, @cols)
    |> assign(:rows, @rows)
    |> assign(:cells, cells)
    |> assign(:edit_cell, nil)
    |> ok()
  end

  def handle_event("edit-cell", %{"cell" => cell}, socket) do
    socket
    |> assign(:edit_cell, cell)
    |> noreply()
  end

  def handle_event("save-cell", %{"cell" => %{"value" => value}}, socket) do
    cells =
      Enum.map(socket.assigns.cells, fn cell ->
        if cell.id == socket.assigns.edit_cell do
          %Cell{cell | value: value}
        else
          cell
        end
      end)

    socket
    |> assign(:cells, cells)
    |> assign(:edit_cell, nil)
    |> noreply()
  end

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}
end
