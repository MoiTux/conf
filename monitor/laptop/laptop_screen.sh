#!/bin/sh
# enable/disable the laptop screen on close/open of the laptop
# screen are considered in one line
# the laptop screen will always be set to the most left part of that line

if [ -n "$DISPLAY" -a ! -f /tmp/.display ];
then
    echo "$DISPLAY" > /tmp/.display
else
    DISPLAY=$(cat /tmp/.display)
    export DISPLAY
fi

if [ -n "$XAUTHORITY" -a ! -f /tmp/.xauthority ];
then
    echo "$XAUTHORITY" > /tmp/.xauthority
else
    XAUTHORITY=$(cat /tmp/.xauthority)
    export XAUTHORITY
fi

state=$(cat /proc/acpi/button/lid/LID/state | tr -d ' ' | cut -d : -f 2)
if [ "$state" = "closed" ]; then
    # XXX keep always one screen to avoid killing the current session
    if [ "$(xrandr | grep \* | wc -l)" -gt 1 ];
    then
       xrandr --output eDP1 --off
    fi
else
    regexp='connected [0-9]{1,4}x[0-9]{1,4}\+0\+0'
    first_screen=$(xrandr | grep -E "${regexp}" | cut -d ' ' -f 1)
    if [ -z "${first_screen}" ]; then
        xrandr --output eDP1 --preferred
    else
        xrandr --output eDP1 --preferred --left-of "${first_screen}"
    fi
fi
