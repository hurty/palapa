defmodule PalapaWeb.RegistrationController do
  use PalapaWeb, :controller
  alias Palapa.Accounts.{Registrations, Registration}
  alias Palapa.Repo

  plug(:put_layout, "public.html")

  # TODO: remove invitation after beta phase
  def new(conn, %{"invitation" => invitation}) do
    beta_subscription =
      Palapa.Beta.Subscription
      |> Repo.get_by!(invitation: invitation, used: false)

    render(conn, "new.html",
      changeset: Registrations.change(%Registration{}),
      beta_subscription: beta_subscription
    )
  end

  # TODO: Throw away after beta phase
  def new(conn, _params) do
    conn
    |> resp(
      403,
      "Sorry, multiple workspaces creation is disabled during the Beta phase. Please use your invitation link to create your workspace."
    )
  end

  # TODO: remove invitation after beta phase
  def create(conn, %{"registration" => registration_params}) do
    beta_subscription =
      Palapa.Beta.Subscription
      |> Repo.get_by!(invitation: registration_params["invitation"], used: false)

    locale = get_session(conn, :locale)

    case Registrations.create(registration_params, locale) do
      {:ok, result} ->
        beta_subscription |> Ecto.Changeset.change(%{used: true}) |> Repo.update()

        conn
        |> PalapaWeb.Authentication.start_session(result.account)
        |> redirect(
          to: Routes.message_path(conn, :index, result.organization_membership.organization)
        )

      {:error, :account_already_exists, _, _} ->
        conn
        |> put_flash(
          :error,
          gettext(
            "It seems you already have a Palapa account. Please sign in first to create a new workspace"
          )
        )
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, _failed_operation, changeset, _changes_so_far} ->
        render(conn, "new.html",
          changeset: %{changeset | action: :insert},
          beta_subscription: beta_subscription
        )
    end
  end
end
