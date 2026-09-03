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
