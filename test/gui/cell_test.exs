defmodule Gui.CellTest do
  use ExUnit.Case, async: true

  alias Gui.Cell

  describe "put_value/1" do
    test "parses text values" do
      cell =
        Cell.build("A", "0")
        |> Cell.put_value("hello world")

      assert cell.value == [text: "hello world"]
    end

    test "parses number values" do
      cell =
        Cell.build("A", "0")
        |> Cell.put_value("29.0")

      assert cell.value == [number: 29.0]
    end

    test "parses functions" do
      cell =
        Cell.build("A", "0")
        |> Cell.put_value("=sum(A1:Z1)")

      assert cell.value == [function: [:sum, range: [coord: "A1", coord: "Z1"]]]
    end
  end
end
