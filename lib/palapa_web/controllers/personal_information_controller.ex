defmodule PalapaWeb.PersonalInformationController do
  use PalapaWeb, :controller

  alias Palapa.Organizations
  alias Palapa.Organizations.PersonalInformation

  def create(conn, params) do
    member = Organizations.get_member!(current_organization(conn), params["member_id"])

    with :ok <- permit(Organizations, :create_personal_information, current_member(conn), member),
         {:ok, new_info} <-
           Organizations.create_personal_information(member, params["personal_information"]) do
      personal_informations =
        Organizations.list_personal_informations(member, current_member(conn))

      new_info = Palapa.Repo.preload(new_info, [:attachments])

      conn
      |> put_view(PalapaWeb.MemberView)
      |> render(
        "_personal_informations_list.html",
        layout: false,
        personal_informations: personal_informations,
        new_info: new_info,
        member: member,
        action_type: :create
      )
    else
      {:error, changeset} ->
        conn
        |> put_view(PalapaWeb.MemberView)
        |> put_status(:unprocessable_entity)
        |> render(
          "_personal_information_form.html",
          layout: false,
          member: member,
          personal_information_changeset: changeset,
          action:
            Routes.member_personal_information_path(
              conn,
              :create,
              current_organization(conn),
              member
            ),
          action_type: :create_with_error
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    personal_information = Organizations.get_personal_information!(id)

    with :ok <-
           permit(
             Organizations,
             :update_personal_information,
             current_member(conn),
             personal_information
           ) do
      changeset = PersonalInformation.update_changeset(personal_information, %{})

      conn
      |> put_view(PalapaWeb.MemberView)
      |> render(
        "_personal_information_form.html",
        layout: false,
        personal_information_changeset: changeset,
        action:
          Routes.personal_information_path(
            conn,
            :update,
            current_organization(conn),
            personal_information
          ),
        action_type: :update
      )
    else
      {:error, _} -> send_resp(conn, :forbidden, "")
    end
  end

  def update(conn, %{"id" => id, "personal_information" => personal_information_attrs}) do
    personal_information = Organizations.get_personal_information!(id)

    with :ok <-
           permit(
             Organizations,
             :update_personal_information,
             current_member(conn),
             personal_information
           ) do
      case Organizations.update_personal_information(
             personal_information,
             personal_information_attrs
           ) do
        {:ok, updated_personal_information} ->
          conn
          |> put_view(PalapaWeb.MemberView)
          |> render("_personal_information.html",
            layout: false,
            info: updated_personal_information
          )

        {:error, changeset} ->
          conn
          |> put_view(PalapaWeb.MemberView)
          |> put_status(:unprocessable_entity)
          |> render(
            "_personal_information_form.html",
            layout: false,
            personal_information_changeset: changeset,
            action:
              Routes.personal_information_path(
                conn,
                :update,
                current_organization(conn),
                personal_information
              ),
            action_type: :update
          )
      end
    else
      {:error, _} -> send_resp(conn, :forbidden, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    personal_information = Organizations.get_personal_information!(id)

    with :ok <-
           permit(
             Organizations,
             :delete_personal_information,
             current_member(conn),
             personal_information
           ),
         {:ok, _deleted_info} <- Organizations.delete_personal_information(personal_information) do
      send_resp(conn, :no_content, "")
    else
      {:error, _changeset} -> send_resp(conn, :forbidden, "")
    end
  end
end
