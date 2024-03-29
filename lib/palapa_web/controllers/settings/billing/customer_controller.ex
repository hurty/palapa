defmodule PalapaWeb.Settings.Billing.CustomerController do
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Attachments

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Billing.Policy,
    action: :update_billing,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug :put_navigation, "settings"
  plug :put_settings_navigation, "billing"
  plug :put_common_breadcrumbs

  def put_settings_navigation(conn, params) do
    assign(conn, :settings_navigation, params)
  end

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      gettext("Settings"),
      Routes.settings_workspace_path(conn, :show, current_organization(conn))
    )
    |> put_breadcrumb(
      gettext("Billing"),
      Routes.settings_customer_path(conn, :show, current_organization(conn))
    )
  end

  def show(conn, _params) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      render(conn, "show.html",
        customer: Billing.Customers.get_customer(current_organization(conn)),
        invoices: Billing.Invoices.list_invoices(current_organization(conn)),
        storage_used_in_bytes: Attachments.storage_used(current_organization(conn)),
        storage_capacity: Attachments.storage_capacity(current_organization(conn))
      )
    end
  end

  def edit(conn, _) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      conn =
        conn
        |> put_breadcrumb(
          gettext("Update billing information"),
          Routes.settings_customer_path(conn, :edit, current_organization(conn))
        )

      customer = Billing.Customers.get_customer(current_organization(conn))

      if customer do
        customer_changeset = Billing.Customers.change_customer(customer)
        render(conn, "edit.html", customer_changeset: customer_changeset)
      else
        conn
        |> put_flash(
          :error,
          gettext("This workspace does not have a paid subscription / billing information")
        )
        |> redirect(to: Routes.settings_customer_path(conn, :show, current_organization(conn)))
      end
    end
  end

  def update(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer = Billing.Customers.get_customer(current_organization(conn))

      case Billing.Customers.update_customer(customer, customer_attrs) do
        {:ok, _customer} ->
          conn
          |> put_flash(:success, gettext("Billing information has been updated successfully"))
          |> redirect(to: Routes.settings_customer_path(conn, :show, current_organization(conn)))

        {:error, customer_changeset} ->
          conn
          |> put_flash(:error, gettext("Billing information couldn't be updated"))
          |> render("edit.html", customer_changeset: customer_changeset)
      end
    end
  end
end
