#!/bin/sh
do_update=1
do_rrdupdate=
WEBROOT=/var/www/html/energy
LOG=/tmp/energy.rrd.log

main() {
  stamp=`mktemp /tmp/energy.rrd.stamp.XXXXX`

  if [ "$1" = "-n" -o "$1" = "--no-update" ]; then
    do_update=
  fi


  if [ ! -r energy.rrd ]; then
    echo create
    ./rrdcreate.sh
    do_rrdupdate=1
  fi

  if [ ! -r "data.csv" -o -n "$do_update" ]; then
    echo 'Fetching data, this may take a while... (sorry, chrissi^!)'
    if ! wget 'http://shiny.tinyhost.de/php/energy.php?id[]=1' -O data.csv; then
      return 1
    fi
  fi

  if [ -n "$do_rrdupdate" -o "data.csv" -nt "energy.rrd" ]; then
    echo update
    ./rrdupdate.sh data.csv
  fi

  ./rrdgraph.sh

  cp energy-60d.png energy-360d.png $WEBROOT

  if [ $stamp -nt $WEBROOT/energy-360d.png ]; then
    echo
    echo "Oops. Something went wrong, the stamp file is newer than the target."
    rm -r $stamp
    return 1
  fi

  rm -r $stamp
}

if tty -s; then
  main "$@"
else
  # be silent for cron
  if ! main "$@" > $LOG 2>&1; then
    echo "Something failed. Here is the log:"
    echo
    cat $LOG
  fi
fi

# vim: set sw=2 ts=2 et:
