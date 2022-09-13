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

  defmodule Number do
    defstruct [:value]
  end

  defmodule Text do
    defstruct [:value]
  end

  defmodule Coord do
    defstruct [:value]
  end

  defmodule Range do
    defstruct [:from, :to]
  end

  defmodule Function do
    defstruct [:type, :args]
  end
end
