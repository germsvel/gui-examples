defmodule Gui.CellParser do
  import NimbleParsec

  identifier = repeat(ascii_char([?a..?z], [?A..?Z]))

  decimal =
    optional(string("-"))
    |> integer(min: 1)
    |> optional(string("."))
    |> optional(integer(min: 1))
    |> eos()

  coord =
    ascii_string([?a..?z, ?A..?Z], 1)
    |> ascii_string([?0..?9], max: 2)

  defparsec(:coord, coord)
end
