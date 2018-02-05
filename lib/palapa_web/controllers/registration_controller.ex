defmodule PalapaWeb.RegistrationController do
  use PalapaWeb, :controller
  alias Palapa.Accounts
  alias Palapa.Accounts.Registration

  plug(:put_layout, "public.html")

  def new(conn, _params, _current) do
    render(conn, "new.html", changeset: Accounts.change_registration(%Registration{}))
  end

  def create(conn, %{"registration" => registration_params}, _current) do
    case Accounts.create_registration(registration_params) do
      {:ok, _} ->
        conn
        |> redirect(to: home_path(conn, :index))

      # |> Authentication.login(user, organization)
      {:error, _failed_operation, changeset, _changes_so_far} ->
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end
end
