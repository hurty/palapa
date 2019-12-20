defmodule PalapaWeb.OrganizationController do
  require Logger
  use PalapaWeb, :controller

  alias Palapa.Organizations
  alias Palapa.Organizations.Organization
  alias Palapa.Billing

  plug :put_layout, "account.html"
  plug :put_navigation, "workspaces"

  def index(conn, _) do
    organizations = current_account(conn) |> Palapa.Organizations.list_organizations()
    render(conn, "index.html", organizations: organizations)
  end

  def new(conn, _) do
    conn
    |> set_changeset()
    |> render("new.html")
  end

  def create(conn, %{"organization" => attrs}) do
    # Needed to know in which language we have to generate the welcome message
    locale = get_session(conn, :locale)

    customer =
      if(attrs["attach_existing_customer"] == "true") do
        Billing.Customers.reusable_customer_accounts(current_account(conn))
        |> Billing.Customers.get_customer(attrs["customer_id"])
      else
        nil
      end

    try do
      case Organizations.create(attrs, current_account(conn), locale, customer) do
        {:ok, %{organization: organization}} ->
          redirect(conn, to: Routes.subscription_path(conn, :new, organization))

        {:error, :organization, changeset, _} ->
          conn
          |> set_changeset()
          |> render("new.html", changeset: changeset)

        error ->
          Logger.error("Subscription error")
          raise(Billing.BillingError, error)
      end
    rescue
      e ->
        Appsignal.Transaction.set_error("Subscription error", e, __STACKTRACE__)

        conn
        |> put_flash(
          :error,
          gettext(
            "An unexpected error occured while creating a new subscription. Please contact support."
          )
        )
        |> redirect(to: Routes.organization_path(conn, :new))
    end
  end

  def delete(conn, _) do
    org = current_organization(conn)

    with :ok <- permit(Organizations.Policy, :delete_organization, current_member(conn), org) do
      case Organizations.delete(org, current_member(conn)) do
        {:ok, _organization} ->
          conn
          |> put_flash(
            :success,
            gettext("The workspace %{workspace} has been deleted", %{workspace: org.name})
          )
          |> redirect(to: Routes.organization_path(conn, :index))

        {:error, _changeset} ->
          conn
          |> put_flash(:error, gettext("An error occurred while deleting the workspace"))
          |> redirect(to: Routes.settings_workspace_path(conn, :edit, org))
      end
    end
  end

  defp set_changeset(conn) do
    conn
    |> assign(:changeset, Organizations.change(%Organization{}))
    |> assign(
      :customers,
      Palapa.Billing.Customers.list_reusable_customer_accounts(current_account(conn))
    )
  end
end
