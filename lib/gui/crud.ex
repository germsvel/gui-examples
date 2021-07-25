defmodule Gui.CRUD do
  defmodule User do
    @enforce_keys [:first_name, :last_name]
    defstruct [:first_name, :last_name]
  end

  def create_user(params) do
    %User{
      first_name: params["first_name"],
      last_name: params["last_name"]
    }
  end
end
