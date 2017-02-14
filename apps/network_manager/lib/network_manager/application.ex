defmodule NetworkManager.Application do

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(NetworkManager.Client, []),
      #worker(NetworkManager.Ethernet, []),
      #worker(NetworkManager.WiFI, []),
      #worker(NetworkManager.AP, []),
      worker(NetworkManager.BoardId, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NetworkManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
