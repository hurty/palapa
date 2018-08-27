defmodule PalapaWeb.MemberInformationTest do
  use PalapaWeb.FeatureCase, async: true

  setup %{session: session} do
    workspace = insert_pied_piper!()

    logged_session =
      session
      |> visit(session_path(PalapaWeb.Endpoint, :new))
      |> fill_in(text_field("Email address"), with: workspace.gilfoyle.account.email)
      |> fill_in(text_field("Password"), with: "password")
      |> click(button("Log in"))

    {:ok, session: logged_session, workspace: workspace}
  end

  test "a member add a new information on his profile", %{
    session: session,
    workspace: workspace
  } do
    session
    |> visit(member_path(PalapaWeb.Endpoint, :show, workspace.organization, workspace.gilfoyle))
    |> click(button("Add information"))
    |> fill_in(text_field("member_information_value"), with: "28 rue saint antoine 44000 Nantes")
    |> click(button("Add information"))
    |> assert_has(css(".js-member-information", text: "28 rue saint antoine 44000 Nantes"))
  end

  test "a member cannot add information on another member profile", %{
    session: session,
    workspace: workspace
  } do
    session
    |> visit(member_path(PalapaWeb.Endpoint, :show, workspace.organization, workspace.richard))
    |> assert_has(Wallaby.Query.text("Personal information shared"))
    |> refute_has(button("Add information"))
  end
end
