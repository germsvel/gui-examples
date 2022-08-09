defmodule Gui.CellParser do
  import NimbleParsec

  identifier =
    repeat(ascii_string([?a..?z, ?A..?Z], min: 1))
    |> tag(:iden)

  number =
    optional(string("-"))
    |> integer(min: 1)
    |> optional(string("."))
    |> optional(integer(min: 1))
    |> eos()
    |> tag(:number)

  coord =
    ascii_string([?a..?z, ?A..?Z], 1)
    |> integer(min: 1, max: 2)
    |> tag(:coord)

  range =
    coord
    |> ignore(string(":"))
    |> concat(coord)
    |> tag(:range)

  defparsec(:coord, coord)
  defparsec(:range, range)
  defparsec(:number, number)
  defparsec(:identifier, identifier)
end
