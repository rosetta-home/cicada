defmodule Cicada.NetworkManager.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    interface =
      Nerves.NetworkInterface.interfaces
      |> Enum.find(fn i -> i |> String.starts_with?("wl") end)
    children = [
      worker(Cicada.NetworkManager.AP, []),
      worker(Cicada.NetworkManager.BoardId, []),
      worker(Cicada.NetworkManager.Client, [interface]),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
