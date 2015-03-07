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

disconnected=$(xrandr | grep 'disconnected [0-9]' | cut -d ' ' -f 1)
for output in $disconnected
do
    # XXX keep always one screen to avoid killing the current session
    if [ "$(xrandr | grep \* | wc -l)" -gt 1 ]
    then
        cmd="${cmd} --output ${output} --off"
    else
        cmd="${cmd} --output eDP1 --preferred"
        cmd="${cmd} --output ${output} --off"
    fi
done

connected=$(xrandr | grep ' connected (' | cut -d ' ' -f 1)

clones=$(xrandr | grep '+[0-9]*+[0-9]*' |
                awk -F '(x[0-9]*)| ' '{print $4}' | sort | uniq -d)
if [ -n "$clones" ]
then
    clones=$(xrandr | grep "$clones" | cut -d ' ' -f 1)
fi

no_laptop='false'
if [ -n "$connected" -o -n "$clones" ]
then
    # XXX a new screen has been connected or clones has been detected
    #     so there is more that one screen no need to keep the laptop screen
    state=$(cat /proc/acpi/button/lid/LID/state | tr -d ' ' | cut -d : -f 2)
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

for output in $clones $connected
do
    if [ "${no_laptop}" = 'true' -a "${output}" = 'eDP1' ]
    then
        continue
    fi
    cmd="${cmd} --output ${output} --preferred"
    if [ -n "${last}" -a "$last" != "$output" ]
    then
        cmd="${cmd} --right-of ${last}"
    fi
    last=$output
done

if [ -n "$cmd" ]
then
    echo "$cmd" > /tmp/cmd
    # XXX xrandr has been overridden so explicit call the xrandr command
    command xrandr $cmd
fi
