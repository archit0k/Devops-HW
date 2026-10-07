# AWS S3

Archit Kulkarni | 24BCS10194 | Section A

S3 stores objects rather than filesystem blocks. A bucket holds objects; each object has a key, content and metadata. Prefixes can look like folders without being real filesystem directories. General-purpose bucket naming is globally scoped, and a bucket belongs to a Region.

S3 Standard suits frequent access; Standard-IA/One Zone-IA suit infrequent access; Intelligent-Tiering handles changing access patterns; Glacier classes trade retrieval characteristics for archival cost. Lifecycle rules move or expire objects. Versioning keeps older object versions; a delete marker does not erase all historical versions. Replication requires setup and permissions rather than happening automatically across Regions.

Use IAM/bucket policies and Block Public Access. Prefer policy-based access over legacy ACLs. Server-side encryption protects stored content; HTTPS protects transfer. Presigned URLs temporarily authorize a specific operation but must be handled as sensitive links. Strong read-after-write consistency applies to object puts/deletes.

Static website hosting is different from a private bucket. The Terraform exercise deliberately keeps its bucket private and uses SSE-S3 encryption. Backups, artifacts and logs are common S3 uses, but state/artifact buckets still need restricted permissions and retention rules.

[AWS S3 documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html).
