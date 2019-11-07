defmodule Palapa.ContactsTest do
  use Palapa.DataCase
  import Palapa.Factory
  alias Palapa.Contacts
  alias Palapa.Contacts.Contact

  describe "contacts" do
    @valid_attrs %{first_name: "Pierre", last_name: "Hurtevent", email: "pierre@palapa.io"}
    @update_attrs %{}
    @invalid_attrs %{email: "some_guy@isp.com"}

    def contact_fixture(attrs \\ %{}) do
      organization = insert!(:organization)
      member = insert!(:member, organization: organization)

      attrs =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, %{contact: contact}} = Contacts.create_contact(organization, attrs, member)

      contact
    end

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      organization = Repo.get_assoc(contact, :organization)
      list = Contacts.list_contacts(organization)
      assert List.first(list).id == contact.id
      assert length(list) == 1
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id).id == contact.id
    end

    test "create_contact/1 with valid data creates a contact" do
      organization = insert!(:organization)
      member = insert!(:member, organization: organization)

      assert {:ok, %{contact: contact}} =
               Contacts.create_contact(organization, @valid_attrs, member)
    end

    test "create_contact/1 with invalid data returns error changeset" do
      organization = insert!(:organization)
      member = insert!(:member, organization: organization)

      assert {:error, :contact, %Ecto.Changeset{}, _changes} =
               Contacts.create_contact(organization, @invalid_attrs, member)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      assert {:ok, %{contact: contact}} = Contacts.update_contact(contact, @update_attrs)
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()

      assert {:error, :contact, %Ecto.Changeset{}, _changes} =
               Contacts.update_contact(contact, %{last_name: nil, first_name: nil})

      assert contact.id == Contacts.get_contact!(contact.id).id
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end
end
