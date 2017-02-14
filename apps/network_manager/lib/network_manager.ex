defmodule NetworkManager do
  require Logger

  defmodule State do
    defstruct interfaces: [], interface: nil
  end

  defmodule Interface do
    defstruct ifname: nil, status: %{}, settings: %{}
  end

end
