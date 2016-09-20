defmodule API do
  use Application

  def start(_type, _opts) do
    import Supervisor.Spec, warn: false

    children = [
      worker(API.TCPServer, [])
    ]

    opts = [strategy: :one_for_one, name: API.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
