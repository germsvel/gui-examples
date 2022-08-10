defmodule Gui.Cell.FormulaParserHelpers do
  import NimbleParsec

  def identifier do
    repeat(ascii_string([?a..?z, ?A..?Z], min: 1))
    |> tag(:iden)
  end

  def number do
    optional(string("-"))
    |> integer(min: 1)
    |> optional(string("."))
    |> optional(integer(min: 1))
    |> eos()
    |> tag(:number)
  end

  def coord do
    ascii_string([?a..?z, ?A..?Z], 1)
    |> integer(min: 1, max: 2)
    |> tag(:coord)
  end

  def range do
    coord()
    |> ignore(string(":"))
    |> concat(coord())
    |> tag(:range)
  end

  def expr do
    choice([
      range(),
      coord(),
      number()
    ])
  end

  def application do
    identifier()
    |> ignore(string("("))
    |> concat(expr())
    |> ignore(string(")"))
    |> tag(:application)
  end

  def text do
    repeat(
      ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)
      |> optional(string(" "))
    )
    |> tag(:text)
  end
end
