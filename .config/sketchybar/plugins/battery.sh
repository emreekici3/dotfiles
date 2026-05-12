#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -o "[0-9]*%" | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep -o "AC Power")

if [ "$CHARGING" = "AC Power" ]; then
  ICON="􀢋"
else
  if [ "$PERCENTAGE" -ge 90 ]; then
    ICON="􀛨"
  elif [ "$PERCENTAGE" -ge 70 ]; then
    ICON="􀺸"
  elif [ "$PERCENTAGE" -ge 50 ]; then
    ICON="􀺶"
  elif [ "$PERCENTAGE" -ge 30 ]; then
    ICON="􀛩"
  elif [ "$PERCENTAGE" -ge 10 ]; then
    ICON="􀛪"
  else
    ICON="􀛫"
  fi
fi

sketchybar --set battery_icon icon="$ICON"
sketchybar --set battery_label label="$PERCENTAGE%"
