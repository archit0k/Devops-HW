# AWS IAM

Archit Kulkarni | 24BCS10194 | Section A

IAM answers two questions: who is making the request (authentication), and what are they allowed to do (authorization). A user is an identity; a group collects users for shared permissions; a role is assumed and supplies temporary credentials. Roles work well for EC2 applications, federation and cross-account access without embedding access keys.

A policy is JSON with `Effect`, `Action`, `Resource` and optional `Condition`. Identity policies attach to users/groups/roles; resource policies attach to supported resources, such as an S3 bucket. Explicit deny overrides allow. A role also has a trust policy saying who can assume it; trust is not the same as its permissions.

Least privilege means only the needed actions on needed resources. MFA adds a second sign-in factor. Protect root credentials and avoid root for daily work; use federation/IAM Identity Center for human access and roles for workloads. Rotate/remove unused long-lived keys, never commit them, and audit activity with CloudTrail. IAM is global rather than a separate identity store per AWS Region.

[AWS IAM introduction](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html), [policy evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html).
