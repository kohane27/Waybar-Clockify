#!/bin/bash

main() {
  while :; do
    if [[ "$(timew get dom.active)" == "0" ]]; then
      printf "%s\n" "0:00:00"
    else
      if [[ "$(timew)" =~ (Total.*?[0-9]{1}:[0-9]{2}:[0-9]{2}) ]]; then
        printf "%s" "${BASH_REMATCH[1]}" | cut -c 21-27
      fi
    fi
    sleep 1
  done
}

main
