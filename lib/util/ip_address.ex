defmodule Cicada.Util.IPAddress do

  def get_address() do
    :inet.getifaddrs()
    |> elem(1)
    |> Enum.reduce_while({}, fn {_interface, attr}, acc ->
      case attr |> get_ipv4 do
        false -> {:cont, acc}
        {} -> {:cont, acc}
        {_, _, _, _} = add-> {:halt, add}
      end
    end)
  end

  def get_ipv4(attr) do
    case attr |> Keyword.get_values(:addr) do
      [] -> false
      l -> l |> Enum.reduce_while({}, fn ip, acc ->
        case ip do
          {127, 0, 0, 1} -> {:cont, acc}
          {_, _, _, _, _, _, _, _} -> {:cont, acc}
          {_, _, _, _} = add -> {:halt, add}
        end
      end)
    end
  end
end
