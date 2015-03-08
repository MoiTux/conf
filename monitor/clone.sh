#!/bin/bash
# the --same-as option of xrandr doesn't work properly if the screens haven't
# the same output mode
# this script will add the --scale option to fix this issue

if [ $# -ne 2 ]
then
  echo 'Usage: clone screen_src screen_dst'
  exit 1
fi

# XXX override xrandr command to only call it once
_xrandr=$(xrandr)
xrandr() {
    echo "$_xrandr"
}

get_preferred() {
  # get the preferred mode of a screen
  echo $(xrandr | awk "/^$1 / {
           do
             getline;
           while (match(\$0, /[0-9]{2}\.[0-9]{2}( |\*)\+/) == 0)
           print \$1
         }")
}

bc() {
  # to simply the way to use bc:
  # e.g : bc 3 / 4 # output .75
  echo $(echo "scale=4;${1}${2}${3}" | command bc)
}

src=$(get_preferred $1)
dst=$(get_preferred $2)

if [ "${src}" = "${dst}" ]
then
  command xrandr --output $1 --preferred --output $2 --preferred --same-as $1
else
  declare $(echo "${src}" | awk -F 'x' '{print "x_src="$1"\ny_src="$2}')
  declare $(echo "${dst}" | awk -F 'x' '{print "x_dst="$1"\ny_dst="$2}')

  pos=$(xrandr | awk '/eDP1/ {print substr($3, index($3, "+") + 1) }')
  pos=$(echo "${pos}" | sed 's/+/x/')

  scale_x=$(bc "${x_src}" / "${x_dst}")
  scale_y=$(bc "${y_src}" / "${y_dst}")

  command xrandr --fb "${src}" \
          --output $1 --preferred --scale 1x1 \
          --output $2 --preferred --pos "${pos}" \
                      --scale "${scale_x}x${scale_y}"
fi
