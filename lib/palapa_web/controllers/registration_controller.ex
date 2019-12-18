defmodule PalapaWeb.RegistrationController do
  use PalapaWeb, :controller
  alias Palapa.Accounts.{Registrations, Registration}

  plug(:put_layout, "public.html")

  def new(conn, _params) do
    render(conn, "new.html", changeset: Registrations.change(%Registration{}))
  end

  def create(conn, %{"registration" => registration_params}) do
    locale = get_session(conn, :locale)

    case Registrations.create(registration_params, locale) do
      {:ok, result} ->
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
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end
end
