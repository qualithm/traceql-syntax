# TraceQL Syntax

Standalone Go parser and AST for [Grafana Tempo](https://github.com/grafana/tempo)'s
TraceQL. Lifts the upstream `traceql` package (and the `tempopb` message types it
needs) out of `grafana/tempo` with the server-side runtime dependencies (the gRPC
service stubs, `dskit`, jaeger, prometheus metrics) stripped away.

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
`grafana/tempo`, with import paths rewritten to this module. See [NOTICE](NOTICE) for
the exact packages vendored and the modifications applied (gRPC stubs removed, dskit
and prometheus dependencies trimmed).

Only first-party code (the trimmed shims and this module's own files) is edited
directly; the vendored directories are refreshed via the sync workflow.

## Syncing from upstream

```bash
./scripts/sync-upstream.sh [TEMPO_VERSION]
```

This re-copies the vendored packages from the module cache and rewrites imports. The
gRPC-stub excision in `tempopb/tempo.pb.go`, the `tempopb/pool.go` metric trim, and
the `internal/util/log/log.go` shim are manual reconciliations documented in the
script — review the diff and re-apply them after a sync.
