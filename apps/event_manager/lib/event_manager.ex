defmodule EventManager do
  require Logger
  defmodule State do
    defstruct count: 0
  end

  def dispatch(type, event) do
    Logger.debug "Dispatching: #{inspect type} - #{inspect event}"
    case Registry.lookup(EventManager.Registry, type) do
      [] -> Logger.debug "No Registrations for #{inspect type}"
      _ ->
        Registry.dispatch(EventManager.Registry, type, fn entries ->
          for {_module, pid} <- entries, do: send(pid, event)
        end)
    end
    Logger.debug "Dispatched: #{inspect event}"
  end
end
