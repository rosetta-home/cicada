defmodule Cicada.SysMon do

  defmodule Memory do
    @derive [Poison.Encoder]
    defstruct total: 0, allocated: 0
  end

  defmodule Cpu do
    @derive [Poison.Encoder]
    defstruct cpu: 0, busy: 0, idle: 0
  end

  defmodule State do
    defstruct cpus: [], memory: %Cicada.SysMon.Memory{}
  end

  def register do
    GenServer.call(Cicada.SysMon.Client, :register)
  end

end
