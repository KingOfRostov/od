defmodule Od.Repo.Migrations.AddHaarToImages do
  use Ecto.Migration

  def change do
    create table(:haar_cascades) do
      add :result, :string
      add :scale_factor, :float, default: 1.05
      add :min_neighbors, :integer, default: 1
      add :object_type, :string, default: "cars"
      add :uuid, :string

      add :image_id, references(:images)
    end

    create index(:haar_cascades, [:image_id])
  end
end
