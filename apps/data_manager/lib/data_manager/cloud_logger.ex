defmodule DataManager.CloudLogger do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DataManager.DataConsumer.start_link(self)
    id = try do
      i = System.cmd("/usr/bin/boardid", ["-b", "rpi", "-n", "4"])
      i |> String.split("\n") |> List.first
    rescue
      ErlangError -> "123456789"
    end
    Logger.info "Board ID: #{id}"
    {:ok, %{boardid: id}}
  end

  def handle_info({:data_event, %{metric: _metric} = event}, state), do: {:noreply, state}

  def handle_info({:data_event, event}, state) do
    Logger.info "Snapshot: #{inspect event}"
    data = %{weather: [], energy: [], ieq: [], hvac: []}
    Enum.reduce(event, data, fn({key, value}, acc) ->
      Logger.info key
      case key do
        <<"Sensor-IEQStation-", id::bytes-size(1), "::", k::binary>> ->
          update_acc(acc, :ieq, id, k, value.value)
        <<"Sensor-IEQStation-", id::bytes-size(2), "::", k::binary>> ->
          update_acc(acc, :ieq, id, k, value.value)
        <<"Sensor-IEQStation-", id::bytes-size(3), "::", k::binary>> ->
          update_acc(acc, :ieq, id, k, value.value)
        <<"Sensor-IEQStation-", id::bytes-size(4), "::", k::binary>> ->
          update_acc(acc, :ieq, id, k, value.value)
        <<"RavenSMCD-", id::bytes-size(18), "::", k::binary>> ->
          update_acc(acc, :energy, id, k, value.value)
        <<"RavenSMCD-", id::bytes-size(16), "::", k::binary>> ->
          update_acc(acc, :energy, id, k, value.value)
        <<"MeteoStick-MeteoStation-", id::bytes-size(1), "::", k::binary>> ->
          update_acc(acc, :weather, id, k, value.value)
        <<"MeteoStick-MeteoStation-", id::bytes-size(2), "::", k::binary>> ->
          update_acc(acc, :weather, id, k, value.value)
        <<"MeteoStick-MeteoStation-", id::bytes-size(3), "::", k::binary>> ->
          update_acc(acc, :weather, id, k, value.value)
        <<"MeteoStick-MeteoStation-", id::bytes-size(4), "::", k::binary>> ->
          update_acc(acc, :weather, id, k, value.value)
        _ -> acc
      end
    end) |> log_data(state.boardid)
    {:noreply, state}
  end

  def log_data(data, id) do
    data = %{id: id, data: data}
    Logger.info "Cloud Snapshot: #{inspect data}"
    priv_dir = :code.priv_dir(:data_manager)
    {:ok, body} = Poison.encode(data)
    {reply, http} = HTTPoison.post "https://127.0.0.1:4000/", body, [{"content-type", "application/json"}], [
      hackney: [
        ssl_options: [
          certfile: "#{priv_dir}/certs/RosettaHomeClient.crt",
          keyfile: "#{priv_dir}/certs/RosettaHomeClient.key"
        ]
      ]
    ]
    Logger.info "Reply: #{inspect http}"
  end

  def update_acc(acc, acc_key, id, key, value) do
    Logger.debug "#{id} #{key}"
    map = Enum.find(acc[acc_key], %{id: id}, fn(map) -> map.id == id end)
    Logger.debug "Got Map: #{inspect map}"
    map = Map.put(map, key, value)
    Logger.debug "Map Updated: #{inspect map}"
    arr = case Enum.find(acc[acc_key], fn(w) -> w.id == id end) do
      nil -> [map]++acc[acc_key]
      _ -> acc[acc_key]
    end
    Logger.debug "Arr: #{inspect arr}"
    Map.put(acc, acc_key, Enum.map(arr, fn(w) ->
      cond do
        w.id == id -> map
        true -> w
      end
    end))
  end
end
