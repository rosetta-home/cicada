defmodule DataManager.DeviceConsumer do
  alias Experimental.{GenStage}
  require Logger

  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, [], subscribe_to: [DeviceManager.Broadcaster]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      handle_metric(event)
    end
    {:noreply, [], state}
  end

  def handle_metric(%DeviceManager.Device{type: type} = device) when type in [:ieq, :weather_station, :smart_meter] do
    device |> send_metric
  end

  def handle_metric(%DeviceManager.Device{} = device), do: nil

  def send_metric(device) do
    id = device.interface_pid |> Atom.to_string
    device.state |> Map.to_list |> Enum.each(fn({k, v} = metric) ->
      case k do
        :id -> nil
        :__struct__ -> nil
        other when v |> is_number -> DataManager.Metric.update_value("#{id}::#{Atom.to_string(k)}", v)
        _ -> nil
      end
    end)
  end
end
