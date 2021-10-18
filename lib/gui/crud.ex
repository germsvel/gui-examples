defmodule Gui.CRUD do
  alias Gui.CRUD.User
  alias Gui.Repo

  @type t ::
          {:new_user, %Ecto.Changeset{}}
          | {:existing_user, %Ecto.Changeset{}}

  def new_user_changes, do: {:new_user, %User{} |> User.changeset()}

  def existing_user_changes(user), do: {:existing_user, User.changeset(user)}

  def user_changes({:new_user, _changeset}, params) do
    {:new_user, User.changeset(%User{}, params)}
  end

  def user_changes({:existing_user, changeset}, params) do
    {:existing_user, User.changeset(changeset, params)}
  end

  def list_users do
    Repo.all(User)
  end

  def create_user({_, changeset}) do
    case Repo.insert(changeset) do
      {:ok, _user} = success -> success
      {:error, changeset} -> {:error, {:new_user, changeset}}
    end
  end

  def update_user({:existing_user, changeset}) do
    case Repo.update(changeset) do
      {:ok, _user} = success -> success
      {:error, changeset} -> {:error, {:existing_user, changeset}}
    end
  end

  def delete_user({:existing_user, changeset}) do
    changeset
    |> Repo.delete()
  end
end
