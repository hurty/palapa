defmodule PalapaWeb.InvitationView do
  use PalapaWeb, :view

  def sent_a_minute_ago?(invitation) do
    if invitation.email_sent_at do
      a_minute_after_sending = Timex.shift(invitation.email_sent_at, minutes: 1)
      Timex.after?(DateTime.utc_now(), a_minute_after_sending)
    else
      false
    end
  end
end
