defmodule PalapaWeb.Settings.Billing.PaymentMethodController do
  use PalapaWeb, :controller

  alias Palapa.Billing

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Billing.Policy,
    action: :update_billing,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug :put_navigation, "settings"
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      "Settings",
      Routes.settings_workspace_path(conn, :show, current_organization(conn))
    )
    |> put_breadcrumb(
      "Billing",
      Routes.settings_customer_path(conn, :show, current_organization(conn))
    )
    |> put_breadcrumb(
      "Payment method",
      Routes.settings_payment_method_path(conn, :edit, current_organization(conn))
    )
  end

  def edit(conn, _) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer = Billing.Customers.get_customer(current_organization(conn))

      render(conn, "edit.html",
        customer_changeset: get_changeset(customer),
        setup_intent: setup_intent()
      )
    end
  end

  def update(conn, %{"customer" => %{"payment_method_id" => payment_method_id}}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer = Billing.Customers.get_customer(current_organization(conn))

      case Billing.Customers.update_customer_payment_method(customer, payment_method_id) do
        {:ok, _result} ->
          conn
          |> put_flash(:success, gettext("Your payment method has been updated"))
          |> redirect(to: Routes.settings_customer_path(conn, :show, current_organization(conn)))

        {:error, :stripe_payment_method, %Stripe.Error{} = stripe_error, _} ->
          conn
          |> put_flash(:error, stripe_error.message)
          |> render("edit.html",
            customer_changeset: get_changeset(customer),
            setup_intent: setup_intent()
          )

        {:error, :customer, changeset, _changes} ->
          conn
          |> put_flash(:error, gettext("An error occurred while updating your payment method"))
          |> render("edit.html",
            customer_changeset: changeset,
            setup_intent: setup_intent()
          )
      end
    end
  end

  defp get_changeset(customer) do
    Billing.Customers.change_customer_payment_method(customer)
  end

  defp setup_intent() do
    {:ok, setup_intent} = Billing.create_setup_intent()
    setup_intent
  end
end
