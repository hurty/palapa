defmodule Palapa.DocumentsTest do
  use Palapa.DataCase

  alias Palapa.Documents
  alias Palapa.Documents.{Document, Section, Page}
  alias Palapa.Events.Event

  import Palapa.Factory

  @valid_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  def document_fixture() do
    organization = insert!(:organization)
    author = insert!(:member, organization: organization)

    {:ok, document} = Documents.create_document(author, nil, @valid_attrs)

    document
  end

  describe "documents" do
    alias Palapa.Documents.Document

    test "list_documents/0 returns all documents" do
      document = document_fixture()
      doc_ids = Documents.list_documents() |> Enum.map(fn doc -> doc.id end)
      assert doc_ids == [document.id]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Documents.get_document!(document.id).id == document.id
    end

    test "create_document/1 with valid data creates a document" do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)

      assert {:ok, document} = Documents.create_document(author, nil, @valid_attrs)

      assert document.title == "some title"

      event_query = from(events in Event, where: events.document_id == ^document.id)
      assert Repo.exists?(event_query)
    end

    test "create_document/1 with invalid data returns error changeset" do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)

      assert {:error, %Ecto.Changeset{}} = Documents.create_document(author, nil, @invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture() |> Repo.preload(:organization)
      second_author = insert!(:admin, organization: document.organization)
      team = insert!(:team, organization: document.organization)

      assert {:ok, document} =
               Documents.update_document(document, second_author, team, @update_attrs)

      assert %Document{} = document
      assert document.title == "some updated title"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture() |> Repo.preload(:organization)
      second_author = insert!(:admin, organization: document.organization)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_document(document, second_author, nil, @invalid_attrs)

      assert document.title == Documents.get_document!(document.id).title
    end

    test "delete_document/2 marks the document and its pages as deleted" do
      document = document_fixture() |> Repo.preload(:last_author)

      assert Documents.delete_document!(document, document.last_author)
      document = Repo.reload(document)
      assert Documents.deleted?(document)
    end

    test "restore_document/1 unmarks the document as deleted" do
      document = document_fixture() |> Repo.preload(:last_author)
      Documents.delete_document!(document, document.last_author)
      document = Repo.reload(document)

      assert Documents.restore_document!(document)
      document = Repo.reload(document)
      refute Documents.deleted?(document)
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end

  describe "sections" do
    test "create section" do
      document = document_fixture()

      {:ok, section} = Documents.create_section(document, document.last_author, @valid_attrs)

      assert %Section{} = section
      assert "First section", section.title
    end

    test "create section with invalid data" do
      document = document_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Documents.create_section(document, document.last_author, @invalid_attrs)
    end

    test "get section" do
      document = document_fixture()
      {:ok, section} = Documents.create_section(document, document.last_author, @valid_attrs)

      assert %Section{} = fetched_section = Documents.get_section!(section.id)
      assert fetched_section.id == section.id
    end

    test "change section" do
      document = document_fixture()
      {:ok, section} = Documents.create_section(document, document.last_author, @valid_attrs)
      assert %Ecto.Changeset{} = Documents.change_section(section)
    end

    test "update section" do
      document = document_fixture()
      organization = Repo.get_assoc(document, :organization)
      second_author = insert!(:admin, organization: organization)

      {:ok, section} = Documents.create_section(document, document.last_author, @valid_attrs)
      {:ok, updated_section} = Documents.update_section(section, second_author, @update_attrs)
      assert updated_section.title == "some updated title"
    end

    test "update section with invalid data" do
      document = document_fixture()
      {:ok, section} = Documents.create_section(document, document.last_author, @valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_section(section, document.last_author, @invalid_attrs)
    end

    test "delete section" do
      document = document_fixture()
      organization = Repo.get_assoc(document, :organization)
      second_author = insert!(:admin, organization: organization)

      {:ok, section} = Documents.create_section(document, document.last_author, @valid_attrs)
      assert {:ok, deleted_section} = Documents.delete_section(section, second_author)
      assert deleted_section.deleted_at
    end
  end

  describe "pages" do
    @valid_page_attrs %{
      title: "My page",
      content: "Great content here"
    }

    setup do
      document = document_fixture()

      %{document: document}
    end

    test "creating new pages at the bottom of a section", %{document: document} do
      assert {:ok, %Page{} = first_page} =
               Documents.create_page(
                 document,
                 document.last_author,
                 @valid_page_attrs
               )

      event_query =
        from(events in Event,
          where: events.document_id == ^document.id and events.page_id == ^first_page.id
        )

      assert Repo.exists?(event_query)

      # Main section has a main page with position 0,
      # so following pages start at position 1
      assert 1 == first_page.position

      assert {:ok, %Page{} = second_page} =
               Documents.create_page(
                 document,
                 document.last_author,
                 @valid_page_attrs
               )

      assert 2 == second_page.position
    end

    test "update page", %{document: document} do
      {:ok, %Page{} = page} =
        Documents.create_page(
          document,
          document.last_author,
          @valid_page_attrs
        )

      organization = Repo.get_assoc(document, :organization)
      second_author = insert!(:admin, organization: organization)
      update_attrs = %{title: "New page title", content: "Updated content"}
      assert {:ok, page} = Documents.update_page(page, second_author, update_attrs)
      assert update_attrs.content == to_string(page.content)
    end

    test "change page returns a changeset", %{document: document} do
      {:ok, %Page{} = page} =
        Documents.create_page(
          document,
          document.last_author,
          @valid_page_attrs
        )

      assert %Ecto.Changeset{} = Documents.change_page(page)
    end

    test "delete page", %{document: document} do
      {:ok, %Page{} = page} =
        Documents.create_page(
          document,
          document.last_author,
          @valid_page_attrs
        )

      {:ok, deleted_page} = Documents.delete_page(page, document.last_author)
      assert deleted_page.deleted_at
    end
  end

  describe "pages and Sections ordering." do
    # We have the following setup
    #
    #
    # - first_section
    #   -- first page
    #   -- blue page
    #   -- red page
    #
    # - Nice Section
    #   -- yellow page
    #
    # - Angry Section (which has no page)

    setup do
      document = document_fixture()

      author = document.last_author

      {:ok, nice_section} = Documents.create_section(document, author, %{title: "nice section"})
      {:ok, angry_section} = Documents.create_section(document, author, %{title: "angry section"})

      {:ok, blue_page} = Documents.create_page(document, author, %{title: "blue page"})

      {:ok, red_page} = Documents.create_page(document, author, %{title: "red page"})

      {:ok, yellow_page} = Documents.create_page(nice_section, author, %{title: "yellow page"})

      %{
        author: author,
        document: document,
        blue_page: blue_page,
        red_page: red_page,
        nice_section: nice_section,
        yellow_page: yellow_page,
        angry_section: angry_section
      }
    end

    test "previous page of first page is nil", %{document: document} do
      first_page = Documents.get_first_page(document)

      assert 0 == first_page.position
      refute Documents.get_previous_page(first_page)
    end

    test "previous page of a page inside the same section", %{
      blue_page: blue_page,
      red_page: red_page
    } do
      assert blue_page.id == Documents.get_previous_page(red_page).id
    end

    test "previous page accross normal section and main section", %{
      red_page: red_page,
      yellow_page: yellow_page
    } do
      assert red_page.id == Documents.get_previous_page(yellow_page).id
    end

    test "previous page accross normal sections", %{
      author: author,
      yellow_page: yellow_page,
      angry_section: angry_section
    } do
      # We start by having:
      # - Nice Section
      #   -- yellow page
      #
      # - Angry Section (which has no page)

      {:ok, pink_page} = Documents.create_page(angry_section, author, %{title: "pink page"})
      assert yellow_page.id == Documents.get_previous_page(pink_page).id
    end

    test "next page of last page is nil", %{yellow_page: yellow_page} do
      refute Documents.get_next_page(yellow_page)
    end

    test "next page inside the same section", %{blue_page: blue_page, red_page: red_page} do
      assert red_page.id == Documents.get_next_page(blue_page).id
    end

    test "next page accross sections", %{red_page: red_page, yellow_page: yellow_page} do
      assert yellow_page.id == Documents.get_next_page(red_page).id
    end

    test "can't move a page at wrong (negative) position", %{
      document: document,
      blue_page: blue_page,
      author: author
    } do
      first_section = Documents.get_first_section!(document)

      assert {:error, %Ecto.Changeset{}} =
               Documents.move_page(blue_page, author, first_section, -1)
    end

    test "can't move a page higher than the maximum position", %{
      document: document,
      blue_page: blue_page,
      author: author
    } do
      first_section = Documents.get_first_section!(document)

      assert {:error, %Ecto.Changeset{}} =
               Documents.move_page(blue_page, author, first_section, 100)
    end

    test "moving a page inside the same section at a lower position", %{
      document: document,
      blue_page: blue_page,
      red_page: red_page,
      author: author
    } do
      # Moving the red page before the red page
      red_page = Repo.preload(red_page, :section)

      new_position = red_page.position - 1
      Documents.move_page(red_page, author, red_page.section, new_position)

      document = Repo.reload(document)
      first_page = Documents.get_first_page(document)
      blue_page = Repo.reload(blue_page)
      red_page = Repo.reload(red_page)

      assert 0 == first_page.position
      assert 1 == red_page.position
      assert 2 == blue_page.position
    end

    test "moving a page inside the same section at a higher position", %{
      document: document,
      blue_page: blue_page,
      red_page: red_page,
      author: author
    } do
      # Moving the blue page above the red page
      blue_page = Repo.preload(blue_page, :section)
      Documents.move_page(blue_page, author, blue_page.section, blue_page.position + 1)

      document = Repo.reload(document)
      first_page = Documents.get_first_page(document)
      red_page = Repo.reload(red_page)
      blue_page = Repo.reload(blue_page)

      assert 0 == first_page.position
      assert 1 == red_page.position
      assert 2 == blue_page.position
    end

    test "moving a page in another section", %{
      document: document,
      blue_page: blue_page,
      red_page: red_page,
      yellow_page: yellow_page,
      author: author
    } do
      first_section = Documents.get_first_section!(document)
      Documents.move_page(yellow_page, author, first_section, 1)

      document = Repo.reload(document)
      first_page = Documents.get_first_page(document)
      red_page = Repo.reload(red_page)
      blue_page = Repo.reload(blue_page)
      yellow_page = Repo.reload(yellow_page)

      assert 0 == first_page.position
      assert 1 == yellow_page.position
      assert 2 == blue_page.position
      assert 3 == red_page.position
    end
  end
end
