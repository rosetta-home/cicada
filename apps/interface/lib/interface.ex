defmodule Interface do
  use Application
  require Logger

  def start(_type, _opts) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Interface.TCPServer, [])
    ]
    Mdns.Server.start
    :inet.getifaddrs()
      |> elem(1)
      |> Enum.filter(fn(intf) -> elem(intf, 0) == 'wlan0' end)
      |> Enum.at(0)
      |> elem(1)
      |> Keyword.get(:addr)
      |> IO.inspect
      |> Mdns.Server.set_ip

    Mdns.Server.add_service(%Mdns.Server.Service{
      domain: "rosetta.local",
      data: :ip,
      ttl: 120,
      type: :a
    })
    opts = [strategy: :one_for_one, name: Interface.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
