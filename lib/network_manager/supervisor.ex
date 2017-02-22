defmodule Cicada.NetworkManager.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Cicada.NetworkManager.Client, []),
      worker(Cicada.NetworkManager.WiFi, []),
      worker(Cicada.NetworkManager.AP, []),
      worker(Cicada.NetworkManager.BoardId, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
