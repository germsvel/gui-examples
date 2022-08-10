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
  end
end
