defmodule Cicada.API.TCPServer do

  def start_link do
    port =  Application.get_env(:api, :tcp_port, 8081)
    dispatch = :cowboy_router.compile([
      { :_,
        [
          {"/ws", Cicada.API.Controller.Websocket, []},
          {"/metric_history", Cicada.API.Controller.MetricHistory, []},
        ]}
    ])
    {:ok, _} = :cowboy.start_http(:api_http,
      100,
      [{:port, port}],
      [{:env, [{:dispatch, dispatch}]}]
    )
  end
end
