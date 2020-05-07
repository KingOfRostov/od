defmodule OdWeb.Gallery.ImageController do
  use OdWeb, :controller
  alias Od.Gallery

  def create(conn, %{"image" => image}) do
    case Gallery.create_image(image) do
      {:ok, image} ->
        Gallery.run_all_algorithms(image)

        conn
        |> put_flash(:info, "Image updated successfully")
        |> redirect(to: Routes.image_index_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Invalid image type, supporting only .jpg .jpeg .png")
        |> redirect(to: Routes.image_index_path(conn, :new), socket: %{changeset: changeset})
    end
  end

  def create(conn, _) do
    conn
    |> put_flash(:error, "Choose image")
    |> redirect(to: Routes.image_index_path(conn, :new))
  end
end
