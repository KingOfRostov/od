defmodule Od.Repo.Migrations.AddTensorflowToAssoc do
  use Ecto.Migration

  def change do
    create table(:tensorflows) do
      add :result, :string
      add :wanted_objects, :string
      add :uuid, :string

      add :image_id, references(:images)
    end

    create index(:tensorflows, [:image_id])
  end
end
