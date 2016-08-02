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
sleep 1
_xrandr=$(xrandr -q)
xrandr() {
    echo "$_xrandr"
}

cmd=''

state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
if [ "${state}" = "closed" ]
then
    # the laptop's screen is closed remove it from available screen
    _xrandr=$(echo "${_xrandr}" | grep -v eDP-1)
    nb_connected_all=$(xrandr | grep -c ' connected ')
    if [ "${nb_connected_all}" -ge 1 ]
    then
        # more than one screen is available force to disable laptop's screen
        cmd="${cmd} --output eDP-1 --off"
    else
        # only the laptop's screen is available force it to avoid
        # killing the X session
        cmd="${cmd} --output eDP-1 --preferred --scale 1x1"
    fi
fi

disconnected=$(xrandr | awk '/disconnected [0-9]/{print $1}')
for output in $disconnected
do
    cmd="${cmd} --output ${output} --off"
done

new=$(xrandr | awk '/ connected \(/{print $1}')
connected=$(xrandr | awk '/ connected [0-9]/{print $1}')

order=$(echo "${new}\n${connected}" | grep eDP-1)
connected=$(echo "${connected}" | grep -v eDP-1 | sort -r -)
new=$(echo "${new}" | grep -v eDP-1 | sort -r -)
order="${order} ${connected} ${new}"

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
