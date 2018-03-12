defmodule Cicada.NetworkManager do
  require Logger

  defmodule State do
    defstruct iface: nil, current_address: nil, bound: false
  end

  def register do
    GenServer.call(Cicada.NetworkManager.Client, :register)
  end

  def up do
    GenServer.call(Cicada.NetworkManager.Client, :up)
  end

end
