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

state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
nb_connected_all=$(xrandr | grep -c ' connected ')
if [ "${state}" = "closed" ]
then
    # the laptop's screen is closed remove it from available screen
    _xrandr=$(echo "${_xrandr}" | grep -v eDP1)
    if [ "${nb_connected_all}" -ge 1 ]
    then
        # more than one screen is available force to disable laptop's screen
        cmd="${cmd} --output eDP1 --off"
    else
        # only the laptop's screen is available force it to avoid
        # killing the X session
        cmd="${cmd} --output eDP1 --preferred --scale 1x1"
    fi
fi

disconnected=$(xrandr | awk '/disconnected [0-9]/{print $1}')
for output in $disconnected
do
    cmd="${cmd} --output ${output} --off"
done

new=$(xrandr | awk '/ connected \(/{print $1}')
connected=$(xrandr | awk '/ connected [0-9]/{print $1}')

order=$(echo "${new}" "${connected}" | grep eDP1)
order="${order} $(echo ${connected} | grep -v eDP1 | sort -r -)"
order="${order} $(echo ${new} | grep -v eDP1 | sort -r -)"

last=$(xrandr | grep ' connected [0-9]' | cut -d + -f 2 | sort -hr | head -1)
last=$(xrandr | grep "+${last}+" | cut -d ' ' -f 1 | head -1)

for output in $order
do
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
