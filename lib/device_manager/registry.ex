defmodule Cicada.DeviceManager.Registry do

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(discovery) do
    Agent.update(__MODULE__, fn d -> discovery end)
  end

  def get do
    Agent.get(__MODULE__, fn d -> d end)
  end

end
