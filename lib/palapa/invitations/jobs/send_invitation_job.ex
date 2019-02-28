defmodule Palapa.Invitations.Jobs.SendInvitationJob do
  alias Palapa.Invitations
  alias Palapa.Invitations.Invitation

  def perform(invitation_id) do
    case Invitations.get(invitation_id) do
      %Invitation{} = invitation ->
        Invitations.send_invitation(invitation)

      _ ->
        {:ignore, "no invitation found"}
    end
  end
end
