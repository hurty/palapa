defmodule Palapa.Attachments do
  use Palapa.Context

  alias Palapa.Attachments.{
    Attachment,
    AttachmentUploader,
    AttachmentParser
  }

  import EctoEnum

  defenum(AttachableTypeEnum, :attachable_type, [
    :personal_information,
    :message,
    :message_comment,
    :page,
    :document_suggestion,
    :document_suggestion_comment,
    :contact_comment,
    :document
  ])

  # --- Scopes

  def where_organization(queryable \\ Attachment, %Organization{} = organization) do
    queryable
    |> where(organization_id: ^organization.id)
  end

  def where_ids(queryable \\ Attachment, ids) when is_list(ids) do
    queryable
    |> where([t], t.id in ^ids)
  end

  def orphan(queryable \\ Attachment) do
    queryable
    |> where([a], is_nil(a.message_id))
    |> where([a], is_nil(a.message_comment_id))
    |> where([a], is_nil(a.personal_information_id))
  end

  # --- Actions

  def get(queryable \\ Attachment, id) do
    queryable
    |> Repo.get(id)
  end

  def get!(queryable \\ Attachment, id) do
    queryable
    |> Repo.get!(id)
  end

  def list(queryable \\ Attachment) do
    queryable
    |> Repo.all()
  end

  def create(
        %Plug.Upload{} = file,
        %Member{} = creator
      ) do
    attrs = build_attachment_attrs(file)

    creator = Repo.preload(creator, :organization)

    {:ok, attachment} =
      %Attachment{}
      |> Attachment.changeset(attrs)
      |> put_assoc(:organization, creator.organization)
      |> put_assoc(:creator, creator)
      |> Repo.insert()

    case AttachmentUploader.store({file, attachment}) do
      {:ok, _filename} ->
        {:ok, attachment}

      error ->
        error
    end
  end

  defp build_attachment_attrs(file) do
    file_stats = File.stat!(file.path)
    IO.inspect(file, label: "file stats")

    checksum = Palapa.Access.file_checksum(file.path)

    %{
      filename: file.filename,
      content_type: file.content_type,
      byte_size: file_stats.size,
      checksum: checksum
    }
  end

  def delete!(%Attachment{} = attachment) do
    Attachment.changeset(attachment, %{})
    |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update!()
  end

  def get_attachable(%Attachment{} = attachment) do
    attachable_type = attachment.attachable_type

    if attachable_type do
      Repo.get_assoc(attachment, attachable_type)
    else
      nil
    end
  end

  def url(%Attachment{} = attachment, version \\ :original, content_disposition \\ "inline") do
    content_disposition =
      "&response-content-disposition=#{content_disposition};filename=#{attachment.filename}"

    AttachmentUploader.url({attachment.filename, attachment}, version, signed: true) <>
      content_disposition
  end

  def put_attachments(%Ecto.Changeset{} = changeset) do
    content = get_field(changeset, :content)
    attachments = find_attachments_in_content(content)

    changeset
    |> put_assoc(:attachments, attachments)
  end

  def list_attachments_from_signed_ids(signed_ids) when is_list(signed_ids) do
    attachments_ids =
      signed_ids
      |> Enum.map(fn sid ->
        case Palapa.Access.verify_signed_id(sid) do
          {:ok, id} -> id
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    list_attachments_by_ids(attachments_ids)
  end

  def list_attachments_by_ids(ids) do
    Attachment
    |> where([q], q.id in ^ids)
    |> Repo.all()
  end

  def delete_orphans() do
    orphan()
    |> Repo.delete_all()
  end

  def image?(attachment) do
    String.starts_with?(attachment.content_type, "image")
  end

  def storage_used(organization) do
    bytes =
      Attachment
      |> where_organization(organization)
      |> where([a], is_nil(a.deleted_at))
      |> select([a], sum(a.byte_size))
      |> Repo.one()

    bytes || 0
  end

  # in GB
  def storage_capacity(_organization) do
    100
  end

  defp find_attachments_in_content(content) do
    signed_ids = AttachmentParser.extract_attachments_signed_ids(content)
    list_attachments_from_signed_ids(signed_ids)
  end
end
