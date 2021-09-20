defmodule Gui.CRUD do
  alias Gui.CRUD.User
  alias Gui.Repo

  @type potentially_invalid_changes() :: %{
          first_name: String.t() | nil,
          last_name: String.t() | nil
        }
  @type valid_changes :: %{first_name: String.t(), last_name: String.t()}
  @type errors :: map()
  @type user_changes() ::
          {:new_changes, potentially_invalid_changes}
          | {:valid_changes, valid_changes}
          | {:invalid_changes, potentially_invalid_changes, errors}

  def new_changes, do: {:new_changes, %{first_name: nil, last_name: nil}}

  def changes_from_user(user), do: {:valid_changes, Map.from_struct(user)}

  def put_change({_type, changes}, key, value), do: {:new_changes, Map.put(changes, key, value)}

  def put_change({_type, changes, _errors}, key, value),
    do: {:new_changes, Map.put(changes, key, value)}

  def list_users do
    Repo.all(User)
  end

  def create_user(user_changes) do
    with {:valid_changes, changes} <- validate_changes(user_changes),
         {:ok, user} <- insert_user(changes) do
      {:ok, user}
    else
      {:invalid_changes, _changes, _errors} = invalid_changes ->
        invalid_changes

      {:error, changeset} ->
        {:invalid_changes, changeset.data, changeset.errors}
    end
  end

  def update_user(user, user_changes) do
    with {:valid_changes, changes} <- validate_changes(user_changes),
         {:ok, user} <- do_update_user(user, changes) do
      {:ok, user}
    else
      {:invalid_changes, _changes, _errors} = invalid_changes ->
        invalid_changes

      {:error, changeset} ->
        {:invalid_changes, changeset.data, changeset.errors}
    end
  end

  def delete_user(user) do
    user
    |> Repo.delete()
  end

  defp insert_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  defp do_update_user(user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end

  defp validate_changes({:valid_changes, _changes} = user_changes), do: user_changes
  defp validate_changes({:invalid_changes, _changes, _errors} = user_changes), do: user_changes

  defp validate_changes({:new_changes, changes}) do
    changeset = %User{} |> User.changeset(changes)

    if changeset.valid? do
      {:valid_changes, changes}
    else
      {:invalid_changes, changes, changeset.errors}
    end
  end
end
