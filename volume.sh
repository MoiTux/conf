#!/bin/sh
# use PulseAudio to easly set the volume up/down/mute

if [ $# -ne 1 ];
then
    echo 'Usage: mute|-x[%|dB]|+x[%|dB]'
    exit 0
fi
device=$(pactl info | grep 'Default Sink' | cut -f 3 -d ' ')
if [ "$1" = "mute" ];
then
    pactl set-sink-mute "${device}" toggle
else
    pactl set-sink-volume "${device}" -- "$1"
fi
