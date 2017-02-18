defmodule DataManager.Application do

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(DataManager.Client, []),
      supervisor(DataManager.Histogram, []),
    ]

    opts = [strategy: :one_for_one, name: DataManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
