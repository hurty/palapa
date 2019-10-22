defmodule PalapaWeb.ContactController do
  use PalapaWeb, :controller

  alias Palapa.Contacts
  alias Palapa.Contacts.Contact

  plug(:put_navigation, "contact")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Contacts", Routes.message_path(conn, :index, current_organization(conn)))
  end

  def index(conn, _params) do
    live_render(conn, PalapaWeb.ContactLive,
      session: %{current_member_id: current_member(conn).id}
    )
  end

  def show(conn, %{"id" => id}) do
    contact =
      conn
      |> current_member()
      |> Contacts.contacts_visible_to()
      |> Contacts.get_contact!(id)

    render(conn, "show.html", contact: contact)
  end

  def new(conn, _params) do
    render(conn, "new.html",
      changeset: Contact.changeset(%Contact{}),
      form_action: Routes.contact_path(conn, :create, current_organization(conn))
    )
  end

  def create(conn, %{"contact" => contact_attrs}) do
    case Contacts.create_contact(
           current_organization(conn),
           contact_attrs,
           current_member(conn)
         ) do
      {:ok, %{contact: contact}} ->
        conn
        |> put_flash(:success, "The contact has been created")
        |> redirect(to: Routes.contact_path(conn, :show, current_organization(conn), contact))

      {:error, :contact, changeset, _changes} ->
        conn
        |> put_flash(:error, "Check the errors")
        |> render("new.html",
          changeset: changeset,
          form_action: Routes.contact_path(conn, :create, current_organization(conn))
        )
    end
  end
end
