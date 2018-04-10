defmodule Palapa.Messages.Message do
  use Palapa.Schema
  alias Palapa.Organizations
  alias Palapa.Messages.{Message, MessageComment}
  alias Palapa.Teams.Team

  schema "messages" do
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:creator, Organizations.Member)
    many_to_many(:teams, Team, join_through: "messages_teams")
    has_many(:comments, MessageComment)
    timestamps()
    field(:title, :string)
    field(:content, :string)
    field(:published_to_everyone, :boolean)
    field(:publish_to, :string, virtual: true)
    field(:publish_teams_ids, {:array, :binary}, virtual: true)
  end

  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:title, :content, :publish_to])
    |> validate_required(:title)
  end
end
