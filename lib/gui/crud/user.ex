defmodule Gui.CRUD.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crud_users" do
    field :first_name, :string
    field :last_name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
