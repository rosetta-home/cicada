defmodule API.DeviceConsumer do
  alias Experimental.{GenStage}
  require Logger

  use GenStage

  def start_link(parent) do
    GenStage.start_link(__MODULE__, parent)
  end

  # Callbacks

  def init(parent) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, parent, subscribe_to: [DeviceManager.Broadcaster]}
  end

  def handle_events(events, _from, parent) do
    for event <- events do
      send(parent, {:device_event, event})
    end
    {:noreply, [], parent}
  end
end
