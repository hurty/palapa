defmodule PalapaWeb.MessageController do
  use PalapaWeb, :controller

  alias Palapa.Messages
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment
  alias Palapa.Teams

  plug(:put_navigation, "message")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Messages", message_path(conn, :index))
  end

  def index(conn, params) do
    messages =
      Messages.visible_to(current_member())
      |> filter_by_selected_team(conn, params)
      |> Messages.paginate(params["page"])

    teams = Teams.list_for_member(current_member())

    conn
    |> render(
      "index.html",
      messages: messages,
      teams: teams,
      selected_team_id: params["team_id"]
    )
  end

  def new(conn, _params) do
    message_changeset = Messages.change(%Message{})
    teams = Teams.list_for_member(current_member())

    conn
    |> put_breadcrumb("New message", message_path(conn, :new))
    |> render("new.html", message_changeset: message_changeset, teams: teams)
  end

  def create(conn, %{"message" => message_params}) do
    with :ok <- permit(Messages, :create, current_member()) do
      teams = Teams.list_for_member(current_member())
      message_teams = find_teams(conn, message_params)

      conn = put_breadcrumb(conn, "New messages", message_path(conn, :new))

      case Messages.create(current_member(), message_params, message_teams) do
        {:ok, message} ->
          conn
          |> put_flash(:success, "Your message has been posted")
          |> redirect(to: message_path(conn, :show, message))

        {:error, message_changeset} ->
          conn
          |> put_flash(:error, "Your message can't be posted")
          |> render("new.html", message_changeset: message_changeset, teams: teams)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    message = find_message!(conn, id)

    new_message_comment = Messages.change_comment(%MessageComment{})

    with :ok <- permit(Messages, :show, current_member()) do
      conn
      |> put_breadcrumb(message.title, message_path(conn, :show, message))
      |> render(
        "show.html",
        message: message,
        comments: message.comments,
        new_message_comment: new_message_comment
      )
    end
  end

  def edit(conn, %{"id" => id}) do
    message = find_message!(conn, id)

    message_changeset = Messages.change(message)
    teams = Teams.list_for_member(current_member())

    with :ok <- permit(Messages, :edit_message, current_member(), message) do
      conn
      |> put_breadcrumb(message.title, message_path(conn, :show, message))
      |> put_breadcrumb("Edit", message_path(conn, :edit, message))
      |> render(
        "edit.html",
        message: message,
        message_changeset: message_changeset,
        teams: teams
      )
    end
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = find_message!(conn, id)
    teams = Teams.list_for_member(current_member())
    message_params = Map.put(message_params, "teams", find_teams(conn, message_params))

    with :ok <- permit(Messages, :delete_message, current_member(), message) do
      case Messages.update(message, message_params) do
        {:ok, _struct} ->
          conn
          |> put_flash(:success, "The message has been updated")
          |> redirect(to: message_path(conn, :show, message))

        {:error, message_changeset} ->
          conn
          |> put_flash(:error, "Your message can't be posted")
          |> render(
            "edit.html",
            message: message,
            message_changeset: message_changeset,
            teams: teams
          )
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    message = find_message!(conn, id)

    with :ok <- permit(Messages, :delete_message, current_member(), message) do
      Messages.delete!(message)

      conn
      |> put_flash(:success, "The message has been deleted")
      |> redirect(to: message_path(conn, :index))
    end
  end

  defp find_message!(conn, id) do
    Messages.where_organization(current_organization())
    |> Messages.get!(id)
  end

  defp find_teams(conn, message_params) do
    message_teams_ids = message_params["publish_teams_ids"] || []

    if message_params["published_to_everyone"] == "false" && Enum.any?(message_teams_ids) do
      Teams.where_organization(current_organization())
      |> Teams.where_ids(message_teams_ids)
      |> Teams.list()
    else
      []
    end
  end

  defp filter_by_selected_team(messages_query, conn, params) do
    if params["team_id"] do
      team =
        Teams.where_organization(current_organization())
        |> Teams.get!(params["team_id"])

      messages_query |> Messages.published_to(team)
    else
      messages_query
    end
  end
end
