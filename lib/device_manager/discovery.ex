defmodule Cicada.DeviceManager.Discovery do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Cicada.DeviceManager
      alias Cicada.DeviceManager.Discovery

      defmodule State do
        defstruct supervisor: nil, module: nil
      end

      def start_link() do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def devices(id) do
        GenServer.call(id, :devices)
      end

      def handle_device(device_state, state) do
        id = state.module.get_id(device_state)
        case Supervisor.start_child(state.supervisor, [id, device_state]) do
          {:ok, pid} ->
            Logger.info "Device Started: #{id} - #{inspect device_state}"
            device = state.module.device(pid)
            state.module.start_histogram(id, device)
          {:error, {:already_started, pid}} ->
            device =
              %DeviceManager.Device{
                state.module.device(pid) | state: state.module.update_state(id, device_state)
              } |> DeviceManager.Client.dispatch
            state.module.update_histogram(id, device)
        end
        state
      end

      def init(:ok) do
        module = register_callbacks()
        {:ok, sup} = DeviceManager.DeviceSupervisor.start_link(module)
        {:ok, %State{module: module, supervisor: sup}}
      end

      def handle_call(:devices, _from, state) do
        devices =
          state.supervisor
          |> Supervisor.which_children
          |> Enum.map(fn {_id, child, _type, [module | _ta] = _modules} ->
            module.device(child)
          end)
        {:reply, devices, state}
      end

    end
  end
end
