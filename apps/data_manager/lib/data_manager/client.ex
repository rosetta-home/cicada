defmodule DataManager.Client do
  use GenServer
  require Logger
  alias DataManager.Histogram

  defmodule History do
    defstruct datapoint: nil,
      metric: nil,
      values: []
  end

  defmodule Device do
    defstruct id: nil,
      history: []
  end

  defmodule State do
    defstruct sensors: []
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DeviceManager.register
    {:ok, %State{}}
  end

  def handle_info(%DeviceManager.Device{type: type} = device, state) do
    {:noreply, %State{state | sensors: device |> send_metric(state)}}
  end

  def handle_info(%DeviceManager.Device{} = device, state), do: {:noreply, state}

  def create_histogram(id, map, state, keys \\ []) do
    map |> Map.to_list |> Enum.flat_map(fn({k, v} = metric) ->
      keys = keys ++ [Atom.to_string(k)]
      key = "#{id}::#{Enum.join(keys, "-")}"
      case k do
        other when other != :__struct__ ->
          case state.sensors |> Enum.member?(key) do
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

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, DataManager, pid)
    {:reply, :ok, state}
  end

  def dispatch(event) do
    EventManager.dispatch(DataManager, event)
  end

end
