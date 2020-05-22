defmodule Od.Gallery.HoughTransform do
  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset
  alias Od.Gallery
  alias Od.Helpers.ImageToBinaryConverter
  @required ~w(result image_id)a
  @optional ~w(uuid blur_strength canny_lower canny_upper hough_line_color line_gap line_length line_treshold circle_min_dist circle_min_radius circle_max_radius circle_param1 circle_param2 mode)a
  @attachments_atoms ~w(result)a
  @attachments_strings ~w(result)

  @defaults %{
    hough_line_color: "255 0 255",
    hough_circle_color: "255 0 255",
    hough_circle_center_color: "255 0 255",
    blur_strength: 9,
    canny_lower: 150,
    canny_upper: 150,
    line_length: 15,
    line_gap: 5,
    line_treshold: 20,
    circle_min_dist: 50,
    circle_min_radius: 10,
    circle_max_radius: 50,
    circle_param1: 500,
    circle_param2: 20,
    mode: "lines"
  }

  schema "hough_transforms" do
    field :result, Od.Image.Type
    field :blur_strength, :integer, default: @defaults.blur_strength
    field :canny_lower, :integer, default: @defaults.canny_lower
    field :canny_upper, :integer, default: @defaults.canny_upper
    field :line_length, :integer, default: @defaults.line_length
    field :line_gap, :integer, default: @defaults.line_gap
    field :line_treshold, :integer, default: @defaults.line_treshold
    field :circle_min_dist, :integer, default: @defaults.circle_min_dist
    field :circle_min_radius, :integer, default: @defaults.circle_min_radius
    field :circle_max_radius, :integer, default: @defaults.circle_max_radius
    field :circle_param1, :integer, default: @defaults.circle_param1
    field :circle_param2, :integer, default: @defaults.circle_param2
    field :hough_line_color, :string, default: @defaults.hough_line_color
    field :hough_circle_color, :string, default: @defaults.hough_circle_color
    field :hough_circle_center_color, :string, default: @defaults.hough_circle_center_color
    field :mode, :string, default: @defaults.mode
    field :uuid, :string

    belongs_to :image, Gallery.Image, on_replace: :delete
  end

  @doc false
  def changeset(hough_transform, attrs) do
    # TODO костыль, пока нет логина и сессии
    attrs = ImageToBinaryConverter.with_files(attrs, @attachments_strings)

    hough_transform
    |> Map.update(:uuid, Ecto.UUID.generate(), fn val -> val || Ecto.UUID.generate() end)
    |> cast(attrs, @required ++ @optional)
    |> cast_attachments(attrs, @attachments_atoms)
    |> validate_required(@required)
  end

  def defaults, do: @defaults
end
