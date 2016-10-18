defmodule Interface.NetworkConsumer do
  alias Experimental.{GenStage}
  require Logger

  use GenStage

  def start_link(parent) do
    GenStage.start_link(__MODULE__, parent)
  end

  def init(parent) do
    {:consumer, parent, subscribe_to: [NetworkManager.Broadcaster]}
  end

  def handle_events(events, _from, parent) do
    for event <- events do
      send(parent, event)
    end
    {:noreply, [], parent}
  end
end
