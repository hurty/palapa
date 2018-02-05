defmodule PalapaWeb.Current do
  defmacro current_organization do
    quote do
      var!(conn).assigns.current_organization
    end
  end

  defmacro current_user do
    quote do
      var!(conn).assigns.current_user
    end
  end
end
