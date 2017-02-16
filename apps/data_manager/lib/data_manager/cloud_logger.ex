defmodule DataManager.CloudLogger do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    #DataManager.DataConsumer.start_link(self)
    id = NetworkManager.BoardId.get
    Logger.info "Board ID: #{id}"
    cloud_url = Application.get_env(:data_manager, :cloud_url)
    Logger.info "Cloud URL: #{cloud_url}"
    {:ok, %{boardid: id, cloud_url: cloud_url}}
  end

  def handle_info({:data_event, event}, state) do
    Logger.info "Sending Cloud Data to: #{state.cloud_url}..."
    data = %{weather: [], energy: [], ieq: [], hvac: []}
    Enum.reduce(event, data, fn({key, value}, acc) ->
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
    end) |> log_data(state.boardid, state.cloud_url)
    {:noreply, state}
  end

  def log_data(data, id, url) do
    data = %{id: id, data: data}
    Logger.info "Cloud Snapshot: #{inspect data}"
    Logger.info "Post: #{inspect url}"
    priv_dir = :code.priv_dir(:data_manager)
    {:ok, body} = Poison.encode(data)
    {_reply, http} = HTTPoison.post url, body, [{"content-type", "application/json"}], [
      hackney: [
        ssl_options: [
          certfile: "#{priv_dir}/certs/RosettaHomeClient.crt",
          keyfile: "#{priv_dir}/certs/RosettaHomeClient.key"
        ]
      ]
    ]
    Logger.info "Reply: #{inspect http}"
  end

  defp merge(map, [leaf], value), do: Map.put(map, leaf, value)
  defp merge(map, [node | remaining_keys], value) do
    inner_map = merge(Map.get(map, node, %{}), remaining_keys, value)
    Map.put(map, node, inner_map)
  end

  def update_acc(acc, acc_key, id, key, value) do
    map = Enum.find(acc[acc_key], %{id: id}, fn(map) -> map.id == id end)
    keys = String.split(key, "-")
    map = merge(map, keys, value)
    arr = case Enum.find(acc[acc_key], fn(w) -> w.id == id end) do
      nil -> [map]++acc[acc_key]
      _ -> acc[acc_key]
    end
    Map.put(acc, acc_key, Enum.map(arr, fn(w) ->
      cond do
        w.id == id -> map
        true -> w
      end
    end))
  end
end
