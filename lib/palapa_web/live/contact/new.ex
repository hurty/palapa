defmodule PalapaWeb.ContactLive.New do
  use PalapaWeb, :live_view
  use PalapaWeb.CurrentLive

  alias PalapaWeb.Router.Helpers, as: Routes

  alias Palapa.Contacts
  alias Palapa.Contacts.{Contact}

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.ContactView, "new.html", assigns)
  end

  def mount(%{account_id: account_id}, socket) do
    account = Accounts.get!(account_id)
    Gettext.put_locale(account.locale)

    {:ok, assign(socket, :current_account, account)}
  end

  def handle_params(%{"organization_id" => organization_id}, _uri, socket) do
    socket =
      socket
      |> fetch_current_context(organization_id)
      |> get_contact_changeset()

    {:noreply, socket}
  end

  def handle_event("update_form", %{"contact" => attrs}, socket) do
    changeset = Contacts.change_contact(%Contact{}, attrs)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle_create_new_company", _value, socket) do
    value = !Ecto.Changeset.get_field(socket.assigns.changeset, :create_new_company)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:create_new_company, value)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"contact" => attrs}, socket) do
    {:noreply, create_contact(socket, attrs)}
  end

  def get_contact_changeset(socket) do
    changeset =
      case get_connect_params(socket) do
        %{"stashed_form" => encoded} ->
          %Contact{}
          |> Contacts.change_contact(Plug.Conn.Query.decode(encoded)["contact"])
          |> Map.put(:action, :insert)

        _ ->
          Contacts.change_contact(%Contact{})
      end

    socket
    |> assign(:companies, Contacts.list_companies(socket.assigns.current_organization))
    |> assign(:changeset, changeset)
  end

  def create_contact(socket, attrs) do
    case Contacts.create_contact(
           socket.assigns.current_organization,
           attrs,
           socket.assigns.current_member
         ) do
      {:ok, %{contact: contact}} ->
        socket
        |> put_flash(:success, gettext("The contact has been created"))
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
