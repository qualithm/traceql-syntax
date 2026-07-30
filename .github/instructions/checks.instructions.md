---
applyTo: "**"
description: "Exact pre-commit commands for the go-vendored CI archetype, kept in sync with ci.yaml"
---

# Pre-commit Checks

This repo's `ci.yaml` is generated from `dx/ci-templates/go-vendored.yaml` via `dx ci sync` (check
for drift with `dx ci drift`). Run these before committing so CI passes on the first try:

```bash
# Scoped to first-party files; vendored packages keep upstream style.
gofmt -s -l ./*.go tempopb/pool.go internal/util/log/log.go
go mod tidy   # commit any resulting go.mod/go.sum diff
go vet ./...
go build ./...
go test -race -count=1 ./...
```

There is no `golangci-lint` job for this repo — vendored upstream code doesn't conform to it. This
fork has no first-party package, so nothing is coverage-gated; vendored code is tracked only.

The daily audit re-runs `scripts/sync-upstream.sh` and requires a byte-clean `git diff`, so never
let a formatter rewrite a vendored file — the comparison has no normalisation, and a single
reformatted line fails the `Upstream Sync Drift` job until it is reverted.
