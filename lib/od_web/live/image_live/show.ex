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
     |> assign(:image, image)}
  end

  @impl true
  def handle_event("inc_hough_line_gap", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    line_gap = hough_transform.line_gap

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, line_gap: line_gap + 2}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_line_gap", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    line_gap = hough_transform.line_gap

    new_line_gap =
      if line_gap == 1 do
        1
      else
        line_gap - 2
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, line_gap: new_line_gap}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("inc_hough_line_treshold", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    line_treshold = hough_transform.line_treshold

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, line_treshold: line_treshold + 2}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_line_treshold", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    line_treshold = hough_transform.line_treshold

    new_line_treshold =
      if line_treshold == 0 do
        0
      else
        line_treshold - 2
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, line_treshold: new_line_treshold}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("inc_hough_line_length", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    line_length = hough_transform.line_length

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, line_length: line_length + 2}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_line_length", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    line_length = hough_transform.line_length

    new_line_length =
      if line_length == 1 do
        1
      else
        line_length - 2
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, line_length: new_line_length}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("inc_hough_blur_strength", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    blur_strength = hough_transform.blur_strength

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, blur_strength: blur_strength + 2}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_blur_strength", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    blur_strength = hough_transform.blur_strength

    new_blur_strength =
      if blur_strength == 1 do
        1
      else
        blur_strength - 2
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, blur_strength: new_blur_strength}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_canny_upper", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    canny_upper = hough_transform.canny_upper

    new_canny_upper =
      if canny_upper == 255 do
        255
      else
        canny_upper + 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, canny_upper: new_canny_upper}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_canny_upper", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    canny_upper = hough_transform.canny_upper

    new_canny_upper =
      if canny_upper == 10 do
        10
      else
        canny_upper - 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, canny_upper: new_canny_upper}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_canny_lower", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    canny_lower = hough_transform.canny_lower

    new_canny_lower =
      if canny_lower == 255 do
        255
      else
        canny_lower + 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, canny_lower: new_canny_lower}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_canny_lower", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    canny_lower = hough_transform.canny_lower

    new_canny_lower =
      if canny_lower == 10 do
        10
      else
        canny_lower - 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, canny_lower: new_canny_lower}
    })

    {:noreply, socket}
  end

  def handle_event("set_hough_mode_to_lines", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, mode: "lines"}
    })

    {:noreply, socket}
  end

  def handle_event("set_hough_mode_to_circles", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, mode: "circles"}
    })

    {:noreply, socket}
  end

  def handle_event("set_hough_mode_to_lines_and_circles", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, mode: "lines_and_circles"}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_circle_min_dist", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_min_dist = hough_transform.circle_min_dist

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_min_dist: circle_min_dist + 5}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_circle_min_dist", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_min_dist = hough_transform.circle_min_dist

    new_circle_min_dist =
      if circle_min_dist == 0 do
        0
      else
        circle_min_dist - 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_min_dist: new_circle_min_dist}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_circle_min_radius", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_min_radius = hough_transform.circle_min_radius

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_min_radius: circle_min_radius + 5}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_circle_min_radius", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_min_radius = hough_transform.circle_min_radius

    new_circle_min_radius =
      if circle_min_radius == 0 do
        0
      else
        circle_min_radius - 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_min_radius: new_circle_min_radius}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_circle_max_radius", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_max_radius = hough_transform.circle_max_radius

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_max_radius: circle_max_radius + 5}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_circle_max_radius", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_max_radius = hough_transform.circle_max_radius

    new_circle_max_radius =
      if circle_max_radius == 0 do
        0
      else
        circle_max_radius - 5
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_max_radius: new_circle_max_radius}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_circle_param1", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_param1 = hough_transform.circle_param1

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_param1: circle_param1 + 10}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_circle_param1", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_param1 = hough_transform.circle_param1

    new_circle_param1 =
      if circle_param1 == 0 do
        0
      else
        circle_param1 - 10
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_param1: new_circle_param1}
    })

    {:noreply, socket}
  end

  def handle_event("inc_hough_circle_param2", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_param2 = hough_transform.circle_param2

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_param2: circle_param2 + 2}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("dec_hough_circle_param2", _, socket) do
    image = socket.assigns.image
    hough_transform = image.hough_transform
    circle_param2 = hough_transform.circle_param2

    new_circle_param2 =
      if circle_param2 == 0 do
        0
      else
        circle_param2 - 2
      end

    Gallery.update_image(image, %{
      hough_transform: %{id: hough_transform.id, circle_param2: new_circle_param2}
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("run_hough", _, socket) do
    hough_transform = socket.assigns.image.hough_transform

    Gallery.run_hough_algorithm(socket.assigns.image, %{
      blur_strength: hough_transform.blur_strength,
      canny_lower: hough_transform.canny_lower,
      canny_upper: hough_transform.canny_upper,
      line_length: hough_transform.line_length,
      line_treshold: hough_transform.line_treshold,
      line_gap: hough_transform.line_gap,
      circle_min_dist: hough_transform.circle_min_dist,
      circle_min_radius: hough_transform.circle_min_radius,
      circle_max_radius: hough_transform.circle_max_radius,
      circle_param1: hough_transform.circle_param1,
      circle_param2: hough_transform.circle_param2,
      mode: hough_transform.mode
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
