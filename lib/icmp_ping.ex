# Copyright 2022 Pertsev Dmitriy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule ICMPPing do
  @moduledoc """
  Documentation for `ICMPPing`.
  """

  alias ICMPPing.IPAddress
  require IPAddress

  @doc """
  Ping IP.

  ## Examples

      iex> ICMPPing.ping("127.0.0.1")
      :pong

      iex> ICMPPing.ping("::1")
      :pong
  """
  def ping(ip, opts \\ %{}) do
    # convert IP to erlang format
    {:ok, ip_addr} = IPAddress.from_string(ip)

    # create socket
    {:ok, socket} = ICMPPing.ICMP.Socket.open(ip_addr, opts)

    packet_opts = %{}
    # send ping
    :ok = send_ping(socket, ip_addr, packet_opts)

    # receive pong
    :ok = receive_ping(socket, ip_addr)

    :pong
  end

  @doc """
  Supervised Ping IP.

  ## Examples

      # iex> ICMPPing.ping_sup("127.0.0.1")
      # :pong

      # iex> ICMPPing.ping_sup("::1")
      # :pong
  """
  def ping_sup(ip, opts \\ %{}, restart_value \\ :transient, timeout \\ 4000) do
    {:ok, sup_pid} =
      Supervisor.start_link(
        [
          %{
            id: ICMPPing.Server,
            start: {ICMPPing.Server, :start_link, []},
            restart: restart_value
          }
        ],
        strategy: :one_for_one,
        name: ICMPPing.Supervisor
      )

    ret =
      sup_pid
      |> Supervisor.which_children()
      |> Enum.find_value(fn {ICMPPing.Server, child, _, _} -> child end)
      |> GenServer.call({:ping, ip, opts}, timeout)

    Supervisor.stop(sup_pid)
    ret
  end

  defp send_ping(socket, ip_addr, packet_options) do
    # TODO packet options
    packet = ICMPPing.ICMP.Packet.new(ip_addr: ip_addr)
    :socket.sendto(socket, packet, get_dest(ip_addr))
  end

  defp get_dest(ip_addr) when IPAddress.is_ipv4(ip_addr), do: %{family: :inet, addr: ip_addr}

  defp get_dest(ip_addr) when IPAddress.is_ipv6(ip_addr), do: %{family: :inet6, addr: ip_addr}

  defp receive_ping(_socket, _ip_addr) do
    :ok
  end
end
