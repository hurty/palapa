defmodule Palapa.Contacts do
  use Palapa.Context

  alias Palapa.Contacts.{Contact, ContactComment}
  alias Palapa.Events.Event

  def visible_to(member) do
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

  def count_all_contacts(organization) do
    Contact
    |> where(organization_id: ^organization.id)
    |> select([c], count(c.id))
    |> Repo.one()
  end

  def list_companies(organization) do
    Contact
    |> where(organization_id: ^organization.id)
    |> where(is_company: true)
    |> order_by(:last_name)
    |> Repo.all()
  end

  def get_contact!(queryable \\ Contact, id) do
    comments_query = ContactComment |> order_by(:inserted_at) |> preload(:attachments)

    queryable
    |> preload([:company, :comments, :employees])
    |> preload(comments: ^comments_query)
    |> Repo.get!(id)
  end

  def create_contact(organization, attrs, author) do
    # if a new associated company is created at the same time, we force it to be part of the same organization.
    attrs =
      if attrs["company"] do
        put_in(attrs, ["company", "organization_id"], organization.id)
      else
        attrs
      end

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

  def update_contact(contact, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:contact, Contact.changeset(contact, attrs))
    |> Repo.transaction()
  end

  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end

  def get_contact_comment!(id) do
    ContactComment
    |> preload([:author, :attachments])
    |> Repo.get!(id)
  end

  def list_contact_comments(%Contact{} = contact) do
    Ecto.assoc(contact, :comments)
    |> order_by([c], desc: c.inserted_at)
    |> preload(author: [:account])
    |> Repo.all()
  end

  def create_contact_comment(%Contact{} = contact, %Member{} = author, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:contact_comment, fn repo, _ ->
      ContactComment.changeset(%ContactComment{}, attrs)
      |> put_change(:organization_id, contact.organization_id)
      |> put_assoc(:contact, contact)
      |> put_assoc(:author, author)
      |> repo.insert()
    end)
    |> Ecto.Multi.insert(:event, fn %{contact_comment: contact_comment} ->
      %Event{
        action: :new_contact_comment,
        organization_id: author.organization_id,
        author: author,
        contact: contact,
        contact_comment: contact_comment
      }
    end)
    |> Repo.transaction()
  end

  def change_contact_comment(%ContactComment{} = contact_comment, attrs \\ %{}) do
    ContactComment.changeset(contact_comment, attrs)
  end

  def update_contact_comment(%ContactComment{} = contact_comment, attrs) do
    contact_comment
    |> ContactComment.changeset(attrs)
    |> Repo.update()
  end

  def delete_contact_comment(%ContactComment{} = contact_comment) do
    contact_comment
    |> Repo.delete()
  end
end
