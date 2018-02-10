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
    |> take_screenshot()
  end
end
