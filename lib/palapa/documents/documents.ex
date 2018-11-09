defmodule Palapa.Documents do
  @moduledoc """
  The Documents context.
  """
  use Palapa.Context

  alias Palapa.Documents.{Document, Section, Page}
  alias Palapa.Position

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Documents.Policy)

  # --- Scopes

  def non_deleted(queryable) do
    queryable
    |> where([q], is_nil(q.deleted_at))
  end

  # --- Actions

  def list_documents(organization) do
    Document
    |> where(organization_id: ^organization.id)
    |> Repo.all()
  end

  def get_document!(id) do
    section_pages_query =
      from(p in Page,
        order_by: p.position
      )
      |> non_deleted()

    sections_query =
      from(s in Section,
        order_by: s.position,
        preload: [pages: ^section_pages_query]
      )
      |> non_deleted()

    from(document in Document,
      preload: [sections: ^sections_query],
      preload: [main_section: [pages: ^section_pages_query]]
    )
    |> Repo.get!(id)
  end

  def create_document(organization, author, attrs \\ %{}) do
    document_changeset =
      %Document{}
      |> Document.changeset(attrs)
      |> put_change(:public, true)
      |> put_assoc(:organization, organization)
      |> put_assoc(:last_author, author)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:document, document_changeset)
    |> Ecto.Multi.run(:main_section, fn _repo, changes ->
      create_section(changes.document, author, %{title: "__main_section__"})
    end)
    |> Ecto.Multi.run(:main_page, fn _repo, changes ->
      create_page(changes.document, changes.main_section, author, attrs)
    end)
    |> Ecto.Multi.run(:link_main_page, fn _repo, changes ->
      changes.document
      |> change(main_section_id: changes.main_section.id)
      |> change(main_page_id: changes.main_page.id)
      |> Repo.update()
    end)
    |> Repo.transaction()
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
    |> Position.move_to_bottom(:document_id)
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

  def delete_section(section) do
    section
    |> change
    |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update()
  end

  def get_page!(id) do
    page =
      Page
      |> Page.with_document()
      |> Page.with_last_author()
      |> Page.with_rich_text()
      |> Repo.get!(id)

    if page.rich_text && page.rich_text.body do
      Map.put(page, :body, page.rich_text.body)
    else
      page
    end
  end

  def create_page(document, section, author, attrs) do
    %Page{}
    |> Page.changeset(%{title: param(attrs, :title)})
    |> put_assoc(:document, document)
    |> put_assoc(:last_author, author)
    |> put_change(:section_id, section.id)
    |> Position.move_to_bottom(:section_id)
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

  def move_page!(page, new_section, new_position) do
    page
    |> Page.changeset(%{
      "section_id" => new_section.id,
      "position" => new_position
    })
    |> Position.recompute_positions()
    |> Repo.update!()
  end

  def delete_page!(page) do
    page
    |> change
    |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update!()
  end

  def get_previous_page(page) do
    # prendre la page avec l'id de position n+1
    # si elle n'existe pas, prendre l'id 1 de la section précédente s'il y en a une

    page = Repo.preload(page, :section)

    case page.position do
      0 -> fetch_last_page_in_previous_section(page)
      _ -> fetch_previous_page_in_the_same_section(page)
    end
  end

  defp fetch_last_page_in_previous_section(page) do
    case page.section.position do
      # if we are in the main section of the document there is no previous section.
      0 -> nil
      _ -> fetch_last_page_in_section_with_position(page.document, page.section.position - 1)
    end
  end

  defp fetch_last_page_in_section_with_position(document, position) do
    # section_id_query =
    #   from(s in Section,
    #     where: is_nil(s.deleted_at),
    #     where: s.document_id == ^document.id and s.position == ^position
    #   )

    from(p in Page,
      join: s in Section,
      on: p.section_id == s.id,
      where: is_nil(p.deleted_at),
      where: is_nil(s.deleted_at),
      where: s.document_id == ^document.id and s.position == ^position,
      order_by: [desc_nulls_last: :position],
      limit: 1
    )
    |> Repo.one()
  end

  defp fetch_previous_page_in_the_same_section(page) do
    IO.puts("fetch_previous_page_in_the_same_section")

    from(p in Page,
      where: is_nil(p.deleted_at),
      where:
        p.document_id == ^page.document_id and p.section_id == ^page.section_id and
          p.position == ^(page.position - 1)
    )
    |> Repo.one()
  end
end
