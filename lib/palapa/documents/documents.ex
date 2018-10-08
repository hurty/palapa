defmodule Palapa.Documents do
  @moduledoc """
  The Documents context.
  """
  use Palapa.Context

  alias Palapa.Documents.{Document, Page}

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents(organization) do
    Document
    |> where(organization_id: ^organization.id)
    |> Repo.all()
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id) do
    from(document in Document,
      left_join: sections in assoc(document, :sections),
      left_join: pages in assoc(sections, :pages),
      preload: [sections: {sections, pages: pages}]
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
        |> put_assoc(:organization, organization)
        |> put_assoc(:document, document)
        |> put_assoc(:last_author, author)
        |> Repo.insert!()

      document
      |> change(first_page_id: first_page.id)
      |> Repo.update!()
    end)
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{source: %Document{}}

  """
  def change_document(%Document{} = document) do
    Document.changeset(document, %{})
  end

  def get_page!(id) do
    Page
    |> preload(last_author: :account)
    |> Repo.get!(id)
  end
end
