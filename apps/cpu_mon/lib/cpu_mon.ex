defmodule CpuMon do
  use Application

  def start(_type, _opts) do
    CpuMon.Supervisor.start_link
  end

end
