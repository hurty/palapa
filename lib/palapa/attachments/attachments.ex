defmodule Palapa.Attachments do
  use Palapa.Context
  alias Palapa.Attachments.Attachment
  alias Palapa.Attachments.AttachmentUploader

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

  # --- Actions

  def get!(queryable \\ Attachment, id) do
    queryable
    |> Repo.get!(id)
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
end
