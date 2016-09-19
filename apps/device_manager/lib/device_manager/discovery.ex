defmodule DeviceManager.Discovery do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias DeviceManager.Discovery

      defmodule State do
        defstruct devices: []
      end

      def start_link do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def init(:ok) do
        init_handlers
        {:ok, %State{}}
      end

      def handle_device(device, state, module) do
        id = module.get_id(device)
        case Enum.any?(state.devices, fn(device) -> device.interface_pid == id end) do
          false ->
            Logger.info("Got Device - #{id} :: #{inspect device}")
            {:ok, pid} = module.start_link(id, device)
            device = module.device(pid)
            DeviceManager.Broadcaster.sync_notify(device)
            %State{state | devices: [device | state.devices]}
          true ->
            Logger.debug("Updating State - #{id} #{inspect device}")
            device = module.update_state(id, device)
            DeviceManager.Broadcaster.sync_notify(device)
            state
        end
      end

      def init_handlers, do: :ok

      defoverridable [init_handlers: 0]

    end
  end
end
