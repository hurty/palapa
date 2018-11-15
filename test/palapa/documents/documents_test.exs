defmodule Palapa.DocumentsTest do
  use Palapa.DataCase
  alias Palapa.Documents

  import Palapa.Factory

  describe "documents" do
    alias Palapa.Documents.Document

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def document_fixture() do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)

      {:ok, document} = Documents.create_document(organization, author, @valid_attrs)

      document
    end

    test "list_documents/0 returns all documents" do
      document = document_fixture()
      doc_ids = Documents.list_documents(document.organization) |> Enum.map(fn doc -> doc.id end)
      assert doc_ids == [document.id]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Documents.get_document!(document.id).id == document.id
    end

    test "create_document/1 with valid data creates a document" do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)

      assert {:ok, %Document{} = document} =
               Documents.create_document(organization, author, @valid_attrs)

      assert document.title == "some title"
      assert document.main_section_id
      assert document.main_page_id
    end

    test "create_document/1 with invalid data returns error changeset" do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)

      assert {:error, %Ecto.Changeset{}} =
               Documents.create_document(organization, author, @invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      second_author = insert!(:admin, organization: document.organization)

      assert {:ok, document} = Documents.update_document(document, second_author, @update_attrs)
      assert %Document{} = document
      assert document.title == "some updated title"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      second_author = insert!(:admin, organization: document.organization)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_document(document, second_author, @invalid_attrs)

      assert document.title == Documents.get_document!(document.id).title
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Documents.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end
end
