defmodule Palapa.Documents do
  @moduledoc """
  The Documents context.
  """
  use Palapa.Context

  alias Palapa.Documents.{Document, Section, Page}
  alias Palapa.Position

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Documents.Policy)

  # --- Actions

  def list_documents(organization) do
    Document
    |> where(organization_id: ^organization.id)
    |> Repo.all()
  end

  def get_document!(id) do
    root_pages_query = from(p in Page, where: is_nil(p.section_id), order_by: p.position)
    section_pages_query = from(p in Page, where: not is_nil(p.section_id), order_by: p.position)

    sections_query =
      from(s in Section, order_by: s.position, preload: [pages: ^section_pages_query])

    from(document in Document,
      preload: [sections: ^sections_query, pages: ^root_pages_query]
    )
    |> Repo.get!(id)
  end

  def create_document(organization, author, attrs \\ %{}) do
    Repo.transaction(fn ->
      document =
        Document.changeset(attrs)
        |> put_change(:public, true)
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

  def create_section(document, author, attrs) do
    document
    |> Ecto.build_assoc(:sections)
    |> Section.changeset(attrs)
    |> put_assoc(:last_author, author)
    |> put_assoc(:pages, [])
    |> Position.move_to_bottom()
    |> Repo.insert()
  end

  def get_section!(id) do
    Section
    |> preload(document: [:team])
    |> Repo.get!(id)
  end

  def change_section(section \\ %Section{}) do
    Section.changeset(section, %{})
  end

  def update_section(section, attrs) do
    Section.changeset(section, attrs)
    |> Repo.update()
  end

  def get_page!(id) do
    page =
      Page
      |> Page.with_last_author()
      |> Page.with_rich_text()
      |> Repo.get!(id)

    if page.rich_text && page.rich_text.body do
      Map.put(page, :body, page.rich_text.body)
    else
      page
    end
  end

  def create_page(document, author, attrs) do
    %Page{}
    |> Page.changeset(%{title: param(attrs, :title)})
    |> put_assoc(:document, document)
    |> put_assoc(:last_author, author)
    |> Position.move_to_bottom()
    |> Repo.insert()
  end

  def update_page(page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  def change_page(page \\ %Page{}) do
    Page.changeset(page, %{})
  end
end
