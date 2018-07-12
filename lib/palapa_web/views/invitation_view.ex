defmodule PalapaWeb.InvitationView do
  use PalapaWeb, :view

  def fresh?(invitation) do
    five_minutes_ago = Timex.shift(Timex.now(), minutes: -5)
    is_nil(invitation.email_sent_at) || Timex.after?(invitation.email_sent_at, five_minutes_ago)
  end
end
