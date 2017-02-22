defmodule Cicada.CpuMon do

  defmodule State do
    defstruct cpus: []
  end

  defmodule Cpu do
    @derive [Poison.Encoder]
    defstruct cpu: 0, busy: 0, idle: 0
  end

  def register do
    GenServer.call(Cicada.CpuMon.Client, :register)
  end

end
