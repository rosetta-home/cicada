defmodule PubSub do
  use Application

  def start(_type, _opts) do
    System.cmd("/usr/lib/erlang/bin/epmd", ["-daemon"])
    PubSub.NetworkListener.start_link
    PubSub.Supervisor.start_link
  end

end
