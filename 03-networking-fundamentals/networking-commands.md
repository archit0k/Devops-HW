# Networking Command Practice

The command list is based on the course's `devops-heros/session4-networking` resources and is organized as a reproducible lab record.

## Address and interface inspection

```bash
ip addr
ip route
```

`ip addr` lists interfaces, MAC addresses, and assigned IP addresses. `ip route` reveals the routing table; the `default via` route is normally the gateway used for destinations outside the local subnet.

## DNS lookup

```bash
nslookup example.com
```

`nslookup` asks a DNS server to resolve a hostname. A successful answer confirms that DNS can translate a name to one or more IP addresses; it does not by itself prove that HTTP is reachable.

## Reachability and path

```bash
ping -c 4 8.8.8.8
traceroute 8.8.8.8
```

`ping` sends ICMP echo requests and measures packet loss and latency. `traceroute` increments packet TTL values to show routers along the path; some routers deliberately suppress these responses, so missing hops are not automatically failures.

## Ports and HTTP

```bash
ss -tulpn
curl -I https://example.com
```

`ss -tulpn` identifies listening TCP/UDP sockets and owning processes (permissions permitting). `curl -I` requests only HTTP headers, making it a quick check of an HTTP endpoint and its status code.

## Practical troubleshooting order

1. Inspect the local address and default route.
2. Ping a known IP to separate routing from DNS problems.
3. Resolve the hostname with `nslookup`.
4. Test the application port with `curl` or `ss`.

On Windows, equivalent commands are `ipconfig /all`, `route print`, `nslookup`, `ping`, `tracert`, and `netstat -ano`.

## Captured local output (Windows, 2026-09-03)

```text
Wi-Fi IPv4 address: 100.129.164.156
Subnet mask:        255.255.240.0
Default gateway:    100.129.160.1

ping 127.0.0.1 (2 packets)
Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
Packets: Sent = 2, Received = 2, Lost = 0 (0% loss)

nslookup example.com
Server:  UnKnown
Address: 100.129.160.1
Name:    example.com
Addresses: 172.66.147.243, 104.20.23.154
```

`netstat -ano -p tcp` also confirmed local listening sockets, including ports 135, 445, 3306, and 5432.
