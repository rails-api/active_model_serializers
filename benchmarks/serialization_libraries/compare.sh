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
  local pattern
  actual="$1"
  expected="$2"
  pattern="$3"

  if [ "$DEBUG" = "true" ]; then get_for_file "${expected}" >&2; fi
  diff --side-by-side \
    <(jq "${pattern}" -S <(get_for_file "${expected}")) \
    <(jq "${pattern}" -S <(get_for_file "${actual}"))
}
echo

echo "-------------------------------------data"
compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json ".data"
echo "-------------------------------------included posts"
compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json ".included | .[] | select(.type == \"posts\")"
echo "-------------------------------------included comments"
compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json ".included | .[] | select(.type == \"comments\")"
echo "-------------------------------------included types: ams"
jq '.included | .[] |  .type' -S < support/json_document-ams.json  | sort -u
echo "-------------------------------------included types: jsonapi_rb"
jq '.included | .[] |  .type' -S < support/json_document-jsonapi_rb.json  | sort -u
