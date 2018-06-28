defmodule Palapa.MessagesTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Messages
  alias Palapa.Messages.Message

  test "create/3 with a public message" do
    organization = insert!(:organization)
    member = insert!(:member, organization: organization)

    assert {:ok, %Message{}} =
             Messages.create(member, %{title: "Hello World", content: "<h1>Hello</h1"})
  end

  test "create/3 with a message for a specific team" do
    organization = insert!(:organization)
    member = insert!(:member, organization: organization)
    team = insert!(:team, organization: organization)

    assert {:ok, %Message{}} =
             Messages.create(member, %{title: "Hello World", content: "<h1>Hello</h1"}, [team])
  end
end
