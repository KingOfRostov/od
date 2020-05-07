defmodule Od.Helpers.ImageToBinaryConverter do
  @moduledoc """
  Converts image from base64 format to binary
  """

  alias Ecto.UUID

  def with_files(attrs, keys) do
    keys
    |> Enum.reduce(attrs, fn key, attrs_acc ->
      with_file(attrs_acc, key, attrs[key])
    end)
  end

  def with_file(attrs, _key, nil) do
    attrs
  end

  def with_file(attrs, key, "") do
    %{attrs | key => nil}
  end

  def with_file(attrs, key, attr) do
    attrs |> Map.put(key, generate_filename(attr))
  end

  def generate_filename(attrs) do
    filename = upload_file(attrs)
    file_extension = filename |> Path.extname() |> String.downcase()
    uniq_filename = "image_" <> UUID.generate() <> file_extension
    %{attrs | filename: uniq_filename}
  end

  defp upload_file(%Plug.Upload{filename: filename}), do: filename

  def with_binary_documents(attrs, keys) do
    keys
    |> Enum.reduce(attrs, fn key, attrs_acc ->
      with_binary_document(attrs_acc, key, attrs[key])
    end)
  end

  def with_binary_document(attrs, _key, nil) do
    attrs
  end

  def with_binary_document(attrs, key, attr) do
    attrs |> Map.put(key, convert_to_binary(attr))
  end

  def convert_to_binary(image_base64) do
    # Decode the image
    {start, length} = :binary.match(image_base64, ";base64,")

    base64_string =
      :binary.part(image_base64, start + length, byte_size(image_base64) - start - length)

    {:ok, image_binary} = Base.decode64(base64_string)

    # Generate a unique filename
    filename =
      image_binary
      |> image_extension()
      |> unique_filename()

    %{filename: filename, binary: image_binary}
  end

  # NOTE: Generates a unique filename with a given extension
  defp unique_filename(extension) do
    "image_" <> UUID.generate() <> extension
  end

  # NOTE: Helper functions to read the binary to determine the image extension
  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>), do: ".png"
  defp image_extension(<<0xFF, 0xD8, _::binary>>), do: ".jpg"
  defp image_extension(_), do: ".error"
end
