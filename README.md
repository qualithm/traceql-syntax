# TraceQL Syntax

Standalone Go parser and AST for [Grafana Tempo](https://github.com/grafana/tempo)'s TraceQL. Lifts
the upstream `traceql` package (and the `tempopb` message types it needs) out of `grafana/tempo`
with the server-side runtime dependencies (the gRPC service stubs, `dskit`, jaeger, prometheus
metrics) stripped away.

## Installation

```bash
go get github.com/qualithm/traceql-syntax
```

## Usage

```go
import "github.com/qualithm/traceql-syntax/traceql"

root, err := traceql.Parse(`{ span.http.status_code >= 500 } | count() > 1`)
if err != nil {
    return err
}
// inspect the parsed AST
```

## Relationship to upstream Tempo

The `traceql/`, `tempopb/`, and `internal/` directories are copied near-verbatim from
`grafana/tempo`, with import paths rewritten to this module. See [NOTICE](NOTICE) for the exact
packages vendored and the modifications applied (gRPC stubs removed, dskit and prometheus
dependencies trimmed).

Only first-party code (the trimmed shims and this module's own files) is edited directly; the
vendored directories are refreshed via the sync workflow.

## Syncing from upstream

```bash
./scripts/sync-upstream.sh [TEMPO_VERSION]
```

This re-copies the vendored packages from the module cache and rewrites imports. The gRPC-stub
excision in `tempopb/tempo.pb.go` and the `tempopb/pool.go` metric trim are hand reconciliations,
so the script holds both files aside and restores them afterwards rather than regenerating them;
`internal/util/log/log.go` is a first-party shim the sync never touches. Everything else under
`traceql/`, `tempopb/`, and `internal/` is byte-for-byte upstream — the daily audit re-runs this
script and fails on any diff, so never let a formatter rewrite those files.

## Development

```bash
make hooks   # point core.hooksPath at .githooks (run once per clone)
make fmt lint test-race
```

The pre-commit hook formats only first-party files and refuses staged changes to the vendored
tree. `.vscode/settings.json` marks the same files read-only as a first line of defence.
