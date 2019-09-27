defmodule PalapaWeb.JoinController do
  use PalapaWeb, :controller
  alias Palapa.Invitations
  alias Palapa.Accounts

  plug(:put_layout, "minimal.html")

  def new(conn, %{"invitation_id" => invitation_id, "token" => token}) do
    invitation = Invitations.get(invitation_id)

    if invitation && Invitations.authorized?(invitation, token) do
      # # In case the user is already a member but the invitation has not been properly deleted
      # # It should not happen in theory, but hey...
      {status, account, _member} = Invitations.retrieve_account_from_invitation(invitation)

      if status == :already_member do
        conn
        |> PalapaWeb.Authentication.start_session(account)
        |> redirect(to: Routes.dashboard_path(conn, :index, account.organization_id))
      else
        changeset = Invitations.JoinForm.changeset(%Invitations.JoinForm{}, %{})

        render(
          conn,
          "new.html",
          invitation: invitation,
          existing_account: account,
          changeset: changeset
        )
      end
    else
      conn
      |> put_status(:forbidden)
      |> render("invalid_invitation.html")
    end
  end

  def create(conn, %{"invitation_id" => invitation_id, "token" => token, "join_form" => join_form}) do
    invitation = Invitations.get(invitation_id)

    if invitation && Invitations.authorized?(invitation, token) do
      case Invitations.join(invitation, join_form) do
        {:ok, result} ->
          conn
          |> PalapaWeb.Authentication.start_session(result.account)
          |> redirect(to: Routes.dashboard_path(conn, :index, result.member.organization_id))

        {:error, _failed_operation, changeset, _changes_so_far} ->
          existing_account = Accounts.get_by(email: invitation.email)

          render(
            conn,
            "new.html",
            invitation: invitation,
            existing_account: existing_account,
            changeset: %{changeset | action: :insert}
          )
      end
    end
  end
end
