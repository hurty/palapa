defmodule Palapa.SearchesTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Searches

  setup do
    workspace = insert_pied_piper!(:full)
    {:ok, workspace: workspace}
  end

  describe "search in members" do
    test "search non-existant member", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "johndoe")

      assert [] == results.entries
    end

    test "search member", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "dinesh")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Dinesh Chugtai" && entry.resource_type == :member
             end)
    end

    test "search member by partial last name", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "chug")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Dinesh Chugtai" && entry.resource_type == :member
             end)
    end

    test "search member with extra whitespaces", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "  dinesh  ")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Dinesh Chugtai" && entry.resource_type == :member
             end)
    end

    test "search member with mixed case", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "DinESH")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Dinesh Chugtai" && entry.resource_type == :member
             end)
    end
  end

  describe "search in teams" do
    test "search non-existant teams", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "teamfromnowhere")

      assert [] == results.entries
    end

    test "search team", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "management")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Management" && entry.resource_type == :team
             end)
    end

    test "search member by partial last name", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "mana")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Management" && entry.resource_type == :team
             end)
    end

    test "search member with extra whitespaces", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "  management  ")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Management" && entry.resource_type == :team
             end)
    end

    test "search member with mixed case", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "MaNaGement")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Management" && entry.resource_type == :team
             end)
    end
  end

  describe "search in messages" do
    setup %{workspace: workspace} do
      message =
        Palapa.Messages.create(workspace.richard, %{
          title: "Welcome everyone",
          content: "It is really a pleasure"
        })

      {:ok, workspace: workspace, message: message}
    end

    test "search non-existant message", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "no-message")

      assert [] == results.entries
    end

    test "search message", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "welcome")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Welcome everyone" && entry.resource_type == :message
             end)
    end

    test "search message by partial title", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "every")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Welcome everyone" && entry.resource_type == :message
             end)
    end

    test "search message with extra whitespaces", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "  welcome  ")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Welcome everyone" && entry.resource_type == :message
             end)
    end

    test "search message with mixed case", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "WeLcOmE")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Welcome everyone" && entry.resource_type == :message
             end)
    end

    test "search message with content", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "pleasure")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Welcome everyone" && entry.resource_type == :message
             end)
    end
  end

  describe "search in documents" do
    setup %{workspace: workspace} do
      {:ok, document} =
        Palapa.Documents.create_document(workspace.richard, nil, %{
          title: "Styleguide"
        })

      {:ok, workspace: workspace, document: document}
    end

    test "search non-existant document page", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "no-doc")

      assert [] == results.entries
    end

    test "search document page", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "styleguide")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Styleguide" && entry.resource_type == :page
             end)
    end

    test "search document page by partial title", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "style")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Styleguide" && entry.resource_type == :page
             end)
    end

    test "search document page with extra whitespaces", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "  styleguide  ")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Styleguide" && entry.resource_type == :page
             end)
    end

    test "search document page with mixed case", %{workspace: workspace} do
      results = Searches.search(workspace.richard, "StYleGuidE")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Styleguide" && entry.resource_type == :page
             end)
    end

    test "search document page with content", %{workspace: workspace, document: document} do
      Palapa.Documents.get_first_page(document)
      |> Palapa.Documents.update_page(%{
        content: "<p>The style you must follow</p>"
      })

      results = Searches.search(workspace.richard, "follow")

      assert Enum.find_value(results.entries, fn entry ->
               entry.title == "Styleguide" && entry.resource_type == :page
             end)
    end
  end
end
