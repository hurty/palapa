defmodule Palapa.Attachments.AttachmentUploader do
  use Waffle.Definition

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
  def s3_object_headers(_version, {file, _scope}) do
    [timeout: 3_000_000, content_type: MIME.from_path(file.file_name)]
  end
end
