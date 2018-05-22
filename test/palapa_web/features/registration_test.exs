defmodule PalapaWeb.RegistrationTest do
  use PalapaWeb.FeatureCase, async: true

  test "a visitor can sign up through the registration form", %{session: session} do
    session
    |> visit(home_path(PalapaWeb.Endpoint, :index))
    |> click(link("Sign up"))
    |> fill_in(text_field("registration_name"), with: "Richard Hendricks")
    |> fill_in(text_field("registration_organization_name"), with: "Pied Piper")
    |> fill_in(text_field("registration_email"), with: "richard.hendricks@piedpiper.com")
    |> fill_in(text_field("registration_password"), with: "password")
    |> click(button("Create a new account"))
    |> assert_text("Dashboard")

    organization = Palapa.Organizations.Organization |> Palapa.Repo.get_by(name: "Pied Piper")
    account = Palapa.Accounts.get_by(email: "richard.hendricks@piedpiper.com")

    # Timezone infos get populated
    assert !is_nil(organization.default_timezone)
    assert !is_nil(account.timezone)
  end
end
