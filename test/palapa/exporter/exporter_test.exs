defmodule Palapa.ExporterTest do
  use Palapa.DataCase
  alias Palapa.Exporter
  import Palapa.Factory

  setup do
    pied_piper = insert_pied_piper!(:full)

    Palapa.Messages.create(
      pied_piper.richard,
      %{title: "This is a message", content: "<div>Message Content</div>"},
      teams: [pied_piper.tech_team]
    )

    %{organization: pied_piper.organization}
  end

  test "export members", %{organization: organization} do
    Exporter.export(organization)
  end
end
