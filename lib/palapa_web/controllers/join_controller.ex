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
      {status, account, member} = Invitations.retrieve_account_from_invitation(invitation)

      case status do
        :already_member ->
          conn
          |> PalapaWeb.Authentication.start_session(account)
          |> redirect(to: Routes.dashboard_path(conn, :index, member.organization_id))

        :existing_account ->
          changeset =
            Invitations.JoinForm.changeset_for_existing_account(%Invitations.JoinForm{}, %{})

          render(conn, "form_with_existing_account.html",
            invitation: invitation,
            changeset: changeset
          )

        _ ->
          changeset = Invitations.JoinForm.changeset(%Invitations.JoinForm{}, %{})

          render(conn, "form_without_existing_account.html",
            invitation: invitation,
            changeset: changeset
          )
      end
    else
      conn
      |> put_status(:forbidden)
      |> assign(:email_support, Application.fetch_env!(:palapa, :email_support))
      |> render("invalid_invitation.html")
    end
  end

  def create(conn, %{
        "invitation_id" => invitation_id,
        "token" => token,
        "join_form" => join_form_attrs
      }) do
    invitation = Invitations.get(invitation_id)

    if invitation && Invitations.authorized?(invitation, token) do
      case Invitations.join(invitation, join_form_attrs) do
        {:ok, result} ->
          conn
          |> PalapaWeb.Authentication.start_session(result.account)
          |> redirect(to: Routes.dashboard_path(conn, :index, result.member.organization_id))

        {:error, _failed_operation, changeset, _changes_so_far} ->
          if Accounts.exists?(invitation.email) do
            render(
              conn,
              "form_with_existing_account.html",
              invitation: invitation,
              changeset: %{changeset | action: :insert}
            )
          else
            render(
              conn,
              "form_without_existing_account.html",
              invitation: invitation,
              changeset: %{changeset | action: :insert}
            )
          end
      end
    end
  end
end
