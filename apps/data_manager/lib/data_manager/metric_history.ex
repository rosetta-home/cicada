defmodule DataManager.MetricHistory do
  use GenServer
  require Logger

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
    defstruct devices: []
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_metrics(id, sensor_type) do
    GenServer.call(__MODULE__, {:get_metrics, id, sensor_type})
  end

  def init(:ok) do
    DataManager.DataConsumer.start_link(self)
    {:ok, %State{}}
  end

  def handle_call({:get_metrics, id, sensor_type}, _from, state) do
    d = Enum.find(state.devices, %Device{id: id}, fn(d) -> d.id == id end)
    h = Enum.filter(d.history, fn(h) ->
        h.metric == sensor_type
    end)
    {:reply, %Device{d | history: h}, state}
  end

  def handle_info({:data_event, event}, state) do
    [id, metric] = event |> get_id
    event = %{event | datapoint: event.datapoint |> to_string }
    {:noreply, case event.datapoint do
      "n" -> state
      "ms_since_reset" -> state
      _ -> handle_datapoint(id, metric, event, state)
    end}
  end

  def get_id(event) do
    event.metric
    |> Enum.reverse
    |> Enum.at(0)
    |> Atom.to_string
    |> String.split("::")
  end

  def get_device(id, devices) do
    Enum.find(devices, %Device{id: id}, fn(d) ->
      d.id == id
    end)
  end

  def get_history(device, event, metric) do
    Enum.find(device.history, %History{metric: metric, datapoint: event.datapoint}, fn(h) ->
      (h.metric == metric && h.datapoint == event.datapoint)
    end)
  end

  def handle_datapoint(id, metric, event, state) do
    device = id |> get_device(state.devices)
    history = device |> get_history(event, metric)
    history = %History{ history | values: [event.value*1 | history.values] }
    d_history = case Enum.any?(device.history, fn(h) ->  h.metric == metric and h.datapoint == event.datapoint end) do
      false -> [history | device.history]
      true -> Enum.map(device.history, fn(h) ->
        case h.metric == metric and h.datapoint == event.datapoint do
          true -> history
          false -> h
        end
      end)
    end
    device = %Device{ device | history: d_history }
    devices = case Enum.any?(state.devices, fn(d) -> d.id == device.id end) do
      false -> [device | state.devices]
      true -> Enum.map(state.devices, fn(d) ->
        case d.id == device.id do
          true -> device
          false -> d
        end
      end)
    end
    %State{ state | devices: devices }
  end

end
