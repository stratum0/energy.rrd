#!/bin/sh
if [ -z "$1" ]; then
  echo "Usage: $0 data.csv"
  echo "expected format for data.csv:"
  echo "  YYYY/MM/DD HH:MM:SS, value"
  exit 1
fi

# regex: "YYYY/MM/DD HH:MM:SS, value" (csv) => "YYYYMMDD@value" (rrdtool update)
# tail: cut off csv header and current (not yet complete) day
tail -n +3 "$1" |
  sed 's/^\([0-9]\{4\}\)\/\([0-9]\{2\}\)\/\([0-9]\{2\}\)[ \t]\+[0-9:]\+,[ \t]\+\([0-9.]\+\)/\1\2\3@\4/' |
  tac |
  while read line; do
    rrdtool update energy.rrd "$line" 2>&1 |
      grep -v 'illegal attempt to update using time [0-9]\+'
  done

# vim: set sw=2 ts=2 et:
