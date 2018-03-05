defmodule Palapa.Announcements.Policy do
  @behaviour Bodyguard.Policy

  alias Palapa.Organizations.Member

  def authorize(:create, %Member{role: _role}, _) do
    true
  end

  def authorize(:show, %Member{role: _role}, _) do
    true
  end
end
