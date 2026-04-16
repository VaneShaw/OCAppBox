#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_DIR="$ROOT_DIR/Example"
WORKSPACE_PATH="$EXAMPLE_DIR/OCAppBoxExample.xcworkspace"
APP_SCHEME_NAME="OCAppBoxExample"
DERIVED_DATA_PATH="$ROOT_DIR/build/DerivedData"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ocappbox-validate.XXXXXX")"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

find_test_destination() {
  local destinations
  destinations="$(xcodebuild -workspace "$WORKSPACE_PATH" -scheme "$APP_SCHEME_NAME" -showdestinations 2>/dev/null)"

  local destination
  destination="$(printf '%s\n' "$destinations" | ruby -e '
    lines = STDIN.read.lines
    candidates = lines.select { |line| line.include?("platform:iOS Simulator") && line.include?("id:") }
    chosen = candidates.find { |line| line.include?("name:iPhone") } || candidates.first
    exit 1 if chosen.nil?
    id = chosen[/id:([^,}]+)/, 1]&.strip
    name = chosen[/name:([^,}]+)/, 1]&.strip
    if id && !id.empty?
      puts "platform=iOS Simulator,id=#{id}"
    elsif name && !name.empty?
      puts "platform=iOS Simulator,name=#{name}"
    else
      exit 1
    end
  ')"

  if [ -z "$destination" ]; then
    echo "No iOS Simulator destination found for $APP_SCHEME_NAME." >&2
    exit 1
  fi

  echo "$destination"
}

echo "==> Installing CocoaPods dependencies"
(
  cd "$EXAMPLE_DIR"
  pod install
)

echo "==> Building example workspace"
xcodebuild \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$APP_SCHEME_NAME" \
  -configuration Debug \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  clean build \
  -quiet

TEST_DESTINATION="$(find_test_destination)"

echo "==> Running unit tests"
xcodebuild \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$APP_SCHEME_NAME" \
  -configuration Debug \
  -destination "$TEST_DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  test \
  -quiet

echo "==> Smoke testing generators"
ruby "$ROOT_DIR/Scripts/generate_module.rb" SmokeModule --output "$TMP_ROOT/Module"
ruby "$ROOT_DIR/Scripts/generate_service.rb" SmokeService --domain Smoke --output "$TMP_ROOT/Service"

echo "Validation passed."
