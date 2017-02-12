defmodule DataManager.DataConsumer do
  require Logger

  use GenStage

  def start_link(parent) do
    GenStage.start_link(__MODULE__, parent)
  end

  # Callbacks

  def init(parent) do
    {:consumer, parent, subscribe_to: [DataManager.Broadcaster]}
  end

  def handle_events(events, _from, parent) do
    for event <- events do
      send(parent, {:data_event, event})
    end
    {:noreply, [], parent}
  end
end
