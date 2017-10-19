#!/usr/bin/env bash
#
# Looks for significant differences between jsonapi-rb vs. ams serialization.
#
# Strategy:
#  1. The data being serialized is the same every time.
#     i.e. All ids and timestamps or otherwise variable fields being serialized
#     are always the same.
#  2. Compare the data in a way that accounts for the order different resources are included.
#    1. Compare the .data members, sort keys.
#    2. Compare the .included posts, sort keys.
#    3. Compare the .included comments, sort keys.
#    4. Confirm the included members are all either posts or comments.
#
# Depends on:
#   jq: installed via npm
#   diff: installed on system
#
# Usage:
#  ./compare.sh
#
# Example output (abridged):
#
# -------------------------------------data (user)
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "birthday": "2017-07-01 05:00:00 UTC",                          "birthday": "2017-07-01 05:00:00 UTC",
#     "created_at": "2017-07-01 05:00:00 UTC",                        "created_at": "2017-07-01 05:00:00 UTC",
#     "first_name": "Diana",                                          "first_name": "Diana",
#     "last_name": "Prince",                                          "last_name": "Prince",
#     "updated_at": "2017-07-01 05:00:00 UTC"                         "updated_at": "2017-07-01 05:00:00 UTC"
#   },                                                              },
#   "id": "1",                                                      "id": "1",
#   "relationships": {                                              "relationships": {
#     "posts": {                                                      "posts": {
#       "data": [                                                       "data": [
#         {                                                               {
#           "id": "2",                                                      "id": "2",
#           "type": "posts"                                                 "type": "posts"
#         },                                                              },
#         {                                                               {
#           "id": "5",                                                      "id": "5",
#           "type": "posts"                                                 "type": "posts"
#         }                                                              }
#       ]                                                               ]
#     }                                                               }
#   },                                                              },
#   "type": "users"                                                 "type": "users"
# }                                                               }
# -------------------------------------included posts
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "body": "awesome content",                                      "body": "awesome content",
#     "created_at": "2017-07-01 05:00:00 UTC",                        "created_at": "2017-07-01 05:00:00 UTC",
#     "title": "Some Post",                                           "title": "Some Post",
#     "updated_at": "2017-07-01 05:00:00 UTC"                         "updated_at": "2017-07-01 05:00:00 UTC"
#   },                                                              },
#   "id": "2",                                                      "id": "2",
#   "relationships": {                                              "relationships": {
#     "comments": {                                                   "comments": {
#       "data": [                                                       "data": [
#         {                                                               {
#           "id": "3",                                                      "id": "3",
#           "type": "comments"                                              "type": "comments"
#         },                                                              },
#         {                                                               {
#           "id": "4",                                                      "id": "4",
#           "type": "comments"                                              "type": "comments"
#         }                                                               }
#       ]                                                               ]
#     },                                                              },
#     "user": {                                                       "user": {
#       "meta": {                                               |       "data": {
#         "included": false                                     |         "id": "1",
#                                                               >         "type": "users"
#       }                                                               }
#     }                                                               }
#   },                                                              },
#   "type": "posts"                                                 "type": "posts"
# }                                                               }
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "body": "awesome content",                                      "body": "awesome content",
#     "created_at": "2017-07-01 05:00:00 UTC",                        "created_at": "2017-07-01 05:00:00 UTC",
#     "title": "Some Post",                                           "title": "Some Post",
#     "updated_at": "2017-07-01 05:00:00 UTC"                         "updated_at": "2017-07-01 05:00:00 UTC"
#   },                                                              },
#   "id": "5",                                                      "id": "5",
#   "relationships": {                                              "relationships": {
#     "comments": {                                                   "comments": {
#       "data": [                                                       "data": [
#         {                                                               {
#           "id": "6",                                                      "id": "6",
#           "type": "comments"                                              "type": "comments"
#         },                                                              },
#         {                                                               {
#           "id": "7",                                                      "id": "7",
#           "type": "comments"                                              "type": "comments"
#         }                                                               }
#       ]                                                               ]
#     },                                                              },
#     "user": {                                                       "user": {
#       "meta": {                                               |       "data": {
#         "included": false                                     |         "id": "1",
#                                                               >         "type": "users"
#       }                                                               }
#     }                                                               }
#   },                                                              },
#   "type": "posts"                                                 "type": "posts"
# }                                                               }
# -------------------------------------included comments
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "author": "me",                                                 "author": "me",
#     "comment": "nice blog"                                          "comment": "nice blog"
#   },                                                              },
#   "id": "3",                                                      "id": "3",
#   "relationships": {                                              "relationships": {
#     "post": {                                                       "post": {
#       "meta": {                                               |       "data": {
#         "included": false                                     |         "id": "2",
#                                                               >         "type": "posts"
#       }                                                               }
#     }                                                               }
#   },                                                              },
#   "type": "comments"                                              "type": "comments"
# }                                                               }
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "author": "me",                                                 "author": "me",
#     "comment": "nice blog"                                          "comment": "nice blog"
#   },                                                              },
#   "id": "4",                                                      "id": "4",
#   "relationships": {                                              "relationships": {
#     "post": {                                                       "post": {
#       "meta": {                                               |       "data": {
#         "included": false                                     |         "id": "2",
#                                                               >         "type": "posts"
#       }                                                               }
#     }                                                               }
#   },                                                              },
#   "type": "comments"                                              "type": "comments"
# }                                                               }
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "author": "me",                                                 "author": "me",
#     "comment": "nice blog"                                          "comment": "nice blog"
#   },                                                              },
#   "id": "6",                                                      "id": "6",
#   "relationships": {                                              "relationships": {
#     "post": {                                                       "post": {
#       "meta": {                                               |       "data": {
#         "included": false                                     |         "id": "5",
#                                                               >         "type": "posts"
#       }                                                               }
#     }                                                               }
#   },                                                              },
#   "type": "comments"                                              "type": "comments"
# }                                                               }
# {                                                               {
#   "attributes": {                                                 "attributes": {
#     "author": "me",                                                 "author": "me",
#     "comment": "nice blog"                                          "comment": "nice blog"
#   },                                                              },
#   "id": "7",                                                      "id": "7",
#   "relationships": {                                              "relationships": {
#     "post": {                                                       "post": {
#       "meta": {                                               |       "data": {
#         "included": false                                     |         "id": "5",
#                                                               >         "type": "posts"
#       }                                                               }
#     }                                                               }
#   },                                                              },
#   "type": "comments"                                              "type": "comments"
# }                                                               }
# -------------------------------------included types: ams
# "comments"
# "posts"
# -------------------------------------included types: jsonapi_rb
# "comments"
# "posts"

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

echo "-------------------------------------data (user)"
compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json ".data"
echo "-------------------------------------included posts"
compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json ".included | .[] | select(.type == \"posts\")"
echo "-------------------------------------included comments"
compare_files support/json_document-ams.json support/json_document-jsonapi_rb.json ".included | .[] | select(.type == \"comments\")"
echo "-------------------------------------included types: ams"
jq '.included | .[] |  .type' -S < support/json_document-ams.json  | sort -u
echo "-------------------------------------included types: jsonapi_rb"
jq '.included | .[] |  .type' -S < support/json_document-jsonapi_rb.json  | sort -u
