# AWS EC2

Archit Kulkarni | 24BCS10194 | Section A

EC2 is a virtual server. An AMI supplies the initial OS/software image; instance type selects compute, memory and networking capacity. General-purpose instances balance resources, compute-optimized instances suit CPU work, and memory-optimized instances suit large in-memory workloads.

EBS provides persistent block storage; instance-store disks are tied to the host lifecycle. An EBS snapshot is a backup, not a running attached disk. A stopped EBS-backed instance generally keeps its disks and stops compute billing, but storage still costs money. Termination can delete the root disk according to its delete-on-termination setting.

An instance sits in a subnet and uses a Security Group. Internet access also needs routing and an appropriate public address; opening a port alone is insufficient. Key pairs support SSH authentication, while IAM roles supply AWS API permissions. User data automates first-boot setup. IMDSv2 uses tokens for metadata requests.

On-Demand is flexible; Spot uses spare capacity and can be interrupted; Savings Plans/Reserved Instances exchange commitment for discounts. Auto Scaling changes instance count; a load balancer distributes requests. CloudWatch reports operational metrics. The Session 19 lab uses one small instance, no public SSH and immediate cleanup.

[AWS EC2 documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html).
