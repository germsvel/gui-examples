defmodule Gui.CRUD do
  alias Gui.CRUD.User
  alias Gui.Repo

  def new_user, do: %User{}

  def list_users do
    Repo.all(User)
  end

  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def update_user(user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end

  def delete_user(user) do
    user
    |> Repo.delete()
  end
end
