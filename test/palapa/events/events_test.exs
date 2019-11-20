defmodule Palapa.Events.EventsTest do
  use Palapa.DataCase
  import Palapa.Factory
  alias Palapa.Events

  describe "email daily recap" do
    setup do
      organization = insert!(:organization)
      member = insert!(:member, organization: organization)

      {:ok, message} =
        Palapa.Messages.create(member, %{
          title: "My message",
          content: "<p>Cool story</p>",
          inserted_at: Timex.now() |> Timex.shift(hours: -24)
        })

      %{message: message, member: member, organization: organization}
    end

    test "send daily recap for a specific account", %{member: member} do
      account = Repo.get_assoc(member, :account)
      assert {:ok, emails} = Events.send_daily_recaps(account)
      assert Enum.count(emails) == 1
    end
  end
end
