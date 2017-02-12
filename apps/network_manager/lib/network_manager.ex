defmodule NetworkManager do
  require Logger

  def start(_type, _opts) do
    {:ok, pid} = NetworkManager.Supervisor.start_link
    System.cmd("modprobe", ["brcmfmac"])
    {:ok, pid}
  end

end
