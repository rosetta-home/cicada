defmodule PubSub.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Phoenix.PubSub.PG2, [PubSub.Server, [pool_size: 1]]),
      worker(PubSub.Tracker, [[name: PubSub.Tracker, pubsub_server: PubSub.Server]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
