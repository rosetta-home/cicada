defmodule Cicada.API.Controller.MetricHistory do
    require Logger
    alias Cicada.DataManager

    defmodule State do
      defstruct device_id: nil,
        sensor_type: nil
    end

    def init({:tcp, :http}, req, _opts) do
        {device_id, req} = :cowboy_req.qs_val("device_id", req)
        {sensor_type, req} = :cowboy_req.qs_val("sensor_type", req)
        {:ok, req, %State{:device_id => device_id, :sensor_type => sensor_type }}
    end

    def handle(req, state) do
        Logger.info "Getting Metrics for #{state.device_id} of type #{state.sensor_type}"
        id = "#{state.device_id}::#{state.sensor_type}"
        history = DataManager.Histogram.Device.Record.history(id)
        device = %{id: "#{state.device_id}::#{state.sensor_type}", history: [
          %{metric: state.sensor_type, datapoint: "value", values: history}
        ]}
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

    def terminate(_reason, _req, _state), do: :ok

end
