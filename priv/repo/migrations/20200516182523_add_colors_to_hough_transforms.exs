defmodule Od.Repo.Migrations.AddColorsToHoughTransforms do
  use Ecto.Migration

  def change do
    alter table(:hough_transforms) do
      add :hough_line_color, :string
      add :hough_circle_color, :string
      add :hough_circle_center_color, :string
    end
  end
end
