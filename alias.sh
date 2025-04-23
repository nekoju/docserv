#!/bin/bash

# Usage:
#   DOC_TOKEN=abc123 DOC_HOST=host.domain:8080 ./doc put note.txt
#   echo "hi" | ./doc put note.txt
#   ./doc get note.txt

# --- required env vars ---
: "${DOC_TOKEN:?Need to set DOC_TOKEN}"
: "${DOC_HOST:?Need to set DOC_HOST (e.g. 192.168.1.10:8080)}"

cmd="$1"
path="$2"

case "$cmd" in
  get)
    curl -sk "https://${DOC_TOKEN}@${DOC_HOST}/docserver/doc/${path}"
    ;;
  put)
    curl -sk -X POST "https://${DOC_TOKEN}@${DOC_HOST}/docserver/doc/${path}" --data-binary @-
    ;;
  del|delete|rm)
    curl -sk -X DELETE "https://${DOC_TOKEN}@${DOC_HOST}/docserver/doc/${path}"
    ;;
  ls|list)
    curl -sk "https://${DOC_TOKEN}@${DOC_HOST}/docserver/list"
    ;;
  *)
    echo "Usage: doc {get|put|del|ls} path"
    exit 1
    ;;
esac

