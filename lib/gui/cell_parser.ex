defmodule Gui.CellParser do
  import NimbleParsec

  identifier = repeat(ascii_string([?a..?z, ?A..?Z], min: 1))

  number =
    optional(string("-"))
    |> integer(min: 1)
    |> optional(string("."))
    |> optional(integer(min: 1))
    |> eos()

  coord =
    ascii_string([?a..?z, ?A..?Z], 1)
    |> integer(min: 1, max: 2)

  range =
    coord
    |> ignore(string(":"))
    |> concat(coord)

  defparsec(:coord, coord)
  defparsec(:range, range)
  defparsec(:number, number)
  defparsec(:identifier, identifier)
end
