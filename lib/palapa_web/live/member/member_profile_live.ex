defmodule PalapaWeb.MemberProfileLive do
  use PalapaWeb, :live_view

  alias Palapa.Organizations
  alias Palapa.Organizations.PersonalInformation

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
    personal_information_changeset = Organizations.change_personal_information(member)

    people_list =
      Enum.map(Palapa.Organizations.list_members(current_organization), fn m ->
        [key: m.account.name, value: to_string(Palapa.Access.GlobalId.create("palapa", m))]
      end)

    teams_list =
      Enum.map(
        Palapa.Teams.where_organization(current_organization) |> Palapa.Teams.list(),
        fn t -> [key: t.name, value: to_string(Palapa.Access.GlobalId.create("palapa", t))] end
      )

    {:ok,
     assign(socket, %{
       current_organization: current_organization,
       member: member,
       current_member: current_member,
       personal_informations: personal_informations,
       personal_information_changeset: personal_information_changeset,
       edit_mode: false,
       action_type: :create,
       show_personal_information_form: false,
       people_list: people_list,
       teams_list: teams_list
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

  def handle_event("show_personal_information_form", _, socket) do
    {:noreply, assign(socket, :show_personal_information_form, true)}
  end

  def handle_event("hide_personal_information_form", _, socket) do
    {:noreply, assign(socket, :show_personal_information_form, false)}
  end

  def handle_event("save_personal_information", %{"personal_information" => attrs}, socket) do
    with :ok <-
           permit(
             Organizations.Policy,
             :create_personal_information,
             socket.assigns.current_member,
             socket.assigns.member
           ) do
      case Organizations.create_personal_information(
             socket.assigns.member,
             attrs
           ) do
        {:ok, _new_info} ->
          socket =
            fetch_member_personal_informations(socket)
            |> assign(:show_personal_information_form, false)
            |> assign(
              :personal_information_changeset,
              Organizations.change_personal_information(socket.assigns.member)
            )

          {:noreply, socket}

        {:error, changeset} ->
          {:noreply, assign(socket, :personal_information_changeset, changeset)}
      end
    end
  end

  def handle_event("validate_personal_information", %{"personal_information" => attrs}, socket) do
    changeset =
      Organizations.change_personal_information(
        %PersonalInformation{},
        socket.assigns.member,
        attrs
      )
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, personal_information_changeset: changeset)}
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
