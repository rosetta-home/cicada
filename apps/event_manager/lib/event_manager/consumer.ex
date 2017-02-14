defmodule EventManager.Consumer do
  use GenStage
  require Logger

  def start_link(parent, selector) do
    GenStage.start_link(__MODULE__, {parent, selector})
  end

  def init({parent, selector}) do
    {:consumer, parent, subscribe_to:
      [{EventManager.Broadcaster, selector: selector}]
    }
  end

  def handle_info({{producer, subscription_tag}, msg}, parent) do
    Logger.info "EventManager: #{inspect msg}"
    send(parent, msg)
    {:noreply, [], parent}
  end

end
