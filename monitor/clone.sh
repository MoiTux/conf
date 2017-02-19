#!/bin/bash
# the --same-as option of xrandr doesn't work properly if the screens haven't
# the same output mode
# this script will add the --scale option to fix this issue

# XXX override xrandr command to only call it once
_xrandr=$(xrandr)
xrandr() {
    echo "$_xrandr"
}

available=$(xrandr | awk '/ connected /{print $1}')

usage() {
  echo 'Usage: clone [screen_src screen_dst]'
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

src=$(get_preferred $src_name)

command xrandr --fb "${src}" \
        --output $src_name --preferred --scale 1x1 \
        --output $dst_name --same-as $src_name --preferred --scale-from "${src}"
