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

defmodule IcmpPing.Icmp.Socket do
  @moduledoc false

  alias IcmpPing.IpAddr
  require IpAddr

  def open(ip_addr, opts) when IpAddr.is_ipv4(ip_addr) do
    :socket.open(:inet, :dgram, :icmp, opts)
  end

  def open(ip_addr, opts) when IpAddr.is_ipv6(ip_addr) do
    :socket.open(:inet6, :dgram, :icmp6, opts)
  end

  def open(_), do: {:error, :malformed_ip_address}
end
