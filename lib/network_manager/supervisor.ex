defmodule Cicada.NetworkManager.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    interface = get_interface()
    children = [
      worker(Cicada.NetworkManager.AP, []),
      worker(Cicada.NetworkManager.BoardId, []),
      worker(Cicada.NetworkManager.Client, [interface]),
    ]
    supervise(children, strategy: :one_for_one)
  end

  def get_interface() do
    case get_wifi() do
      nil ->
        :timer.sleep(500)
        get_interface()
      other -> other
    end
  end

  def get_wifi() do
    Nerves.NetworkInterface.interfaces
    |> Enum.find(fn i -> i |> String.starts_with?("wl") end)
  end
end
