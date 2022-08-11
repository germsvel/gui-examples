defmodule Gui.Cell.FormulaParserTest do
  use ExUnit.Case, async: true

  alias Gui.Cell.FormulaParser
  alias Gui.Cell.{Coord, Function, Range, Number, Text}

  test "parses a coordinate" do
    {:ok, [%Coord{value: "A0"}], "", %{}, {1, 0}, 2} = FormulaParser.coord("A0")
    {:ok, [%Coord{value: "Z99"}], "", %{}, {1, 0}, 3} = FormulaParser.coord("Z99")
  end

  test "parses a range" do
    {:ok, [%Range{from: %Coord{value: "A0"}, to: %Coord{value: "A9"}}], "", _, _, _} =
      FormulaParser.range("A0:A9")

    {:ok, [%Range{from: %Coord{value: "A0"}, to: %Coord{value: "Z0"}}], "", _, _, _} =
      FormulaParser.range("A0:Z0")

    {:ok, [%Range{from: %Coord{value: "F10"}, to: %Coord{value: "Z99"}}], "", _, _, _} =
      FormulaParser.range("F10:Z99")
  end

  test "parses numbers" do
    {:ok, [%Number{value: 29}], "", _, _, _} = FormulaParser.number("29")
    {:ok, [%Number{value: 23.9}], "", _, _, _} = FormulaParser.number("23.9")
    {:ok, [%Number{value: -0.333}], "", _, _, _} = FormulaParser.number("-0.333")
  end

  test "parses identifiers" do
    {:ok, [:add], "", _, _, _} = FormulaParser.identifier("add")
    {:ok, [:sub], "", _, _, _} = FormulaParser.identifier("sub")
    {:ok, [:sum], "", _, _, _} = FormulaParser.identifier("sum")
    {:ok, [:div], "", _, _, _} = FormulaParser.identifier("div")
    {:ok, [:mult], "", _, _, _} = FormulaParser.identifier("mult")
  end

  test "parses function application" do
    {:ok, [function: [:sum, %Range{from: %Coord{value: "A1"}, to: %Coord{value: "B1"}}]], "", _,
     _, _} = FormulaParser.function("sum(A1:B1)")

    {:ok, [function: [:div, %Range{from: %Coord{value: "A1"}, to: %Coord{value: "B1"}}]], "", _,
     _, _} = FormulaParser.function("div(A1:B1)")
  end

  test "parses text" do
    {:ok, [text: "hello world"], "", _, _, _} = FormulaParser.text("hello world")
  end

  test "parses formulas that can be numbers, text, or function applications" do
    {:ok, [text: "hello world"], "", _, _, _} = FormulaParser.formula("hello world")
    {:ok, [%Number{value: 23.9}], "", _, _, _} = FormulaParser.formula("23.9")

    {:ok, [function: [:sum, %Range{from: %Coord{value: "A1"}, to: %Coord{value: "B1"}}]], "", _,
     _, _} = FormulaParser.formula("=sum(A1:B1)")
  end
end
