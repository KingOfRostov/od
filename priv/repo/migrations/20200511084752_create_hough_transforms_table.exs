defmodule Od.Repo.Migrations.CreateHoughTransformsTable do
  use Ecto.Migration

  def change do
    create table(:hough_transforms) do
      add :result, :string
      add :blur_strength, :integer, default: 9
      add :canny_lower, :integer, default: 150
      add :canny_upper, :integer, default: 150
      add :line_gap, :integer, default: 5
      add :line_length, :integer, default: 15
      add :line_treshold, :integer, default: 20
      add :circle_min_dist, :integer, default: 50
      add :circle_min_radius, :integer, default: 10
      add :circle_max_radius, :integer, default: 50
      add :circle_param1, :integer, default: 500
      add :circle_param2, :integer, default: 20
      add :mode, :string, default: "lines"
      add :uuid, :string

      add :image_id, references(:images)
    end

    create index(:hough_transforms, [:image_id])
  end
end
