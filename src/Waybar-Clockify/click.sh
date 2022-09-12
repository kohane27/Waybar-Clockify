#!/bin/bash

# rofi flags:
#
# -location
# Specify where the window should be located. The numbers map to the following locations on screen:
# 1 2 3
# 8 0 4
# 7 6 5
#
# -fixed-num-lines
# Keep a fixed number of visible lines.
#
# -hover-select -me-select-entry '' -me-accept-entry MousePrimary
# utilize hover-select and accept an entry in a single click:

selection=$(rofi -location 3 -dmenu -theme Arc-Dark.rasi -no-fixed-num-lines -hover-select -me-select-entry '' -me-accept-entry MousePrimary "$@" <~/.config/waybar/scripts/Waybar-Clockify/clockify-tags.txt)

# no active tracker running; can start
if [[ "$(timew get dom.active)" == "0" ]]; then
  # start
  timew start >/dev/null 2>&1
  # tag selection
  timew tag @1 "$selection"
# active tracker with tag
elif [[ "$(timew get dom.active)" == "1" ]] && [[ "$(timew get dom.active.tag.count)" == "1" ]]; then
  current_tag="$(timew get dom.active.tag.1)"
  # untag current tag
  timew untag @1 "$current_tag"
  # tag again with new selection
  timew tag @1 "$selection"
fi

exit 0
