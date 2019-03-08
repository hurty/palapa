defmodule PalapaWeb.ProfileController do
  use PalapaWeb, :controller

  alias Palapa.Organizations

  plug(:put_navigation, "Profile")

  def update(conn, %{"id" => member_id, "member" => member_attrs}) do
    member = Organizations.get_member!(current_organization(), member_id)

    with :ok <- permit(Organizations, :edit_member, current_member()) do
      case Organizations.update_member_profile(member, member_attrs) do
        {:ok, member} ->
          put_flash(conn, :success, "Your profile has been updated.")
          |> redirect(to: profile_path(conn, :edit, current_organization(), member))

        {:error, _changeset} ->
          put_flash(conn, :error, "An error occured while updating your profile.")
          |> redirect(to: profile_path(conn, :edit, current_organization(), member))
      end
    end
  end
end
