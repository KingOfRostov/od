defmodule Od.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false
  alias Od.Repo

  alias Od.Gallery.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(from image in Image, order_by: {:desc, image.id}, preload: ^Image.preload_list())
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id) do
    Image |> Repo.get!(id) |> Repo.preload(Image.preload_list())
  end

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:image_created)
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
    |> broadcast(:image_updated)
  end

  @doc """
  Deletes a image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    delete_arc_image(image.image)
    delete_arc_image(image.tensorflow_image)
    delete_arc_inner_image(image.hough_transform)
    delete_arc_inner_image(image.haar_cascade)

    image
    |> Repo.delete()
    |> broadcast(:image_deleted)
  end

  defp delete_arc_image(nil), do: nil
  defp delete_arc_image(image), do: Od.Image.delete({image, image})

  defp delete_arc_inner_image(nil), do: nil
  defp delete_arc_inner_image(image), do: Od.Image.delete({image.result, image})

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{data: %Image{}}

  """
  def change_image(%Image{} = image, attrs \\ %{}) do
    Image.changeset(image, attrs)
  end

  def run_hough_algorithm(image, param) do
    Image.run_hough_algorithm(image, param)
  end

  def run_haar_algorithm(image, params) do
    Image.run_haar_algorithm(image, params)
  end

  def run_tensorflow_algorithm(image, params) do
    Image.run_tensorflow_algorithm(image, params)
  end

  def run_all_algorithms(image) do
    Task.start(fn -> Image.run_all_algorithms(image) end)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Od.PubSub, "gallery")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, image} = result, event) do
    Phoenix.PubSub.broadcast(Od.PubSub, "gallery", {event, image})
    result
  end
end
