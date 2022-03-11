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

defmodule ICMPPing.ICMP.Packet do
  @moduledoc false

  alias ICMPPing.IPAddress
  require IPAddress

  @empty_checksum <<0::16>>
  @empty_payload <<0::8*32>>

  @enforce_keys [:ip_addr]
  defstruct @enforce_keys ++ [id: nil, seq: 0, payload: @empty_payload]

  @type t :: %__MODULE__{
          ip_addr: binary,
          id: 0..0xFFFF,
          seq: non_neg_integer,
          payload: binary
        }

  @echo_request_v4 <<8::8>>
  # @echo_reply_v4 <<0::8>>
  @echo_request_v6 <<128::8>>
  # @echo_reply_v6 <<129::8>>

  def new(list) when is_list(list), do: new(struct(__MODULE__, list))

  # IPv4 section
  def new(%__MODULE__{ip_addr: ip_addr, id: id, seq: seq, payload: payload})
      when IPAddress.is_ipv4(ip_addr) and id == nil do
    insert_checksum_v4(
      <<@echo_request_v4, <<0::8>>, @empty_checksum::binary, get_hash_of_current_process()::16,
        seq::16, payload::binary>>
    )
  end

  def new(%__MODULE__{ip_addr: ip_addr, id: id, seq: seq, payload: payload})
      when IPAddress.is_ipv4(ip_addr) do
    insert_checksum_v4(
      <<@echo_request_v4, <<0::8>>, @empty_checksum::binary, id::16, seq::16, payload::binary>>
    )
  end

  # IPv6 section
  def new(%__MODULE__{ip_addr: ip_addr, id: id, seq: seq, payload: payload})
      when IPAddress.is_ipv6(ip_addr) and id == nil do
    insert_checksum_v6(
      <<@echo_request_v6, <<0::8>>, @empty_checksum::binary, get_hash_of_current_process()::16,
        seq::16, payload::binary>>
    )
  end

  def new(%__MODULE__{ip_addr: ip_addr, id: id, seq: seq, payload: payload})
      when IPAddress.is_ipv6(ip_addr) do
    insert_checksum_v6(
      <<@echo_request_v6, <<0::8>>, @empty_checksum::binary, id::16, seq::16, payload::binary>>
    )
  end

  # Return ICMPv4 packet with calcucaled checksum
  defp insert_checksum_v4(payload = <<head::16, @empty_checksum>> <> tail) do
    <<head::16, ICMPPing.IPChecksum.calculate(payload)::16, tail::binary>>
  end

  # Return ICMPv6 packet with calcucaled checksum
  defp insert_checksum_v6(_payload = <<head::16, @empty_checksum>> <> tail) do
    # calculate checksum with pseudo ipv6 header
    <<head::16, @empty_checksum::binary, tail::binary>>
  end

  # If packet id was not supplied, we use hash from current process pid
  @spec get_hash_of_current_process() :: 0..0xFFFF
  defp get_hash_of_current_process(), do: :erlang.phash2(self(), 65_536)

  # @spec behead(binary) :: {:ok, binary}
  # @doc """
  # strips the IPv4 header from the incoming data
  # """
  # def behead(
  #       <<_version_ihl, _dscp_ecn, _length::16, _id::16, _flags_frag_offset::16, _ttl, _proto,
  #         _header_cksum::16, _src_ip::32, _dst_ip::32>> <> payload
  #     ) do
  #   {:ok, payload}
  # end

  # @spec decode(binary) :: {:ok, t} | {:error, :packet}
  # @doc """
  # decodes an icmp packet and converts it to a structured datatype.
  # """
  # def decode(<<0, 0, _checksum::16, id::16, seq::16, payload::binary>>) do
  #   {:ok, %__MODULE__{type: :echo_reply, seq: seq, id: id, payload: payload}}
  # end

  # def decode(_), do: {:error, :packet}
end
