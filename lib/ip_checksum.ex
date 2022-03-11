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

defmodule ICMPPing.IPChecksum do
  @moduledoc false

  use Bitwise, only_operators: true

  @doc """
  Calculate checksum.

  ## Examples
  Test vector from RFC 1071:

      iex> ICMPPing.IPChecksum.calculate(<<0x00, 0x01, 0xf2, 0x03, 0xf4, 0xf5, 0xf6, 0xf7>>)
      -56819

  """
  def calculate(binary) do
    checksum(binary)
  end

  def checksum(binary, checksum64bit \\ 0)

  def checksum(<<>>, checksum64bit) do
    fold_with_overflow32(checksum64bit)
  end

  def checksum(<<n1::32, n2::32>> <> rest, checksum64bit) do
    checksum(rest, n1 + n2 + checksum64bit)
  end

  def checksum(<<n1::16>> <> rest, checksum64bit) do
    checksum(rest, n1 + checksum64bit)
  end

  def checksum(<<n1::8>>, checksum64bit) do
    checksum(<<>>, n1 + checksum64bit)
  end

  def fold_with_overflow32(checksum) do
    sum = (checksum &&& 0xFFFFFFFF) + (checksum >>> 32)
    fold_with_overflow16(sum)
  end

  def fold_with_overflow16(checksum) do
    sum = (checksum &&& 0xFFFF) + (checksum >>> 16)
    ~~~((sum &&& 0xFFFF) + (sum >>> 16))
  end
end
