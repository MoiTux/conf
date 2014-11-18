#!/bin/sh
# use PulseAudio to easly set the volume up/down/mute
# also use notify-send (libnotify-bin) to notif the level's volume

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
id=$(pactl list short sinks | grep "${device}" | cut -f 1)
id=$(( $id + 1 ))
volume=$(pactl list sinks | grep 'Mute' | sed -n "${id}p" | cut -d ' ' -f 2)
if [ "${volume}" = 'no' ];
then
    volume=$(pactl list sinks | grep -E '[^ ]Volume:'  | sed -n "${id}p" | \
                    cut -d / -f 2)
    echo 'Volume is at:' $volume
    notify-send -t 1 'Volume is at: ' "${volume}"
else
    echo 'Volume: Mute'
    notify-send -t 1 'Volume: ' 'Mute'
fi
