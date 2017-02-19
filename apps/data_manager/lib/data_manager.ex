defmodule DataManager do

  def register do
    GenServer.call(DataManager.Client, :register)
  end

  def history(device, metric) do
    
  end

end
