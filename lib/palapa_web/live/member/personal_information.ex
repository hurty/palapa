defmodule PalapaWeb.MemberProfileLive.PersonalInformation do
  use PalapaWeb, :live_component

  alias Palapa.Organizations
  alias Palapa.Organizations.PersonalInformation

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.MemberView, "_personal_information.html", assigns)
  end

  def handle_event("hide_personal_information_form", _, socket) do
    socket =
      socket
      |> assign(:personal_information_changeset, nil)

    {:noreply, socket}
  end

  def handle_event("save_personal_information", %{"personal_information" => attrs}, socket) do
    with :ok <-
           permit(
             Organizations.Policy,
             :create_personal_information,
             socket.assigns.current_member,
             socket.assigns.current_member
           ) do
      case Organizations.create_personal_information(
             socket.assigns.current_member,
             attrs
           ) do
        {:ok, _info} ->
          socket =
            socket
            |> assign(:personal_information_changeset, nil)

          send(self(), "fetch_member_personal_informations")
          {:noreply, socket}

        {:error, changeset} ->
          {:noreply, assign(socket, :personal_information_changeset, changeset)}
      end
    end
  end

  def handle_event("validate_personal_information", %{"personal_information" => attrs}, socket) do
    changeset =
      Organizations.new_personal_information(
        %PersonalInformation{},
        socket.assigns.current_member,
        attrs
      )
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, personal_information_changeset: changeset)}
  end

  def handle_event("delete_personal_information", %{"id" => id}, socket) do
    personal_information = Organizations.get_personal_information!(id)

    with :ok <-
           permit(
             Organizations.Policy,
             :delete_personal_information,
             socket.assigns.current_member,
             personal_information
           ) do
      case Organizations.delete_personal_information(personal_information) do
        {:ok, _deleted_info} ->
          send(self(), "fetch_member_personal_informations")
          {:noreply, socket}

        {:error, _} ->
          # FIXME: add global notice with unexpected errors
          nil
      end
    end
  end

  def handle_event("edit_personal_information", _, socket) do
    changeset =
      if socket.assigns.action_type == :create do
        Organizations.new_personal_information(socket.assigns.current_member)
      else
        Organizations.change_personal_information(socket.assigns.info)
      end

    people_list =
      Enum.map(Organizations.list_members(socket.assigns.current_organization), fn m ->
        [key: m.account.name, value: to_string(Palapa.Access.GlobalId.create("palapa", m))]
      end)

    teams_list =
      Enum.map(
        Palapa.Teams.where_organization(socket.assigns.current_organization)
        |> Palapa.Teams.list(),
        fn t -> [key: t.name, value: to_string(Palapa.Access.GlobalId.create("palapa", t))] end
      )

    socket =
      socket
      |> assign(:personal_information_changeset, changeset)
      |> assign(:teams_list, teams_list)
      |> assign(:people_list, people_list)

    {:noreply, socket}
  end
end
