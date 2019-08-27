defmodule PalapaWeb.PasswordResetController do
  use PalapaWeb, :controller

  alias Palapa.Accounts

  plug(:put_layout, "public.html")

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    if email && email =~ ~r/@/ do
      account = Accounts.get_by(email: email)

      if account do
        {:ok, password_reset_token} = Accounts.generate_password_reset_token(account)

        Accounts.Emails.password_reset(account, password_reset_token)
        |> Palapa.Mailer.deliver_now()
      end

      render(conn, "create.html", email: email)
    else
      conn
      |> put_flash(:error, "Please enter a valid email address")
      |> render("new.html")
    end
  end

  def edit(conn, %{"password_reset_token" => token}) do
    account = Accounts.find_account_by_password_reset_token(token)

    if account do
      render(conn, "edit.html",
        account: account,
        password_reset_token: token,
        password_changeset: Accounts.Account.password_reset_changeset(account, %{})
      )
    else
      conn
      |> put_flash(:error, "Invalid token")
      |> render("invalid_token.html")
    end
  end

  def update(conn, %{"password" => password_attrs}) do
    account =
      Accounts.find_account_by_password_reset_token(password_attrs["password_reset_token"])

    if account do
      case Accounts.reset_password(account, password_attrs) do
        {:ok, account} ->
          conn
          |> PalapaWeb.Authentication.start_session(account)
          |> redirect(to: workspace_path(conn, :index))

        {:error, changeset} ->
          conn
          |> put_flash(:error, "Cannot update the password")
          |> render("edit.html",
            account: account,
            password_reset_token: password_attrs["password_reset_token"],
            password_changeset: changeset
          )
      end
    else
      conn
      |> put_flash(:error, "Invalid token")
      |> render("invalid_token.html")
    end
  end
end
