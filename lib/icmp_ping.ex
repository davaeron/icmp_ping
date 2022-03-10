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

defmodule IcmpPing do
  @moduledoc """
  Documentation for `IcmpPing`.
  """

  alias IcmpPing.IpAddr
  require IpAddr

  @doc """
  Ping IP.

  ## Examples

      iex> IcmpPing.ping("127.0.0.1")
      :pong

      iex> IcmpPing.ping("::1")
      :pong
  """
  def ping(ip, opts \\ %{}) do
    # convert IP to erlang format
    {:ok, ip_addr} = IpAddr.from_string(ip)

    # create socket
    {:ok, socket} = IcmpPing.Icmp.Socket.open(ip_addr, opts)

    # send ping
    :ok = send_ping(socket, ip_addr)

    # receive pong
    :ok = receive_ping(socket, ip_addr)

    :pong
  end

  @doc """
  Supervised Ping IP.

  ## Examples

      iex> IcmpPing.ping_sup("127.0.0.1")
      :pong

      iex> IcmpPing.ping_sup("::1")
      :pong
  """
  def ping_sup(ip, opts \\ %{}, restart_value \\ :transient, timeout \\ 4000) do
    {:ok, sup_pid} =
      Supervisor.start_link(
        [
          %{
            id: IcmpPing.Server,
            start: {IcmpPing.Server, :start_link, []},
            restart: restart_value
          }
        ],
        strategy: :one_for_one,
        name: IcmpPing.Supervisor
      )

    sup_pid
    |> Supervisor.which_children()
    |> Enum.find_value(fn {IcmpPing.Server, child, _, _} -> child end)
    |> GenServer.call({:ping, ip, opts}, timeout)
  end

  defp send_ping(socket, ip_addr) do
    packet = IcmpPing.Icmp.Packet.new()
    :socket.sendto(socket, packet, get_dest(ip_addr))
  end

  defp get_dest(ip_addr) when IpAddr.is_ipv4(ip_addr), do: %{family: :inet, addr: ip_addr}

  defp get_dest(ip_addr) when IpAddr.is_ipv6(ip_addr), do: %{family: :inet6, addr: ip_addr}

  defp receive_ping(_socket, _ip_addr) do
    :ok
  end
end
