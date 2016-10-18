defmodule Interface do
  use Application
  require Logger

  def start(_type, _opts) do
    {:ok, pid} = Interface.Supervisor.start_link(self)
  end

end
