defmodule Interface.Supervisor do
  use Supervisor
  require Logger

  def start_link(parent) do
    Supervisor.start_link(__MODULE__, parent, name: __MODULE__)
  end

  def init(parent) do
    children = [
      worker(Interface.NetworkListener, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
