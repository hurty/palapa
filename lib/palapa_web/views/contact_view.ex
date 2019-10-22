defmodule PalapaWeb.ContactView do
  use PalapaWeb, :view

  def full_name(contact) do
    "#{contact.first_name} #{contact.last_name}"
    |> String.trim()
  end
end
