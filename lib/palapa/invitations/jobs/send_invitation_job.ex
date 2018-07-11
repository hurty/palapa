defmodule Palapa.Invitations.Jobs.SendInvitationJob do
  alias Palapa.Invitations

  def perform(invitation_id) do
    invitation = Invitations.get(invitation_id)

    if invitation do
      email =
        Invitations.Emails.invitation(invitation)
        |> Palapa.Mailer.deliver_now()

      {:ok, invitation} = Invitations.put_sent_at(invitation)
      {:ok, invitation, email}
    else
      {:ignore, "Invitation not found"}
    end
  end
end
