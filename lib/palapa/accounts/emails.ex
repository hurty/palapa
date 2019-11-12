defmodule Palapa.Accounts.Emails do
  import Bamboo.Email

  def base_email() do
    new_email()
    |> from(~s[Palapa <do-not-reply@palapa.io>])
  end

  def password_reset(account, password_reset_token) do
    reset_link =
      PalapaWeb.Router.Helpers.password_reset_url(
        PalapaWeb.Endpoint,
        :edit,
        password_reset_token: password_reset_token
      )

    base_email()
    |> to(account.email)
    |> subject("Password reset")
    |> html_body("""
     <p>Click the following link to reset your password: <a href="#{reset_link}">#{reset_link}</a></p>
     <p>If you didn't request to reset your password, please ignore this email.</p>
    """)
  end
end
