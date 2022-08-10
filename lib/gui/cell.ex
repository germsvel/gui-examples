defmodule Gui.Cell do
  alias __MODULE__

  defstruct [:id, :col, :row, :value]

  def build(col, row), do: %__MODULE__{id: col <> row, col: col, row: row}

  def put_value(cell, value) do
    %Cell{cell | value: parse_value(value)}
  end

  defp parse_value(value) do
    {:ok, type, "", _, _, _} = Cell.FormulaParser.formula(value)
    type
  end

  defimpl String.Chars, for: Gui.Cell do
    def to_string(%{value: value}) do
      case value do
        [text: text] -> text
        [number: number] -> "#{number}"
        [function: func] -> "Function = #{inspect(func)}"
        nil -> ""
      end
    end
  end
end
