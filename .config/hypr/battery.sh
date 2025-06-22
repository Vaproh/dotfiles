#!/usr/bin/env bash
upower -i "$(upower -e | grep battery)" \
  | awk '/percentage:/ { printf "  %s", $2 }'

