defmodule PalapaWeb.Settings.Billing.CustomerController do
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Billing.Customer

  plug :put_navigation, "settings"
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", workspace_path(conn, :show, current_organization()))
    |> put_breadcrumb("Billing", billing_path(conn, :index, current_organization()))
  end

  def new(conn, _) do
    customer_changeset = Billing.change_customer_infos(%Customer{})

    conn
    |> put_breadcrumb("Upgrade your account", customer_path(conn, :edit, current_organization()))
    |> render("new.html", customer_changeset: customer_changeset)
  end

  def create(conn, %{"customer" => customer_attrs}) do
    case Billing.create_customer_infos(current_organization(), customer_attrs) do
      {:ok, _} ->
        redirect(conn, to: billing_path(conn, :index, current_organization()))

      {:error, :customer, customer_changeset, _changes_so_far} ->
        render(conn, "new.html", customer_changeset: customer_changeset)
    end
  end

  def edit(conn, _) do
    customer_changeset = Billing.change_customer_infos(%Customer{})
    render(conn, "edit.html", customer_changeset: customer_changeset)
  end
end
