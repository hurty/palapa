defmodule Palapa.JobQueue do
  use EctoJob.JobQueue, table_name: "jobs"

  alias Palapa.Repo
  alias Palapa.Organizations
  alias Palapa.Billing
  alias Palapa.Events

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "daily_email", "account_id" => account_id}) do
    account = Palapa.Accounts.get(account_id)

    cond do
      !account ->
        Repo.transaction(multi)

      true ->
        multi
        |> Ecto.Multi.run(:send_daily_email, fn _repo, _changes ->
          Events.send_daily_recaps(account)
        end)
        |> Ecto.Multi.run(:schedule_next_daily_email, fn _repo, _changes ->
          Events.schedule_daily_email(account)
        end)
        |> Repo.transaction()
    end
  end

  def perform(%Multi{} = multi, %{
        "type" => "update_stripe_customer",
        "customer_id" => customer_id
      }) do
    customer = Billing.Customers.get_customer(customer_id)

    if !customer do
      # if the customer doesn't exists anymore, we let the job delete itself
      Repo.transaction(multi)
    else
      multi
      |> Ecto.Multi.run(:update_stripe_customer, fn _repo, _changes ->
        Billing.Customers.update_stripe_customer(customer)
      end)
      |> Repo.transaction()
    end
  end

  def perform(%Multi{} = multi, %{
        "type" => "cancel_subscription",
        "organization_id" => organization_id
      }) do
    organization = Organizations.get(organization_id)

    if !organization do
      Repo.transaction(multi)
    else
      Billing.Subscriptions.cancel_subscription(organization)
    end
  end

  def perform(%Multi{} = multi, %{
        "type" => "delete_avatar",
        "account_id" => account_id
      }) do
    account = Palapa.Accounts.get(account_id)

    if !account do
      Repo.transaction(multi)
    else
      Ecto.Multi.run(multi, :delete_avatar, fn _, _ ->
        case Palapa.Avatar.delete({account.avatar, account}) do
          :ok -> {:ok, nil}
          other -> other
        end
      end)
      |> Repo.transaction()
    end
  end
end
