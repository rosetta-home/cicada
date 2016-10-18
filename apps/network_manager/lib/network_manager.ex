defmodule NetworkManager do
  require Logger

  def start(_type, _opts) do
    NetworkManager.Supervisor.start_link
  end

end
