defmodule Palapa.Invitations.Emails do
  import Bamboo.Email
  import PalapaWeb.Gettext

  # Usage
  #
  # def welcome_email do
  #   new_email(
  #     to: "pierre.hurtevent@gmail.com",
  #     from: "support@myapp.com",
  #     subject: "Welcome to the app.",
  #     html_body: "<strong>Thanks for joining!</strong>",
  #     text_body: "Thanks for joining!"
  #   )

  #   # or pipe using Bamboo.Email functions
  #   new_email
  #   |> to("foo@example.com")
  #   |> from("me@example.com")
  #   |> subject("Welcome!!!")
  #   |> html_body("<strong>Welcome</strong>")
  #   |> text_body("welcome")
  # end

  def base_email() do
    new_email()
    |> from(Application.fetch_env!(:palapa, :email_transactionnal))
  end

  def invitation(%Palapa.Invitations.Invitation{} = invitation) do
    invitation =
      invitation
      |> Palapa.Repo.preload(creator: :account)
      |> Palapa.Repo.preload(:organization)

    join_link =
      PalapaWeb.Router.Helpers.join_url(PalapaWeb.Endpoint, :new, invitation.id, invitation.token)

    locale = invitation.creator.account.locale || "en"

    Gettext.with_locale(PalapaWeb.Gettext, locale, fn ->
      base_email()
      |> to(invitation.email)
      |> subject(
        gettext("You have been invited to join \"%{workspace}\"", %{
          workspace: invitation.organization.name
        })
      )
      |> html_body("""
      <p>#{
        gettext(
          "%{creator} invited you to join the workspace \"%{workspace}\" on the Palapa application.",
          %{
            creator: invitation.creator.account.name,
            workspace: invitation.organization.name
          }
        )
      } <br><br>#{gettext("Click the following link to get started:")} <a href="#{join_link}">#{
        join_link
      }</a></p>
      """)
    end)
  end
end
