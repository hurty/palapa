defmodule Palapa.Contacts do
  use Palapa.Context

  alias Palapa.Contacts.{Contact, ContactComment}
  alias Palapa.Events.Event

  def contacts_visible_to(member) do
    Contact
    |> where(organization_id: ^member.organization_id)
  end

  def list_contacts(organization, search_pattern \\ nil)

  def list_contacts(organization, search_pattern) when is_nil(search_pattern) do
    Contact
    |> where(organization_id: ^organization.id)
    |> preload(:company)
    |> order_by(:last_name)
    |> Repo.all()
  end

  def list_contacts(organization, search_pattern) when is_binary(search_pattern) do
    escaped_pattern = "%" <> Repo.escape_like_pattern(search_pattern) <> "%"

    Contact
    |> where([c], ilike(c.first_name, ^escaped_pattern))
    |> or_where([c], ilike(c.last_name, ^escaped_pattern))
    |> where(organization_id: ^organization.id)
    |> preload(:company)
    |> order_by(:last_name)
    |> Repo.all()
  end

  def get_contact!(queryable \\ Contact, id) do
    queryable
    |> preload(:company)
    |> preload(:comments)
    |> Repo.get!(id)
  end

  def create_contact(organization, attrs \\ %{}, author) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:contact, fn _ ->
      %Contact{}
      |> Contact.changeset(attrs)
      |> put_assoc(:organization, organization)
    end)
    |> Ecto.Multi.insert(:event, fn %{contact: contact} ->
      %Event{
        action: :new_contact,
        organization_id: author.organization_id,
        author: author,
        contact: contact
      }
    end)
    |> Repo.transaction()
  end

  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end

  def get_contact_comment!(id) do
    ContactComment
    |> preload([:creator, :attachments])
    |> Repo.get!(id)
  end

  def list_contact_comments(%Contact{} = contact) do
    Ecto.assoc(contact, :comments)
    |> order_by([c], desc: c.inserted_at)
    |> preload(creator: [:account])
    |> Repo.all()
  end

  def create_contact_comment(%Contact{} = contact, %Member{} = creator, attrs) do
    ContactComment.changeset(%ContactComment{}, attrs)
    |> put_change(:organization_id, contact.organization_id)
    |> put_assoc(:contact, contact)
    |> put_assoc(:creator, creator)
    |> Repo.insert()
  end

  def change_contact_comment(%ContactComment{} = contact_comment) do
    ContactComment.changeset(contact_comment, %{})
  end

  def update_contact_comment!(%ContactComment{} = contact_comment, attrs) do
    contact_comment
    |> ContactComment.changeset(attrs)
    |> Repo.update!()
  end

  def delete_contact_comment(%ContactComment{} = contact_comment) do
    contact_comment
    |> Repo.delete()
  end
end
