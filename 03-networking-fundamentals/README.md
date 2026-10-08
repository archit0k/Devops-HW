# Session 4 - Networking Fundamentals

Archit Kulkarni | 24BCS10194 | Section A

[Command notes](networking-commands.md) cover addressing, routing, interfaces, ports, DNS and connectivity checks. [Actual Linux/network command output](../01-linux-fundamentals/evidence/foundations.txt) records `ip addr`, `ip route`, `ss`, `getent`, `ping`, file/process checks and the system-information script.

A local address identifies an interface; the subnet mask/prefix identifies its network. The default route handles destinations without a more specific route. TCP uses a connection and reliable ordered delivery; UDP does not provide those guarantees. DNS maps names to records, while an HTTP connection also needs a working route, port and application.

Troubleshooting order: check the interface/address, route, name resolution, listening socket and then the application response. A failed ping alone does not prove the web service is down; ICMP can be filtered.

Modern networks use CIDR, not classful allocation. Private IPv4 ranges are `10.0.0.0/8`, `172.16.0.0/12` and `192.168.0.0/16`. `127.0.0.0/8` is loopback, and `169.254.0.0/16` is link-local.

## Recheck

[Windows/WSL command output](evidence/network-check-complete.txt) records the Wi-Fi address/prefix, default gateway, DNS lookup, listening TCP ports, an eight-hop route trace and HTTPS status 200. Some hops did not answer the trace; the HTTPS check still worked. [check-network.ps1](check-network.ps1) repeats these read-only checks without changing DNS settings.
