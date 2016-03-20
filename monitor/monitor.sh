#!/bin/sh
# auto config new screen
# screen are considered in one line
# a new screen will be added to the right of the previous screen

if [ -n "$DISPLAY" -a ! -f /tmp/.display ]
then
    echo "$DISPLAY" > /tmp/.display
else
    DISPLAY=$(cat /tmp/.display)
    export DISPLAY
fi

if [ -n "$XAUTHORITY" -a ! -f /tmp/.xauthority ]
then
    echo "$XAUTHORITY" > /tmp/.xauthority
else
    XAUTHORITY=$(cat /tmp/.xauthority)
    export XAUTHORITY
fi

# XXX override xrandr command to only call it once
_xrandr=$(xrandr)
xrandr() {
    echo "$_xrandr"
}

cmd=''

nb_connected=$(xrandr | grep -c ' connected [0-9]')
disconnected=$(xrandr | awk '/disconnected [0-9]/{print $1}')
if [ "${nb_connected}" -eq 0 ]
then
    # XXX keep always one screen to avoid killing the current session
    cmd="${cmd} --output eDP1 --preferred --scale 1x1"
    disconnected="echo ${disconnected} | grep -v eDP1"
fi

for output in $disconnected
do
    cmd="${cmd} --output ${output} --off"
done

new=$(xrandr | awk '/ connected (/{print $1}')
connected=$(xrandr | awk '/(+[0-9]{1,4}){2}/{print $1}')

no_laptop='false'
if [ -n "$new" -o -n "$connected" ]
then
    # XXX a new screen has been connected or clones has been detected
    #     so there is more that one screen no need to keep the laptop screen
    state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
    if [ "$state" = "closed" ]
    then
        cmd="${cmd} --output eDP1 --off"
        no_laptop='true'
    fi
fi

last=$(xrandr | grep ' connected [0-9]' | cut -d + -f 2 | sort -hr | head -1)
if [ "${no_laptop}" = 'true' ]
then
    last=$(xrandr | grep -v eDP1)
else
    last=$(xrandr)
fi
last=$(echo "$last" | grep "+${last}+" | cut -d ' ' -f 1 | head -1)

for output in $connected $new
do
    if [ "${no_laptop}" = 'true' -a "${output}" = 'eDP1' ]
    then
        continue
    fi
    cmd="${cmd} --output ${output} --preferred --scale 1x1"
    if [ -n "${last}" -a "$last" != "$output" ]
    then
        cmd="${cmd} --right-of ${last}"
    fi
    last=$output
done

if [ -n "$cmd" ]
then
    # XXX xrandr has been overridden so explicit call the xrandr command
    command xrandr $cmd
fi
