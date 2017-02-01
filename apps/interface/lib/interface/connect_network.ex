defmodule Interface.ConnectNetwork do
  require Logger

  defmodule State do
    defstruct hostname: nil
  end

  def init({:tcp, :http}, req, _opts) do
    {host, req} = :cowboy_req.host(req)
    {:ok, req, %State{:hostname => host }}
  end

  def handle(req, state) do
    {:ok, kv, req2} = :cowboy_req.body_qs(req)
    :ok = NetworkManager.Client.write_creds(kv)
    NetworkManager.Client.join_network
    st = EEx.eval_file(Path.join(:code.priv_dir(:interface), "network_saved.html.eex"), [])
    headers = [
        {"cache-control", "no-cache"},
        {"connection", "close"},
        {"content-type", "text/html"},
        {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
        {"pragma", "no-cache"},
        {"Access-Control-Allow-Origin", "*"},
    ]
    {:ok, req3} = :cowboy_req.reply(200, headers, st, req2)
    {:ok, req3, state}
  end

  def terminate(_reason, _req, _state), do: :ok

end
