defmodule PalapaWeb.BetaSubscriptionController do
  use PalapaWeb, :controller
  alias Palapa.Repo
  alias Palapa.Beta.Subscription

  plug(:put_layout, "home.html")

  def create(conn, %{"subscription" => subscription}) do
    case(
      Subscription.changeset(%Subscription{}, subscription)
      |> Repo.insert(on_conflict: :replace_all, conflict_target: :email)
    ) do
      {:ok, subscription} ->
        render(conn, "success.html", email: subscription.email, beta: subscription.beta)

      {:error, changeset} ->
        beta = Ecto.Changeset.get_field(changeset, :beta)

        if beta do
          render(conn, "form_beta.html", changeset: changeset)
        else
          render(conn, "form.html", changeset: changeset)
        end
    end
  end

  def index(conn, _params) do
    redirect(conn, to: Routes.home_path(conn, :index))
  end
end
