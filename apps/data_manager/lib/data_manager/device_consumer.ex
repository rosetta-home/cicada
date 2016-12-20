defmodule DataManager.DeviceConsumer do
  alias Experimental.{GenStage}
  require Logger

  use GenStage

  defmodule State do
    defstruct sensors: []
  end

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, %State{}, subscribe_to: [DeviceManager.Broadcaster, CpuMon.Broadcaster]}
  end

  def handle_events(events, _from, state) do
    keys = for event <- events, key <- handle_metric(event, state), key != nil, do: key
    {:noreply, [], %State{ state | sensors: Enum.uniq(keys ++ state.sensors)}}
  end

  def handle_metric(%DeviceManager.Device{type: type} = device, state) when type in [:ieq, :weather_station, :smart_meter] do
    device |> send_metric(state)
  end

  def handle_metric(%DeviceManager.Device{} = device, state), do: []

  def handle_metric(%{cpu: cpu} = event, state) do
    %{
      type: "cpu",
      state: event,
      name: "CPU #{event.cpu}",
      module: "CpuMon.Cpu",
      interface_pid: :"cpu_mon-cpu-#{event.cpu}",
      device_pid: :""
    } |> send_metric(state)
  end

  def create_histogram(id, map, state, keys \\ []) do
    map |> Map.to_list |> Enum.flat_map(fn({k, v} = metric) ->
      keys = keys ++ [Atom.to_string(k)]
      key = "#{id}::#{Enum.join(keys, "-")}"
      case k do
        other when v |> is_number ->
          case Enum.member?(state.sensors, key) do
            true -> nil
            false -> Histogram.new(key)
          end
          Histogram.Record.add(key, v)
          [key]
        other_map when v |> is_map -> create_histogram(id, v, state, keys)
        _ -> [nil]
      end
    end)
  end

  def send_metric(device, state) do
    id = device.interface_pid |> Atom.to_string
    create_histogram(id, device.state, state)
  end
end
