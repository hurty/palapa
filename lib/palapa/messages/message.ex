defmodule Palapa.Messages.Message do
  use Palapa.Schema
  alias Palapa.Organizations
  alias Palapa.Messages.{Message, MessageComment}
  alias Palapa.Teams.Team
  alias Palapa.Attachments.Attachment
  alias Palapa.RichText

  schema "messages" do
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:creator, Organizations.Member)
    many_to_many(:teams, Team, join_through: "messages_teams", on_replace: :delete)
    has_many(:comments, MessageComment)

    many_to_many(:attachments, Attachment,
      join_through: "messages_attachments",
      on_replace: :delete
    )

    timestamps()
    field(:title, :string)
    field(:content, RichText.Type)
    field(:published_to_everyone, :boolean)
    field(:publish_teams_ids, {:array, :binary}, virtual: true)
    field(:deleted_at, :utc_datetime)
    field(:comments_count, :integer)
  end

  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:title, :content, :published_to_everyone, :publish_teams_ids])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments)
    |> put_teams(attrs)
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
