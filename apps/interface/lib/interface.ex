defmodule Interface do
  use Application

  def start(_type, _opts) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Interface.TCPServer, [])
    ]

    opts = [strategy: :one_for_one, name: Interface.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
