defmodule Cicada.NetworkManager.BoardId do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    id = try do
      {id, 0} = System.cmd("/usr/bin/boardid", ["-b", "macaddr"])
      id |> String.split("\n") |> List.first
    rescue
      e in ErlangError ->
        Logger.info "#{inspect e}"
        "123456789"
    end
    {:ok, id}
  end

  def get, do: GenServer.call(__MODULE__, :id)

  def handle_call(:id, _from, state), do: {:reply, state, state}

end
