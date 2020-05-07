defmodule OdWeb.ImageLive.Show do
  use OdWeb, :live_view

  alias Od.Gallery

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Gallery.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, Gallery.get_image!(id))}
  end

  @impl true
  def handle_event("run_hough", _, socket) do
    Gallery.run_hough_algorithm(socket.assigns.image)
    {:noreply, socket}
  end

  @impl true
  def handle_event("run_haar", _, socket) do
    Gallery.run_haar_algorithm(socket.assigns.image)
    {:noreply, socket}
  end

  @impl true
  def handle_event("run_tensorflow", _, socket) do
    Gallery.run_tensorflow_algorithm(socket.assigns.image)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:image_updated, image}, socket) do
    {:noreply, update(socket, :image, fn _ -> image end)}
  end

  defp page_title(:show), do: "Show Image"
end
