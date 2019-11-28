defmodule Palapa.Exporter.ExportUploader do
  use Waffle.Definition

  def filename(_, {_file, _organization}) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    "export_#{timestamp}.zip"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, organization}) do
    "exports/organizations/#{organization.id}/"
  end

  def gcs_object_headers(_version, {_file, _scope}) do
    # for "image.png", would produce: "image/png"
    [timeout: 3_000_000, content_type: "application/zip"]
  end
end
