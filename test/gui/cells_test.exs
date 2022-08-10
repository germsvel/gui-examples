defmodule Gui.CellsTest do
  use ExUnit.Case, async: true

  alias Gui.{Cells, Cell}

  describe "new/0" do
    test "creates new set of cells" do
      %Cells{cells: cells} = Cells.new()

      assert [%Cell{id: "A0"} | _] = cells
    end

    test "includes cols and rows" do
      %Cells{cols: cols, rows: rows} = Cells.new()

      assert ["A", "B" | _] = cols
      assert ["0", "1" | _] = rows
    end
  end

  describe "evaluate/1" do
    test "evaluates the value when a string" do
      value = [text: "hello world"]

      result = Cells.evaluate(value)

      assert result == "hello world"
    end

    test "evaluates the value when an integer" do
      assert 23 == Cells.evaluate(number: 23)
      assert 23.1 == Cells.evaluate(number: 23.1)
      assert -23.1 == Cells.evaluate(number: -23.1)
    end
  end
end
