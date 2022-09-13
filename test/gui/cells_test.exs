defmodule Gui.CellsTest do
  use ExUnit.Case, async: true

  alias Gui.{Cells, Cell}
  alias Gui.Cell.{Text, Number, Range, Function}

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
      value = [%Text{value: "hello world"}]

      result = Cells.evaluate([], value)

      assert result == "hello world"
    end

    test "evaluates the value when an integer" do
      assert 23 == Cells.evaluate([], [%Number{value: 23}])
      assert 23.1 == Cells.evaluate([], [%Number{value: 23.1}])
      assert -23.1 == Cells.evaluate([], [%Number{value: -23.1}])
    end

    test "evaluates coordinate values based on cell values" do
      sheet = Cells.new()
      [cell | rest] = sheet.cells

      cell = Cell.put_value(cell, "Hello world")

      cells = [cell | rest]

      result = Cells.evaluate(cells, coord: cell.id)

      assert result == "Hello world"
    end

    test "evaluates functions" do
      sheet = Cells.new()
      [cell1, cell2, cell3 | rest] = sheet.cells

      cell1 = Cell.put_value(cell1, "23")
      cell2 = Cell.put_value(cell2, "25")
      cell3 = Cell.put_value(cell3, "=SUM(#{cell1.id}:#{cell2.id})")

      cells = [cell1, cell2, cell3 | rest]

      result = Cells.evaluate(cells, cell3.value)

      assert result == 48
    end
  end
end
