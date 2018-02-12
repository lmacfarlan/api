defmodule Data.Models.Vote do
  require Logger
  import Ecto.Changeset
  use Ecto.Schema

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "votes" do
    field :movie_id,  :string
    field :liked,     :boolean

    timestamps()
    belongs_to :user, Data.Models.User
  end

  def changeset(model, params \\ :empty) do
    model 
    |> cast(params, [:user_id, :movie_id], [])
    |> validate_required([:user_id, :movie_id])
  end
end
