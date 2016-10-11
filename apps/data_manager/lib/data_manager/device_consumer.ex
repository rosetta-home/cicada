defmodule DataManager.DeviceConsumer do
  alias Experimental.{GenStage}
  require Logger

  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  # Callbacks

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, [], subscribe_to: [DeviceManager.Broadcaster]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      handle_metric(event)
    end
    {:noreply, [], state}
  end

  def handle_metric(%DeviceManager.Device{type: :ieq} = device) do
    id = device.interface_pid |> Atom.to_string
    device.state |> Map.to_list |> Enum.each(fn({k, v} = metric) ->
      case k do
        :id -> nil
        :__struct__ -> nil
        other -> DataManager.Metric.update_value("#{id}::#{Atom.to_string(k)}", v)
      end
    end)
  end

  def handle_metric(%DeviceManager.Device{type: :smart_meter} = device) do
    id = device.interface_pid |> Atom.to_string
    device.state |> Map.to_list |> Enum.each(fn({k, v} = metric) ->
      case k do
        :id -> nil
        :__struct__ -> nil
        other -> DataManager.Metric.update_value("#{id}::#{Atom.to_string(k)}", v)
      end
    end)
  end

  def handle_metric(%DeviceManager.Device{} = device) do
    #Nothing
  end
end
