defmodule DataManager do
  use Application

  def start(_type, _opts) do
    DataManager.Supervisor.start_link
  end

end
