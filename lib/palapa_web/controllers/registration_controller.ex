defmodule PalapaWeb.RegistrationController do
  use PalapaWeb, :controller
  alias Palapa.Accounts.{Registrations, Registration}

  plug(:put_layout, "public.html")

  def new(conn, _params) do
    render(conn, "new.html", changeset: Registrations.change(%Registration{}))
  end

  def create(conn, %{"registration" => registration_params}) do
    case Registrations.create(registration_params) do
      {:ok, result} ->
        conn
        |> PalapaWeb.Authentication.start_session(result.account)
        |> redirect(
          to: Routes.dashboard_path(conn, :index, result.organization_membership.organization)
        )

      {:error, _failed_operation, changeset, _changes_so_far} ->
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end
end
