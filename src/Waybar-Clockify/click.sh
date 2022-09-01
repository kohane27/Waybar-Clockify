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

# no active tracker running; can start
if [[ "$(timew get dom.active)" == 0 ]]; then
  # start
  timew start >/dev/null 2>&1
  selection=$(rofi -location 3 -dmenu -theme Arc-Dark.rasi -no-fixed-num-lines -hover-select -me-select-entry '' -me-accept-entry MousePrimary "$@" <~/.config/waybar/scripts/Waybar-Clockify/clockify-tags.txt)
  # tag selection
  timew tag @1 "$selection"
  exit 0
fi
