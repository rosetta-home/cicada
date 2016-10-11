defmodule DataManager.Metric do
  use Elixometer
  require Logger

  def update_value(namespace, value) when namespace |> is_atom do
    namespace |> Atom.to_string |> update_value(value)
  end

  def update_value(namespace, value) when namespace |> is_binary and value |> is_number do
    update_histogram(namespace, value, (15*60), false)
    update_gauge(namespace, value)
  end

  def update_value(namespace, value), do: nil

end
