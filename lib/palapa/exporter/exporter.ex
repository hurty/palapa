# WIP !! Exports a workspace data in multiple json files an produces a zip archive.
#
# OK members.json (member info + account full name, personal informations)
# OK teams.json (team infos + team members)
# OK messages.json (message, sharing settings, teams, comments)
# TODO contacts.json (contact info + comments)
# TODO documents/<doc_title>/doc.json (sections) + page_title.json (page + comments)

defmodule Palapa.Exporter do
  import Ecto.Query
  alias Palapa.Organizations

  def export(organization) do
    {:ok, dir_path} = Briefly.create(directory: true)

    export_members(organization, dir_path)
    export_teams(organization, dir_path)
    export_messages(organization, dir_path)

    files = ['members.json', 'teams.json', 'messages.json']

    {:ok, zip_path} = Briefly.create()
    {:ok, _} = :zip.create(zip_path, files, cwd: dir_path)

    Palapa.Exporter.ExportUploader.store({zip_path, organization})
  end

  def export_members(organization, dir_path) do
    members_json =
      list_members(organization)
      |> Jason.encode!()

    path = "#{dir_path}/members.json"
    File.write!(path, members_json)
    path
  end

  def list_members(organization) do
    organization
    |> Ecto.assoc(:members)
    |> Organizations.active()
    |> join(:inner, [m], a in assoc(m, :account))
    |> preload([:account, :personal_informations])
    |> order_by([_, a], a.name)
    |> Palapa.Repo.all()
  end

  def export_teams(organization, dir_path) do
    teams_json =
      list_teams(organization)
      |> Jason.encode!()

    path = "#{dir_path}/teams.json"
    File.write!(path, teams_json)
    path
  end

  def list_teams(organization) do
    Ecto.assoc(organization, :teams)
    |> preload(:members)
    |> order_by(:name)
    |> Palapa.Repo.all()
  end

  def export_messages(organization, dir_path) do
    messages_json =
      list_messages(organization)
      |> Jason.encode!()

    path = "#{dir_path}/messages.json"
    File.write!(path, messages_json)
    path
  end

  def list_messages(organization) do
    Palapa.Messages.where_organization(organization)
    |> Palapa.Messages.non_deleted()
    |> order_by([m], desc: m.inserted_at)
    |> preload([[comments: [:attachments]], :teams, :attachments])
    |> Palapa.Repo.all()
  end
end
