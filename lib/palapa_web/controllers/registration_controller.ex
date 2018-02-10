require IEx

defmodule PalapaWeb.RegistrationController do
  use PalapaWeb, :controller
  alias Palapa.Accounts
  alias Palapa.Accounts.Registration

  plug(:put_layout, "public.html")

  def new(conn, _params) do
    render(conn, "new.html", changeset: Accounts.change_registration(%Registration{}))
  end

  def create(conn, %{"registration" => registration_params}) do
    case Accounts.create_registration(registration_params) do
      {:ok, result} ->
        conn
        |> PalapaWeb.Authentication.login(result.user, result.organization)
        |> redirect(to: dashboard_path(conn, :index))

      {:error, _failed_operation, changeset, _changes_so_far} ->
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end
end
