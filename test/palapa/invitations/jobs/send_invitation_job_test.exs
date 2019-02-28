defmodule Palapa.Invitations.Jobs.SendInvitationJobTest do
  use Palapa.DataCase
  use Bamboo.Test, shared: true

  alias Palapa.Invitations
  alias Palapa.Invitations.Jobs.SendInvitationJob

  test "do nothing if the invitation doesn't exists" do
    # unexisting invitation id
    assert {:ignore, _} = SendInvitationJob.perform("32107cd7-712a-44f9-85c3-b6d4d5b354ed")
  end

  test "do nothing if the invitation has already been sent" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    # Pretend the invitation has already been sent
    invitation
    |> change(%{email_sent_at: DateTime.utc_now() |> DateTime.truncate(:second)})
    |> Repo.update!()

    assert {:ignore, _} = SendInvitationJob.perform(invitation.id)
  end
end
