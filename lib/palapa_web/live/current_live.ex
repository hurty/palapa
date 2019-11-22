defmodule PalapaWeb.CurrentLive do
  defmacro __using__(_) do
    quote do
      alias Palapa.Accounts

      def fetch_current_context(socket, organization_id) do
        organization =
          Accounts.organization_visible_for_account(
            socket.assigns.current_account,
            organization_id
          )

        member = Accounts.member_for_organization(socket.assigns.current_account, organization)

        socket
        |> assign_new(:current_member, fn -> member end)
        |> assign_new(:current_organization, fn -> organization end)
      end
    end
  end
end
