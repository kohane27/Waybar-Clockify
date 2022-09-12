#!/bin/bash

is_t_p_d_field_exist() {
  # timewarrior data format:
  # inc 20220830T061333Z - 20220830T061354Z # '{"p": "Health","t": ["run","gym"],"d": "treadmill"}'
  json=$(timew get dom.tracked.1.json)
  timew_tags=$(printf "%s" "$json" | jq -cr '.tags[0]')

  # check if t field exists
  if printf "%s\n" "$timew_tags" | jq -e 'has("t")' >/dev/null; then
    # parse potential multiple tags
    # --tag "misc,code,read"
    tag=$(printf "%s" "$timew_tags" | jq -cr '.t' | tr -d '"[]')
  else
    # "t field DOES NOT exist"
    tag=""
  fi
  # check if p field exists
  if printf "%s\n" "$timew_tags" | jq -e 'has("p")' >/dev/null; then
    project=$(printf "%s" "$timew_tags" | jq -cr '.p')
  else
    # "p field DOES NOT exist"
    project=""
  fi

  # check if d field exists
  if printf "%s\n" "$timew_tags" | jq -e 'has("d")' >/dev/null; then
    description=$(printf "%s" "$timew_tags" | jq -cr '.d')
  else
    # "d field DOES NOT exist"
    description=""
  fi
}

stop() {
  # no active instance running; exit
  if [[ $(timew get dom.active) == "0" ]]; then
    exit 1
  else
    # stop active tracker
    timew stop
    start=$(timew get dom.tracked.1.start | sed "s/T/ /g")
    end=$(timew get dom.tracked.1.end | sed "s/T/ /g")

    # real record exists, check if json inside tag exists
    is_t_p_d_field_exist

    # send to `clockify-cli`
    clockify-cli manual \
      --project "$project" \
      --description "$description" \
      --when "$start" \
      --when-to-close "$end" \
      --tag "$tag" \
      --interactive=0
    exit 0
  fi
}

stop
