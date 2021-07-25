defmodule Gui.Repo.Migrations.CreateCrudUsers do
  use Ecto.Migration

  def change do
    create table(:crud_users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      timestamps()
    end
  end
end
