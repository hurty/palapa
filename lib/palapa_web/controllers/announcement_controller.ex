defmodule PalapaWeb.AnnouncementController do
  use PalapaWeb, :controller
  alias Palapa.Announcements
  alias Palapa.Announcements.Announcement
  alias Palapa.Teams

  plug(:put_navigation, "announcement")

  def index(conn, _params) do
    announcements =
      Announcements.visible_to(current_member())
      |> Announcements.list()

    render(conn, "index.html", announcements: announcements)
  end

  def new(conn, _params) do
    announcement = Announcements.change(%Announcement{})
    teams = Palapa.Teams.list_for_member(current_member())
    render(conn, "new.html", announcement: announcement, teams: teams)
  end

  def create(conn, %{"announcement" => announcement_params}) do
    with :ok <- permit(Announcements, :create, current_member()) do
      teams =
        if announcement_params["teams_ids"] do
          Teams.where_organization(current_organization())
          |> Teams.where_ids(announcement_params["teams_ids"])
          |> Teams.list()
        else
          nil
        end

      {:ok, announcement} = Announcements.create(current_member(), announcement_params, teams)

      conn
      |> put_flash(:success, "Your message has been posted")
      |> redirect(to: announcement_path(conn, :show, announcement))
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
