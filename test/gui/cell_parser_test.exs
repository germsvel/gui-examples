defmodule Gui.CellParserTest do
  use ExUnit.Case, async: true

  alias Gui.CellParser

  test "parses a coordinate" do
    {:ok, [coord: ["A", 0]], "", %{}, {1, 0}, 2} = CellParser.coord("A0")
    {:ok, [coord: ["Z", 99]], "", %{}, {1, 0}, 3} = CellParser.coord("Z99")
  end

  test "parses a range" do
    {:ok, [range: [coord: ["A", 0], coord: ["A", 9]]], "", _, _, _} = CellParser.range("A0:A9")
    {:ok, [range: [coord: ["A", 0], coord: ["Z", 0]]], "", _, _, _} = CellParser.range("A0:Z0")

    {:ok, [range: [coord: ["F", 10], coord: ["Z", 99]]], "", _, _, _} =
      CellParser.range("F10:Z99")
  end

  test "parses numbers" do
    {:ok, [number: [29]], "", _, _, _} = CellParser.number("29")
    {:ok, [number: [23, ".", 9]], "", _, _, _} = CellParser.number("23.9")
    {:ok, [number: ["-", 0, ".", 333]], "", _, _, _} = CellParser.number("-0.333")
  end

  test "parses identifiers" do
    {:ok, [iden: ["sum"]], "", _, _, _} = CellParser.identifier("sum")
    {:ok, [iden: ["div"]], "", _, _, _} = CellParser.identifier("div")
  end

  test "parses function application" do
    {:ok, [application: [iden: ["sum"], range: [coord: ["A", 1], coord: ["B", 1]]]], "", _, _, _} =
      CellParser.application("sum(A1:B1)")

    {:ok, [application: [iden: ["div"], range: [coord: ["A", 1], coord: ["B", 1]]]], "", _, _, _} =
      CellParser.application("div(A1:B1)")
  end

  test "parses text" do
    {:ok, [text: ["hello", " ", "world"]], "", _, _, _} = CellParser.text("hello world")
  end

  test "parses formulas that can be numbers, text, or function applications" do
    {:ok, [text: ["hello", " ", "world"]], "", _, _, _} = CellParser.formula("hello world")
    {:ok, [number: [23, ".", 9]], "", _, _, _} = CellParser.formula("23.9")

    {:ok, [application: [iden: ["sum"], range: [coord: ["A", 1], coord: ["B", 1]]]], "", _, _, _} =
      CellParser.formula("=sum(A1:B1)")
  end
end
