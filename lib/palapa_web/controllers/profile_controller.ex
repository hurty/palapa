defmodule PalapaWeb.ProfileController do
  use PalapaWeb, :controller

  alias Palapa.Organizations

  plug(:put_navigation, "Profile")

  def update(conn, %{"id" => member_id, "member" => member_attrs}) do
    member = Organizations.get_member!(current_organization(conn), member_id)

    with :ok <- permit(Organizations.Policy, :edit_member, current_member(conn)) do
      case Organizations.update_member_profile(member, member_attrs) do
        {:ok, member} ->
          put_flash(conn, :success, gettext("Your profile has been updated."))
          |> redirect(to: Routes.profile_path(conn, :edit, current_organization(conn), member))

        {:error, _changeset} ->
          put_flash(conn, :error, gettext("An error occured while updating your profile."))
          |> redirect(to: Routes.profile_path(conn, :edit, current_organization(conn), member))
      end
    end
  end
end
