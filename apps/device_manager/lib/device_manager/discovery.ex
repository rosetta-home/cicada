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
        Process.flag(:trap_exit, true)
        Process.send_after(self, :init_handlers, 100)
        {:ok, %State{}}
      end

      def handle_info(:init_handlers, state) do
        init_handlers
        {:noreply, state}
      end

      def handle_info({:EXIT, from, reason}, state) do
        Logger.info("Process #{inspect from} crashed: #{inspect reason} Current Devices: #{inspect state.devices}")
        devices = Enum.filter(state.devices, fn({pid, device}) ->
          case pid do
            from -> false
            _ -> true
          end
        end)
        :timer.sleep(1000)
        {:noreply, %State{ state | devices: devices} }
      end

      def handle_device(device_state, state, module) do
        id = module.get_id(device_state)
        case Enum.any?(state.devices, fn({pid, device}) -> device.interface_pid == id end) do
          false ->
            Logger.info("Got Device - #{id} :: #{inspect device_state}")
            pid = case module.start_link(id, device_state) do
              {:error, {:already_started, pid}} -> pid
              {:ok, pid} -> pid
            end
            %State{state | devices: [{pid, module.device(pid)} | state.devices]}
          true ->
            Logger.debug("Updating State - #{id} #{inspect device_state}")
            DeviceManager.Broadcaster.sync_notify(
              %DeviceManager.Device{
                module.device(id) | state: module.update_state(id, device_state)
              }
            )
            state
        end
      end

      def init_handlers, do: :ok

      defoverridable [init_handlers: 0]

    end
  end
end
