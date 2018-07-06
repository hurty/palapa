defmodule Palapa.Attachments do
  use Palapa.Context
  alias Palapa.Attachments.{Attachment, AttachmentUploader, AttachmentParser}

  # --- Authorizations

  defdelegate(authorize(action, user, params), to: Palapa.Attachments.Policy)

  # --- Scopes

  def visible_to(queryable \\ Attachment, %Member{} = member) do
    queryable
    |> where_organization(member.organization)
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
    {:ok, attachment} =
      %Attachment{}
      |> Attachment.changeset(Map.take(file, [:filename, :content_type]))
      |> put_change(:organization_id, organization.id)
      |> Repo.insert()

    case AttachmentUploader.store({file, attachment}) do
      {:ok, _filename} ->
        {:ok, attachment}

      _ ->
        {:error}
    end
  end

  def delete!(%Attachment{} = attachment) do
    Attachment.changeset(attachment, %{})
    |> put_change(:deleted_at, DateTime.utc_now())
    |> Repo.update!()
  end

  # the 'version' can be :original or :thumb
  def url(%Attachment{} = attachment, version \\ :original) do
    AttachmentUploader.url({attachment.filename, attachment}, version)
  end

  def put_attachments(%Ecto.Changeset{} = changeset) do
    content = get_field(changeset, :content)
    organization = get_field(changeset, :organization)
    attachments = find_attachments_in_content(content, organization)
    IO.inspect(attachments)

    changeset
    |> put_assoc(:attachments, attachments)
  end

  def delete_orphans() do
    orphan()
    |> Repo.delete_all()
  end

  defp find_attachments_in_content(text, organization) do
    ids = AttachmentParser.extract_attachments_ids(text)

    where_organization(organization)
    |> where_ids(ids)
    |> list
  end
end
