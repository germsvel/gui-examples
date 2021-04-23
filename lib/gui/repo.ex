defmodule Gui.Repo do
  use Ecto.Repo,
    otp_app: :gui,
    adapter: Ecto.Adapters.Postgres
end
