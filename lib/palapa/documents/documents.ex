defmodule Palapa.Documents do
  use Palapa.Context
  import EctoEnum

  alias Palapa.Documents.{Document, Section, Page, DocumentAccess}
  alias Palapa.Teams.Team
  alias Palapa.Position
  alias Palapa.Events.Event

  defenum(DocumentTypeEnum, :type, ~w(
    internal
    attachment
    link
  )s)

  # --- Errors

  defmodule DeleteMainPageError do
    defexception message: "Cannot delete the main page of a document."
  end

  defmodule ForbiddenPositionError do
    defexception message: "This position is forbidden"
  end

  # --- Scopes

  def non_deleted(queryable) do
    queryable
    |> where([q], is_nil(q.deleted_at))
  end

  def deleted(queryable) do
    queryable
    |> where([q], not is_nil(q.deleted_at))
    |> order_by(desc: :deleted_at)
    |> preload(deletion_author: :account)
  end

  def documents_visible_to(queryable \\ Document, %Member{} = member) do
    from(documents in queryable,
      where: documents.organization_id == ^member.organization_id and is_nil(documents.team_id),
      or_where: documents.team_id in ^Teams.list_ids_for_member(member)
    )
  end

  def pages_visible_to(queryable \\ Page, %Member{} = member) do
    from(pages in queryable,
      join: documents in assoc(pages, :document),
      where: documents.organization_id == ^member.organization_id and is_nil(documents.team_id),
      or_where: documents.team_id in ^Teams.list_ids_for_member(member)
    )
  end

  def sections_visible_to(queryable \\ Section, %Member{} = member) do
    from(sections in queryable,
      join: documents in assoc(sections, :document),
      where: documents.organization_id == ^member.organization_id and is_nil(documents.team_id),
      or_where: documents.team_id in ^Teams.list_ids_for_member(member)
    )
  end

  def documents_sorted_by(queryable, field) do
    case field do
      "title" -> order_by(queryable, asc: :title)
      _ -> order_by(queryable, desc_nulls_first: :updated_at)
    end
  end

  def documents_shared_with_team(querybale \\ Document, team)
  def documents_shared_with_team(queryable, team) when is_nil(team), do: queryable

  def documents_shared_with_team(queryable, %Team{} = team) do
    from(q in queryable,
      join: t in assoc(q, :team),
      where: t.id == ^team.id
    )
  end

  def documents_with_search_query(queryable \\ Document, search_string) do
    if Palapa.Searches.blank_query?(search_string) do
      queryable
    else
      matching_documents_query =
        from(searches in Palapa.Searches.search_query(search_string),
          join: pages in assoc(searches, :page),
          join: documents in assoc(pages, :document),
          select: documents.id
        )

      from(q in queryable,
        join: matching_docs in ^subquery(matching_documents_query),
        on: q.id == matching_docs.id,
        distinct: true
      )
    end
  end

  # --- Actions

  def list_documents(queryable \\ Document, page \\ 1) do
    queryable
    |> preload([:team, [last_author: :account]])
    |> Repo.paginate(page: page, page_size: 15)
  end

  def recent_documents(member) do
    last_accessed_documents_query =
      from(da in DocumentAccess,
        where: da.member_id == ^member.id,
        order_by: [desc: :last_access_at],
        limit: 6
      )

    Document
    |> documents_visible_to(member)
    |> join(:inner, [d], document_accesses in subquery(last_accessed_documents_query),
      on: d.id == document_accesses.document_id
    )
    |> non_deleted()
    |> preload(:team)
    |> select([documents, ..., document_accesses], {documents, document_accesses})
    |> order_by([documents, ..., document_accesses], desc: document_accesses.last_access_at)
    |> Repo.all()
    |> Enum.map(fn {doc, _access} -> doc end)
  end

  def get_document!(queryable \\ Document, id, accessing_member \\ nil) do
    section_pages_query =
      from(p in Page,
        order_by: p.position
      )
      |> non_deleted

    sections_query =
      from(s in Section,
        order_by: s.position,
        preload: [pages: ^section_pages_query]
      )
      |> non_deleted

    document =
      from(document in queryable,
        preload: [team: [], last_author: [:account]],
        preload: [sections: ^sections_query]
      )
      |> Repo.get!(id)

    if accessing_member do
      mark_document_as_accessed!(document, accessing_member)
    end

    document
  end

  def get_first_page(%Document{} = document) do
    from(sections in Ecto.assoc(document, :sections),
      join: pages in assoc(sections, :pages),
      where: sections.position == 0,
      where: pages.position == 0,
      where: is_nil(pages.deleted_at),
      select: pages
    )
    |> Repo.one()
  end

  def get_first_page(%Section{} = section) do
    from(pages in Ecto.assoc(section, :pages),
      where: pages.position == 0,
      where: is_nil(pages.deleted_at)
    )
    |> Repo.one()
  end

  def get_first_section!(document) do
    from(sections in Ecto.assoc(document, :sections),
      where: sections.position == 0
    )
    |> Repo.one!()
  end

  def create_document(author, team, attrs) do
    document_changeset =
      %Document{}
      |> Document.changeset(attrs)
      |> put_change(:organization_id, author.organization_id)
      |> put_assoc(:team, team)
      |> put_assoc(:last_author, author)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:document, document_changeset)
    |> Ecto.Multi.run(:first_section, fn _repo, changes ->
      create_first_section(changes.document, author)
    end)
    |> Ecto.Multi.run(:first_page, fn _repo, changes ->
      create_page(changes.first_section, author, attrs, true)
    end)
    |> Ecto.Multi.insert(:event, fn %{document: document} ->
      %Event{
        action: :new_document,
        organization_id: author.organization_id,
        author: author,
        document: document
      }
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result.document}

      {:error, _step, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def document_has_at_least_one_section?(document) do
    Ecto.assoc(document, :sections)
    |> non_deleted()
    |> Repo.exists?()
  end

  def create_first_section(document, author) do
    create_section(document, author, %{title: "Document pages"})
  end

  def update_document(document, author, team, attrs) do
    document
    |> Document.changeset(attrs)
    |> put_change(:last_author_id, author.id)
    |> put_team(team)
    |> Repo.update()
  end

  defp put_team(changeset, team) when is_nil(team) do
    put_change(changeset, :team_id, nil)
  end

  defp put_team(changeset, %Team{} = team) do
    put_change(changeset, :team_id, team.id)
  end

  def delete_document!(document, author) do
    unless deleted?(document) do
      document
      |> Document.delete_changeset(author)
      |> Repo.update!()
    end
  end

  def deleted?(item) do
    !is_nil(item.deleted_at)
  end

  def restore_document!(document) do
    document
    |> Document.restore_changeset()
    |> Repo.update!()
  end

  def change_document(document) do
    Document.changeset(document, %{})
  end

  def touch_document(%Document{} = document, %Member{} = author) do
    document
    |> change(%{last_author_id: author.id})
    |> Repo.update()
  end

  def document_visible_to?(document, member) do
    documents_visible_to(member)
    |> where(id: ^document.id)
    |> Repo.exists?()
  end

  def create_section(document, author, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:section, fn repo, _changes ->
      document
      |> Ecto.build_assoc(:sections)
      |> Section.changeset(attrs)
      |> put_change(:last_author_id, author.id)
      |> put_assoc(:pages, [])
      |> Position.insert_at_bottom(:document_id, document.id, :position)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{section: section}} -> {:ok, section}
      {:error, :section, changeset, _changes} -> {:error, changeset}
    end
  end

  def get_section!(queryable \\ Section, id) do
    queryable
    |> preload(document: [:team])
    |> Repo.get!(id)
  end

  def change_section(section \\ %Section{}) do
    Section.changeset(section, %{})
  end

  def update_section(section, author, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:section, fn repo, _changes ->
      Section.changeset(section, attrs)
      |> Palapa.Position.recompute_positions(:document_id, :position)
      |> repo.update()
    end)
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      document = Repo.get_assoc(section, :document)
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{section: section}} -> {:ok, section}
      {:error, :section, changeset, _changes} -> {:error, changeset}
    end
  end

  def delete_section(section, author) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:section, fn repo, _changes ->
      section
      |> change
      |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
      |> put_change(:position, nil)
      |> Palapa.Position.recompute_positions(:document_id, :position)
      |> repo.update()
    end)
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      document = Repo.get_assoc(section, :document)
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{section: section}} -> {:ok, section}
      {:error, :section, changeset, _changes} -> {:error, changeset}
    end
  end

  def get_page!(queryable \\ Page, id, accessing_member \\ nil) do
    page =
      queryable
      |> Page.with_document()
      |> Page.with_section()
      |> Page.with_last_author()
      |> Page.with_attachments()
      |> Repo.get!(id)

    if accessing_member do
      mark_document_as_accessed!(page.document, accessing_member)
    end

    page
  end

  def create_page(document_or_section, author, attrs, skip_event \\ false)

  def create_page(%Section{} = section, author, attrs, skip_event) do
    page_changeset =
      %Page{}
      |> Page.changeset(attrs)
      |> put_change(:document_id, section.document_id)
      |> put_assoc(:last_author, author)
      |> put_change(:section_id, section.id)
      |> Position.insert_at_bottom(:section_id, section.id, :position)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:page, page_changeset)
    |> Ecto.Multi.run(
      :event,
      fn _repo, %{page: page} ->
        if skip_event do
          {:ok, nil}
        else
          %Event{
            action: :new_document_page,
            organization_id: author.organization_id,
            author: author,
            document_id: page.document_id,
            page_id: page.id
          }
          |> Repo.insert()
        end
      end
    )
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      document = Repo.get_assoc(section, :document)
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{page: page}} ->
        {:ok, page}

      {:error, _action, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def create_page(%Document{} = document, author, attrs, skip_event) do
    first_section = get_first_section!(document)
    create_page(first_section, author, attrs, skip_event)
  end

  def update_page(page, author, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:page, fn repo, _changes ->
      page
      |> Repo.preload([:attachments])
      |> Page.changeset(attrs)
      |> put_change(:last_author_id, author.id)
      |> Palapa.Position.recompute_positions(:section_id, :position)
      |> repo.update()
    end)
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      document = Repo.get_assoc(page, :document)
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{page: page}} -> {:ok, page}
      {:error, :page, changeset, _changes} -> {:error, changeset}
    end
  end

  def change_page(page \\ %Page{}, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  def move_page(page, author, new_section, new_position) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:page, fn repo, _changes ->
      page
      |> Page.changeset(%{
        "section_id" => new_section.id,
        "position" => new_position
      })
      |> Palapa.Position.recompute_positions(:section_id, :position)
      |> repo.update()
    end)
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      document = Repo.get_assoc(page, :document)
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{page: page}} -> {:ok, page}
      {:error, :page, changeset, _changes} -> {:error, changeset}
    end
  end

  def delete_page(page, author) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:page, fn _repo, _changes ->
      page
      |> change
      |> put_change(:deleted_at, DateTime.utc_now() |> DateTime.truncate(:second))
      |> put_change(:position, nil)
      |> Palapa.Position.recompute_positions(:section_id, :position)
      |> Repo.update()
    end)
    |> Ecto.Multi.run(:touch_document, fn _repo, _changes ->
      document = Repo.get_assoc(page, :document)
      touch_document(document, author)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{page: page}} -> {:ok, page}
      {:error, :page, changeset, _changes} -> {:error, changeset}
    end
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

  def get_document_by_public_token!(token) do
    section_pages_query =
      from(p in Page,
        order_by: p.position
      )
      |> non_deleted

    sections_query =
      from(s in Section,
        order_by: s.position,
        preload: [pages: ^section_pages_query]
      )
      |> non_deleted

    from(document in Document,
      preload: [:team, :last_author],
      preload: [sections: ^sections_query],
      where: document.public_token == ^token
    )
    |> non_deleted()
    |> Repo.one!()
  end

  def document_public?(document) do
    !is_nil(document.public_token)
  end

  def generate_public_token(document) do
    token = Palapa.Access.generate_token()

    document
    |> change(%{public_token: token})
    |> Repo.update()
  end

  def destroy_public_token(document) do
    document
    |> change(%{public_token: nil})
    |> Repo.update()
  end
end
