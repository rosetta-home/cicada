defmodule Cicada.DeviceManager.DiscoverySupervisor do
  use Supervisor

  def start_link(children) do
    Supervisor.start_link(__MODULE__, children, name: __MODULE__)
  end

  def init(children) do
    c = children |> Enum.map(fn dis -> worker(dis, []) end)
    supervise(c, strategy: :one_for_one)
  end
end
