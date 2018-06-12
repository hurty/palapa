defmodule Palapa.Attachments.AttachmentUploader do
  use Arc.Definition

  @versions [:original, :thumb]
  @transform_extensions ~w(.jpg .jpeg .gif .png)

  # We only generate thumbnails for image formats
  def transform(:thumb, {file, _scope}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    if(Enum.member?(@transform_extensions, file_extension)) do
      {:convert, "-strip -thumbnail 600x>"}
    else
      :noaction
    end
  end

  def filename(version, {_file, scope}) do
    "#{scope.id}_#{version}"
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
end
