defmodule Palapa.Contacts do
  use Palapa.Context

  alias Palapa.Contacts.Contact
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
end
