defmodule Cicada.DeviceManager.Device.Histogram do
  use Supervisor
  require Logger
  alias Cicada.DeviceManager
  alias Cicada.DeviceManager.Device
  alias Cicada.DeviceManager.Device.Histogram

  def start_link(id, %Device{} = device) do
    Supervisor.start_link(__MODULE__, {id, device}, name: id)
  end

  def snapshot(id) do
    Supervisor.which_children(id) |> Enum.map(fn {_id, child, _type, _module} ->
      Histogram.Record.values(child)
    end)
  end

  def reset(id) do
    Supervisor.which_children(id) |> Enum.each(fn {_id, child, _type, _module} ->
      Histogram.Record.reset(child)
    end)
  end

  def update_records(id, map, keys \\ []) do
    map |> Map.to_list |> Enum.each(fn {k, v} ->
      keys = keys ++ [Atom.to_string(k)]
      key = "#{id}::#{Enum.join(keys, "-")}"
      case v do
        map when map |> is_map -> update_records(id, map, keys)
        value when k != :__struct__ and k != :id ->
          Logger.debug "Updating #{key}: #{value}"
          Histogram.Record.add(key, value)
        _ -> nil
      end

    end)
  end

  def records(id, map, keys \\ []) do
    map |> Map.to_list |> Enum.flat_map(fn {k, v} ->
      keys = keys ++ [Atom.to_string(k)]
      key = "#{id}::#{Enum.join(keys, "-")}"
      case v do
        map when map |> is_map -> records(id, map, keys)
        value when k != :__struct__ and k != :id->
          Logger.info "#{inspect k}: #{inspect value}"
          [worker(Histogram.Record, [key, keys, value], id: key)]
        _ -> []
      end
    end)
  end

  def init({id, %Device{} = device}) do
    Logger.info "Starting Histogram Record: #{id}"
    children = id |> records(device.state)
    supervise(children, strategy: :one_for_one)
  end

end
