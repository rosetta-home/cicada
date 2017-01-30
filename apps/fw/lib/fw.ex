defmodule Fw do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # worker(Fw.Worker, [arg1, arg2, arg3]),
    ]

    System.cmd("ip", ["route", "add", "default", "via", "192.168.11.1"]) |> print_cmd_result
    System.cmd("ip", ["link", "set", "wlan0", "up"]) |> print_cmd_result
    System.cmd("ip", ["addr", "add", "192.168.24.1/24", "dev", "wlan0"]) |> print_cmd_result

    System.cmd("dnsmasq", ["--dhcp-lease", "/root/dnsmasq.lease"]) |> print_cmd_result

    System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"]) |> print_cmd_result

    System.cmd("/usr/sbin/wpa_supplicant",  ["-i", "wlan0", "-C", "/var/run/wpa_supplicant", "-B"])
    :timer.sleep 1000
    {:ok, pid} = Nerves.WpaSupplicant.start_link("/var/run/wpa_supplicant/wlan0")
    ssids = Nerves.WpaSupplicant.scan(pid)
    #Nerves.WpaSupplicant.set_network(pid, ssid: ssid, key_mgmt: :"WPA-PSK", psk: secret)

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp print_cmd_result({message, 0}) do
    IO.puts message
  end

  defp print_cmd_result({message, err_no}) do
    IO.puts "ERROR (#{err_no}): #{message}"
  end

end
