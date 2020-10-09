#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q conky

# Wait until the processes have been shut down
while pgrep -u $UID -x conky  >/dev/null; do sleep 1; done

# Launch bar1 and bar2
conky -d -c $HOME/.config/conky/conkyrc_orange_4k
