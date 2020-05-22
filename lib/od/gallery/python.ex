defmodule Od.Gallery.Python do
  def run_hough(image_path, %{
        canny_lower: canny_lower,
        canny_upper: canny_upper,
        blur_strength: blur_strength,
        hough_line_color: hough_line_color,
        line_length: line_length,
        line_treshold: line_treshold,
        line_gap: line_gap,
        circle_min_dist: circle_min_dist,
        circle_min_radius: circle_min_radius,
        circle_max_radius: circle_max_radius,
        circle_param1: circle_param1,
        circle_param2: circle_param2,
        mode: mode
      }) do
    new_image_path =
      cond do
        String.ends_with?(image_path, ".jpg") ->
          Regex.replace(~r(\.jpg$), image_path, "_hough.jpg")

        String.ends_with?(image_path, ".png") ->
          Regex.replace(~r(\.png$), image_path, "_hough.png")

        String.ends_with?(image_path, ".jpeg") ->
          Regex.replace(~r(\.jpeg$), image_path, "_hough.jpeg")
      end

    [hough_line_r, hough_line_g, hough_line_b] = String.split(hough_line_color, " ")

    command =
      ~s(python3 object_detection_algorithms.py --hough_line_color #{hough_line_r} #{hough_line_g} #{
        hough_line_b
      } #{hough_line_color} --hough_line_gap #{line_gap} --hough_line_treshold #{line_treshold} --hough_line_length #{
        line_length
      } --canny_upper #{canny_upper} --canny_lower #{canny_lower} --blur_strength #{blur_strength} --hough_circle_min_dist #{
        circle_min_dist
      } --hough_circle_param1 #{circle_param1} --hough_circle_param2 #{circle_param2} --hough_circle_min_radius #{
        circle_min_radius
      } --hough_circle_max_radius #{circle_max_radius} --new_image_path '#{new_image_path}' --image_path '#{
        image_path
      }' --hough_mode '#{mode}' --method 'hough')

    command |> String.to_charlist() |> :os.cmd() |> to_string() |> String.trim()
  end

  def run_haar(image_path, %{
        object_type: object_type,
        min_neighbors: min_neighbors,
        scale_factor: scale_factor
      }) do
    new_image_path =
      cond do
        String.ends_with?(image_path, ".jpg") ->
          Regex.replace(~r(\.jpg$), image_path, "_haar.jpg")

        String.ends_with?(image_path, ".png") ->
          Regex.replace(~r(\.png$), image_path, "_haar.png")

        String.ends_with?(image_path, ".jpeg") ->
          Regex.replace(~r(\.jpeg$), image_path, "_haar.jpeg")
      end

    # TODO change cars
    command =
      ~s(python3 object_detection_algorithms.py --object_type '#{object_type}' --min_neighbors #{
        min_neighbors
      } --scale_factor #{scale_factor} --new_image_path '#{new_image_path}' --image_path '#{
        image_path
      }' --method 'haar')

    command |> String.to_charlist() |> :os.cmd() |> to_string() |> String.trim()
  end

  def run_tensorflow(image_path) do
    new_image_path =
      cond do
        String.ends_with?(image_path, ".jpg") ->
          Regex.replace(~r(\.jpg$), image_path, "_tensorflow.jpg")

        String.ends_with?(image_path, ".png") ->
          Regex.replace(~r(\.png$), image_path, "_tensorflow.png")

        String.ends_with?(image_path, ".jpeg") ->
          Regex.replace(~r(\.jpeg$), image_path, "_tensorflow.jpeg")
      end

    command =
      ~s(python3 object_detection_algorithms.py --new_image_path '#{new_image_path}' --image_path '#{
        image_path
      }' --method 'tensorflow')

    command
    |> String.to_charlist()
    |> :os.cmd()
    |> to_string()
    |> String.trim()
    |> String.split("\n")
    |> List.last()
  end
end
