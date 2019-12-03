defmodule PalapaWeb.BetaSubscriptionController do
  use PalapaWeb, :controller
  alias Palapa.Repo
  alias Palapa.Beta.Subscription

  plug(:put_layout, "home.html")

  def create(conn, %{"subscription" => subscription}) do
    changeset = Subscription.changeset(%Subscription{}, subscription)
    beta = Ecto.Changeset.get_field(changeset, :beta)

    status =
      if beta do
        Repo.insert(changeset, on_conflict: :replace_all, conflict_target: :email)
      else
        Repo.insert(changeset, on_conflict: :nothing)
      end

    case status do
      {:ok, subscription} ->
        render(conn, "success.html", email: subscription.email, beta: subscription.beta)

      {:error, changeset} ->
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
