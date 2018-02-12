defmodule Data.Providers.Vote do
  require Logger
  import Ecto.Query

  alias Data.Repo
  alias Data.Models.Vote

  def get(user_id: user_id) do
    Vote |> Repo.get_by(user_id: user_id)
  end

  def insert(params \\ %{}) do
    case get(user_id: params[:user_id]) do
      nil   -> %Vote{}
      vote  -> vote
    end
    |> Vote.changeset(params)
    |> Repo.insert_or_update()
  end
end
