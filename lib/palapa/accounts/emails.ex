defmodule Palapa.Accounts.Emails do
  import Bamboo.Email
  import PalapaWeb.Gettext

  def base_email() do
    new_email()
    |> from(Application.fetch_env!(:palapa, :email_transactionnal))
  end

  def password_reset(account, password_reset_token) do
    locale = account.locale || "en"

    Gettext.with_locale(PalapaWeb.Gettext, locale, fn ->
      reset_link =
        PalapaWeb.Router.Helpers.password_reset_url(
          PalapaWeb.Endpoint,
          :edit,
          password_reset_token: password_reset_token
        )

      base_email()
      |> to(account.email)
      |> subject(gettext("Password reset"))
      |> html_body("""
       <p>#{gettext("Click the following link to reset your password:")} <a href="#{reset_link}">#{
        reset_link
      }</a></p>
       <p>#{gettext("If you didn't request to reset your password, please ignore this email.")}</p>
      """)
    end)
  end
end
