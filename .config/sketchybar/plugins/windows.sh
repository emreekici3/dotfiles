#!/bin/bash

MAX_WINS=20

WINDOWS=$(osascript <<'APPLESCRIPT'
set appList to {}
tell application "System Events"
    set procs to every process whose background only is false
    repeat with p in procs
        try
            if (count of windows of p) > 0 then
                set appName to name of p
                if appName is not in appList then
                    set end of appList to appName
                end if
            end if
        end try
    end repeat
end tell
set output to ""
repeat with a in appList
    set output to output & a & linefeed
end repeat
return output
APPLESCRIPT
)

FOCUSED=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)

INDEX=0
while IFS= read -r APP; do
  [ -z "$APP" ] && continue
  [ $INDEX -ge $MAX_WINS ] && break

  ITEM_NAME="win.$INDEX"

  if [ "$APP" = "$FOCUSED" ]; then
    BG_COLOR=0xff9bd692
    TEXT_COLOR=0xff000000
  else
    BG_COLOR=0xff0D0B1A
    TEXT_COLOR=0xffffffff
  fi

  # click_script: tiklaninca o uygulamayi activate et
  CLICK="osascript -e 'tell application \"$APP\" to activate'"

  sketchybar --add item "$ITEM_NAME" left 2>/dev/null
  sketchybar --set "$ITEM_NAME" \
               drawing=on \
               click_script="$CLICK" \
               label="$APP" \
               label.color=$TEXT_COLOR \
               label.font="SF Pro:Semibold:13" \
               label.padding_left=8 \
               label.padding_right=8 \
               icon.drawing=off \
               background.drawing=on \
               background.color=$BG_COLOR \
               background.height=26 \
               background.corner_radius=6 \
               padding_left=4 \
               padding_right=0

  INDEX=$((INDEX + 1))
done <<< "$WINDOWS"

for i in $(seq $INDEX $((MAX_WINS - 1))); do
  sketchybar --set "win.$i" drawing=off 2>/dev/null
done
