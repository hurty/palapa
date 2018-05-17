defmodule Palapa.Messages.Message do
  use Palapa.Schema
  alias Palapa.Organizations
  alias Palapa.Messages.{Message, MessageComment}
  alias Palapa.Teams.Team

  schema "messages" do
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:creator, Organizations.Member)
    many_to_many(:teams, Team, join_through: "messages_teams", on_replace: :delete)
    has_many(:comments, MessageComment)
    timestamps()
    field(:title, :string)
    field(:content, :string)
    field(:published_to_everyone, :boolean)
    field(:publish_teams_ids, {:array, :binary}, virtual: true)
    field(:deleted_at, :utc_datetime)
    field(:comments_count, :integer)
  end

  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:title, :content, :published_to_everyone, :publish_teams_ids])
    |> put_teams(attrs)
    |> update_change(:content, &HtmlSanitizeEx.html5(&1))
    |> validate_required(:title)
  end

  defp put_teams(changeset, attrs) do
    if attrs["teams"] do
      put_assoc(changeset, :teams, attrs["teams"])
    else
      changeset
    end
  end
end
