defmodule OdWeb.ImageLive.Index do
  use OdWeb, :live_view

  alias Od.Gallery
  alias Od.Gallery.Image

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Gallery.subscribe()
    {:ok, assign(socket, :images, fetch_images())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Image")
    |> assign(:image, %Image{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Images")
    |> assign(:image, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    image = Gallery.get_image!(id)
    {:ok, _} = Gallery.delete_image(image)

    {:noreply, assign(socket, :images, fetch_images())}
  end

  @impl true
  def handle_info({:image_created, image}, socket) do
    image = Gallery.get_image!(image.id)
    {:noreply, update(socket, :images, fn images -> [image | images] end)}
  end

  @impl true
  def handle_info({:image_deleted, image}, socket) do
    {:noreply,
     update(socket, :images, fn images -> Enum.reject(images, &(&1.id == image.id)) end)}
  end

  @impl true
  def handle_info({:image_updated, _image}, socket) do
    {:noreply, update(socket, :images, fn _ -> Gallery.list_images() end)}
  end

  defp fetch_images do
    Gallery.list_images()
  end
end
