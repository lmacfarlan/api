defmodule Data.Providers.User do
  require Logger

  alias Data.Repo
  alias Data.Models.User

  def get(id: id) do
    User |> Repo.get(id)
  end

  def get(device: device) do
    User |> Repo.get_by(device: device)
  end

  def get(token: token) do
    User |> Repo.get_by(token: token)
  end

  def create(params \\ %{}) do
    %User{} 
    |> User.changeset(params)
    |> Repo.insert()
  end
end
