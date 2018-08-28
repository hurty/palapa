defmodule PalapaWeb.MemberInformationController do
  use PalapaWeb, :controller

  alias Palapa.Organizations

  def create(conn, params) do
    member = Organizations.get_member!(current_organization(), params["member_id"])

    with :ok <- permit(Organizations, :create_member_information, current_member(), member),
         {:ok, new_info} <-
           Organizations.create_member_information(member, params["member_information"]) do
      member_informations = Organizations.list_member_informations(member, current_member())

      conn
      |> put_view(PalapaWeb.MemberView)
      |> render(
        "_member_informations.html",
        layout: false,
        member_informations: member_informations,
        new_info: new_info
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
