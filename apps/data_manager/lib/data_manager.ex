defmodule DataManager do

  def register do
    GenServer.call(DataManager.Client, :register)
  end

end
