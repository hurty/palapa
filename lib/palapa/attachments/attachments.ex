defmodule Palapa.Attachments do
  use Palapa.Context

  alias Palapa.Attachments.{
    Attachment,
    AttachmentUploader,
    AttachmentImageUploader,
    AttachmentParser
  }

  # --- Authorizations

  defdelegate(authorize(action, user, params), to: Palapa.Attachments.Policy)

  # --- Scopes

  def visible_to(queryable \\ Attachment, %Member{} = member) do
    queryable
    |> where(organization_id: ^member.organization_id)
  end

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
    |> where([a], is_nil(a.member_information_id))
  end

  # --- Actions

  def get!(queryable \\ Attachment, id) do
    queryable
    |> Repo.get!(id)
  end

  def list(queryable \\ Attachment) do
    queryable
    |> Repo.all()
  end

  def create(%Organizations.Organization{} = organization, %Plug.Upload{} = file) do
    file_stats = File.stat!(file.path)

    attrs = %{
      filename: file.filename,
      content_type: file.content_type,
      byte_size: file_stats.size
    }

    {:ok, attachment} =
      %Attachment{}
      |> Attachment.changeset(attrs)
      |> put_change(:organization_id, organization.id)
      |> Repo.insert()

    # We have 2 different uploaders because Arc doesn't support skipping versions
    # if the file is not an image

    if image?(attachment) do
      case AttachmentImageUploader.store({file, attachment}) do
        {:ok, _filename} ->
          {:ok, attachment}

        _ ->
          {:error}
      end
    else
      case AttachmentUploader.store({file, attachment}) do
        {:ok, _filename} ->
          {:ok, attachment}

        _ ->
          {:error}
      end
    end
  end

  def delete!(%Attachment{} = attachment) do
    Attachment.changeset(attachment, %{})
    |> put_change(:deleted_at, DateTime.utc_now())
    |> Repo.update!()
  end

  def get_attachable(%Attachment{} = attachment) do
    cond do
      attachment.message_id ->
        Repo.preload(attachment, :message).message

      attachment.message_comment_id ->
        Repo.preload(attachment, :message_comment).message_comment

      attachment.member_information_id ->
        Repo.preload(attachment, :member_information).member_information

      true ->
        nil
    end
  end

  # the 'version' can be :original or :thumb
  def url(%Attachment{} = attachment, version \\ :original) do
    if image?(attachment) do
      AttachmentImageUploader.url({attachment.filename, attachment}, version, signed: true)
    else
      if version == :original do
        AttachmentUploader.url({attachment.filename, attachment}, :original, signed: true)
      else
        nil
      end
    end
  end

  def put_attachments(%Ecto.Changeset{} = changeset) do
    content = get_field(changeset, :content)
    organization = get_field(changeset, :organization)
    attachments = find_attachments_in_content(content, organization)

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

    Attachment
    |> Palapa.Access.scope_by_ids(attachments_ids)
    |> Repo.all()
  end

  def delete_orphans() do
    orphan()
    |> Repo.delete_all()
  end

  def image?(attachment) do
    image_types = [
      "image/gif",
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/tiff",
      "image/bmp",
      "image/x-bmp",
      "image/webp"
    ]

    Enum.member?(image_types, attachment.content_type)
  end

  defp find_attachments_in_content(text, organization) do
    ids = AttachmentParser.extract_attachments_ids(text)

    where_organization(organization)
    |> where_ids(ids)
    |> list
  end
end
