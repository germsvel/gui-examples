defmodule Gui.Cell.FormulaParserHelpers do
  import NimbleParsec

  alias Gui.Cell.{Coord, Function, Range, Number, Text}

  def identifier do
    choice([
      string("add") |> replace(:add),
      string("sub") |> replace(:sub),
      string("sum") |> replace(:sum),
      string("div") |> replace(:div),
      string("mult") |> replace(:mult),
      string("ADD") |> replace(:add),
      string("SUB") |> replace(:sub),
      string("SUM") |> replace(:sum),
      string("DIV") |> replace(:div),
      string("MULT") |> replace(:mult)
    ])
    |> lookahead_not(ascii_char([?a..?z, ?A..?Z, ?0..?9]))
  end

  def integer do
    optional(string("-"))
    |> integer(min: 1)
    |> eos()
  end

  def float do
    optional(string("-"))
    |> integer(min: 1)
    |> string(".")
    |> integer(min: 1)
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_float, []})
    |> eos()
  end

  def number do
    choice([float(), integer()])
    |> unwrap_and_tag(:number)
  end

  def coord do
    ascii_string([?a..?z, ?A..?Z], 1)
    |> integer(min: 1, max: 2)
    |> reduce({Enum, :join, [""]})
    |> unwrap_and_tag(:coord)
    |> post_traverse(:to_struct)
  end

  def range do
    coord()
    |> ignore(string(":"))
    |> concat(coord())
    |> tag(:range)
    |> post_traverse(:to_struct)
  end

  def expr do
    choice([
      range(),
      coord(),
      number()
    ])
  end

  def function do
    identifier()
    |> ignore(string("("))
    |> concat(expr())
    |> ignore(string(")"))
    |> tag(:function)
  end

  def text do
    repeat(
      ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)
      |> optional(string(" "))
    )
    |> reduce({Enum, :join, [""]})
    |> unwrap_and_tag(:text)
  end

  def to_struct(rest, [coord: value], context, _line, _offset) do
    {rest, [%Coord{value: value}], context}
  end

  def to_struct(rest, [range: [from, to]], context, _line, _offset) do
    {rest, [%Range{from: from, to: to}], context}
  end
end
