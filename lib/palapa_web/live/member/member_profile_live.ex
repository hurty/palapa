defmodule PalapaWeb.MemberProfileLive do
  use PalapaWeb, :live_view

  alias Palapa.Organizations

  def render(assigns) do
    Phoenix.View.render(PalapaWeb.MemberView, "_member_profile.html", assigns)
  end

  def mount(%{member: member, current_member: current_member}, socket) do
    {:ok, assign(socket, %{member: member, current_member: current_member, edit_mode: false})}
  end

  def handle_event("edit_member_title", _, socket) do
    IO.inspect(socket.assigns.member)

    profile_changeset = Organizations.Member.update_profile_changeset(socket.assigns.member)

    IO.inspect(profile_changeset)

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
end
