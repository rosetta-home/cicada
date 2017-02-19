defmodule CpuMon.Application do

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(CpuMon.Client, []),
    ]

    opts = [strategy: :one_for_one, name: CpuMon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
