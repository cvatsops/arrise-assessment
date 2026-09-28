# Notes

## Task 1

db-01 is protected. It's the only io2 instance, so it's the db tier — the
one that actually holds data. Everything else is stateless enough to just
rebuild. prevent_destroy isn't hardcoded to a resource address though, it
comes from a field in the instances map (each.value.prevent_destroy), so
the module itself doesn't care which one is "special" — that's decided in
envs/dev.

## Task 2

Local state = everyone's got their own tfstate file, no shared truth, no
lock. Two applies at once → both plan against stale state, both push to
AWS, whoever finishes last overwrites their local file and the other
person's state is now wrong. Could even race on the same resource.

S3 backend fixes the "everyone has their own copy" part. DynamoDB is what
actually blocks concurrent applies — Terraform grabs a lock row before
touching state, second apply just errors out instead of running. Clear
failure instead of silent corruption.

## Task 3

**Real access keys for engine/ci?** No. ci should be OIDC (GitHub/GitLab
assuming a role via AssumeRoleWithWebIdentity, short-lived, no static
keys). engine should be SSO via Identity Center, not a standalone user.
Built it with access keys here because that's literally what the task
asked for, but wouldn't do it this way for real.

**Root vs roleB's ARN in roleC's trust policy?** Trusting root means anyone
in Account A with AssumeRole permission can get in — you're relying on
every other policy in the account being correct. Trusting roleB's specific
ARN means only that role can ever assume it, no matter what else gets
created later. Also just matches what the task asked for.

## Task 4

Left out: any managed policy (too broad), ecr:* (only need push actions, no
delete), ecs create/delete service (only updating an existing one),
unscoped PassRole (locked to one role + PassedToService condition,
otherwise it's a privilege-escalation hole), and any S3 write (read-only on
the artifacts bucket). The two Resource: "*" entries left in are AWS's
fault, not mine — GetAuthorizationToken and RegisterTaskDefinition don't
support resource scoping.

## Task 5

Two bugs. Trust policy points at user/roleB — roleB's a role, not a user,
so that ARN never matches and AssumeRole fails. Fixed to role/roleB.
Permissions policy is s3:* on Resource "*" — full access to every bucket in
the account instead of just the one. Scoped it down to the actual bucket
ARN. Both in fixed.tf.