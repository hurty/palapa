defmodule PalapaWeb.Settings.Billing.CustomerController do
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Billing.Customer
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

  def new(conn, _) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer_changeset = Billing.Customers.change_customer(%Customer{})

      conn
      |> put_breadcrumb(
        gettext("Upgrade your account"),
        Routes.settings_customer_path(conn, :new, current_organization(conn))
      )
      |> render("new.html", customer_changeset: customer_changeset)
    end
  end

  def create(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      case Billing.Subscriptions.create_subscription(
             current_organization(conn),
             customer_attrs
           ) do
        {:ok, _result} ->
          redirect(conn, to: Routes.payment_path(conn, :new, current_organization(conn)))

        {:error, :customer, customer_changeset, _changes_so_far} ->
          render(conn, "new.html", customer_changeset: customer_changeset)

        {:error, :stripe_customer, _error, _changes} ->
          conn
          |> put_flash(
            :error,
            gettext("The billing service is unreachable. Please try again or ask support")
          )
          |> redirect(to: Routes.settings_customer_path(conn, :new, current_organization(conn)))
      end
    end
  end

  def edit(conn, _) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      conn =
        conn
        |> put_breadcrumb(
          "Update billing information",
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
