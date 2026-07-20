package log

import (
	kitlog "github.com/go-kit/log"
)

// Logger is a shared go-kit logger. It defaults to a no-op logger; the TraceQL
// parser only reads this global and never configures it, so the upstream
// InitLogger/LevelFilter helpers (which pulled in grafana/dskit) are omitted
// from this fork.
var Logger = kitlog.NewNopLogger()
