#!/usr/bin/env bash
# Re-sync vendored Tempo TraceQL source files into this fork.
#
# Usage:
#   scripts/sync-upstream.sh [TEMPO_VERSION]
#
# Defaults to the version below. The script does not commit; review the diff
# manually. Several files require MANUAL reconciliation after the copy because
# they are trimmed reimplementations or hand-stripped generated code — see the
# "MANUAL" notes below.
#
# Paths overwritten by this script (do NOT add first-party code here):
#   traceql/                         (copy_dir, full wipe + copy)
#   tempopb/                         (copy_dir; backendwork.* then removed)
#   internal/regexp/                 (copy_dir)
#   internal/collector/              (copy_dir)
#   internal/util/errors.go          (cp)
#   internal/util/traceid.go         (cp)
#   LICENSE                          (cp from tempopb/LICENSE_APACHE2)
#
# First-party / manually-reconciled paths (NEVER overwritten by this script —
# re-apply the strip after each sync and review the diff):
#   tempopb/tempo.pb.go   — excise the generated gRPC client/server service
#                           block (from the "Reference imports to suppress
#                           errors" grpc marker through the last _serviceDesc,
#                           just before the first `func (m *...) Marshal()`) and
#                           drop the now-unused context/grpc/codes/status imports.
#   tempopb/pool.go       — drop the Prometheus buffer-pool miss metrics.
#   internal/util/log/log.go — trimmed shim exposing only `Logger`.
#   doc.go, README.md, Makefile, NOTICE, VERSION, codecov.yaml, .golangci.yaml,
#   .github/, scripts/

set -euo pipefail

TEMPO_VERSION="${1:-v1.5.1-0.20260521222423-9f50627757b1}"
MODULE_PATH="github.com/qualithm/traceql-syntax"

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

# Resolve the Tempo source in the local module cache.
GOPATH="$(go env GOPATH)"
tempo="$GOPATH/pkg/mod/github.com/grafana/tempo@${TEMPO_VERSION}"
if [[ ! -d "$tempo" ]]; then
  echo "Tempo ${TEMPO_VERSION} is not in the module cache. Run:" >&2
  echo "  go mod download github.com/grafana/tempo@${TEMPO_VERSION}" >&2
  exit 1
fi

# Copy vendored directories verbatim.
copy_dir() {
  local src="$1" dst="$2"
  # Module cache files/dirs are mode 0555; ensure dst is writable before rm
  # and after cp so subsequent operations can modify the tree.
  if [[ -e "$dst" ]]; then
    chmod -R u+w "$dst"
  fi
  rm -rf "$dst"
  mkdir -p "$dst"
  cp -R "$src"/. "$dst"/
  chmod -R u+w "$dst"
}

copy_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    chmod u+w "$dst"
  fi
  cp "$src" "$dst"
  chmod u+w "$dst"
}

copy_dir "$tempo/pkg/traceql"   "traceql"
copy_dir "$tempo/pkg/tempopb"   "tempopb"
copy_dir "$tempo/pkg/regexp"    "internal/regexp"
copy_dir "$tempo/pkg/collector" "internal/collector"

copy_file "$tempo/pkg/util/errors.go"  "internal/util/errors.go"
copy_file "$tempo/pkg/util/traceid.go" "internal/util/traceid.go"

# Drop the gRPC-only backend-work service package entirely (unused by the parser).
rm -f tempopb/backendwork.pb.go tempopb/backendwork.proto

# Rewrite imports (longest prefixes first).
rewrite() {
  find "$@" -name '*.go' -print0 | xargs -0 sed -i.bak \
    -e "s|github.com/grafana/tempo/pkg/tempopb|${MODULE_PATH}/tempopb|g" \
    -e "s|github.com/grafana/tempo/pkg/traceql|${MODULE_PATH}/traceql|g" \
    -e "s|github.com/grafana/tempo/pkg/regexp|${MODULE_PATH}/internal/regexp|g" \
    -e "s|github.com/grafana/tempo/pkg/collector|${MODULE_PATH}/internal/collector|g" \
    -e "s|github.com/grafana/tempo/pkg/util/log|${MODULE_PATH}/internal/util/log|g" \
    -e "s|github.com/grafana/tempo/pkg/util|${MODULE_PATH}/internal/util|g"
  find "$@" -name '*.go.bak' -delete
}
rewrite traceql tempopb internal

# Refresh LICENSE from upstream.
copy_file "$tempo/pkg/tempopb/LICENSE_APACHE2" "LICENSE"

# Tidy and report.
go mod tidy
echo
echo "Sync complete against Tempo ${TEMPO_VERSION}."
echo "MANUAL steps still required (see header): re-excise the gRPC service block"
echo "and imports from tempopb/tempo.pb.go, re-trim tempopb/pool.go, and confirm"
echo "internal/util/log/log.go is the trimmed shim. Then run \`go build ./...\`,"
echo "\`go test ./...\`, and \`govulncheck ./...\`."
