defmodule Gui.CellParserTest do
  use ExUnit.Case, async: true

  alias Gui.CellParser

  test "parses a coordinate" do
    {:ok, ["A", "0"], "", %{}, {1, 0}, 2} = CellParser.coord("A0")
    {:ok, ["Z", "99"], "", %{}, {1, 0}, 3} = CellParser.coord("Z99")
  end
end
