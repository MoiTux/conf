#!/bin/sh
# enable/disable the laptop screen on close/open of the laptop

export DISPLAY=':0.0'
export XAUTHORITY="${HOME}/.Xauthority"

state=$(cat /proc/acpi/button/lid/LID/state | tr -d ' ' | cut -d : -f 2)
if [ "$state" = "closed" ]; then
    xrandr --output eDP1 --off
else
    regexp='connected [0-9]{1,4}x[0-9]{1,4}\+0\+0'
    first_screen=$(xrandr | grep -E "${regexp}" | cut -d ' ' -f 1)
    if [ -z "${first_screen}" ]; then
        xrandr --output eDP1 --preferred
    else
        xrandr --output eDP1 --preferred --left-of "${first_screen}"
    fi
fi
