defmodule PalapaWeb.ContactLive do
  use PalapaWeb, :live_view
  use PalapaWeb.CurrentLive

  alias PalapaWeb.Router.Helpers, as: Routes
  alias Palapa.Accounts
  alias Palapa.Contacts
  alias Palapa.Contacts.{Contact, ContactComment}

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.ContactView, "index.html", assigns)
  end

  def mount(%{account_id: account_id}, socket) do
    account = Accounts.get!(account_id)

    {:ok,
     assign(socket, %{
       current_account: account,
       contact: nil,
       contacts: nil,
       search: nil,
       edit_contact_comment_id: nil
     })}
  end

  # Display contact details
  def handle_params(
        %{"organization_id" => organization_id, "id" => contact_id},
        _uri,
        socket
      ) do
    socket =
      socket
      |> fetch_current_context(organization_id)
      |> list_contacts()
      |> get_contact(contact_id)

    {:noreply, socket}
  end

  def handle_params(
        %{"organization_id" => organization_id},
        _uri,
        socket
      ) do
    socket =
      socket
      |> fetch_current_context(organization_id)
      |> list_contacts()
      |> show_contact_at(0)

    {:noreply, socket}
  end

  # --- KEYBOARD NAVIGATION

  def handle_event("navigate_contact", %{"code" => "ArrowDown"}, socket) do
    if socket.assigns.contact_index < length(socket.assigns.contacts) - 1 do
      {:noreply, show_contact_at(socket, socket.assigns.contact_index + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("navigate_contact", %{"code" => "ArrowUp"}, socket) do
    if socket.assigns.contact_index > 0 do
      {:noreply, show_contact_at(socket, socket.assigns.contact_index - 1)}
    else
      {:noreply, socket}
    end
  end

  # No op
  def handle_event("navigate_contact", _key, socket) do
    {:noreply, socket}
  end

  def handle_event("search_contacts", %{"search" => search}, socket) do
    socket = assign(socket, :search, search)
    {:noreply, list_contacts(socket)}
  end

  def handle_event("create_contact_comment", %{"contact_comment" => comment_attrs}, socket) do
    %{contact: contact, current_member: current_member} = socket.assigns

    case(Contacts.create_contact_comment(contact, current_member, comment_attrs)) do
      {:ok, _} ->
        {:noreply, get_contact(socket, contact)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("list_contacts", _value, socket) do
    {:noreply, list_contacts(socket)}
  end

  def handle_event("delete_contact_comment", %{"comment_id" => id}, socket) do
    comment = Contacts.get_contact_comment!(id)
    {:noreply, delete_contact_comment(socket, comment)}
  end

  def handle_event("edit_contact_comment", %{"comment_id" => id}, socket) do
    comment = Contacts.get_contact_comment!(id)
    {:noreply, edit_contact_comment(socket, comment)}
  end

  def handle_event(
        "update_contact_comment",
        %{"comment_id" => id, "contact_comment" => attrs},
        socket
      ) do
    comment = Contacts.get_contact_comment!(id)

    {:noreply, update_contact_comment(socket, comment, attrs)}
  end

  def handle_event("delete_contact", _, socket) do
    {:noreply, delete_contact(socket)}
  end

  def list_contacts(socket) do
    search = socket.assigns.search
    organization = socket.assigns.current_organization

    socket
    |> assign(contacts: Contacts.list_contacts(organization, search))
    |> assign(all_contacts_count: Contacts.count_all_contacts(organization))
  end

  def get_contact(socket, contact_id) when is_binary(contact_id) do
    contact = Contacts.get_contact!(contact_id)
    get_contact_details(socket, contact)
  end

  def get_contact(socket, %Contact{} = contact) do
    get_contact_details(socket, contact)
  end

  defp get_contact_details(socket, contact) do
    socket
    |> assign(:contact, contact)
    |> assign(:contact_comment_changeset, Contacts.change_contact_comment(%ContactComment{}))
    |> assign(:contact_comments, Contacts.list_contact_comments(contact))
    |> assign(
      contact_index: Enum.find_index(socket.assigns.contacts, fn c -> c.id == contact.id end)
    )
  end

  def show_contact_at(socket, index) do
    contact = Enum.at(socket.assigns.contacts, index)

    if contact do
      live_redirect(socket,
        to: Routes.live_path(socket, __MODULE__, socket.assigns.current_organization, contact.id)
      )
    else
      socket
    end
  end

  def delete_contact(socket) do
    Contacts.delete_contact(socket.assigns.contact)

    socket
    |> put_flash(:success, "The contact has been deleted")
    |> live_redirect(
      to: Routes.live_path(socket, __MODULE__, socket.assigns.current_organization)
    )
  end

  def delete_contact_comment(socket, comment) do
    Contacts.delete_contact_comment(comment)
    get_contact(socket, comment.contact_id)
  end

  def edit_contact_comment(socket, comment) do
    socket
    |> assign(:update_contact_comment_changeset, Contacts.change_contact_comment(comment))
    |> assign(:edit_contact_comment_id, comment.id)
  end

  def update_contact_comment(socket, comment, attrs) do
    with :ok <-
           Bodyguard.permit!(
             Contacts.Policy,
             :edit_comment,
             socket.assigns.current_member,
             comment
           ) do
      Contacts.update_contact_comment!(comment, attrs)

      socket
      |> assign(:edit_contact_comment_id, nil)
      |> get_contact(comment.contact_id)
    end
  end
end
