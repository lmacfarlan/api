defmodule Data.Models.User do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "users" do
    field :token,   :string
    field :device,  :string

    has_many :votes, Data.Models.Vote

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model 
    |> cast(params, [:device], [])
    |> generate_token()
  end

  defp generate_token(changeset) do
    changeset |> put_change(:token, SecureRandom.urlsafe_base64())
  end
end
