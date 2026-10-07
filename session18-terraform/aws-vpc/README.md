# AWS VPC

Archit Kulkarni | 24BCS10194 | Section A

A VPC is a logically isolated regional network with an IP address range. A subnet is a portion of that range in one Availability Zone. A public subnet has a route to an Internet Gateway; a private subnet does not. This classification does not by itself give an instance a public IP or permit incoming connections.

Route tables choose the next hop for matching destinations. An Internet Gateway connects a VPC to the internet; a NAT Gateway lets private IPv4 workloads initiate outbound connections without allowing unsolicited inbound connections. NAT has separate charges, so it is not used in this small homework lab.

Security Groups are stateful allow rules attached to interfaces; NACLs are stateless subnet rules supporting allow and deny. Peering connects VPCs but is not transitive. Transit Gateway provides a central routing hub. VPN connects over encrypted internet tunnels; Direct Connect provides a dedicated connectivity option. VPC endpoints can access supported AWS services privately. Flow Logs record network-flow metadata, not packet payloads.

Plan non-overlapping CIDRs, separate application/database tiers and check routes, addresses and security controls together when troubleshooting connectivity.

[AWS VPC guide](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html), [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html).
