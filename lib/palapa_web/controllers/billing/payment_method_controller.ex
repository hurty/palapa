defmodule PalapaWeb.Billing.PaymentMethodController do
  use PalapaWeb, :controller

  alias Palapa.Billing

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Billing.Policy,
    action: :update_billing,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug(:put_layout, :account)
  plug(:put_navigation, "workspaces")

  def edit(conn, _) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer = Billing.Customers.get_customer(current_organization(conn))
      {:ok, setup_intent} = Billing.create_setup_intent()

      render(conn, "edit.html",
        customer_changeset: get_changeset(customer),
        setup_intent: setup_intent
      )
    end
  end

  def update(conn, %{"customer" => %{"payment_method_id" => payment_method_id}}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer = Billing.Customers.get_customer(current_organization(conn))

      case Billing.Customers.update_customer_payment_method(customer, payment_method_id) do
        {:ok, _result} ->
          # The PaymentController will handle the potential pending invoice / 3DSecure challenge
          redirect(conn,
            to: Routes.payment_path(conn, :new, current_organization(conn))
          )

        {:error, :stripe_payment_method, %Stripe.Error{} = stripe_error, _} ->
          conn
          |> put_flash(:error, stripe_error.message)
          |> render("edit.html", customer_changeset: get_changeset(customer))

        {:error, :customer, changeset, _changes} ->
          conn
          |> put_flash(:error, "An error occurred while updating your payment method")
          |> render("edit.html", customer_changeset: changeset)
      end
    end
  end

  defp get_changeset(customer) do
    Billing.Customers.change_customer_payment_method(customer)
  end
end
