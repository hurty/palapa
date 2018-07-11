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
    |> from("no-reply@palapa.com")
  end

  def invitation(%Palapa.Invitations.Invitation{} = invitation) do
    invitation =
      invitation
      |> Palapa.Repo.preload(creator: :account)
      |> Palapa.Repo.preload(:organization)

    base_email()
    |> to(invitation.email)
    |> subject("You've been invited to join Palapa")
    |> html_body("""
    <p>#{invitation.creator.name} invited you to join #{invitation.organization.name} on Palapa. Click the following link
    : <a href="#">#{invitation.token}</a></p>
    """)
  end
end
