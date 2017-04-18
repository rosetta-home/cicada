defmodule Cicada.DeviceManager.Discovery do
  defmacro __using__(module: module) do
    quote bind_quoted: [module: module] do
      use GenServer
      require Logger
      alias Cicada.DeviceManager
      alias Cicada.DeviceManager.Discovery

      @device_module module

      def start_link() do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def devices(id) do
        GenServer.call(id, :devices)
      end

      def handle_device(device_state, state) do
        id = @device_module.get_id(device_state)
        case Supervisor.start_child(:"#{@device_module}.Supervisor", [id, device_state]) do
          {:ok, pid} ->
            Logger.info "Device Started: #{id} - #{inspect device_state}"
            device = @device_module.device(pid)
            @device_module.start_histogram(id, device)
          {:error, {:already_started, pid}} ->
            device =
              %DeviceManager.Device{
                @device_module.device(pid) | state: @device_module.update_state(id, device_state)
              } |> DeviceManager.dispatch
            @device_module.update_histogram(id, device)
        end
        state
      end

      def init(:ok) do
        {:ok, sup} = DeviceManager.DeviceSupervisor.start_link(@device_module)
        {:ok, register_callbacks()}
      end

      def handle_call(:devices, _from, state) do
        {:reply, :"#{@device_module}.Supervisor"
          |> Supervisor.which_children
          |> Enum.map(fn {_id, child, _type, [module | _ta] = _modules} ->
            module.device(child)
          end),
        state}
      end
    end
  end
end
