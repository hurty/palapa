defmodule Palapa.Announcements.Policy do
  @behaviour Bodyguard.Policy

  alias Palapa.Organizations.Member

  def authorize(:create, %Member{}, _) do
    true
  end

  def authorize(:show, %Member{}, _) do
    true
  end
end
