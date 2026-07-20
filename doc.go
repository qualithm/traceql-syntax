// Package traceqlsyntax is the root of a partial fork of Grafana Tempo's
// TraceQL parser packages, stripped of Tempo's runtime dependencies (the gRPC
// service stubs in tempopb, dskit, jaeger, and the query/storage machinery).
//
// Use the traceql sub-package to parse and inspect TraceQL expressions:
//
//	import "github.com/qualithm/traceql-syntax/traceql"
//
//	root, err := traceql.Parse(`{ span.http.status_code >= 500 } | count() > 1`)
//	if err != nil {
//	    return err
//	}
//
// See the README for the relationship to upstream Tempo and the sync workflow.
package traceqlsyntax
