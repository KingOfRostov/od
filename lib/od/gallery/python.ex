defmodule Od.Gallery.Python do
  def run_hough(image_path) do
    new_image_path =
      cond do
        String.ends_with?(image_path, ".jpg") ->
          Regex.replace(~r(\.jpg$), image_path, "_hough.jpg")

        String.ends_with?(image_path, ".png") ->
          Regex.replace(~r(\.png$), image_path, "_hough.png")

        String.ends_with?(image_path, ".jpeg") ->
          Regex.replace(~r(\.jpeg$), image_path, "_hough.jpeg")
      end

    command = ~s(python3 object_detection_algorithms.py #{new_image_path} #{image_path} hough)

    command |> String.to_charlist() |> :os.cmd() |> to_string() |> String.trim()
  end

  def run_haar(image_path) do
    new_image_path =
      cond do
        String.ends_with?(image_path, ".jpg") ->
          Regex.replace(~r(\.jpg$), image_path, "_haar.jpg")

        String.ends_with?(image_path, ".png") ->
          Regex.replace(~r(\.png$), image_path, "_haar.png")

        String.ends_with?(image_path, ".jpeg") ->
          Regex.replace(~r(\.jpeg$), image_path, "_haar.jpeg")
      end

    command = ~s(python3 object_detection_algorithms.py cars #{new_image_path} #{image_path} haar)

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
      ~s(python3 object_detection_algorithms.py #{new_image_path} #{image_path} tensorflow)

    command
    |> String.to_charlist()
    |> :os.cmd()
    |> to_string()
    |> String.trim()
    |> String.split("\n")
    |> List.last()
  end
end
