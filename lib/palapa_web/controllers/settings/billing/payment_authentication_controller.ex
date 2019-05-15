defmodule PalapaWeb.Settings.Billing.PaymentAuthenticationController do
  use PalapaWeb, :controller
  plug :put_navigation, "settings"

  def new(conn, %{"client_secret" => client_secret}) do
    render(conn, "new.html", client_secret: client_secret)
  end
end
