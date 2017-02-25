defmodule Cicada.DataManager.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Cicada.DataManager.Client, []),
      supervisor(Cicada.DataManager.Histogram, []),
      supervisor(Registry, [:unique, Cicada.DataManager.Registry, []]),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
