defmodule Data.Repo.Migrations.AddTokenToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :device, :string
    end
  end
end
