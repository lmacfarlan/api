defmodule Data.Repo.Migrations.AddVoteToVotes do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :liked, :boolean, default: false
    end
  end
end
