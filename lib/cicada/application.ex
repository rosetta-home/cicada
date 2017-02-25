defmodule Cicada.Application do
  use Application
  alias Cicada.{API, NetworkManager, SysMon, DataManager, DeviceManager, EventManager, Util, VoiceControl}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(EventManager.Supervisor, []),
      supervisor(NetworkManager.Supervisor, []),
      supervisor(DeviceManager.Supervisor, []),
      supervisor(SysMon.Supervisor, []),
      supervisor(DataManager.Supervisor, []),
      supervisor(API.Supervisor, []),
      supervisor(VoiceControl.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Cicada.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
