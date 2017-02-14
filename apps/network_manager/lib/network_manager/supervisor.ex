defmodule NetworkManager.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(NetworkManager.Broadcaster, []),
      worker(NetworkManager.Client, []),
      worker(NetworkManager.BoardId, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
