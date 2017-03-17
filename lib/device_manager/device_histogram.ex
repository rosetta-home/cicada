defmodule Cicada.DeviceManager.DeviceHistogram do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Cicada.DeviceManager.Device.Histogram
      alias Cicada.DeviceManager.Device

      def start_histogram(id, %Device{} = device) do
        GenServer.call(id, {:start_histogram, id, device})
      end

      def update_histogram(id, %Device{} = device) do
        GenServer.call(id, {:update_histogram, id, device})
      end

      def snapshot(id) do
        GenServer.call(id, {:snapshot, id})
      end

      def handle_call({:snapshot, id}, _from, state) do
        id = :"Histogram-#{id}"
        {:reply, [%{device: state, values: Histogram.snapshot(id)}], state}
      end

      def handle_call({:start_histogram, id, %Device{} = device}, _from, state) do
        id = :"Histogram-#{id}"
        {:reply, Histogram.start_link(id, device), state}
      end

      def handle_call({:update_histogram, id, device}, _from, state) do
        id = :"Histogram-#{id}"
        {:reply, Histogram.update_records(id, device.state), state}
      end

    end
  end
end
