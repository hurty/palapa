defmodule Palapa.Documents do
  @moduledoc """
  The Documents context.
  """
  use Palapa.Context

  alias Palapa.Documents.{Document, Section, Page}
  alias Palapa.Position

  def list_documents(organization) do
    Document
    |> where(organization_id: ^organization.id)
    |> Repo.all()
  end

  def get_document!(id) do
    pages_query = from(s in Page, order_by: s.position)
    sections_query = from(s in Section, order_by: s.position, preload: [pages: ^pages_query])

    from(document in Document,
      preload: [sections: ^sections_query, pages: ^pages_query]
    )
    |> Repo.get!(id)
  end

  def create_document(organization, author, attrs \\ %{}) do
    Repo.transaction(fn ->
      document =
        %Document{}
        |> Document.changeset(attrs)
        |> put_assoc(:organization, organization)
        |> put_assoc(:last_author, author)
        |> Repo.insert!()

      first_page =
        %Page{}
        |> Page.changeset(%{title: param(attrs, :title), position: 0})
        |> put_assoc(:document, document)
        |> put_assoc(:last_author, author)
        |> Repo.insert!()

      document
      |> change(first_page_id: first_page.id)
      |> Repo.update!()
    end)
  end

  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  def change_document(%Document{} = document) do
    Document.changeset(document, %{})
  end

  def get_page!(id) do
    Page
    |> preload(last_author: :account)
    |> Repo.get!(id)
  end

  def create_section(document, attrs) do
    document
    |> Ecto.build_assoc(:sections)
    |> Section.changeset(attrs)
    |> Position.move_to_bottom()
    |> Repo.insert()
  end

  def change_section(section) do
    Section.changeset(section, %{})
  end
end
