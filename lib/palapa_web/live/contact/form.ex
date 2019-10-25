defmodule PalapaWeb.ContactLive.Form do
  use PalapaWeb, :live_view
  use PalapaWeb.CurrentLive

  alias PalapaWeb.Router.Helpers, as: Routes

  alias Palapa.Contacts
  alias Palapa.Contacts.{Contact}

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.ContactView, "form.html", assigns)
  end

  def mount(%{account_id: account_id, organization_id: organization_id}, socket) do
    socket =
      socket
      |> assign(:current_account, Accounts.get!(account_id))
      |> fetch_current_context(organization_id)
      |> get_contact_changeset()

    {:ok, socket}
  end

  def handle_event("update_form", %{"contact" => attrs}, socket) do
    changeset =
      Contacts.change_contact(%Contact{}, attrs)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create_contact", %{"contact" => attrs}, socket) do
    {:noreply, create_contact(socket, attrs)}
  end

  def handle_event("toggle_create_new_company", _value, socket) do
    value = !Ecto.Changeset.get_field(socket.assigns.changeset, :create_new_company)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:create_new_company, value)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def get_contact_changeset(socket) do
    socket
    |> assign(:companies, Contacts.list_companies(socket.assigns.current_organization))
    |> assign(:changeset, Contacts.change_contact(%Contact{}))
  end

  def create_contact(socket, attrs) do
    case Contacts.create_contact(
           socket.assigns.current_organization,
           attrs,
           socket.assigns.current_member
         ) do
      {:ok, %{contact: contact}} ->
        socket
        |> put_flash(:success, "The contact has been created")
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
