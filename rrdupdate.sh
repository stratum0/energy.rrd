#!/bin/sh
if [ -z "$1" ]; then
  echo "Usage: $0 data.csv"
  echo "expected format for data.csv:"
  echo "  YYYY/MM/DD HH:MM:SS, value"
  exit 1
fi

tail -n +3 "$1" |
  sed 's/^\([0-9]\{4\}\)\/\([0-9]\{2\}\)\/\([0-9]\{2\}\)[ \t]\+[0-9:]\+,[ \t]\+\([0-9.]\+\)/\1\2\3@\4/' |
  tac |
  xargs --verbose --no-run-if-empty -L1 -I'{}' \
    /bin/sh -c 'if ! rrdtool update energy.rrd {}; then exit 0; fi'

# Note: if last-update in energy.rrd is newer than our data, rrdtool will exit
# with 255, which leads to xargs exiting immediately.

# vim: set sw=2 ts=2 et:
