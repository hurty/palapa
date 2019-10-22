defmodule PalapaWeb.ContactLive do
  use PalapaWeb, :live_view

  alias PalapaWeb.Router.Helpers, as: Routes

  alias Palapa.Accounts
  alias Palapa.Contacts
  alias Palapa.Contacts.Contact

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.ContactView, "index.html", assigns)
  end

  def fetch_current_context(organization_id, socket) do
    organization =
      Accounts.organization_for_account(socket.assigns.current_account, organization_id)

    member = Accounts.member_for_organization(socket.assigns.current_account, organization)

    socket
    |> assign_new(:current_member, fn -> member end)
    |> assign_new(:current_organization, fn -> organization end)
  end

  def mount(%{account_id: account_id}, socket) do
    account = Accounts.get!(account_id)
    {:ok, assign(socket, %{current_account: account, contact: nil, changeset: nil})}
  end

  # Display contact details
  def handle_params(
        %{"organization_id" => organization_id, "id" => contact_id},
        _uri,
        socket
      ) do
    socket = fetch_current_context(organization_id, socket)

    socket =
      socket
      |> assign(contact: Contacts.get_contact!(contact_id))
      |> assign_new(:contacts, fn ->
        Contacts.list_contacts(socket.assigns.current_organization)
      end)

    {:noreply, socket}
  end

  def handle_params(
        %{"organization_id" => organization_id},
        _uri,
        socket
      ) do
    socket = fetch_current_context(organization_id, socket)
    contacts = Contacts.list_contacts(socket.assigns.current_organization)
    contact = List.first(contacts)
    # changeset = Contact.changeset(%Contact{})
    {:noreply, assign(socket, contacts: contacts, contact: contact)}
  end

  def handle_event("list_contacts", _value, socket) do
    list_contacts(socket)
  end

  def handle_event("search_contacts", %{"search" => search}, socket) do
    list_contacts(socket, search)
  end

  def handle_event("create_contact", %{"contact" => contact_attrs}, socket) do
    case Contacts.create_contact(
           socket.assigns.current_organization,
           contact_attrs,
           socket.assigns.current_member
         ) do
      {:ok, %{contact: contact}} ->
        socket
        |> put_flash(:success, "The contact has been created")
        |> live_redirect(
          to: Routes.live_path(socket, __MODULE__, socket.assigns.current_organization, contact)
        )

      {:error, :contact, changeset, _changes} ->
        socket
        |> put_flash(:error, "Check the errors")
        |> list_contacts()
    end
  end

  def list_contacts(socket, search \\ nil) do
    contacts = Contacts.list_contacts(socket.assigns.current_organization, search)
    {:noreply, assign(socket, contacts: contacts)}
  end
end
