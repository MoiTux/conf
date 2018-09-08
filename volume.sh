#!/bin/sh
# use PulseAudio to easly set the volume up/down/mute
# also use notify-send (libnotify-bin) to notif the level's volume

if [ $# -ne 1 ];
then
    echo 'Usage: mute|-x[%|dB]|+x[%|dB]'
    exit 0
fi

if [ "$1" = 'mute' ];
then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
else
    pactl set-sink-volume @DEFAULT_SINK@ "$1"
fi

device=$(pactl info | grep 'Default Sink' | cut -f 3 -d ' ')
id=$(pactl list short sinks | grep "${device}" | cut -f 1)

id=$(( $id + 1 ))  # sed idx start a 1

is_mute=$(pactl list sinks | grep 'Mute' | sed -n "${id}p" | cut -d ' ' -f 2)
if [ "${is_mute}" = 'no' ];
then
    volume=$(pactl list sinks | grep -E '[^ ]Volume:'  | sed -n "${id}p" | \
                    cut -d / -f 2)
    echo 'Volume is at:' $volume
    notify-send -t 1000 "Volume is at: ${volume}"
else
    echo 'Volume: Mute'
    notify-send -t 1000 'Volume is Mute'
fi
