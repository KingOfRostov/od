defmodule Od.GalleryTest do
  use Od.DataCase

  alias Od.Gallery

  describe "images" do
    alias Od.Gallery.Image

    @valid_attrs %{
      haar_image: "some haar_image",
      hough_transform: "some hough_transform",
      image: "some image",
      tensorflow_image: "some tensorflow_image",
      uuid: "some uuid"
    }
    @update_attrs %{
      haar_image: "some updated haar_image",
      hough_transform: "some updated hough_transform",
      image: "some updated image",
      tensorflow_image: "some updated tensorflow_image",
      uuid: "some updated uuid"
    }
    @invalid_attrs %{
      haar_image: nil,
      hough_transform: nil,
      image: nil,
      tensorflow_image: nil,
      uuid: nil
    }

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Gallery.create_image()

      image
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Gallery.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Gallery.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Gallery.create_image(@valid_attrs)
      assert image.haar_image == "some haar_image"
      assert image.hough_transform == "some hough_transform"
      assert image.image == "some image"
      assert image.tensorflow_image == "some tensorflow_image"
      assert image.uuid == "some uuid"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, %Image{} = image} = Gallery.update_image(image, @update_attrs)
      assert image.haar_image == "some updated haar_image"
      assert image.hough_transform == "some updated hough_transform"
      assert image.image == "some updated image"
      assert image.tensorflow_image == "some updated tensorflow_image"
      assert image.uuid == "some updated uuid"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Gallery.update_image(image, @invalid_attrs)
      assert image == Gallery.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Gallery.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Gallery.change_image(image)
    end
  end
end
