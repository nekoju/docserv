#!/bin/bash

# Usage:
#   DOC_TOKEN=abc123 DOC_HOST=host.domain:8080 ./doc put note.txt
#   echo "hi" | ./doc put note.txt
#   ./doc get note.txt

# --- required env vars ---
: "${DOC_TOKEN:?Need to set DOC_TOKEN}"
: "${DOC_HOST:?Need to set DOC_HOST (e.g. 192.168.1.10:8080)}"

cmd="$1"
paths="$2"

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
  edit)
    local path="$1"
    local tmpfile
    tmpfile=$(mktemp /tmp/docedit.XXXXXX)
  
    # Fetch the file into the temp file
    curl -sk https://"${DOC_TOKEN}@${DOC_HOST}/docserver/doc/${path}" -o "$tmpfile"
  
    # Open in $EDITOR or default to vi
    "${EDITOR:-vi}" "$tmpfile"
  
    # Confirm upload
    read -p "Upload changes back to remote? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      cat "$tmpfile" | curl -sk -X POST https://"${DOC_TOKEN}@${DOC_HOST}/docserver/doc/${path}" --data-binary @-
      echo "Uploaded."
    else
      echo "Aborted upload."
    fi
  
    # Clean up
    rm -f "$tmpfile"
      ;;
  *)
    echo "Usage: doc {get|put|del|ls|edit} path"
    echo "Use xargs, e.g.:"
    echo "doc list | grep '^my_dir\\/' | xargs -n1 doc get"
    echo "doc list | grep '^my_dir\\/' | xargs -n1 doc del"
    exit 1
    ;;
esac

