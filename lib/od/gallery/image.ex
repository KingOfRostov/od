defmodule Od.Gallery.Image do
  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset
  alias Od.Gallery
  alias Od.Gallery.Python
  alias Od.Helpers.ImageToBinaryConverter
  alias Od.Repo
  @preload_list ~w(hough_transform haar_cascade)a
  @required ~w(image)a
  @optional ~w(uuid)a
  @attachments_atoms ~w(image tensorflow_image)a
  @attachments_strings ~w(image tensorflow_image)
  schema "images" do
    has_one :hough_transform, Gallery.HoughTransform, on_replace: :delete, on_delete: :delete_all
    has_one :haar_cascade, Gallery.HaarCascade, on_replace: :delete, on_delete: :delete_all
    field :image, Od.Image.Type
    field :tensorflow_image, Od.Image.Type
    field :uuid, :string
    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    attrs = ImageToBinaryConverter.with_files(attrs, @attachments_strings)

    image
    |> Map.update(:uuid, Ecto.UUID.generate(), fn val -> val || Ecto.UUID.generate() end)
    |> cast(attrs, @required ++ @optional)
    |> cast_attachments(attrs, @attachments_atoms)
    |> cast_assoc(:hough_transform)
    |> cast_assoc(:haar_cascade)
    |> validate_required(@required)
  end

  def run_all_algorithms(image) do
    image = Repo.preload(image, preload_list())
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    Task.start(fn ->
      hough_defaults = Gallery.HoughTransform.defaults()

      run_hough(image, cwd, filename, %{
        blur_strength: hough_defaults.blur_strength,
        canny_lower: hough_defaults.canny_lower,
        canny_upper: hough_defaults.canny_upper,
        hough_line_color: hough_defaults.hough_line_color,
        line_length: hough_defaults.line_length,
        line_treshold: hough_defaults.line_treshold,
        line_gap: hough_defaults.line_gap,
        circle_min_dist: hough_defaults.circle_min_dist,
        circle_min_radius: hough_defaults.circle_min_radius,
        circle_max_radius: hough_defaults.circle_max_radius,
        circle_param1: hough_defaults.circle_param1,
        circle_param2: hough_defaults.circle_param2,
        mode: hough_defaults.mode
      })
    end)

    Task.start(fn ->
      haar_defaults = Gallery.HaarCascade.defaults()

      run_haar(image, cwd, filename, %{
        scale_factor: haar_defaults.scale_factor,
        min_neighbors: haar_defaults.min_neighbors,
        object_type: haar_defaults.object_type
      })
    end)

    # Task.start(fn -> run_tensorflow(image, cwd, filename) end)
  end

  def run_hough_algorithm(image, params) do
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    run_hough(image, cwd, filename, params)
  end

  def run_haar_algorithm(image, params) do
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    run_haar(image, cwd, filename, params)
  end

  def run_tensorflow_algorithm(image) do
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    run_tensorflow(image, cwd, filename)
  end

  def run_tensorflow(_image, _cwd, nil), do: nil

  def run_tensorflow(image, cwd, filename) do
    tensorflow_image_path = Python.run_tensorflow(cwd <> filename)
    filename = tensorflow_image_path |> String.split("/") |> List.last()

    image
    |> Gallery.update_image(%{
      "tensorflow_image" => %Plug.Upload{
        filename: filename,
        path: Path.expand(tensorflow_image_path)
      }
    })
    |> delete_python_image(tensorflow_image_path)
  end

  def run_haar(_image, _cwd, nil, _), do: nil

  def run_haar(image, cwd, filename, params) do
    haar_image_path = Python.run_haar(cwd <> filename, params)
    filename = haar_image_path |> String.split("/") |> List.last()

    update_params = %{
      haar_cascade:
        Map.merge(params, %{
          result: %Plug.Upload{
            filename: filename,
            path: Path.expand(haar_image_path)
          },
          image_id: image.id
        })
    }

    image
    |> Repo.preload(preload_list())
    |> Gallery.update_image(update_params)
    |> delete_python_image(haar_image_path)
  end

  def run_hough(_image, _cwd, nil, _), do: nil

  def run_hough(image, cwd, filename, params) do
    hough_transform_path = Python.run_hough(cwd <> filename, params)
    filename = hough_transform_path |> String.split("/") |> List.last()

    update_params = %{
      hough_transform:
        Map.merge(params, %{
          result: %Plug.Upload{
            filename: filename,
            path: Path.expand(hough_transform_path)
          },
          image_id: image.id
        })
    }

    image
    |> Repo.preload(preload_list())
    |> Gallery.update_image(update_params)
    |> delete_python_image(hough_transform_path)
  end

  def preload_list, do: @preload_list

  defp delete_python_image({:ok, _}, image_path) do
    File.rm!(image_path)
  end

  defp delete_python_image(_, _), do: nil

  defp get_filename_and_cwd(image) do
    storage_dir = Od.Image.storage_dir(:original, {image.image, image})

    filename =
      Enum.find(
        File.ls!(storage_dir <> "/"),
        &(String.replace(&1, ~r/(.jpg$)?(.jpeg$)?(.png$)?/, "") ==
            Od.Image.filename(:original, {image.image, image}))
      )

    cwd = File.cwd!() <> "/" <> storage_dir

    %{filename: filename, cwd: cwd}
  end
end
