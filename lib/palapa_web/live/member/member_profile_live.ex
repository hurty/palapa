defmodule PalapaWeb.MemberProfileLive do
  use PalapaWeb, :live_view

  alias Palapa.Organizations

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.MemberView, "_member_profile.html", assigns)
  end

  def mount(
        %{
          member_id: member_id,
          current_member_id: current_member_id,
          current_organization_id: current_organization_id
        },
        socket
      ) do
    member = Organizations.get_member!(member_id)
    current_member = Organizations.get_member!(current_member_id)
    current_organization = Organizations.get!(current_organization_id)

    personal_informations = Organizations.list_personal_informations(member, current_member)

    {:ok,
     assign(socket, %{
       connect_params: get_connect_params(socket),
       profile_title_edit_mode: false,
       current_organization: current_organization,
       member: member,
       current_member: current_member,
       personal_informations: personal_informations
     })}
  end

  def handle_event("edit_member_title", _, socket) do
    profile_changeset = Organizations.Member.update_profile_changeset(socket.assigns.member)

    {:noreply,
     assign(socket,
       edit_mode: true,
       profile_changeset: profile_changeset
     )}
  end

  def handle_event("update_member_title", %{"member" => member_attrs}, socket) do
    case Organizations.update_member_profile(socket.assigns.member, member_attrs) do
      {:ok, member} ->
        {:noreply, assign(socket, member: member, edit_mode: false)}

      {:error, profile_changeset} ->
        {:noreply,
         assign(socket,
           profile_changeset: profile_changeset
         )}
    end
  end

  # update the list
  def handle_info("fetch_member_personal_informations", socket) do
    {:noreply, fetch_member_personal_informations(socket)}
  end

  def fetch_member_personal_informations(socket) do
    personal_informations =
      Organizations.list_personal_informations(
        socket.assigns.member,
        socket.assigns.current_member
      )

    assign(socket, :personal_informations, personal_informations)
  end
end
