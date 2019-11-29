NimbleCSV.define(ContactCSV, [])

defmodule Palapa.Contacts.ContactExporter do
  import Ecto.Query
  alias Palapa.Contacts.Contact

  @csv_header [
    "Given Name",
    "Family Name",
    "E-mail 1 - Type",
    "E-mail 1 - Value",
    "IM 1 - Service",
    "IM 1 - Value",
    "Phone 1 - Type",
    "Phone 1 - Value",
    "Phone 2 - Type",
    "Phone 2 - Value",
    "Address 1 - Type",
    "Address 1 - Street",
    "Address 1 - City",
    "Address 1 - PO Box",
    "Address 1 - Region",
    "Address 1 - Postal Code",
    "Address 1 - Country",
    "Address 1 - Extended Address",
    "Organization 1 - Type",
    "Organization 1 - Name",
    "Organization 1 - Title",
    "Custom Field 1 - Type",
    "Custom Field 1 - Value"
  ]

  def exportCSV(organization) do
    {:ok, file} = Briefly.create()
    query = contacts_query(organization)

    header = [@csv_header] |> ContactCSV.dump_to_iodata()
    File.write(file, header, [:write, :utf8])

    Palapa.Repo.transaction(fn ->
      Palapa.Repo.stream(query)
      |> ContactCSV.dump_to_stream()
      |> Stream.into(File.stream!(file, [:append, :utf8]))
      |> Stream.run()
    end)

    file
  end

  def contacts_query(organization) do
    from(c in Contact,
      left_join: companies in Contact,
      on: c.company_id == companies.id,
      where: c.organization_id == ^organization.id,
      select: [
        c.first_name,
        c.last_name,
        "email",
        c.email,
        "social network",
        c.chat,
        "phone",
        c.phone,
        "work",
        c.work,
        "address",
        c.address_line1,
        c.address_city,
        # PO BOX
        nil,
        # Region
        nil,
        c.address_postal_code,
        c.address_country,
        c.address_line2,
        "company",
        companies.last_name,
        c.title,
        "additional info",
        c.additional_info
      ]
    )
  end
end
