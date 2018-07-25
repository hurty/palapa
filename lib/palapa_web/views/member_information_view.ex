defmodule PalapaWeb.MemberInformationView do
  use PalapaWeb, :view

  alias Palapa.Organizations.MemberInformation

  # Map for FontAwesome icons names
  @information_types %{
    custom: %{icon: "fas fa-info-circle", label: "Custom"},
    email: %{icon: "fas fa-at", label: "Email"},
    phone: %{icon: "fas fa-mobile-alt", label: "Phone"},
    address: %{icon: "fas fa-map-marker-alt", label: "Address"},
    birthday: %{icon: "fas fa-birthday-cake", label: "Birthday"},
    person_to_contact: %{icon: "fas fa-ambulance", label: "Contact in case of emergency"},
    office_hours: %{icon: "fas fa-briefcase", label: "Office hours"},
    skype: %{icon: "fab fa-skype", label: "Skype"},
    twitter: %{icon: "fab fa-twitter", label: "Twitter"},
    facebook: %{icon: "fab fa-facebook", label: "Facebook"},
    linkedin: %{icon: "fab fa-linkedin", label: "LinkedIn"},
    github: %{icon: "fab fa-github", label: "Github"}
  }

  def information_types_for_select do
    @information_types
    |> Enum.map(fn type ->
      {type_key, %{label: type_label}} = type
      {type_label, type_key}
    end)
  end

  def information_type_label(%MemberInformation{} = info) do
    information_types = @information_types

    ~E"""
    <span class="">
      <i class="text-green-light <%= information_types[info.type][:icon] %>"></i>&nbsp

      <%= if info.type == :custom do %>
        <%= info.custom_label %>
      <% else %>
        <%= information_types[info.type][:label] %>
      <% end %>
    </span>
    """
  end
end
