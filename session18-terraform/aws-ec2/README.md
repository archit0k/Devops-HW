# AWS EC2

Archit Kulkarni | 24BCS10194 | Section A

[Back to Session 18](../README.md)

## Compute and storage

EC2 is a virtual server. An AMI supplies the initial OS/software image; instance type selects compute, memory and networking capacity. General-purpose instances balance resources, compute-optimized instances suit CPU work, and memory-optimized instances suit large in-memory workloads.

EBS provides persistent block storage; instance-store disks are tied to the host lifecycle. An EBS snapshot is a backup, not a running attached disk. A stopped EBS-backed instance generally keeps its disks and stops compute billing, but storage still costs money. Termination can delete the root disk according to its delete-on-termination setting.

## Networking and access

An instance sits in a subnet and uses a Security Group. Internet access also needs routing and an appropriate public address; opening a port alone is insufficient. A private IP is used within the VPC; a public IPv4 address supports internet routing when the other network controls permit it. Key pairs support SSH authentication, while IAM roles supply AWS API permissions. User data automates first-boot setup. IMDSv2 uses tokens for metadata requests.

## Lifecycle and uses

An instance moves from pending to running. Stopping an EBS-backed instance preserves its disks; starting boots it again, while rebooting restarts the OS without terminating the instance. Termination removes the instance, with attached-disk retention controlled separately.

On-Demand is flexible; Spot uses spare capacity and can be interrupted; Savings Plans/Reserved Instances exchange commitment for discounts. Auto Scaling changes instance count; a load balancer distributes requests. CloudWatch reports operational metrics. Common uses include web servers, build workers and compute jobs. [Session 19](../../session19-cloud-terraform/README.md) uses one web-server instance without public SSH.

[AWS EC2 documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html).
