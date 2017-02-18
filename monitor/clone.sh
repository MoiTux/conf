#!/bin/bash
# the --same-as option of xrandr doesn't work properly if the screens haven't
# the same output mode
# this script will add the --scale option to fix this issue

available=$(xrandr | awk '/ connected /{print $1}')

usage() {
  echo 'Usage: clone screen_src screen_dst'
  echo -e "Available screen:\n${available}"
  exit 1
}

if [ $# -eq 0 ]
then
  src_name='eDP-1'
  dst_name=$(xrandr | awk '/ connected /{print $1}' | grep -v eDP-1 | head -1)
elif [ $# -ne 2 ]
then
  usage
else
  src_name=$1
  dst_name=$2
fi

if [ $(echo "${available}" | grep -c "^${src_name}$") -ne 1 ]
then
  echo "${src_name} is not a valide screen"
  usage
fi

if [ $(echo "${available}" | grep -c "^${dst_name}$") -ne 1 ]
then
  echo "${dst_name} is not a valide screen"
  usage
fi

# XXX override xrandr command to only call it once
_xrandr=$(xrandr)
xrandr() {
    echo "$_xrandr"
}

get_preferred() {
  # get the preferred mode of a screen
  res=$(xrandr | awk "/^$1 / "'{
    do {
      getline;
      if ( match($0, /[0-9]{2}\.[0-9]{2}( |\*)\+/) != 0) {
        print $1;
        break;
      }
    } while (match($0, /^ /))
  }')
  if [ -z "${res}" ]
  then
    # no preferred found fallback to the first available mode
    res=$(xrandr | awk "/^$1 / "'{
      getline;
      print $1
    }')
  fi
  echo $res
}

bc() {
  # to simply the way to use bc:
  # e.g : bc 3 / 4 # output .75
  echo $(echo "scale=4;${1}${2}${3}" | command bc)
}

src=$(get_preferred $src_name)
dst=$(get_preferred $dst_name)

if [ "${src}" = "${dst}" ]
then
  command xrandr --output $src_name --preferred \
                 --output $dst_name --preferred --same-as $src_name
else
  declare $(echo "${src}" | awk -F 'x' '{print "x_src="$1"\ny_src="$2}')
  declare $(echo "${dst}" | awk -F 'x' '{print "x_dst="$1"\ny_dst="$2}')

  pos=$(xrandr | awk "/${src_name}/ "'{
    i=1;
    while (i <= NF) {
      if ( match($i, /\+/) )
         print substr($i, index($i, "+") + 1);
      i++
    }
  }')
  pos=$(echo "${pos}" | sed 's/+/x/')

  scale_x=$(bc "${x_src}" / "${x_dst}")
  scale_y=$(bc "${y_src}" / "${y_dst}")

  command xrandr --fb "${src}" \
          --output $src_name --preferred --scale 1x1 \
          --output $dst_name --preferred --pos "${pos}" \
                             --scale "${scale_x}x${scale_y}"
fi
