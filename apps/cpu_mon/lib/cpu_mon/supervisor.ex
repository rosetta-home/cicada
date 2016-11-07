defmodule CpuMon.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(CpuMon.Broadcaster, []),
      worker(CpuMon.Client, []),
    ]
    supervise(children, strategy: :one_for_one)
  end

end
