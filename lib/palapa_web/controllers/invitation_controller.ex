defmodule PalapaWeb.InvitationController do
  use PalapaWeb, :controller

  alias Palapa.Invitations

  plug(:put_navigation, "member")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    put_breadcrumb(
      conn,
      gettext("Your workspace"),
      Routes.member_path(conn, :index, current_organization(conn))
    )
  end

  def new(conn, _params) do
    with :ok <- permit(Invitations.Policy, :create, current_member(conn)) do
      invitations = Palapa.Invitations.list(current_organization(conn))

      conn
      |> put_breadcrumb(
        gettext("Invite people"),
        Routes.invitation_path(conn, :new, current_organization(conn))
      )
      |> render("new.html", invitations: invitations)
    end
  end

  def create(conn, %{"invitation" => %{"email_addresses" => email_addresses}}) do
    with :ok <- permit(Invitations.Policy, :create, current_member(conn)) do
      {:ok, emails, malformed, already_member} =
        Invitations.parse_emails(email_addresses, current_organization(conn))

      Enum.each(emails, fn email ->
        Invitations.create_or_renew(email, current_member(conn))
      end)

      if Enum.any?(malformed) || Enum.any?(already_member) do
        conn
        |> put_breadcrumb(
          gettext("Invite people"),
          Routes.invitation_path(conn, :new, current_organization(conn))
        )
        |> render(
          "create.html",
          emails: emails,
          malformed: malformed,
          already_member: already_member
        )
      else
        conn =
          if Enum.any?(emails) do
            put_flash(conn, :success, gettext("Invitations have been sent"))
          else
            put_flash(conn, :error, gettext("You must enter at least one email address"))
          end

        conn
        |> redirect(to: Routes.invitation_path(conn, :new, current_organization(conn)))
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    invitation = Invitations.visible_to(current_member(conn)) |> Invitations.get!(id)

    with :ok <- permit(Invitations.Policy, :delete, current_member(conn), invitation),
         {:ok, _invitation} = Invitations.delete(invitation) do
      send_resp(conn, :no_content, "")
    end
  end

  def renew(conn, %{"invitation_id" => invitation_id}) do
    invitation = Invitations.visible_to(current_member(conn)) |> Invitations.get!(invitation_id)

    with :ok <- permit(Invitations.Policy, :renew, current_member(conn), invitation),
         {:ok, new_invitation} <-
           Invitations.create_or_renew(invitation.email, current_member(conn)) do
      conn
      |> put_flash(
        :success,
        gettext("%{email} has been sent a new invitation", %{
          email: new_invitation.email
        })
      )
      |> redirect(
        to:
          Routes.invitation_path(conn, :new, current_organization(conn), %{
            "renewed" => new_invitation.id
          })
      )
    end
  end
end
