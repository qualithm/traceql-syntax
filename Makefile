GOVULNCHECK_VERSION := v1.3.0
GOSEC_VERSION := v2.27.1
GOSEC_ARGS ?= -exclude-dir=traceql -exclude-dir=tempopb -exclude-dir=internal ./...

.PHONY: build test test-race lint fmt audit gosec install-tools sync

build:
	go build ./...

test:
	go test ./...

test-race:
	go test -race ./...

fmt:
	gofmt -s -w ./*.go
	command -v goimports >/dev/null && goimports -w -local github.com/qualithm/traceql-syntax ./*.go || true

lint:
	go vet ./...
	command -v golangci-lint >/dev/null && golangci-lint run || echo "golangci-lint not installed; skipping"

audit:
	govulncheck ./...

gosec:
	gosec $(GOSEC_ARGS)

install-tools:
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)
	go install github.com/securego/gosec/v2/cmd/gosec@$(GOSEC_VERSION)

# Re-sync vendored Tempo source. See scripts/sync-upstream.sh for the version pin.
sync:
	./scripts/sync-upstream.sh
