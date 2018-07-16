defmodule Palapa.Invitations.InvitationsTest do
  use Palapa.DataCase

  alias Palapa.Invitations
  alias Palapa.Invitations.Invitation

  test "create/2 generate an invitation" do
    workspace = Palapa.Factory.insert_pied_piper!()

    assert {:ok, %Invitation{}} =
             Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)
  end

  test "create/2 replaces an existing invitation" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation_1} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    count_invitations_before = Repo.count(Invitation)

    {:ok, invitation_2} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    count_invitations_after = Repo.count(Invitation)

    refute invitation_1.id == invitation_2.id
    assert count_invitations_after == count_invitations_before
  end

  test "delete/1 deletes an existing invitation" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    count_invitations_before = Repo.count("invitations")

    assert {:ok, _} = Invitations.delete(invitation)
    count_invitations_after = Repo.count("invitations")
    assert count_invitations_after == count_invitations_before - 1
  end

  test "mark_as_sent/2 fills the email sending date of the invitation" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    assert {:ok, invitation} = Invitations.mark_as_sent(invitation)
    refute is_nil(invitation.email_sent_at)
  end

  test "authorized?/2 is falsy if the invitation is expired" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    invitation = invitation |> Ecto.Changeset.change(%{expire_at: Timex.now()}) |> Repo.update!()
    refute Invitations.authorized?(invitation, invitation.token)
  end

  test "authorized?/2 is falsy if the invitation is given with the bad token" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    refute Invitations.authorized?(invitation, "bad-token")
  end

  test "authorized?/2 is true if the invitation and token are valid" do
    workspace = Palapa.Factory.insert_pied_piper!()

    {:ok, invitation} =
      Invitations.create_or_renew("dinesh.chugtai@piedpiper.com", workspace.richard)

    assert Invitations.authorized?(invitation, invitation.token)
  end

  describe "Email addresses parsing" do
    test "parse_emails/1 removes duplicated addresses" do
      emails_string = """
      richard.hendricks@piedpiper.com
      jared.dunn@piedpiper.com
      richard.hendricks@piedpiper.com
      """

      {:ok, emails, _malformed} = Invitations.parse_emails(emails_string)
      assert emails == ["richard.hendricks@piedpiper.com", "jared.dunn@piedpiper.com"]
    end

    test "parse_emails/1 removes leading and trailing whitespaces" do
      emails_string = """

        richard.hendricks@piedpiper.com
      jared.dunn@piedpiper.com


      """

      {:ok, emails, _malformed} = Invitations.parse_emails(emails_string)
      assert emails == ["richard.hendricks@piedpiper.com", "jared.dunn@piedpiper.com"]
    end

    test "parse_emails/1 treats whitespaces as separator between addresses" do
      emails_string = """
      richard.hendricks@piedpiper.com   bertram.gilfoyle@piedpiper.com
      jared.dunn@piedpiper.com
      """

      {:ok, emails, _malformed} = Invitations.parse_emails(emails_string)

      assert emails == [
               "richard.hendricks@piedpiper.com",
               "bertram.gilfoyle@piedpiper.com",
               "jared.dunn@piedpiper.com"
             ]
    end

    test "parse_emails/1 treats commas as separator between addresses" do
      emails_string = """
      richard.hendricks@piedpiper.com,bertram.gilfoyle@piedpiper.com,jared.dunn@piedpiper.com
      """

      {:ok, emails, _malformed} = Invitations.parse_emails(emails_string)

      assert emails == [
               "richard.hendricks@piedpiper.com",
               "bertram.gilfoyle@piedpiper.com",
               "jared.dunn@piedpiper.com"
             ]
    end

    test "parse_emails/1 ignores malformed emails" do
      emails_string = """
      richard.hendricks@piedpiper.com
      jared.dunn_without_arobase_piedpiper.com
      @hurrah.com
      """

      {:ok, emails, malformed} = Invitations.parse_emails(emails_string)

      assert emails == ["richard.hendricks@piedpiper.com"]
      assert malformed == ["jared.dunn_without_arobase_piedpiper.com", "@hurrah.com"]
    end

    test "parse_emails/2 ignores malformed emails and people who are already members" do
      # Richard is already a member, Dinesh is not.
      emails_string = """
      dinesh@piedpiper.com
      richard.hendricks@piedpiper.com
      jared.dunn_without_arobase_piedpiper.com
      @hurrah.com
      """

      workspace = Palapa.Factory.insert_pied_piper!()

      {:ok, emails, malformed, already_member} =
        Invitations.parse_emails(emails_string, workspace.organization)

      assert emails == ["dinesh@piedpiper.com"]
      assert malformed == ["jared.dunn_without_arobase_piedpiper.com", "@hurrah.com"]
      assert already_member == ["richard.hendricks@piedpiper.com"]
    end
  end
end
