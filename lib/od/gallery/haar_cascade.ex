defmodule Od.Gallery.HaarCascade do
  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset
  alias Od.Gallery
  alias Od.Helpers.ImageToBinaryConverter
  @required ~w(result image_id)a
  @optional ~w(uuid scale_factor min_neighbors object_type)a
  @attachments_atoms ~w(result)a
  @attachments_strings ~w(result)

  @defaults %{
    scale_factor: 1.05,
    min_neighbors: 1,
    object_type: "cars"
  }

  schema "haar_cascades" do
    field :result, Od.Image.Type
    field :scale_factor, :float, default: @defaults.scale_factor
    field :min_neighbors, :integer, default: @defaults.min_neighbors
    field :object_type, :string, default: @defaults.object_type
    field :uuid, :string

    belongs_to :image, Gallery.Image, on_replace: :delete
  end

  @doc false
  def changeset(haar_cascade, attrs) do
    # TODO костыль, пока нет логина и сессии
    attrs = ImageToBinaryConverter.with_files(attrs, @attachments_strings)

    haar_cascade
    |> Map.update(:uuid, Ecto.UUID.generate(), fn val -> val || Ecto.UUID.generate() end)
    |> cast(attrs, @required ++ @optional)
    |> cast_attachments(attrs, @attachments_atoms)
    |> validate_required(@required)
  end

  def defaults, do: @defaults
end
