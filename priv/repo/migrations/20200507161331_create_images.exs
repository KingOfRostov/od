defmodule Od.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :image, :string
      add :uuid, :string
      add :hough_image, :string
      add :haar_image, :string
      add :tensorflow_image, :string

      timestamps()
    end

  end
end
