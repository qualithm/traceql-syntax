---
description: "Runtime conventions for the first-party code of a Go module that vendors upstream"
paths:
  - "*.go"
  - "logqlmodel/**/*.go"
  - "internal/util/log/**/*.go"
---

# Runtime Conventions

These cover first-party files only. Upstream source copied in by `scripts/sync-upstream.sh` keeps
upstream's errors and logging, so never edit it to match.

## Errors

- A package's errors are `ErrName` sentinels or `NameError` types. New messages are lowercase, with
  no trailing punctuation, and name what failed (`unexpected token`). A sentinel that mirrors an
  upstream one keeps upstream's text word for word, so errors match upstream's.
- A parse error names the position it failed at, so a caller can point to it.

## Logging

- A library never writes to stdout or stderr and adds no log handlers.
- A logging shim (`internal/util/log`) exposes what the synced code reads, such as a package-level
  no-op `Logger`. Keep that shape: synced code reads it directly, so turning it into a parameter
  breaks the build.
- Never log a query or a parser message that quotes one: queries can carry user data.
