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
      customer_changeset = Billing.change_customer_payment_method(current_organization(conn))
      render(conn, "edit.html", customer_changeset: customer_changeset)
    end
  end

  def update(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer = Billing.get_customer(current_organization(conn))

      case Billing.update_customer_payment_method(customer, customer_attrs) do
        {:ok, _result} ->
          # The PaymentController will handle the potential pending invoice / 3DSecure challenge
          redirect(conn,
            to: Routes.payment_path(conn, :new, current_organization(conn))
          )

        {:error, :customer, %Ecto.Changeset{} = customer_changeset, _} ->
          render(conn, "edit.html", customer_changeset: customer_changeset)

        {:error, _, _, _} ->
          customer_changeset = Billing.change_customer_payment_method(current_organization(conn))

          conn
          |> put_flash(
            :error,
            "An error occured while updating the payment method. Please try again or ask support"
          )
          |> render("edit.html", customer_changeset: customer_changeset)
      end
    end
  end
end
