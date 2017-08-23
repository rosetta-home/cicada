defmodule Cicada.DeviceManager.Device.Histogram.Record do
  use GenServer
  require Logger

  #@history_length Application.get_env(:data_manager, :history_length)

  defmodule State do
    defstruct values: [],
      id: nil,
      key: nil,
      current_value: nil
  end

  def start_link(id, key, value) do
    GenServer.start_link(__MODULE__, {id, key, value}, name: id |> String.to_atom)
  end

  def add(id, value) do
    GenServer.cast(id |> String.to_existing_atom, {:add, value})
  end

  def reset(id) when id |> is_pid do
    GenServer.cast(id, :reset)
  end

  def reset(id), do: reset(id |> String.to_existing_atom)

  def values(id) when id |> is_pid do
    GenServer.call(id, :values)
  end

  def values(id), do: values(id |> String.to_existing_atom)

  def history(id) when id |> is_pid do
    GenServer.call(id, :history)
  end

  def history(id), do: history(id |> String.to_existing_atom)

  def get_value(values, func) do
    try do
      func.(values)
    rescue
      _ -> 0
    end
  end

  def init({id, key, value}) do
    {:ok, %State{id: id, key: key, values: [value], current_value: value}}
  end

  def handle_call(:history, _from, state), do: {:reply, state.values, state}

  def handle_call(:values, _from, state) do
    values = state.values
    res = %{
      key: state.key,
      value: state.current_value,
      count: values |> Enum.count,
      values: values,
      mean: nil,
      min: nil,
      max: nil,
      median: nil,
      std_dev: nil,
      p50: nil,
      p75: nil,
      p90: nil,
      p95: nil,
      p99: nil,
      p999: nil
    }
    res =
      case values |> Enum.all?(fn v -> v |> is_number end) && values |> length > 3 do
        true ->
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
        false -> res
      end
    {:reply, res, state}
  end

  def handle_cast(:reset, state) do
    {:noreply, %State{state | values: [], current_value: nil}}
  end

  def handle_cast({:add, value}, state) do
    {:noreply,
      %State{ state | values: [ value | state.values ] |> Enum.slice(0..100), current_value: value }
    }
  end
end
