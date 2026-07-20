---
applyTo: "**"
description: "Exact pre-commit commands for the go-vendored CI archetype, kept in sync with ci.yaml"
---

# Pre-commit Checks

This repo's `ci.yaml` is generated from `dx/ci-templates/go-vendored.yaml` via `dx ci sync` (check
for drift with `dx ci drift`). Run these before committing so CI passes on the first try:

```bash
gofmt -s -l ./*.go logqlmodel/   # scoped: vendored packages keep upstream style, not enforced
go mod tidy                      # commit any resulting go.mod/go.sum diff
go vet ./...
go build ./...
go test -race -count=1 ./...
```

There is no `golangci-lint` job for this repo — vendored upstream code doesn't conform to it. On PRs
targeting `main`, CI additionally enforces >=80% first-party line coverage for `logqlmodel/` (the
vendored `syntax`/`log`/`internal` packages are tracked but not gated).
