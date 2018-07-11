defmodule Palapa.Mailer do
  use Bamboo.Mailer, otp_app: :palapa

  defmodule DeliverLaterStrategy do
    @behaviour Bamboo.DeliverLaterStrategy

    def deliver_later(adapter, email, config) do
      args = [adapter, email, config] |> :erlang.term_to_binary() |> Base.encode64()

      {:ok, _jid} =
        Verk.enqueue(%Verk.Job{
          queue: :default,
          class: "Palapa.Mailer.DeliverLaterStrategy",
          args: [args]
        })
    end

    def perform(binary) do
      [adapter, email, config] = binary |> Base.decode64!() |> :erlang.binary_to_term()
      adapter.deliver(email, config)
    end
  end
end
