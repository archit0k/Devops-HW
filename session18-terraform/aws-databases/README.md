# DynamoDB and RDS

Archit Kulkarni | 24BCS10194 | Section A

[Back to Session 18](../README.md)

| Choice | Data/access model | Typical use |
| --- | --- | --- |
| DynamoDB | Key-value/document records with designed key/index access patterns | Session data, event metadata or a high-throughput key lookup |
| RDS | Relational tables, SQL, joins, constraints and transactions | Bookings, orders or other related business records |

## DynamoDB

DynamoDB is a managed key-value/document NoSQL database. Tables contain items and attributes. A primary key is a partition key alone or a partition key plus sort key. Partition-key choice spreads workload; one hot key can still be a bottleneck. Queries need key conditions, while scans inspect a much larger set of data and usually cost more.

Secondary indexes enable other access patterns. On-demand and provisioned capacity differ in how throughput is purchased/planned. TTL expires eligible data asynchronously, not at an exact deadline. Streams expose item changes for event-driven consumers. Point-in-time recovery/backups protect against accidental changes; global tables replicate across supported Regions. Design access patterns first instead of expecting arbitrary SQL joins.

[DynamoDB documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html).

## RDS

RDS manages relational engines such as PostgreSQL/MySQL, handling tasks including backups, patching and monitoring. A DB instance is the managed compute/storage environment running the selected engine. Relational tables, constraints, SQL joins and transactions suit structured records with relationships. Aurora is AWS's MySQL/PostgreSQL-compatible relational option.

Multi-AZ deployment improves availability; it is not automatically a read-scaling substitute. Read replicas serve read traffic and typically use asynchronous replication. Automated backups allow recovery within the retention window; manual snapshots are separate retained backups. Use private DB subnets, restricted Security Groups, encryption and managed credentials. Storage/IO, instance size and data transfer affect cost.

I would choose RDS for a booking application's relational constraints and DynamoDB for suitable key-based, predictable access patterns. Neither is deployed just for these research notes.

[RDS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html).
