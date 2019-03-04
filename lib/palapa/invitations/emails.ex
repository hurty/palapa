defmodule Palapa.Invitations.Emails do
  import Bamboo.Email

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
    |> from("do-not-reply@palapa.io")
  end

  def invitation(%Palapa.Invitations.Invitation{} = invitation) do
    invitation =
      invitation
      |> Palapa.Repo.preload(creator: :account)
      |> Palapa.Repo.preload(:organization)

    join_link =
      PalapaWeb.Router.Helpers.join_url(PalapaWeb.Endpoint, :new, invitation.id, invitation.token)

    base_email()
    |> to(invitation.email)
    |> subject("You have been invited to join #{invitation.organization.name}")
    |> html_body("""
    <p>#{invitation.creator.account.name} invited you to join the workspace '#{
      invitation.organization.name
    }'". Click the following link to get started: <a href="#{join_link}">#{join_link}</a></p>
    """)
  end
end
