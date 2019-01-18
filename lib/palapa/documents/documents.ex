defmodule Palapa.Documents do
  @moduledoc """
  The Documents context.
  """
  use Palapa.Context

  alias Palapa.Documents.{Document, Section, Page, DocumentAccess}
  alias Palapa.Position

  # --- Errors

  defmodule DeleteMainPageError do
    defexception message: "Cannot delete the main page of a document."
  end

  defmodule ForbiddenPositionError do
    defexception message: "This position is forbidden"
  end

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Documents.Policy)

  # --- Scopes

  def non_deleted(queryable) do
    queryable
    |> where([q], is_nil(q.deleted_at))
  end

  def documents_visible_to(queryable \\ Document, %Member{} = member) do
    member_teams_ids =
      Ecto.assoc(member, :teams)
      |> Repo.all()
      |> Enum.map(fn team -> team.id end)

    queryable
    |> join(:left, [documents], document_teams in assoc(documents, :teams))
    |> where([_, t], t.id in ^member_teams_ids)
    |> or_where(shared_with_everyone: true, organization_id: ^member.organization_id)
    |> distinct(true)
  end

  def pages_visible_to(queryable \\ Page, %Member{} = member) do
    member_teams_ids =
      Ecto.assoc(member, :teams)
      |> Repo.all()
      |> Enum.map(fn team -> team.id end)

    queryable
    |> join(:left, [pages], documents in assoc(pages, :document))
    |> join(:left, [pages, documents], document_teams in assoc(documents, :teams))
    |> where([_, _, teams], teams.id in ^member_teams_ids)
    |> or_where(
      [_pages, documents, _teams],
      documents.shared_with_everyone == true and
        documents.organization_id == ^member.organization_id
    )
    |> distinct(true)
  end

  def sections_visible_to(queryable \\ Section, %Member{} = member) do
    member_teams_ids =
      Ecto.assoc(member, :teams)
      |> Repo.all()
      |> Enum.map(fn team -> team.id end)

    queryable
    |> join(:left, [sections], documents in assoc(sections, :document))
    |> join(:left, [sections, documents], document_teams in assoc(documents, :teams))
    |> where([_, _, teams], teams.id in ^member_teams_ids)
    |> or_where(
      [_sections, documents, _teams],
      documents.shared_with_everyone == true and
        documents.organization_id == ^member.organization_id
    )
    |> distinct(true)
  end

  # --- Actions

  def list_documents(member) do
    documents_visible_to(member)
    |> non_deleted()
    |> preload(:teams)
    |> Repo.all()
  end

  def get_document!(queryable \\ Document, id, accessing_member \\ nil) do
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

    document =
      from(document in queryable,
        preload: [sections: ^sections_query],
        preload: [main_section: [pages: ^section_pages_query]]
      )
      |> non_deleted()
      |> Repo.get!(id)

    if accessing_member do
      mark_document_as_accessed!(document, accessing_member)
    end

    document
  end

  def create_document(author, attrs) do
    create_document(author, [], attrs)
  end

  def create_document(author, teams, attrs) do
    document_changeset =
      %Document{}
      |> Document.changeset(attrs)
      |> put_change(:shared_with_everyone, Enum.empty?(teams))
      |> put_change(:organization_id, author.organization_id)
      |> put_assoc(:teams, teams)
      |> put_assoc(:last_author, author)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:document, document_changeset)
    |> Ecto.Multi.run(:main_section, fn _repo, changes ->
      create_section(changes.document, author, attrs)
    end)
    |> Ecto.Multi.run(:main_page, fn _repo, changes ->
      create_page(changes.main_section, author, attrs)
    end)
    |> Ecto.Multi.run(:linked_document, fn _repo, changes ->
      changes.document
      |> change(main_section_id: changes.main_section.id)
      |> change(main_page_id: changes.main_page.id)
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result.linked_document}

      {:error, _step, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def update_document(document, author, attrs) do
    document
    |> Document.changeset(attrs)
    |> put_assoc(:last_author, author)
    |> Repo.update()
  end

  def delete_document(document) do
    Repo.delete(document)
  end

  def change_document(document) do
    Document.changeset(document, %{})
  end

  def document_visible_to?(document, member) do
    document.shared_with_everyone ||
      documents_visible_to(member)
      |> where(id: ^document.id)
      |> Repo.exists?()
  end

  def create_section(document, author, attrs) do
    document
    |> Ecto.build_assoc(:sections)
    |> Section.changeset(attrs)
    |> put_assoc(:last_author, author)
    |> put_assoc(:pages, [])
    |> Position.insert_at_bottom(:document_id, document.id, :position)
    |> Repo.insert()
  end

  def get_section!(queryable \\ Section, id) do
    queryable
    |> preload(document: [:teams])
    |> Repo.get!(id)
  end

  def change_section(section \\ %Section{}) do
    Section.changeset(section, %{})
  end

  def update_section(section, attrs) do
    Section.changeset(section, attrs)
    |> Palapa.Position.recompute_positions(:document_id, :position)
    |> Repo.update()
  end

  def delete_section(section) do
    section
    |> change
    |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> Palapa.Position.recompute_positions(:document_id, :position)
    |> Repo.update()
  end

  def main_section?(section) do
    section = Repo.preload(section, :document)
    section.id == section.document.main_section_id
  end

  def get_page!(queryable \\ Page, id, accessing_member \\ nil) do
    page =
      queryable
      |> Page.with_document()
      |> Page.with_last_author()
      |> Repo.get!(id)

    if accessing_member do
      mark_document_as_accessed!(page.document, accessing_member)
    end

    page
  end

  def create_page(section, author, attrs) do
    %Page{}
    |> Page.changeset(attrs)
    |> put_change(:document_id, section.document_id)
    |> put_assoc(:last_author, author)
    |> put_change(:section_id, section.id)
    |> Position.insert_at_bottom(:section_id, section.id, :position)
    |> Repo.insert()
  end

  def update_page(page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Palapa.Position.recompute_positions(:section_id, :position)
    |> Repo.update()
  end

  def change_page(page \\ %Page{}, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  def move_page!(page, new_section, new_position) do
    if main_section?(new_section) && new_position == 0 do
      raise ForbiddenPositionError
    end

    page
    |> Page.changeset(%{
      "section_id" => new_section.id,
      "position" => new_position
    })
    |> Palapa.Position.recompute_positions(:section_id, :position)
    |> Repo.update!()
  end

  def delete_page!(page) do
    if main_page?(page) do
      raise DeleteMainPageError
    end

    page
    |> change
    |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> Palapa.Position.recompute_positions(:section_id, :position)
    |> Repo.update!()
  end

  def main_page?(page) do
    page = Repo.preload(page, :document)
    page.id == page.document.main_page_id
  end

  def get_previous_page(page) do
    page = Repo.preload(page, [:section])

    from(p in Page,
      join: s in Section,
      as: :section,
      on: p.section_id == s.id,
      where: is_nil(p.deleted_at),
      where: is_nil(s.deleted_at),
      where: p.document_id == ^page.document_id,
      where:
        (s.position == ^page.section.position and p.position < ^page.position) or
          s.position < ^page.section.position,
      order_by: [desc: s.position, desc: p.position],
      limit: 1
    )
    |> Repo.one()
  end

  def get_next_page(page) do
    page = Repo.preload(page, [:section])

    from(p in Page,
      join: s in Section,
      as: :section,
      on: p.section_id == s.id,
      where: is_nil(p.deleted_at),
      where: is_nil(s.deleted_at),
      where: p.document_id == ^page.document_id,
      where:
        (s.position == ^page.section.position and p.position > ^page.position) or
          s.position > ^page.section.position,
      order_by: [asc: s.position, asc: p.position],
      limit: 1
    )
    |> Repo.one()
  end

  def mark_document_as_accessed!(document, member) do
    DocumentAccess.changeset(%{
      document: document,
      member: member,
      last_access_at: DateTime.utc_now()
    })
    |> Repo.insert!(
      on_conflict: :replace_all,
      conflict_target: [:document_id, :member_id]
    )
  end
end
