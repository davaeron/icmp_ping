# IcmpPing

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `icmp_ping` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:icmp_ping, "~> 0.1.0"}
  ]
end
```

In Linux execute following lines of code to allow userlevel ping for current user group:

$ echo "net.ipv4.ping_group_range = `id -g` `id -g`" | sudo tee -a /etc/sysctl.conf

$ sudo sysctl -p


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/icmp_ping>.

## Copyright and License

Copyright (c) 2022, Pertsev Dmitriy.

This library is released under the Apache License, Version 2.0. See the [LICENSE](./LICENSE) file
for further details.

This project contains some parts from 3rd party works as follow:

- NetAddress by Lambda, Inc., and Isaac Yonemoto: [ityonemo/net_address](https://github.com/ityonemo/net_address).
