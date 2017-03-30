defmodule Cicada.DeviceManager.Discovery do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Cicada.DeviceManager
      alias Cicada.DeviceManager.Discovery

      defmodule State do
        defstruct devices: []
      end

      def start_link() do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def snapshot(id) do
        GenServer.call(id, :snapshot)
      end

      def reset_histogram(id) do
        GenServer.call(id, :reset_histogram)
      end

      def handle_device(device_state, module, state) do
        id = module.get_id(device_state)
        case Enum.any?(state.devices,
          fn({pid, module, device}) -> device.interface_pid == id end)
        do
          false ->
            Logger.info("Got Device - #{id} :: #{inspect device_state}")
            pid =
              case module.start_link(id, device_state) do
                {:error, {:already_started, pid}} -> pid
                {:ok, pid} -> pid
                {:error, error} -> nil
              end
            case pid do
              nil -> state
              _ ->
                device = module.device(pid)
                module.start_histogram(id, device)
                %State{state | devices: [{pid, module, device} | state.devices]}
            end
          true ->
            Logger.debug("Updating State - #{id} #{inspect device_state}")
            device = %DeviceManager.Device{
              module.device(id) | state: module.update_state(id, device_state)
            } |> DeviceManager.Client.dispatch
            module.update_histogram(id, device)
            state
        end
      end

      def init(:ok) do
        Process.flag(:trap_exit, true)
        register_callbacks()
        {:ok, %State{}}
      end

      def handle_call(:snapshot, _from, state) do
        {:reply, state.devices |> Enum.flat_map(fn {pid, module, device} ->
          module.snapshot(device.interface_pid)
        end), state}
      end

      def handle_call(:reset_histogram, _from, state) do
        state.devices |> Enum.each(fn {pid, module, device} ->
          module.reset_histogram(device.interface_pid)
        end)
        {:reply, :ok, state}
      end

      def handle_info({:EXIT, crashed, reason}, state) when reason != :normal do
        Logger.info("Process #{inspect crashed} crashed: #{inspect reason} Current State: #{inspect state}")
        devices =
          Enum.filter(state.devices, fn {pid, module, device} ->
            case pid do
              ^crashed ->
                Logger.info "Removing #{inspect crashed} = #{inspect pid}"
                false
              _ -> true
            end
          end)
        {:noreply, %State{ state | devices: devices} }
      end

      def handle_info({:EXIT, crashed, reason}, state), do: {:noreply, state}
    end
  end
end
