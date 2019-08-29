defmodule PalapaWeb.MemberInformationView do
  use PalapaWeb, :view

  alias Palapa.Organizations.MemberInformation

  # # Map for FontAwesome icons names
  # @information_types %{
  #   email: %{icon: "fas fa-at", label: "Email", placeholder: "Example: your@email.com"},
  #   phone: %{icon: "fas fa-mobile-alt", label: "Phone", placeholder: "Example: (+33) 123456789"},
  #   address: %{
  #     icon: "fas fa-map-marker-alt",
  #     label: "Address",
  #     placeholder: "Example: 221B Baker Street, London, England"
  #   },
  #   birthday: %{icon: "fas fa-birthday-cake", label: "Birthday", placeholder: ""},
  #   person_to_contact: %{
  #     icon: "fas fa-ambulance",
  #     label: "Contact in case of emergency",
  #     placeholder: "Example: Mom's phone 0123456789"
  #   },
  #   office_hours: %{
  #     icon: "fas fa-briefcase",
  #     label: "Office hours",
  #     placeholder: "Example: Monday - Friday, 9am-5pm"
  #   },
  #   skype: %{icon: "fab fa-skype", label: "Skype", placeholder: "your.username"},
  #   twitter: %{
  #     icon: "fab fa-twitter",
  #     label: "Twitter",
  #     placeholder: "Example: https://twitter.com/<your-user-name>"
  #   },
  #   facebook: %{
  #     icon: "fab fa-facebook",
  #     label: "Facebook",
  #     placeholder: "Example: https://www.facebook.com/<your-user-name>"
  #   },
  #   linkedin: %{
  #     icon: "fab fa-linkedin",
  #     label: "LinkedIn",
  #     placeholder: "Example: https://www.linkedin.com/in/<your-user-name>"
  #   },
  #   github: %{
  #     icon: "fab fa-github",
  #     label: "Github",
  #     placeholder: "Example: https://github.com/<your-user-name>"
  #   },
  #   custom: %{
  #     icon: "fas fa-info-circle",
  #     label: "Custom",
  #     placeholder: "Your custom information"
  #   }
  # }

  def autolink(text) do
    if text =~ ~r/https?:\/\/(www\.)?/ do
      link(text, to: text, target: "_blank")
    else
      text
    end
  end

  def show_visibility_whitelist?(organization) do
    Palapa.Teams.organization_has_teams?(organization) ||
      Palapa.Organizations.members_count(organization) > 1
  end

  def visibility_text(%MemberInformation{} = information) do
    nb_teams = length(information.teams)
    nb_members = length(information.members)

    cond do
      nb_teams > 0 && nb_members > 0 ->
        "This information is only visible to you, #{nb_teams} team(s) and #{nb_members} other member(s)"

      nb_teams > 0 && nb_members == 0 ->
        "This information is only visible to you and #{nb_teams} team(s)"

      nb_teams == 0 && nb_members > 0 ->
        "This information is only visible to you and #{nb_members} other member(s)"

      true ->
        "This information is only visible to you"
    end
  end
end
