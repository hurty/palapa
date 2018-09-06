defmodule PalapaWeb.MemberInformationController do
  use PalapaWeb, :controller

  alias Palapa.Organizations

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
        member: member
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
          member_information_changeset: changeset
        )
    end
  end
end
