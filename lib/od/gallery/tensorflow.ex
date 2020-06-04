defmodule Od.Gallery.Tensorflow do
  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset
  alias Od.Gallery
  alias Od.Helpers.ImageToBinaryConverter
  @required ~w(result image_id)a
  @optional ~w(wanted_objects)a
  @attachments_atoms ~w(result)a
  @attachments_strings ~w(result)

  @defaults %{
    wanted_objects: "car airplane bicycle motorcycle train bus truck boat laptop mouse"
  }

  schema "tensorflows" do
    field :result, Od.Image.Type
    field :wanted_objects, :string, default: @defaults.wanted_objects
    field :uuid, :string

    belongs_to :image, Gallery.Image, on_replace: :delete
  end

  @doc false
  def changeset(tensorflow, attrs) do
    # TODO костыль, пока нет логина и сессии
    attrs = ImageToBinaryConverter.with_files(attrs, @attachments_strings)

    tensorflow
    |> Map.update(:uuid, Ecto.UUID.generate(), fn val -> val || Ecto.UUID.generate() end)
    |> cast(attrs, @required ++ @optional)
    |> cast_attachments(attrs, @attachments_atoms)
    |> validate_required(@required)
  end

  def defaults, do: @defaults
end
