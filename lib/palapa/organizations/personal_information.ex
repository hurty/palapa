defmodule Palapa.Organizations.PersonalInformation do
  use Palapa.Schema

  alias Palapa.Organizations.Member
  alias Palapa.Teams.Team
  # alias Palapa.Attachments
  # alias Palapa.Attachments.Attachment

  @derive {Jason.Encoder, only: [:label, :value]}
  schema "personal_informations" do
    belongs_to(:member, Member)
    field(:label, :string)
    field(:value, :string)
    field(:private, :boolean, default: false)
    timestamps()

    # has_many(:attachments, Attachment, on_replace: :delete)

    many_to_many(:teams, Team,
      join_through: "personal_information_visibilities",
      on_delete: :delete_all,
      on_replace: :delete
    )

    many_to_many(:members, Member,
      join_through: "personal_information_visibilities",
      on_delete: :delete_all,
      on_replace: :delete
    )

    field(:visibilities, {:array, :string}, virtual: true)
  end

  def changeset(%__MODULE__{} = personal_information, attrs) do
    personal_information
    |> cast(attrs, [:label, :value, :private, :visibilities])
    # |> put_attachments(attrs)
    |> put_visibilities(attrs)
    |> validate_required([:label])

    # |> put_conditional_validations
  end

  def put_conditional_validations(changeset) do
    get_field(changeset, :attachments)

    if(Enum.any?(get_field(changeset, :attachments))) do
      changeset
    else
      validate_required(changeset, [:value])
    end
  end

  def put_visibilities(changeset, attrs) do
    cond do
      attrs["visibilities"] ->
        teams = Palapa.Access.GlobalId.locate_all(attrs["visibilities"], Team)
        members = Palapa.Access.GlobalId.locate_all(attrs["visibilities"], Member)

        changeset
        |> put_assoc(:teams, teams)
        |> put_assoc(:members, members)

      get_field(changeset, :teams) || get_field(changeset, :members) ->
        teams_sids =
          get_field(changeset, :teams, [])
          |> Enum.map(fn team ->
            to_string(Palapa.Access.GlobalId.create("palapa", team))
          end)

        members_sids =
          get_field(changeset, :members, [])
          |> Enum.map(fn member ->
            to_string(Palapa.Access.GlobalId.create("palapa", member))
          end)

        changeset
        |> put_change(:visibilities, teams_sids ++ members_sids)

      true ->
        changeset
    end
  end

  # defp put_attachments(changeset, attrs) do
  #   if is_list(attrs["attachments"]) do
  #     attachments = Attachments.list_attachments_from_signed_ids(attrs["attachments"])

  #     put_assoc(changeset, :attachments, attachments)
  #   else
  #     changeset
  #   end
  # end
end
