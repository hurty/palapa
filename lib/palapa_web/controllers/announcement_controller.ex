defmodule PalapaWeb.AnnouncementController do
  use PalapaWeb, :controller

  alias Palapa.Announcements
  alias Palapa.Announcements.Announcement
  alias Palapa.Teams

  plug(:put_navigation, "announcement")

  def index(conn, params) do
    announcements_query =
      Announcements.visible_to(current_member())
      |> filter_by_selected_team(conn, params)

    today =
      Timex.now()
      |> Timex.end_of_day()

    beginning_of_week =
      today
      |> Timex.beginning_of_week()

    this_week_announcements =
      announcements_query
      |> Announcements.published_between(beginning_of_week, today)
      |> Announcements.list()

    other_announcements =
      announcements_query
      |> Announcements.published_before(beginning_of_week)
      |> Announcements.paginate(params["page"])

    teams = Teams.list_for_member(current_member())

    render(
      conn,
      "index.html",
      this_week_announcements: this_week_announcements,
      other_announcements: other_announcements,
      teams: teams,
      selected_team_id: params["team_id"]
    )
  end

  defp filter_by_selected_team(announcements_query, conn, params) do
    if params["team_id"] do
      team =
        Teams.where_organization(current_organization())
        |> Teams.get!(params["team_id"])

      announcements_query |> Announcements.published_to(team)
    else
      announcements_query
    end
  end

  def new(conn, _params) do
    announcement = Announcements.change(%Announcement{})
    teams = Teams.list_for_member(current_member())

    render(conn, "new.html", announcement: announcement, teams: teams)
  end

  def create(conn, %{"announcement" => announcement_params}) do
    with :ok <- permit(Announcements, :create, current_member()) do
      teams = Teams.list_for_member(current_member())
      announcement_teams = find_teams(conn, announcement_params)

      case Announcements.create(current_member(), announcement_params, announcement_teams) do
        {:ok, announcement} ->
          conn
          |> put_flash(:success, "Your message has been posted")
          |> redirect(to: announcement_path(conn, :show, announcement))

        {:error, announcement} ->
          conn
          |> put_flash(:error, "Your message can't be posted")
          |> render("new.html", announcement: announcement, teams: teams)
      end
    end
  end

  defp find_teams(conn, announcement_params) do
    announcement_teams_ids = announcement_params["publish_teams_ids"] || []

    if announcement_params["publish_to"] == "specific_teams" && Enum.any?(announcement_teams_ids) do
      Teams.where_organization(current_organization())
      |> Teams.where_ids(announcement_teams_ids)
      |> Teams.list()
    else
      []
    end
  end

  def show(conn, %{"id" => id}) do
    announcement =
      Announcements.where_organization(current_organization())
      |> Announcements.get!(id)

    with :ok <- permit(Announcements, :show, current_member()) do
      render(conn, "show.html", announcement: announcement)
    end
  end
end
