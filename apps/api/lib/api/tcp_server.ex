defmodule API.TCPServer do

  def start_link do
    port =  Application.get_env(:api, :tcp_port, 8081)
    dispatch = :cowboy_router.compile([
      { :_,
        [
          {"/ws", API.Websocket, []},
          {"/metric_history", API.MetricHistory, []},
        ]}
    ])
    {:ok, _} = :cowboy.start_http(:api_http,
      10,
      [{:port, port}],
      [{:env, [{:dispatch, dispatch}]}]
    )
  end
end
