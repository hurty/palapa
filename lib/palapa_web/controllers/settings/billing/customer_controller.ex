defmodule PalapaWeb.Settings.Billing.CustomerController do
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Billing.Customer

  plug :put_navigation, "settings"
  plug :put_settings_navigation, "billing"
  plug :put_common_breadcrumbs

  def put_settings_navigation(conn, params) do
    assign(conn, :settings_navigation, params)
  end

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", settings_workspace_path(conn, :show, current_organization()))
    |> put_breadcrumb("Billing", settings_customer_path(conn, :show, current_organization()))
  end

  def show(conn, _params) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      customer = Billing.get_customer(current_organization())
      invoices = Billing.list_invoices(current_organization())
      render(conn, "show.html", customer: customer, invoices: invoices)
    end
  end

  def new(conn, _) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      customer_changeset = Billing.change_customer_infos(%Customer{})

      conn
      |> put_breadcrumb(
        "Upgrade your account",
        settings_customer_path(conn, :new, current_organization())
      )
      |> render("new.html", customer_changeset: customer_changeset)
    end
  end

  def create(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      case Billing.create_customer_and_synchronize_subscription(
             current_organization(),
             customer_attrs
           ) do
        {:ok, result} ->
          case Billing.payment_next_action(result.stripe_subscription) do
            :requires_action ->
              client_secret =
                result.stripe_subscription["latest_invoice"]["payment_intent"]["client_secret"]

              redirect(conn,
                to:
                  settings_payment_authentication_path(conn, :new, current_organization(),
                    client_secret: client_secret
                  )
              )

            :requires_payment_method ->
              nil

            # Ask just for the card details

            :ok ->
              redirect(conn, to: settings_customer_path(conn, :show, current_organization()))
          end

        {:error, :customer, customer_changeset, _changes_so_far} ->
          render(conn, "new.html", customer_changeset: customer_changeset)

        {:error, :stripe_customer, error, _changes} ->
          conn
          |> put_flash(:error, error.message)
          |> redirect(to: settings_customer_path(conn, :new, current_organization()))
      end
    end
  end

  def edit(conn, _) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      conn =
        conn
        |> put_breadcrumb(
          "Update billing information",
          settings_customer_path(conn, :edit, current_organization())
        )

      customer = Billing.get_customer(current_organization())

      if customer do
        customer_changeset = Billing.change_customer_infos(customer)
        render(conn, "edit.html", customer_changeset: customer_changeset)
      else
        conn
        |> put_flash(
          :error,
          "This workspace does not have a paid subscription / billing information"
        )
        |> redirect(to: settings_customer_path(conn, :show, current_organization()))
      end
    end
  end

  def update(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      customer = Billing.get_customer(current_organization())

      case Billing.update_customer_infos(customer, customer_attrs) do
        {:ok, _customer} ->
          conn
          |> put_flash(:success, "Billing information has been updated successfully")
          |> redirect(to: settings_customer_path(conn, :show, current_organization()))

        {:error, customer_changeset} ->
          conn
          |> put_flash(:error, "Billing information couldn't be updated")
          |> render("edit.html", customer_changeset: customer_changeset)
      end
    end
  end
end
