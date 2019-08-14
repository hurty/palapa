defmodule PalapaWeb.Settings.WorkspaceView do
  use PalapaWeb, :view

  def list_admins(organization) do
    Palapa.Organizations.list_admins(organization)
  end
end
