defmodule Palapa.Messages do
  use Palapa.Context
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment
  alias Palapa.Organizations.Organization
  alias Palapa.Organizations.Member
  alias Palapa.Teams.Team

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Messages.Policy)

  # --- Scopes

  def visible_to(queryable \\ Message, %Member{} = member) do
    queryable
    |> where_organization(member.organization)
    |> published_to_everyone
    |> or_where([q], q.id in ^messages_ids_visible_to(member))
  end

  def where_organization(queryable \\ Message, %Organization{} = organization) do
    queryable
    |> where(organization_id: ^organization.id)
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

  defp messages_ids_visible_to(%Member{} = member) do
    teams = Ecto.assoc(member, :teams)

    from(
      messages in Message,
      distinct: true,
      join: message_teams in assoc(messages, :teams),
      join: member_teams in subquery(teams),
      on: message_teams.id == member_teams.id,
      select: messages.id
    )
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
    |> preload([:creator, :teams, [comments: :creator]])
    |> Repo.get!(id)
  end

  def create(%Organizations.Member{} = creator, attrs, teams) do
    %Message{}
    |> Message.changeset(attrs)
    |> put_change(:organization, creator.organization)
    |> put_change(:creator, creator)
    |> put_teams(teams)
    |> Repo.insert()
  end

  def change(%Message{} = message) do
    Message.changeset(message, %{})
  end

  def change_comment(%MessageComment{} = message_comment) do
    MessageComment.changeset(message_comment, %{})
  end

  def get_comment!(queryable \\ MessageComment, id) do
    queryable
    |> preload(:creator)
    |> Repo.get!(id)
  end

  def create_comment(%Message{} = message, %Member{} = creator, attrs) do
    %MessageComment{}
    |> MessageComment.changeset(attrs)
    |> put_change(:message, message)
    |> put_change(:organization, creator.organization)
    |> put_change(:creator, creator)
    |> Repo.insert()
  end

  def update_comment(%MessageComment{} = message_comment, attrs) do
    message_comment
    |> MessageComment.changeset(attrs)
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
    |> order_by(desc: :inserted_at)
    |> preload([:creator, :teams])
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
