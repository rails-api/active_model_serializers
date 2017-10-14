#!/usr/bin/env bash

set -o pipefail

DEBUG="${DEBUG:-false}"

if ! command -v jq &>/dev/null; then
  npm install -g jq
fi

get_for_file() {
  local path
  path="$1"
  result="$(cat ${path})"
  echo "$result"
}

compare_files() {
  local actual
  local expected
  actual="$1"
  expected="$2"
  if [ "$DEBUG" = "true" ]; then get_for_file "${expected}" >&2; fi
  diff --side-by-side \
    <(jq '.' -S <(get_for_file "${expected}")) \
    <(jq '.' -S <(get_for_file "${actual}"))
}
echo

compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json
