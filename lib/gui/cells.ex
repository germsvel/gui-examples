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

  def evaluate(text: text), do: text
  def evaluate(number: number), do: number
end
