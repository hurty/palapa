defmodule PalapaWeb.SearchControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Repo, warn: false

  setup do
    workspace = insert_pied_piper!(:full)

    conn = login(workspace.gilfoyle)

    {:ok, conn: conn, workspace: workspace}
  end

  test "global search", %{conn: conn, workspace: workspace} do
    Palapa.Documents.create_document(workspace.richard, nil, %{
      title: "Styleguide for everyone"
    })

    Palapa.Messages.create(workspace.richard, %{
      title: "Welcome everyone",
      content: "It is really a pleasure"
    })

    conn = get(conn, search_path(conn, :index, workspace.organization, query: "every"))
    assert html_response(conn, 200) =~ "Styleguide for everyone"
    assert html_response(conn, 200) =~ "Welcome everyone"
  end

  test "global search AJAX", %{conn: conn, workspace: workspace} do
    Palapa.Documents.create_document(workspace.richard, nil, %{
      title: "Styleguide for everyone"
    })

    Palapa.Messages.create(workspace.richard, %{
      title: "Welcome everyone",
      content: "It is really a pleasure"
    })

    conn =
      conn
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> put_req_header("content-type", "text/html")
      |> get(search_path(conn, :index, workspace.organization, query: "every"))

    assert html_response(conn, 200) =~ "Styleguide for everyone"
    assert html_response(conn, 200) =~ "Welcome everyone"
  end
end
