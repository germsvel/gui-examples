defmodule Gui.Cell do
  defstruct [:id, :col, :row, :value]

  def build(col, row), do: %__MODULE__{id: col <> row, col: col, row: row}

  defimpl String.Chars, for: Cell do
    def to_string(%{value: value}) do
      case value do
        "=" <> rest -> "function #{rest}"
        raw_value -> raw_value
      end
    end
  end
end
