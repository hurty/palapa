defmodule PalapaWeb.MemberInformationController do
  use PalapaWeb, :controller

  alias Palapa.Organizations
  alias Palapa.Organizations.MemberInformation

  def create(conn, params) do
    member = Organizations.get_member!(current_organization(), params["member_id"])

    with :ok <- permit(Organizations, :create_member_information, current_member(), member),
         {:ok, new_info} <-
           Organizations.create_member_information(member, params["member_information"]) do
      member_informations = Organizations.list_member_informations(member, current_member())

      conn
      |> put_view(PalapaWeb.MemberView)
      |> render(
        "_member_informations_list.html",
        layout: false,
        member_informations: member_informations,
        new_info: new_info,
        member: member,
        action: :create
      )
    else
      {:error, changeset} ->
        conn
        |> put_view(PalapaWeb.MemberView)
        |> put_status(:unprocessable_entity)
        |> render(
          "_member_information_form.html",
          layout: false,
          member: member,
          member_information_changeset: changeset,
          action: member_member_information_path(conn, :create, current_organization(), member),
          action_type: :create
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    member_information = Organizations.get_member_information!(id)

    with :ok <-
           permit(Organizations, :update_member_information, current_member(), member_information) do
      changeset = MemberInformation.update_changeset(member_information, %{})

      conn
      |> put_view(PalapaWeb.MemberView)
      |> render(
        "_member_information_form.html",
        layout: false,
        member_information_changeset: changeset,
        action:
          member_information_path(conn, :update, current_organization(), member_information),
        action_type: :update
      )
    else
      {:error, _} -> send_resp(conn, :forbidden, "")
    end
  end

  def update(conn, %{"id" => id, "member_information" => member_information_attrs}) do
    member_information = Organizations.get_member_information!(id)

    with :ok <-
           permit(Organizations, :update_member_information, current_member(), member_information) do
      case Organizations.update_member_information(member_information, member_information_attrs) do
        {:ok, updated_member_information} ->
          conn
          |> put_view(PalapaWeb.MemberView)
          |> render("_member_information.html",
            layout: false,
            info: updated_member_information
          )

        {:error, changeset} ->
          conn
          |> put_view(PalapaWeb.MemberView)
          |> render(
            "_member_information_form.html",
            layout: false,
            member_information_changeset: changeset,
            action:
              member_information_path(conn, :update, current_organization(), member_information),
            action_type: :update
          )
      end
    else
      {:error, _} -> send_resp(conn, :forbidden, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    member_information = Organizations.get_member_information!(id)

    with :ok <-
           permit(Organizations, :delete_member_information, current_member(), member_information),
         {:ok, _deleted_info} <- Organizations.delete_member_information(member_information) do
      send_resp(conn, :no_content, "")
    else
      {:error, _changeset} -> send_resp(conn, :forbidden, "")
    end
  end
end
