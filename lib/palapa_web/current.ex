defmodule PalapaWeb.Current do
  defmacro current_account do
    quote do
      var!(conn).assigns.current_account
    end
  end

  defmacro current_organization do
    quote do
      var!(conn).assigns.current_organization
    end
  end

  defmacro current_member do
    quote do
      var!(conn).assigns.current_member
    end
  end

  def current_member(conn) do
    conn.assigns.current_member
  end
end
