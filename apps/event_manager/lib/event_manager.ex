defmodule EventManager do

  defmodule State do
    defstruct count: 0
  end

  def dispatch(type, event) do
    Registry.dispatch(EventManager.Registry, type, fn entries ->
      for {_module, [pid]} <- entries, do: send(pid, event)
    end)
  end
end
