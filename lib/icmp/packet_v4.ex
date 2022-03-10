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

defmodule IcmpPing.Icmp.PacketV4 do
  @moduledoc false

  @empty_checksum <<0::16>>
  @empty_payload <<0::8*4>>

  defstruct id: nil, type: :echo_request, seq: 0, payload: @empty_payload

  @type icmp_types :: :echo_request | :echo_reply

  @type t :: %__MODULE__{
          id: 0..0xFFFF,
          type: icmp_types,
          seq: non_neg_integer,
          payload: binary
        }

  @type_to_code [echo_request: <<8>>, echo_reply: <<0>>]

  def new(), do: new(struct(__MODULE__))

  def new(list) when is_list(list), do: new(struct(__MODULE__, list))

  def new(%__MODULE__{type: type, id: id, seq: seq, payload: payload}) when id == nil do
    new(%__MODULE__{type: type, id: get_hash_of_current_process(), seq: seq, payload: payload})
  end

  def new(%__MODULE__{type: type, id: id, seq: seq, payload: payload}) do
    insert_checksum(
      <<@type_to_code[type]::binary, <<0::8>>, @empty_checksum::binary, id::16, seq::16,
        payload::binary>>
    )

    # <<@type_to_code[type]::binary, <<0::8>>, @empty_checksum::binary, id::16, seq::16,
    #   payload::binary>>
  end

  defp insert_checksum(payload = <<first::16, @empty_checksum>> <> rest) do
    <<first::16, sum16compl(payload)::16, rest::binary>>
  end

  defp sum16compl(binary, sum16 \\ 0)

  defp sum16compl(<<first::16>>, sum16), do: Bitwise.~~~(first + sum16)

  defp sum16compl(<<first::16>> <> rest, sum16), do: sum16compl(rest, first + sum16)

  @spec get_hash_of_current_process() :: 0..0xFFFF
  defp get_hash_of_current_process(), do: :erlang.phash2(self(), 65_536)

  @spec behead(binary) :: {:ok, binary}
  @doc """
  strips the IPv4 header from the incoming data
  """
  def behead(
        <<_version_ihl, _dscp_ecn, _length::16, _id::16, _flags_frag_offset::16, _ttl, _proto,
          _header_cksum::16, _src_ip::32, _dst_ip::32>> <> payload
      ) do
    {:ok, payload}
  end

  @spec decode(binary) :: {:ok, t} | {:error, :packet}
  @doc """
  decodes an icmp packet and converts it to a structured datatype.
  """
  def decode(<<0, 0, _checksum::16, id::16, seq::16, payload::binary>>) do
    {:ok, %__MODULE__{type: :echo_reply, seq: seq, id: id, payload: payload}}
  end

  def decode(_), do: {:error, :packet}
end
