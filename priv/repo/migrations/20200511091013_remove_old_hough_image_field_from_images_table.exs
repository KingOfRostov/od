defmodule Od.Repo.Migrations.RemoveOldHoughImageFieldFromImagesTable do
  use Ecto.Migration

  def up do
    alter table(:images) do
      remove :hough_image
    end
  end

  def down do
    alter table(:images) do
      add :hough_image, :string
    end
  end
end
