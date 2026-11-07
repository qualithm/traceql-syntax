package traceqlsyntax_test

import (
	"testing"

	"github.com/qualithm/traceql-syntax/traceql"
)

// Seeds span the grammar: spanset filters, intrinsics and scoped attributes,
// structural and set operators, pipelines, aggregates, metrics and hints.
var traceqlSeeds = []string{
	`{ }`,
	`{ .http.status_code = 500 }`,
	`{ span.http.method = "GET" && resource.service.name != "api" }`,
	`{ duration > 1s || status = error }`,
	`{ name =~ "GET /.*" && kind = server }`,
	`{ .a = 1 } >> { .b = 2 }`,
	`{ .a } > { .b } ~ { .c } !>> { .d }`,
	`{ .a = 1 } && { .b = 2 } || { .c = 3 }`,
	`{ .a = 1 } | count() > 2`,
	`{ } | avg(duration) > 100ms | by(resource.service.name)`,
	`{ } | select(span.http.url, duration)`,
	`{ status = error } | rate() by (resource.service.name)`,
	`{ } | quantile_over_time(duration, .5, .99) with (sample=true)`,
	`{ trace:rootService = "api" && event:name = "exception" }`,
	`{ .a != nil && .b = true && .c >= -1.5 }`,
	`{ link:traceID = "abc" } | coalesce()`,
}

// FuzzParse checks that the TraceQL parsers never panic, and that a parsed
// expression prints and reparses without panicking.
func FuzzParse(f *testing.F) {
	for _, seed := range traceqlSeeds {
		f.Add(seed)
	}
	f.Fuzz(func(t *testing.T, query string) {
		_, _ = traceql.ParseLenient(query)
		expr, err := traceql.Parse(query)
		if err != nil {
			return
		}
		_, _ = traceql.Parse(expr.String())
	})
}
