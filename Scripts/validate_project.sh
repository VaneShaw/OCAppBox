#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/OCAppBox.xcodeproj"
WORKSPACE_PATH="$ROOT_DIR/OCAppBox.xcworkspace"
APP_SCHEME_NAME="OCAppBox"
DERIVED_DATA_PATH="$ROOT_DIR/build/DerivedData"
WORKSPACE_DERIVED_DATA_PATH="$ROOT_DIR/build/WorkspaceDerivedData"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ocappbox-validate.XXXXXX")"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

find_test_destination() {
  local destinations
  destinations="$(xcodebuild -project "$PROJECT_PATH" -scheme "$APP_SCHEME_NAME" -showdestinations 2>/dev/null)"

  local destination
  destination="$(printf '%s\n' "$destinations" | ruby -e '
    lines = STDIN.read.lines
    candidates = lines.select do |line|
      line.include?("platform:iOS Simulator") &&
        line.include?("id:") &&
        !line.include?("placeholder") &&
        !line.include?("Any iOS Simulator Device") &&
        !line.include?("error:")
    end
    chosen = candidates.find { |line| line.include?("name:iPhone") } || candidates.first
    exit 0 if chosen.nil?
    id = chosen[/id:([^,}]+)/, 1]&.strip
    name = chosen[/name:([^,}]+)/, 1]&.strip
    if id && !id.empty?
      puts "platform=iOS Simulator,id=#{id}"
    elsif name && !name.empty?
      puts "platform=iOS Simulator,name=#{name}"
    else
      exit 0
    end
  ')"

  echo "$destination"
}

echo "==> Regenerating starter app project"
ruby "$ROOT_DIR/Scripts/generate_project.rb"

echo "==> Building starter app project"
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$APP_SCHEME_NAME" \
  -configuration Debug \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  clean build \
  -quiet

TEST_DESTINATION="$(find_test_destination)"

if [ -n "$TEST_DESTINATION" ]; then
  echo "==> Running unit tests"
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$APP_SCHEME_NAME" \
    -configuration Debug \
    -destination "$TEST_DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    test \
    -quiet
else
  echo "==> Skipping unit tests (no concrete iOS Simulator runtime available)"
fi

echo "==> Installing starter app third-party dependencies"
(
  cd "$ROOT_DIR"
  pod install
)

echo "==> Building starter app workspace"
xcodebuild \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$APP_SCHEME_NAME" \
  -configuration Debug \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$WORKSPACE_DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  build \
  -quiet

echo "==> Smoke testing generators"
ruby "$ROOT_DIR/Scripts/generate_module.rb" SmokeModule --output "$TMP_ROOT/Module"
ruby "$ROOT_DIR/Scripts/generate_service.rb" SmokeService --domain Smoke --output "$TMP_ROOT/Service"
ruby "$ROOT_DIR/Scripts/generate_service.rb" Feed --domain API --kind api --output "$TMP_ROOT/APIService"
ruby "$ROOT_DIR/Scripts/generate_page.rb" SmokeModule Feed --type plain --output "$TMP_ROOT/Page/Plain"
ruby "$ROOT_DIR/Scripts/generate_page.rb" SmokeModule FeedTable --type table --output "$TMP_ROOT/Page/Table"
ruby "$ROOT_DIR/Scripts/generate_page.rb" SmokeModule FeedGrid --type collection --output "$TMP_ROOT/Page/Collection"

TMP_ROUTE_HEADER="$TMP_ROOT/Route/OCBDemoRouteCatalog.h"
TMP_ROUTE_IMPL="$TMP_ROOT/Route/OCBDemoRouteCatalog.m"
mkdir -p "$(dirname "$TMP_ROUTE_HEADER")"
printf '%s\n' '#import <Foundation/Foundation.h>' '' 'NS_ASSUME_NONNULL_BEGIN' '' 'NS_ASSUME_NONNULL_END' > "$TMP_ROUTE_HEADER"
printf '%s\n' '#import "OCBDemoRouteCatalog.h"' > "$TMP_ROUTE_IMPL"
ruby "$ROOT_DIR/Scripts/generate_route.rb" SmokeModule Feed \
  --header "$TMP_ROUTE_HEADER" \
  --impl "$TMP_ROUTE_IMPL"

test -f "$TMP_ROOT/Service/Smoke/OCBSmokeServiceService.m"
test -f "$TMP_ROOT/APIService/API/OCBFeedService.h"
test -f "$TMP_ROOT/APIService/API/OCBFeedService.m"
test -f "$TMP_ROOT/Page/Plain/OCBSmokeModuleFeedViewController.m"
test -f "$TMP_ROOT/Page/Table/OCBSmokeModuleFeedTableViewController.m"
test -f "$TMP_ROOT/Page/Collection/OCBSmokeModuleFeedGridViewController.m"
grep -q 'OCBDemoRouteSmokeModuleFeed' "$TMP_ROUTE_HEADER"
grep -q 'ocb://smoke_module/feed' "$TMP_ROUTE_IMPL"

echo "Validation passed."
