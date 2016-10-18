defmodule API.MetricHistory do
    require Logger

    defmodule State do
      defstruct device_id: nil,
        sensor_type: nil
    end

    def init({:tcp, :http}, req, opts) do
        {device_id, req} = :cowboy_req.qs_val("device_id", req)
        {sensor_type, req} = :cowboy_req.qs_val("sensor_type", req)
        {:ok, req, %State{:device_id => device_id, :sensor_type => sensor_type }}
    end

    def handle(req, state) do
        Logger.info "Getting Metrics for #{state.device_id} of type #{state.sensor_type}"
        device = DataManager.MetricHistory.get_metrics(state.device_id, state.sensor_type)
        headers = [
            {"cache-control", "no-cache"},
            {"connection", "close"},
            {"content-type", "application/json"},
            {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
            {"pragma", "no-cache"},
            {"Access-Control-Allow-Origin", "*"},
        ]
        {:ok, resp} = Poison.encode(device)
        {:ok, req2} = :cowboy_req.reply(200, headers, resp, req)
        {:ok, req2, state}
    end

    def terminate(_reason, req, state), do: :ok

end