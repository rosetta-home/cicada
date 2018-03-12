defmodule Cicada.DistributionManager.Client do
  use GenServer
  require Logger
  alias Cicada.NetworkManager.State, as: NM
  alias Cicada.NetworkManager.Interface, as: NMInterface
  alias Cicada.{NetworkManager}

   @app Mix.Project.config[:app]

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :os.cmd 'epmd -daemon'
    NetworkManager.register
    {:ok, %{}}
  end

  def handle_info(%NM{current_address: address}, state) when address != nil do
    Logger.info "Distribution Manager IP: #{inspect address}"
    :net_kernel.stop()
    :net_kernel.start([:"#{@app}@#{address}"])
    {:noreply, state}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_info(mes, state) do
    {:noreply, state}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, DeviceManager, pid)
    {:reply, :ok, state}
  end

  def handle_call({:register_device, module}, _from, state) do
    module.start_link
    {:reply, :ok, state}
  end

end
