defmodule Palapa.Contacts.ContactExporter do
  @csv_mapping %{
    first_name: "Given Name",
    last_name: "Family Name",
    # Associated with "E-mail 1 - Type"
    email: "Email 1 - Value",
    company: "Organization 1 - Name",
    title: "Organization 1 - Title",
    phone: "",
    work: "",
    chat: "",
    address_line1: "",
    address_line2: "",
    address_postal_code: "",
    address_city: "",
    address_country: "",
    additional_info: ""
  }
end
