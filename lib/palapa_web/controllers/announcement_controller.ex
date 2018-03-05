defmodule PalapaWeb.AnnouncementController do
  use PalapaWeb, :controller
  alias Palapa.Announcements
  alias Palapa.Announcements.Announcement

  plug(:put_navigation, "announcement")

  def index(conn, _params) do
    announcements = Announcements.list(current_organization())
    render(conn, "index.html", announcements: announcements)
  end

  def new(conn, _params) do
    announcement = Announcements.change(%Announcement{})
    render(conn, "new.html", announcement: announcement)
  end

  def create(conn, %{"announcement" => announcement_params}) do
    with :ok <- permit(Announcements, :create, current_member()) do
      {:ok, announcement} =
        Announcements.create(current_organization(), current_member(), announcement_params)

      redirect(conn, to: announcement_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    announcement = Announcements.get(id)

    with :ok <- permit(Announcements, :show, current_member()) do
      render(conn, "show.html", announcement: announcement)
    end
  end
end
