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
    |> put_breadcrumb("Messages", Routes.message_path(conn, :index, current_organization(conn)))
  end

  def index(conn, params) do
    selected_team =
      if params["team_id"] do
        Teams.where_organization(current_organization(conn))
        |> Teams.get!(params["team_id"])
      end

    messages =
      Messages.visible_to(current_member(conn))
      |> filter_team(selected_team)
      |> Messages.paginate(params["page"])

    teams = Teams.list_for_member(current_member(conn))

    conn
    |> render(
      "index.html",
      messages: messages,
      teams: teams,
      selected_team: selected_team
    )
  end

  def new(conn, _params) do
    message_changeset = Messages.change(%Message{})
    teams = Teams.list_for_member(current_member(conn))

    conn
    |> put_breadcrumb("New message", Routes.message_path(conn, :new, current_organization(conn)))
    |> render("new.html", message_changeset: message_changeset, teams: teams)
  end

  def create(conn, %{"message" => message_params}) do
    with :ok <- permit(Messages.Policy, :create, current_member(conn)) do
      teams = Teams.list_for_member(current_member(conn))
      message_teams = find_teams(message_params, current_member(conn))

      conn =
        put_breadcrumb(
          conn,
          "New messages",
          Routes.message_path(conn, :new, current_organization(conn))
        )

      case Messages.create(current_member(conn), message_params, message_teams) do
        {:ok, message} ->
          conn
          |> put_flash(:success, "Your message has been posted")
          |> redirect(to: Routes.message_path(conn, :show, current_organization(conn), message))

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

    with :ok <- permit(Messages.Policy, :show, current_member(conn), message) do
      conn
      |> put_breadcrumb(
        message.title,
        Routes.message_path(conn, :show, current_organization(conn), message)
      )
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
    teams = Teams.list_for_member(current_member(conn))

    with :ok <- permit(Messages.Policy, :edit_message, current_member(conn), message) do
      conn
      |> put_breadcrumb(
        message.title,
        Routes.message_path(conn, :show, current_organization(conn), message)
      )
      |> put_breadcrumb(
        "Edit",
        Routes.message_path(conn, :edit, current_organization(conn), message)
      )
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
    message_teams = find_teams(message_params, current_member(conn))

    with :ok <- permit(Messages.Policy, :delete_message, current_member(conn), message) do
      case Messages.update(message, message_params, message_teams) do
        {:ok, _struct} ->
          conn
          |> put_flash(:success, "The message has been updated")
          |> redirect(to: Routes.message_path(conn, :show, current_organization(conn), message))

        {:error, message_changeset} ->
          teams = Teams.list_for_member(current_member(conn))

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
    message =
      Messages.where_organization(current_organization(conn))
      |> Messages.get!(id)

    with :ok <- permit(Messages.Policy, :delete_message, current_member(conn), message) do
      Messages.delete!(message)

      conn
      |> put_flash(:success, "The message has been deleted")
      |> redirect(to: Routes.message_path(conn, :index, current_organization(conn)))
    end
  end

  defp find_message!(conn, id) do
    Messages.visible_to(current_member(conn))
    |> Messages.get!(id)
  end

  defp find_teams(message_params, member) do
    message_teams_ids = message_params["publish_teams_ids"] || []

    if message_params["published_to_everyone"] == "false" && Enum.any?(message_teams_ids) do
      Teams.visible_to(member)
      |> Teams.where_ids(message_teams_ids)
      |> Teams.list()
    else
      []
    end
  end

  defp filter_team(query, team) do
    if team do
      query
      |> Messages.published_to(team)
    else
      query
    end
  end
end
