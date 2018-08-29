defmodule Palapa.Messages do
  use Palapa.Context
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment
  alias Palapa.Teams.Team
  alias Palapa.Attachments

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Messages.Policy)

  # --- Scopes

  def visible_to(queryable \\ Message, %Member{} = member) do
    member_teams_ids =
      Ecto.assoc(member, :teams)
      |> Repo.all()
      |> Enum.map(fn team -> team.id end)

    queryable
    |> join(:left, [messages], message_teams in assoc(messages, :teams))
    |> where([_, t], t.id in ^member_teams_ids)
    |> or_where(published_to_everyone: true, organization_id: ^member.organization_id)
    |> distinct(true)
  end

  def where_organization(queryable \\ Message, %Organization{} = organization) do
    queryable
    |> where(organization_id: ^organization.id)
  end

  def non_deleted(queryable \\ Message) do
    queryable
    |> where([q], is_nil(q.deleted_at))
  end

  def published_to(queryable \\ Message, %Team{} = team) do
    queryable
    |> where([q], q.id in ^messages_ids_where_team(team))
  end

  def published_to_everyone(queryable \\ Message) do
    queryable
    |> where(published_to_everyone: true)
  end

  def published_between(queryable \\ Message, time_start, time_end) do
    queryable
    |> where([a], a.inserted_at >= ^time_start and a.inserted_at < ^time_end)
  end

  def published_before(queryable \\ Message, time) do
    queryable
    |> where([a], a.inserted_at < ^time)
  end

  defp messages_ids_where_team(%Team{} = team) do
    Ecto.assoc(team, :messages)
    |> select([q], q.id)
    |> Repo.all()
  end

  # --- Actions

  def list(queryable \\ Message) do
    queryable
    |> prepare_list()
    |> Repo.all()
  end

  def paginate(queryable \\ Message, page \\ 1) do
    queryable
    |> prepare_list
    |> Repo.paginate(page: page, page_size: 10)
  end

  def get!(queryable \\ Message, id) do
    queryable
    |> non_deleted
    |> preload([[creator: :account], :teams, [comments: [creator: :account]]])
    |> Repo.get!(id)
  end

  def create(%Organizations.Member{} = creator, attrs, teams \\ nil) do
    creator = Repo.preload(creator, :organization)

    %Message{}
    |> Message.changeset(attrs)
    |> put_change(:organization, creator.organization)
    |> put_change(:creator, creator)
    |> put_teams(teams)
    |> Attachments.put_attachments()
    |> Repo.insert()
  end

  def change(%Message{} = message) do
    Message.changeset(message, %{})
  end

  def update(%Message{} = message, attrs, teams \\ nil) do
    message
    |> Repo.preload([:organization, :attachments, :teams])
    |> Message.changeset(attrs)
    |> put_teams(teams)
    |> Attachments.put_attachments()
    |> Repo.update()
  end

  def delete!(%Message{} = message) do
    __MODULE__.change(message)
    |> put_change(:deleted_at, DateTime.utc_now())
    |> Repo.update!()
  end

  def deleted?(resource) do
    !is_nil(resource.deleted_at)
  end

  def get_comment!(queryable \\ MessageComment, id) do
    queryable
    |> preload(creator: :account)
    |> Repo.get!(id)
  end

  def create_comment(%Message{} = message, %Member{} = creator, attrs) do
    creator = Repo.preload(creator, [:organization, :account])

    %MessageComment{}
    |> MessageComment.changeset(attrs)
    |> put_change(:message, message)
    |> put_change(:organization, creator.organization)
    |> put_change(:creator, creator)
    |> Attachments.put_attachments()
    |> Repo.insert()
  end

  def change_comment(%MessageComment{} = message_comment) do
    MessageComment.changeset(message_comment, %{})
  end

  def update_comment(%MessageComment{} = message_comment, attrs) do
    message_comment
    |> Repo.preload([:organization, :attachments])
    |> MessageComment.changeset(attrs)
    |> Attachments.put_attachments()
    |> Repo.update()
  end

  def delete_comment!(%MessageComment{} = message_comment) do
    message_comment
    |> Repo.delete!()
  end

  def comments_count(%Message{} = message) do
    message
    |> Ecto.assoc(:comments)
    |> Repo.count()
  end

  defp prepare_list(queryable) do
    queryable
    |> non_deleted
    |> order_by(desc: :inserted_at)
    |> preload([[creator: :account], :teams])
  end

  defp put_teams(changeset, teams) do
    if teams && Enum.any?(teams) do
      changeset
      |> put_change(:published_to_everyone, false)
      |> put_assoc(:teams, teams)
    else
      changeset
    end
  end
end
