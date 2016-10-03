defmodule DataManager.Metric do
  use Elixometer
  require Logger

  def update_value(namespace, value) when namespace |> is_atom do
    namespace |> Atom.to_string |> update_value(value)
  end

  def update_value(namespace, value) when namespace |> is_binary do
    update_histogram(namespace, value, (60*60*6))
    update_gauge(namespace, value)
  end

end
