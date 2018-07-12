defmodule PalapaWeb.InvitationController do
  use PalapaWeb, :controller

  alias Palapa.Invitations

  plug(:put_navigation, "member")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    put_breadcrumb(conn, "People & Teams", member_path(conn, :index, current_organization()))
  end

  def new(conn, _params) do
    with :ok <- permit(Invitations, :create, current_member()) do
      invitations = Palapa.Invitations.list(current_organization())

      conn
      |> put_breadcrumb("Invite people", invitation_path(conn, :new, current_organization()))
      |> render("new.html", invitations: invitations)
    end
  end

  def create(conn, %{"invitation" => %{"email_addresses" => email_addresses}}) do
    with :ok <- permit(Invitations, :create, current_member()) do
      {:ok, emails, ignored} = Invitations.parse_emails(email_addresses)

      Enum.each(emails, fn email ->
        Invitations.create(email, current_member())
      end)

      if Enum.any?(ignored) do
        conn
        |> render("create.html", emails: emails, ignored: ignored)
      else
        conn =
          if Enum.any?(emails) do
            put_flash(conn, :success, "Invitations have been sent")
          else
            put_flash(conn, :error, "You must enter at least one email address")
          end

        conn
        |> redirect(to: invitation_path(conn, :new, current_organization()))
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    invitation = Invitations.visible_to(current_member()) |> Invitations.get!(id)

    with :ok <- permit(Invitations, :delete, current_member(), invitation),
         {:ok, _invitation} = Invitations.delete(invitation) do
      send_resp(conn, :no_content, "")
    end
  end

  def renew(conn, %{"invitation_id" => invitation_id}) do
    invitation = Invitations.visible_to(current_member()) |> Invitations.get!(invitation_id)

    with :ok <- permit(Invitations, :renew, current_member(), invitation),
         {:ok, new_invitation} <- Invitations.renew(invitation, current_member()) do
      conn
      |> put_flash(:success, "#{new_invitation.email} has been sent a new invitation")
      |> redirect(
        to: invitation_path(conn, :new, current_organization(), %{"renewed" => new_invitation.id})
      )
    end
  end
end
