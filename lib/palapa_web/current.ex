defmodule PalapaWeb.Current do
  def current_account(conn) do
    conn.assigns[:current_account]
  end

  def current_member(conn) do
    conn.assigns[:current_member]
  end

  def current_organization(conn) do
    conn.assigns[:current_organization]
  end
end
