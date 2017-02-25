defmodule Cicada.DataManager do

  def register do
    GenServer.call(Cicada.DataManager.Client, :register)
  end

end
