defmodule Palapa.Invitations.InvitationsTest do
  use Palapa.DataCase

  alias Palapa.Invitations
  alias Palapa.Invitations.Invitation

  test "create/2 generate an invitation" do
    workspace = Palapa.Factory.insert_pied_piper!()

    assert {:ok, %Invitation{}} =
             Invitations.create("dinesh.chugtai@piedpiper.com", workspace.richard)
  end

  test "create/2 replaces an existing invitation" do
    workspace = Palapa.Factory.insert_pied_piper!()
    {:ok, invitation_1} = Invitations.create("dinesh.chugtai@piedpiper.com", workspace.richard)
    count_invitations_before = Repo.count(Invitation)
    {:ok, invitation_2} = Invitations.create("dinesh.chugtai@piedpiper.com", workspace.richard)
    count_invitations_after = Repo.count(Invitation)

    refute invitation_1.id == invitation_2.id
    assert count_invitations_after == count_invitations_before
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
