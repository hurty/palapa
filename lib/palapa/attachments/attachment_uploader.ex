defmodule Palapa.Attachments.AttachmentUploader do
  use Waffle.Definition
  alias Palapa.Attachments

  @versions [:original, :gallery]

  def transform(:gallery, {_file, scope}) do
    if Attachments.image?(scope) do
      :noaction
    else
      :skip
    end
  end

  def filename(:original, {_file, scope}) do
    scope.id
  end

  def filename(:gallery, {_file, scope}) do
    "#{scope.id}_gallery"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/organizations/#{scope.organization_id}/attachments/#{scope.id}/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  def gcs_object_headers(_version, {file, _scope}) do
    # for "image.png", would produce: "image/png"
    [timeout: 3_000_000, content_type: MIME.from_path(file.file_name)]
  end

  # defp transformable_image?(file) do
  #   Enum.member?(@transform_extensions, file_extension(file))
  # end

  # defp file_extension(file) do
  #   file.file_name |> Path.extname() |> String.downcase()
  # end
end
