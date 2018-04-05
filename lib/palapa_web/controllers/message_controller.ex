defmodule PalapaWeb.MessageController do
  use PalapaWeb, :controller

  alias Palapa.Messages
  alias Palapa.Messages.Message
  alias Palapa.Teams

  plug(:put_navigation, "message")

  def index(conn, params) do
    messages_query =
      Messages.visible_to(current_member())
      |> filter_by_selected_team(conn, params)

    today =
      Timex.now()
      |> Timex.end_of_day()

    beginning_of_week =
      today
      |> Timex.beginning_of_week()

    this_week_messages =
      messages_query
      |> Messages.published_between(beginning_of_week, today)
      |> Messages.list()

    other_messages =
      messages_query
      |> Messages.published_before(beginning_of_week)
      |> Messages.paginate(params["page"])

    teams = Teams.list_for_member(current_member())

    render(
      conn,
      "index.html",
      this_week_messages: this_week_messages,
      other_messages: other_messages,
      teams: teams,
      selected_team_id: params["team_id"]
    )
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

  def new(conn, _params) do
    message = Messages.change(%Message{})
    teams = Teams.list_for_member(current_member())

    render(conn, "new.html", message: message, teams: teams)
  end

  def create(conn, %{"message" => message_params}) do
    with :ok <- permit(Messages, :create, current_member()) do
      teams = Teams.list_for_member(current_member())
      message_teams = find_teams(conn, message_params)

      case Messages.create(current_member(), message_params, message_teams) do
        {:ok, message} ->
          conn
          |> put_flash(:success, "Your message has been posted")
          |> redirect(to: message_path(conn, :show, message))

        {:error, message} ->
          conn
          |> put_flash(:error, "Your message can't be posted")
          |> render("new.html", message: message, teams: teams)
      end
    end
  end

  defp find_teams(conn, message_params) do
    message_teams_ids = message_params["publish_teams_ids"] || []

    if message_params["publish_to"] == "specific_teams" && Enum.any?(message_teams_ids) do
      Teams.where_organization(current_organization())
      |> Teams.where_ids(message_teams_ids)
      |> Teams.list()
    else
      []
    end
  end

  def show(conn, %{"id" => id}) do
    message =
      Messages.where_organization(current_organization())
      |> Messages.get!(id)

    with :ok <- permit(Messages, :show, current_member()) do
      render(conn, "show.html", message: message)
    end
  end
end
