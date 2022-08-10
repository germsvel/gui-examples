defmodule Gui.Cell.FormulaParser do
  import NimbleParsec
  import Gui.Cell.FormulaParserHelpers

  defparsec(:expr, expr())
  defparsec(:coord, coord())
  defparsec(:range, range())
  defparsec(:number, number())
  defparsec(:identifier, identifier())
  defparsec(:application, application())
  defparsec(:text, text())

  defparsec(
    :formula,
    choice([number(), ignore(string("=")) |> concat(application()), text()])
  )
end