#!/bin/bash

# Usage:
#   source <(curl -s https://filedump.stuff/alias.sh)
#   DOC_TOKEN=abc123 DOC_HOST=host.domain:8080 doc put note.txt
#   doc get note.txt

# --- required env vars ---
: "${DOC_TOKEN:?Need to set DOC_TOKEN}"
: "${DOC_HOST:?Need to set DOC_HOST (e.g. 192.168.1.10:8080)}"

function doc() {
  local cmd="$1"
  shift

  case "$cmd" in
    get)
      local path="$1"
      curl -s "${DOC_TOKEN}@${DOC_HOST}/doc/${path}"
      ;;
    put)
      local path="$1"
      curl -s -X POST "${DOC_TOKEN}@${DOC_HOST}/doc/${path}" --data-binary @-
      ;;
    del|delete|rm)
      local path="$1"
      curl -s -X DELETE "${DOC_TOKEN}@${DOC_HOST}/doc/${path}"
      ;;
    ls|list)
      curl -s "${DOC_TOKEN}@${DOC_HOST}/list"
      ;;
    *)
      echo "Usage: doc {get|put|del|ls} path"
      ;;
  esac
}

