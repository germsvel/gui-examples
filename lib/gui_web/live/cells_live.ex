defmodule GuiWeb.CellsLive do
  use GuiWeb, :live_view

  alias Gui.{Cells, Cell}

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
                  <.form let={f} for={:cell} phx-click-away="cancel-edit" phx-submit="save-cell" %>
                    <%= text_input f, :value, value: cell.value %>
                  </.form>
                </td>
              <% else %>
                <td id={cell.id} phx-click="edit-cell" phx-value-cell={cell.id} class="border border-slate-500"><%= to_string(cell) %></td>
              <% end %>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  defp row_cells(cells, row), do: Enum.filter(cells, fn %{row: cell_row} -> cell_row == row end)

  def mount(_, _, socket) do
    sheet = Cells.new()

    socket
    |> assign(:cols, sheet.cols)
    |> assign(:rows, sheet.rows)
    |> assign(:cells, sheet.cells)
    |> assign(:edit_cell, nil)
    |> ok()
  end

  def handle_event("edit-cell", %{"cell" => cell}, socket) do
    socket
    |> assign(:edit_cell, cell)
    |> noreply()
  end

  def handle_event("cancel-edit", _, socket) do
    socket
    |> assign(:edit_cell, nil)
    |> noreply()
  end

  def handle_event("save-cell", %{"cell" => %{"value" => value}}, socket) do
    cells =
      Enum.map(socket.assigns.cells, fn cell ->
        if cell.id == socket.assigns.edit_cell do
          Cell.put_value(cell, value)
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
