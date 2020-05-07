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
    image = Gallery.get_image!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, image)
     |> assign(:blur_strength, 1)
     |> assign(:canny_lower, 150)
     |> assign(:canny_upper, 150)
     |> assign(:hough_line_length, 15)
     |> assign(:hough_line_treshold, 20)
     |> assign(:hough_line_gap, 5)}
  end

  @impl true
  def handle_event("inc_hough_line_gap", _, socket) do
    hough_line_gap = socket.assigns.hough_line_gap
    {:noreply, assign(socket, :hough_line_gap, hough_line_gap + 2)}
  end

  @impl true
  def handle_event("dec_hough_line_gap", _, socket) do
    hough_line_gap = socket.assigns.hough_line_gap

    new_hough_line_gap =
      if hough_line_gap == 1 do
        1
      else
        hough_line_gap - 2
      end

    {:noreply, assign(socket, :hough_line_gap, new_hough_line_gap)}
  end

  @impl true
  def handle_event("inc_hough_line_treshold", _, socket) do
    hough_line_treshold = socket.assigns.hough_line_treshold
    {:noreply, assign(socket, :hough_line_treshold, hough_line_treshold + 2)}
  end

  @impl true
  def handle_event("dec_hough_line_treshold", _, socket) do
    hough_line_treshold = socket.assigns.hough_line_treshold

    new_hough_line_treshold =
      if hough_line_treshold == 0 do
        0
      else
        hough_line_treshold - 2
      end

    {:noreply, assign(socket, :hough_line_treshold, new_hough_line_treshold)}
  end

  @impl true
  def handle_event("inc_hough_line_length", _, socket) do
    hough_line_length = socket.assigns.hough_line_length
    {:noreply, assign(socket, :hough_line_length, hough_line_length + 2)}
  end

  @impl true
  def handle_event("dec_hough_line_length", _, socket) do
    hough_line_length = socket.assigns.hough_line_length

    new_hough_line_length =
      if hough_line_length == 1 do
        1
      else
        hough_line_length - 2
      end

    {:noreply, assign(socket, :hough_line_length, new_hough_line_length)}
  end

  @impl true
  def handle_event("inc_blur_strength", _, socket) do
    blur_strength = socket.assigns.blur_strength
    {:noreply, assign(socket, :blur_strength, blur_strength + 2)}
  end

  @impl true
  def handle_event("dec_blur_strength", _, socket) do
    blur_strength = socket.assigns.blur_strength

    new_blur_strength =
      if blur_strength == 1 do
        1
      else
        blur_strength - 2
      end

    {:noreply, assign(socket, :blur_strength, new_blur_strength)}
  end

  def handle_event("inc_canny_upper", _, socket) do
    canny_upper = socket.assigns.canny_upper

    new_canny_upper =
      if canny_upper == 255 do
        255
      else
        canny_upper + 5
      end

    {:noreply, assign(socket, :canny_upper, new_canny_upper)}
  end

  @impl true
  def handle_event("dec_canny_upper", _, socket) do
    canny_upper = socket.assigns.canny_upper

    new_canny_upper =
      if canny_upper == 10 do
        10
      else
        canny_upper - 5
      end

    {:noreply, assign(socket, :canny_upper, new_canny_upper)}
  end

  def handle_event("inc_canny_lower", _, socket) do
    canny_lower = socket.assigns.canny_lower

    new_canny_lower =
      if canny_lower == 255 do
        255
      else
        canny_lower + 5
      end

    {:noreply, assign(socket, :canny_lower, new_canny_lower)}
  end

  @impl true
  def handle_event("dec_canny_lower", _, socket) do
    canny_lower = socket.assigns.canny_lower

    new_canny_lower =
      if canny_lower == 10 do
        10
      else
        canny_lower - 5
      end

    {:noreply, assign(socket, :canny_lower, new_canny_lower)}
  end

  @impl true
  def handle_event("run_hough", _, socket) do
    Gallery.run_hough_algorithm(socket.assigns.image, %{
      blur_strength: socket.assigns.blur_strength,
      canny_lower: socket.assigns.canny_lower,
      canny_upper: socket.assigns.canny_upper,
      hough_line_length: socket.assigns.hough_line_length,
      hough_line_treshold: socket.assigns.hough_line_treshold,
      hough_line_gap: socket.assigns.hough_line_gap
    })

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

  @impl true
  def handle_info({:image_deleted, image}, socket) do
    {:noreply, update(socket, :image, fn _ -> image end)}
  end

  @impl true
  def handle_info({:image_created, image}, socket) do
    {:noreply, update(socket, :image, fn _ -> image end)}
  end

  defp page_title(:show), do: "Show Image"
end
