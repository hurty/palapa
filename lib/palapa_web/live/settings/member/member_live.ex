defmodule PalapaWeb.Settings.MemberLive do
  use PalapaWeb, :live_view

  alias Palapa.Organizations
  alias Palapa.Accounts

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.Settings.MemberView, "members.html", assigns)
  end

  def mount(
        %{
          account_id: account_id,
          current_organization_id: current_organization_id,
          current_member_id: current_member_id
        },
        socket
      ) do
    account = Accounts.get!(account_id)
    Gettext.put_locale(Palapa.Gettext, account.locale)

    socket =
      socket
      |> assign_new(:current_organization, fn -> Organizations.get!(current_organization_id) end)
      |> assign_new(:current_member, fn -> Organizations.get_member!(current_member_id) end)
      |> assign(:confirm_delete_member_id, nil)
      |> assign(:live_notice, nil)

    members = Organizations.list_members(socket.assigns.current_organization)

    {:ok, assign(socket, members: members)}
  end

  def handle_event("update_administrators", params, socket) do
    administrators_ids =
      [socket.assigns.current_member.id | Map.get(params, "administrators", [])]
      |> Enum.uniq()

    case Organizations.update_administrators(
           socket.assigns.current_organization,
           administrators_ids
         ) do
      {:ok, _result} ->
        members = Organizations.list_members(socket.assigns.current_organization)

        socket =
          socket
          |> assign(:members, members)
          |> assign(:live_notice, "The list of admins has been updated!")

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("delete_member", %{"member_id" => member_id}, socket) do
    {:noreply, assign(socket, %{confirm_delete_member_id: member_id})}
  end

  def handle_event("confirm_delete_member", %{"member_id" => member_id}, socket) do
    member = Organizations.get_member!(member_id)

    with :ok <-
           permit(Organizations.Policy, :delete_member, socket.assigns.current_member, member),
         Organizations.delete_member(member) do
      updated_members_list = Organizations.list_members(socket.assigns.current_organization)

      socket =
        socket
        |> assign(:live_notice, nil)
        |> assign(:members, updated_members_list)

      {:noreply, socket}
    end
  end

  def handle_event("cancel_delete_member", _, socket) do
    {:noreply, assign(socket, %{confirm_delete_member_id: nil})}
  end
end
