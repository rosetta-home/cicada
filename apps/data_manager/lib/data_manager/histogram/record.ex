defmodule DataManager.Histogram.Device.Record do
  use GenServer
  require Logger

  #@history_length Application.get_env(:data_manager, :history_length)

  defmodule State do
    defstruct values: [],
      id: nil,
      current_value: 0
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: id |> String.to_atom)
  end

  def add(id, value) do
    GenServer.cast(id |> String.to_existing_atom, {:add, value})
  end

  def reset(id) when id |> is_pid do
    GenServer.cast(id, :reset)
  end

  def reset(id) do
    GenServer.cast(id |> String.to_existing_atom, :reset)
  end

  def values(id) when id |> is_pid do
    GenServer.call(id, :values)
  end

  def values(id) do
    GenServer.call(id |> String.to_existing_atom, :values)
  end

  def history(id) when id |> is_pid do
    GenServer.call(id, :history)
  end

  def history(id) do
    GenServer.call(id |> String.to_existing_atom, :history)
  end

  def init(id) do
    {:ok, %State{id: id}}
  end

  def handle_call(:history, _from, state), do: {:reply, state.values, state}

  def handle_call(:values, _from, state) do
    values = state.values
    res = %{
      id: state.id,
      value: state.current_value,
      count: values |> Enum.count
    }
    res =
      case values do
        [head | _tail] when head |> is_number ->
          %{res |
            mean: values |> Statistics.mean,
            min: values |> Statistics.min,
            max: values |> Statistics.max,
            median: values |> Statistics.median,
            std_dev: values |> Statistics.stdev,
            p50: values |> Statistics.percentile(50),
            p75: values |> Statistics.percentile(75),
            p90: values |> Statistics.percentile(90),
            p95: values |> Statistics.percentile(95),
            p99: values |> Statistics.percentile(99),
            p999: values |> Statistics.percentile(99.9)
          }
        _ -> res
      end
    {:reply, res, state}
  end

  def handle_cast(:reset, state) do
    {:noreply, %State{id: state.id}}
  end

  def handle_cast({:add, value}, state) do
    {:noreply, %State{ state | values: [ value | state.values ] |> Enum.slice(0..1000), current_value: value }}
  end
end
