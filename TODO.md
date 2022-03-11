# TODO

* Packet options
* ICMPv6 checksum (?) Looks like it works automagically, even if i supply zero checksum
* How TTL works ? It's setsockopts

* Extend "opts" for send_ping:
socket_options: [], packet_options: []
for socket:
TTL
for packet:
    identifier: 0..0xFFFF,
    sequence_number: non_neg_integer,
    payload: binary

* some ASCII default payload
* payload generator may be? 
