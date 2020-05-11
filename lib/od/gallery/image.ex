defmodule Od.Gallery.Image do
  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset
  alias Od.Gallery
  alias Od.Gallery.Python
  alias Od.Helpers.ImageToBinaryConverter
  @required ~w(image)a
  @optional ~w(uuid)a
  @attachments_atoms ~w(image haar_image hough_image tensorflow_image)a
  @attachments_strings ~w(image haar_image hough_image tensorflow_image)
  schema "images" do
    field :haar_image, Od.Image.Type
    field :hough_image, Od.Image.Type
    field :image, Od.Image.Type
    field :tensorflow_image, Od.Image.Type
    field :uuid, :string
    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    # TODO костыль, пока нет логина и сессии
    attrs = ImageToBinaryConverter.with_files(attrs, @attachments_strings)

    image
    |> Map.update(:uuid, Ecto.UUID.generate(), fn val -> val || Ecto.UUID.generate() end)
    |> cast(attrs, @required ++ @optional)
    |> cast_attachments(attrs, @attachments_atoms)
    |> validate_required(@required)
  end

  def run_all_algorithms(image) do
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    Task.start(fn ->
      run_hough(image, cwd, filename, %{
        canny_lower: 150,
        canny_upper: 150,
        hough_line_length: 15,
        hough_line_treshold: 20,
        blur_strength: 9,
        hough_line_gap: 5,
        hough_circle_min_dist: 50,
        hough_circle_min_radius: 10,
        hough_circle_max_radius: 50,
        hough_circle_param1: 500,
        hough_circle_param2: 20,
        hough_mode: "lines"
      })
    end)

    Task.start(fn -> run_haar(image, cwd, filename) end)
    Task.start(fn -> run_tensorflow(image, cwd, filename) end)
  end

  def run_hough_algorithm(image, param) do
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    run_hough(image, cwd, filename, param)
  end

  def run_haar_algorithm(image) do
    %{filename: filename, cwd: cwd} = get_filename_and_cwd(image)

    run_haar(image, cwd, filename)
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

  def run_haar(_image, _cwd, nil), do: nil

  def run_haar(image, cwd, filename) do
    haar_image_path = Python.run_haar(cwd <> filename)
    filename = haar_image_path |> String.split("/") |> List.last()

    image
    |> Gallery.update_image(%{
      "haar_image" => %Plug.Upload{filename: filename, path: Path.expand(haar_image_path)}
    })
    |> delete_python_image(haar_image_path)
  end

  def run_hough(_image, _cwd, nil, _), do: nil

  def run_hough(image, cwd, filename, param) do
    hough_image_path = Python.run_hough(cwd <> filename, param)
    filename = hough_image_path |> String.split("/") |> List.last()

    image
    |> Gallery.update_image(%{
      "hough_image" => %Plug.Upload{filename: filename, path: Path.expand(hough_image_path)}
    })
    |> delete_python_image(hough_image_path)
  end

  defp delete_python_image({:ok, _}, image_path) do
    File.rm!(image_path)
  end

  defp delete_python_image(_, _), do: nil

  defp get_filename_and_cwd(image) do
    storage_dir = Od.Image.storage_dir(:original, {image.image, image})

    filename =
      Enum.find(
        File.ls!(storage_dir <> "/"),
        &(&1 =~ Od.Image.filename(:original, {image.image, image}))
      )

    cwd = File.cwd!() <> "/" <> storage_dir

    %{filename: filename, cwd: cwd}
  end
end
