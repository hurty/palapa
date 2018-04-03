defmodule Palapa.InvitationsTest do
  use Palapa.DataCase

  alias Palapa.Invitations

  describe "Email addresses parsing" do
    test "parse_emails/1 removes duplicated addresses" do
      emails_string = """
      richard.hendricks@piedpiper.com
      jared.dunn@piedpiper.com
      richard.hendricks@piedpiper.com
      """

      {:ok, emails, _ignored} = Invitations.parse_emails(emails_string)
      assert emails == ["richard.hendricks@piedpiper.com", "jared.dunn@piedpiper.com"]
    end

    test "parse_emails/1 removes leading and trailing whitespaces" do
      emails_string = """

        richard.hendricks@piedpiper.com  
      jared.dunn@piedpiper.com


      """

      {:ok, emails, _ignored} = Invitations.parse_emails(emails_string)
      assert emails == ["richard.hendricks@piedpiper.com", "jared.dunn@piedpiper.com"]
    end

    test "parse_emails/1 treats whitespaces as separator between addresses" do
      emails_string = """
      richard.hendricks@piedpiper.com   bertram.gilfoyle@piedpiper.com
      jared.dunn@piedpiper.com
      """

      {:ok, emails, _ignored} = Invitations.parse_emails(emails_string)

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

      {:ok, emails, _ignored} = Invitations.parse_emails(emails_string)

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

      {:ok, emails, ignored} = Invitations.parse_emails(emails_string)

      assert emails == ["richard.hendricks@piedpiper.com"]
      assert ignored == ["jared.dunn_without_arobase_piedpiper.com", "@hurrah.com"]
    end
  end
end