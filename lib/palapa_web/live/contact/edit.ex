defmodule PalapaWeb.ContactLive.Edit do
  use PalapaWeb, :live_view
  use PalapaWeb.CurrentLive

  alias PalapaWeb.Router.Helpers, as: Routes

  alias Palapa.Contacts
  alias Palapa.Contacts.{Contact}

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.ContactView, "edit.html", assigns)
  end

  def mount(%{account_id: account_id}, socket) do
    account = Accounts.get!(account_id)
    Gettext.put_locale(Palapa.Gettext, account.locale)

    {:ok, assign(socket, :current_account, account)}
  end

  def handle_params(
        %{"organization_id" => organization_id, "id" => contact_id},
        _uri,
        socket
      ) do
    socket =
      socket
      |> fetch_current_context(organization_id)
      |> get_contact_changeset(contact_id)

    {:noreply, socket}
  end

  def handle_event("update_form", %{"contact" => attrs}, socket) do
    changeset =
      Contacts.change_contact(%Contact{}, attrs)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle_create_new_company", _value, socket) do
    value = !Ecto.Changeset.get_field(socket.assigns.changeset, :create_new_company)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:create_new_company, value)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"contact" => attrs}, socket) do
    {:noreply, update_contact(socket, attrs)}
  end

  def get_contact_changeset(socket, contact_id) do
    contact =
      Contacts.visible_to(socket.assigns.current_member)
      |> Contacts.get_contact!(contact_id)

    changeset =
      case get_connect_params(socket) do
        %{"stashed_form" => encoded} ->
          %Contact{}
          |> Contacts.change_contact(Plug.Conn.Query.decode(encoded)["contact"])
          |> Map.put(:action, :update)

        _ ->
          Contacts.change_contact(contact)
      end

    socket
    |> assign(:contact, contact)
    |> assign(:changeset, changeset)
    |> assign(:companies, Contacts.list_companies(socket.assigns.current_organization))
  end

  def update_contact(socket, attrs) do
    case Contacts.update_contact(socket.assigns.contact, attrs) do
      {:ok, %{contact: contact}} ->
        socket
        |> put_flash(:success, "The contact has been updated")
        |> redirect(
          to:
            Routes.live_path(
              socket,
              PalapaWeb.ContactLive,
              socket.assigns.current_organization,
              contact.id
            )
        )

      {:error, :contact, changeset, _} ->
        assign(socket, :changeset, changeset)
    end
  end
end
