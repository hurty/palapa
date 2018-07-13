defmodule Palapa.Invitations.Jobs.SendInvitationJob do
  alias Palapa.Invitations

  def perform(invitation_id) do
    invitation = Invitations.get(invitation_id)

    if invitation && is_nil(invitation.email_sent_at) do
      email =
        Invitations.Emails.invitation(invitation)
        |> Palapa.Mailer.deliver_now()

      {:ok, invitation} = Invitations.mark_as_sent(invitation)
      {:ok, invitation, email}
    else
      {:ignore, "Invitation not found or already sent"}
    end
  end
end
