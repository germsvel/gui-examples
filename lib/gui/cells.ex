defmodule Gui.Cells do
  alias Gui.Cell

  defstruct [:cells, :rows, :cols]

  # @cols ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  @cols ~w(A B C D E F)
  # @rows for i <- 0..99, do: to_string(i)
  @rows for i <- 0..9, do: to_string(i)

  def new do
    cells =
      for row <- @rows, col <- @cols do
        Cell.build(col, row)
      end

    %__MODULE__{cells: cells, cols: @cols, rows: @rows}
  end

  def evaluate(_cells, nil), do: ""
  def evaluate(_cells, text: text), do: text
  def evaluate(_cells, number: number), do: number

  def evaluate(cells, coord: coord) do
    cell = find_by(cells, id: coord)
    evaluate(cells, cell.value)
  end

  def evaluate(cells, function: function) do
    [operation, args] = function
    arg_list = eval_args(cells, args)

    case operation do
      :sum -> Enum.reduce(arg_list, 0, fn acc, i -> acc + i end)
    end
  end

  def eval_args(cells, {:range, coords}) do
    Enum.map(coords, fn coord -> evaluate(cells, coord) end)
  end

  defp find_by(cells, id: id) do
    Enum.find(cells, fn cell -> cell.id == id end)
  end
end
