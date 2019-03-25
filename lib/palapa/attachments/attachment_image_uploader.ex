defmodule Palapa.Attachments.AttachmentImageUploader do
  use Arc.Definition

  @versions [:original, :gallery, :thumb]
  @transform_extensions ~w(.jpg .jpeg .gif .png)

  # We only generate thumbnails for image formats
  def transform(:gallery, {file, _scope}) do
    if transformable_image?(file) do
      {:convert, "-strip -thumbnail 1000x>"}
    else
      :noaction
    end
  end

  def transform(:thumb, {file, _scope}) do
    if transformable_image?(file) do
      {:convert, "-strip -thumbnail 600x>"}
    else
      :noaction
    end
  end

  def filename(version, {_file, scope}) do
    "#{scope.id}/#{scope.id}_#{version}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/organizations/#{scope.organization_id}/attachments/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end

  defp transformable_image?(file) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@transform_extensions, file_extension)
  end
end
