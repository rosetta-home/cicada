defmodule Histogram.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info "Starting Histogram"
    children = [
      worker(Histogram.Record, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_record(id) do
    Logger.debug "Starting record: #{id}"
    Supervisor.start_child(__MODULE__, [id])
  end
end
