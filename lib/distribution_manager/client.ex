defmodule Cicada.DistributionManager.Client do
  use GenServer
  require Logger
  alias Cicada.NetworkManager.State, as: NM
  alias Cicada.{NetworkManager}

  @app Mix.Project.config[:app]

  def set_net_kernel(address, state) do
    Logger.info "Distribution Manager IP: #{inspect address}"
    :net_kernel.stop()
    :net_kernel.start([:"#{@app}@#{address}"])
    %{state | current_address: address}
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :os.cmd 'epmd -daemon'
    NetworkManager.register
    {:ok, %{current_address: nil}}
  end

  def handle_info(%NM{current_address: address}, %{current_address: add} = state)
  when address |> is_tuple() and add != address do
    {:noreply, set_net_kernel(address |> Tuple.to_list() |> Enum.join("."), state)}
  end

  def handle_info(%NM{current_address: address}, %{current_address: add} = state)
  when address |> is_binary() and add != address do
    {:noreply, set_net_kernel(address, state)}
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
