#!/bin/sh
do_update=1
do_rrdupdate=

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
  wget 'http://shiny.tinyhost.de/php/energy.php?id[]=1' -O data.csv
fi

if [ -n "$do_rrdupdate" -o "data.csv" -nt "energy.rrd" ]; then
  echo update
  ./rrdupdate.sh data.csv
fi

./rrdgraph.sh

cp energy-60d.png energy-360d.png /srv/www/stuff/stratum0/
