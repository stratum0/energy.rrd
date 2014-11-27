#!/bin/sh
rrdtool create energy.rrd --no-overwrite \
  --step $((60*60*24)) --start 20120101 \
  'DS:energy_kWh:GAUGE:172800:0:1000' \
  "RRA:AVERAGE:0:1:$((5*366))" \
  "RRA:MAX:0:1:$((5*366))" \
  "RRA:MIN:0:1:$((5*366))" \

# vim: set sw=2 ts=2 et:
