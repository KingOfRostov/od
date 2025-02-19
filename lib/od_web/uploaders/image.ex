defmodule Od.Image do
  use Arc.Definition
  use Arc.Ecto.Definition

  @extension_whitelist ~w(.jpg .jpeg .png)

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 150x150^ -gravity center -extent 150x150"}
  end

  def full_path(version, {file, scope}) do
    storage_dir(version, {file, scope}) <> filename(version, {file, scope})
  end

  # Override the persisted filenames:
  def filename(version, {file, _scope}) do
    "#{file.file_name}_#{version}"
  end

  # Override the storage directory:
  def storage_dir(version, {_file, _scope}) do
    "uploads/images/"
  end
end
