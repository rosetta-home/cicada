defmodule EventManager.Heartbeat do
  use GenServer
  require Logger
  alias EventManager.Consumer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Consumer.start_link(self, fn
      %EventManager.State{} -> true
      _ -> false
    end)
    Process.send_after(self, :heartbeat, 1000)
    {:ok, %EventManager.State{}}
  end

  def handle_info(:heartbeat, state) do
    state = %EventManager.State{state | count: state.count+1}
    GenStage.async_notify(EventManager.Broadcaster, state)
    Process.send_after(self, :heartbeat, 1000)
    {:noreply, state}
  end

  def handle_info(event, state) do
    {:noreply, state}
  end

end
