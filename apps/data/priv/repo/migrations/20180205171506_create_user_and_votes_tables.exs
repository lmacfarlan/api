defmodule Data.Repo.Migrations.CreateUserAndVotesTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :token, :string

      timestamps()
    end

    create unique_index(:users, [:token,])

    create table(:votes) do
      add :movie_id,  :string
      add :user_id,   references(:users)

      timestamps()
    end
  end
end
