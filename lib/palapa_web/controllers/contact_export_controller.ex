defmodule PalapaWeb.ContactExportController do
  use PalapaWeb, :controller
  alias Palapa.Contacts
  alias Palapa.Contacts.ContactExporter

  def index(conn, _) do
    with :ok <- permit(Contacts.Policy, :export_contacts, current_member(conn)) do
      file = ContactExporter.exportCSV(current_organization(conn))

      send_download(conn, {:file, file},
        content_type: "text/csv",
        filename: "#{current_organization(conn).name}_contacts.csv"
      )
    end
  end
end
