defmodule Cicada.DataManager do

  def register do
    GenServer.call(Cicada.DataManager.Client, :register)
  end

  def history(device, metric) do

  end

end
