defmodule PalapaWeb.MemberProfileLive.PersonalInformation do
  use PalapaWeb, :live_component

  alias Palapa.Organizations
  alias Palapa.Organizations.PersonalInformation

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.MemberView, "_personal_information.html", assigns)
  end

  def handle_event("hide_form", _, socket) do
    socket =
      socket
      |> assign(:personal_information_changeset, nil)

    {:noreply, socket}
  end

  def handle_event("edit", _, socket) do
    changeset =
      case socket.assigns.connect_params do
        %{"stashed_form" => encoded} ->
          attrs = Plug.Conn.Query.decode(encoded)["personal_information"]

          Organizations.change_personal_information(%PersonalInformation{}, attrs)
          |> Map.put(:action, :insert)

        _ ->
          Organizations.change_personal_information(%PersonalInformation{})
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

  def handle_event("save", %{"personal_information" => attrs}, socket) do
    case socket.assigns.action_type do
      :create -> create_personal_information(socket, attrs)
      :update -> update_personal_information(socket, attrs)
    end
  end

  def handle_event("validate", %{"personal_information" => attrs}, socket) do
    changeset =
      Organizations.change_personal_information(%PersonalInformation{}, attrs)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, personal_information_changeset: changeset)}
  end

  def handle_event("delete", _, socket) do
    with :ok <-
           permit(
             Organizations.Policy,
             :delete_personal_information,
             socket.assigns.current_member,
             socket.assigns.info
           ) do
      case Organizations.delete_personal_information(socket.assigns.info) do
        {:ok, _deleted_info} ->
          send(self(), "fetch_member_personal_informations")
          {:noreply, socket}

        {:error, _} ->
          # FIXME: add global notice with unexpected errors
          nil
      end
    end
  end

  defp create_personal_information(socket, attrs) do
    with :ok <-
           permit(
             Organizations.Policy,
             :create_personal_information,
             socket.assigns.current_member,
             socket.assigns.current_member
           ) do
      case Organizations.create_personal_information(socket.assigns.current_member, attrs) do
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

  defp update_personal_information(socket, attrs) do
    with :ok <-
           permit(
             Organizations.Policy,
             :update_personal_information,
             socket.assigns.current_member,
             socket.assigns.info
           ) do
      case Organizations.update_personal_information(socket.assigns.info, attrs) do
        {:ok, info} ->
          socket =
            socket
            |> assign(:personal_information_changeset, nil)
            |> assign(:info, info)

          {:noreply, socket}

        {:error, changeset} ->
          {:noreply, assign(socket, :personal_information_changeset, changeset)}
      end
    end
  end
end
