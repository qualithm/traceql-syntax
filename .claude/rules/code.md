---
description: "Code guidelines for a Go module that vendors upstream source"
paths:
  - "*.go"
  - "logqlmodel/**/*.go"
  - "internal/util/log/**/*.go"
  - "tempopb/pool.go"
  - "tempopb/tempo.pb.go"
---

# Go Code Guidelines (vendored upstream)

Most of this module is upstream source that `scripts/sync-upstream.sh` copies in. Its header lists
the paths it overwrites and the first-party ones it keeps. These rules cover the first-party files
only.

## Never hand-edit synced paths

- A change to a path the script overwrites is lost on the next sync and fails the daily audit's
  Upstream Sync Drift job. Change the pin and re-run the script instead, or move the change into a
  first-party file.
- Upstream code keeps upstream's style: its errors, panics, logging and lint findings stay as they
  are. Don't reformat it or "fix" it to match these rules.
- A file the script holds aside (a trimmed reimplementation or hand-stripped generated code) is
  reconciled by hand when the pin moves: follow the script's notes, and review the diff against
  upstream.

## First-party code

- `make lint` runs `golangci-lint` with the repo's `.golangci.yaml` (errcheck, errorlint, revive's
  exported-doc rule, gosec) over the first-party packages. `gofmt` and `goimports` (local packages
  last) format them, and `doc.go` holds the one-line package comment.
- Errors are lowercase, with no trailing punctuation, and wrapped with context:
  `fmt.Errorf("parsing query: %w", err)`. Never panic on input: a parser returns an error for any
  string it's given. A sentinel that mirrors upstream keeps upstream's exact text.
- Tests sit next to the code: table-driven with `t.Run`, plus the fuzz (and, where present,
  property) tests at the root. A behaviour change carries tests that cover its new lines
  (`dx coverage patch` checks them).
- Run `go mod tidy` after a dependency change and commit `go.sum`. No `replace` directives.
- A hand-stripped generated file (`tempopb/tempo.pb.go`) takes only the strip its sync note
  describes: no doc comments, rewording or reformatting, so the next re-strip stays a clean diff.

## Generated files

`.github/workflows/ci.yaml` is generated from `dx/ci-templates/` by `dx ci sync`; never edit it
here. Required checks: `CI Required`, `PR Title`, `Decision Citations`.
