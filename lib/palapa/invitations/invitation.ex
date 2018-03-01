defmodule Palapa.Invitations.Invitation do
  use Palapa.Schema

  alias Palapa.Organizations

  schema "invitations" do
    field(:email, :string)
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:creator, Organizations.Member)
    timestamps()
    field(:email_sent_at, :utc_datetime)
    field(:expire_at, :utc_datetime)
    field(:token, :string)
  end
end
