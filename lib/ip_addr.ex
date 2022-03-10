# Copyright 2020 Lambda, Inc., and Isaac Yonemoto.  All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule IcmpPing.IpAddr do
  @moduledoc """
  This file is from NetAddress by Lambda, Inc., and Isaac Yonemoto.
  """

  @typedoc "ipv4 representation in erlang."
  @type v4 :: {byte, byte, byte, byte}

  @typedoc "16-bit integers"
  @type short :: 0x0..0xFFFF

  @typedoc "ipv6 representation in erlang."
  @type v6 :: {short, short, short, short, short, short, short, short}

  @typedoc "any ip address, either v4 or v6"
  @type addr :: v4 | v6

  ####################################################################
  ## guards

  @doc false
  defguard is_byte(n) when is_integer(n) and n >= 0 and n <= 255
  @doc false
  defguard is_short(n) when is_integer(n) and n >= 0 and n <= 0xFFFF

  @doc """
  true if the argument is an ipv4 datatype
  usable in guards.
  ```elixir
  iex> IcmpPing.IpAddr.is_ipv4({10, 0, 0, 1})
  true
  iex> IcmpPing.IpAddr.is_ipv4(:foo)
  false
  iex> IcmpPing.IpAddr.is_ipv4({256, 0, 0, 0})
  false
  ```
  """
  defguard is_ipv4(v4)
           when is_tuple(v4) and tuple_size(v4) == 4 and
                  is_byte(elem(v4, 0)) and is_byte(elem(v4, 1)) and
                  is_byte(elem(v4, 2)) and is_byte(elem(v4, 3))

  @doc """
  true if the argument is an ipv6 datatype
  usable in guards.
  ```elixir
  iex> IcmpPing.IpAddr.is_ipv6({0, 0, 0, 0, 0, 0, 0, 1})
  true
  iex> IcmpPing.IpAddr.is_ipv6(:foo)
  false
  iex> IcmpPing.IpAddr.is_ipv6({0x10000, 0, 0, 0, 0, 0, 0, 1})
  false
  ```
  """
  defguard is_ipv6(v6)
           when is_tuple(v6) and tuple_size(v6) == 8 and
                  is_short(elem(v6, 0)) and is_short(elem(v6, 1)) and
                  is_short(elem(v6, 2)) and is_short(elem(v6, 3)) and
                  is_short(elem(v6, 4)) and is_short(elem(v6, 5)) and
                  is_short(elem(v6, 6)) and is_short(elem(v6, 7))

  @doc """
  true if the argument is either ipv6 or ipv4 datatype
  usable in guards.
  ```elixir
  iex> IcmpPing.IpAddr.is_ip({0, 0, 0, 0, 0, 0, 0, 1})
  true
  iex> IcmpPing.IpAddr.is_ip({127, 0, 0, 1})
  true
  ```
  """
  defguard is_ip(ip) when is_ipv4(ip) or is_ipv6(ip)

  ####################################################################
  ## conversions

  @doc """
  Converts an ip address from a string.
  ```elixir
  iex> IcmpPing.IpAddr.from_string!("255.255.255.255")
  {255, 255, 255, 255}
  ```
  """
  @spec from_string!(String.t()) :: addr
  def from_string!(str) do
    case from_string(str) do
      {:ok, v} -> v
      _ -> raise ArgumentError, "malformed ip address string #{str}"
    end
  end

  @doc """
  Converts an ip address from a string, returning an ok or error tuple on failure.
  """
  @spec from_string(String.t()) :: {:ok, addr} | {:error, :einval}
  def from_string(str) do
    str
    |> String.to_charlist()
    |> :inet.parse_address()
  end
end
