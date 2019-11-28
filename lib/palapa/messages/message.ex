defmodule Palapa.Messages.Message do
  use Palapa.Schema
  alias Palapa.Organizations
  alias Palapa.Messages.{Message, MessageComment}
  alias Palapa.Teams.Team
  alias Palapa.Attachments.Attachment
  alias Palapa.RichText

  @derive {Jason.Encoder,
           only: [
             :creator_id,
             :title,
             :content,
             :inserted_at,
             :published_to_everyone,
             :comments,
             :attachments
           ]}

  schema "messages" do
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:creator, Organizations.Member)
    many_to_many(:teams, Team, join_through: "messages_teams", on_replace: :delete)
    has_many(:comments, MessageComment)

    has_many(:attachments, Attachment, on_replace: :delete)

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
    |> cast(attrs, [:title, :content, :published_to_everyone, :inserted_at])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments, :message)
    |> validate_required(:title)
  end
end
