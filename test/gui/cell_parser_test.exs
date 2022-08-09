defmodule Gui.CellParserTest do
  use ExUnit.Case, async: true

  alias Gui.CellParser

  test "parses a coordinate" do
    {:ok, ["A", 0], "", %{}, {1, 0}, 2} = CellParser.coord("A0")
    {:ok, ["Z", 99], "", %{}, {1, 0}, 3} = CellParser.coord("Z99")
  end

  test "parses a range" do
    {:ok, ["A", 0, "A", 9], "", _, _, _} = CellParser.range("A0:A9")
    {:ok, ["A", 0, "Z", 0], "", _, _, _} = CellParser.range("A0:Z0")
    {:ok, ["F", 10, "Z", 99], "", _, _, _} = CellParser.range("F10:Z99")
  end

  test "parses numbers" do
    {:ok, [29], "", _, _, _} = CellParser.number("29")
    {:ok, [23, ".", 9], "", _, _, _} = CellParser.number("23.9")
    {:ok, ["-", 0, ".", 333], "", _, _, _} = CellParser.number("-0.333")
  end

  test "parses identifiers" do
    {:ok, ["sum"], "", _, _, _} = CellParser.identifier("sum")
    {:ok, ["div"], "", _, _, _} = CellParser.identifier("div")
  end
end
