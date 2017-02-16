defmodule NetworkManager.Application do

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(NetworkManager.Client, []),
      worker(NetworkManager.WiFi, []),
      worker(NetworkManager.AP, []),
      worker(NetworkManager.BoardId, []),
    ]

    opts = [strategy: :one_for_one, name: NetworkManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
