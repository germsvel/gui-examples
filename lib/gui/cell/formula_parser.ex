defmodule Gui.Cell.FormulaParser do
  import NimbleParsec
  import Gui.Cell.FormulaParserHelpers

  defparsec(:expr, expr())
  defparsec(:coord, coord())
  defparsec(:range, range())
  defparsec(:number, number())
  defparsec(:identifier, identifier())
  defparsec(:function, function())
  defparsec(:text, text())

  defparsec(
    :formula,
    choice([number(), ignore(string("=")) |> concat(function()), text()])
  )
end
