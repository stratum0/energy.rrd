#!/bin/sh
LC_ALL=C
COST_PER_KWH="0.2625"
LIMIT="27.397"    # 10000 kWh / 365 days
NOW="`LC_ALL=C date|sed -s 's/:/\\\\:/g'`"
THIRTYDAYSAGO="`LC_ALL=C date +%s --date='30 days ago 00:00'`"
SIXMONTHSAGO="`LC_ALL=C date +%s --date='180 days ago 00:00'`"

rrdgraph() {
  fn=$1
  shift
  rrdtool graph $fn -a PNG \
    --pango-markup \
    --lower-limit 0 \
    --x-grid 'WEEK:1:MONTH:1:MONTH:1:0:%b %d' \
    --y-grid '1:5' \
    --vertical-label 'energy (kWh)' \
    --right-axis "${COST_PER_KWH}:0" --right-axis-label 'cost (€)' \
    --right-axis-format '%3.2lf' \
    --width 1200 \
    --height 600 \
    "$@"
}

rrdgraph energy-60d.png \
  --end now --start end-60d \
  --title "Stratum 0 energy consumption – last two months" \
  'DEF:energy=energy.rrd:energy_kWh:AVERAGE:start=end-180d' \
  "SHIFT:energy:$((60*60*24))" \
  'VDEF:max=energy,MAXIMUM' \
  'VDEF:min=energy,MINIMUM' \
  'VDEF:last=energy,LAST' \
  "CDEF:trend30d=0,1,$((60*60*24*30)),energy,PREDICT" \
  "SHIFT:trend30d:$((60*60*24))" \
  'VDEF:avg=trend30d,LAST' \
  'CDEF:_total_m=trend30d,30,*' \
  'VDEF:total_m=_total_m,LAST' \
  "CDEF:_cost1d=energy,${COST_PER_KWH},*" \
  'VDEF:cost1d=_cost1d,LAST' \
  "CDEF:_cost30d=trend30d,${COST_PER_KWH},*" \
  "CDEF:_cost30m=trend30d,30,${COST_PER_KWH},*,*" \
  'VDEF:cost30d=_cost30d,LAST' \
  'VDEF:cost30m=_cost30m,LAST' \
  'COMMENT:                         │\g' \
  'COMMENT:   Min   Max   Cur       │\g' \
  "COMMENT:  Projection  │\g" \
  "COMMENT: Cost (at ${COST_PER_KWH} €/kWh)\n" \
  'COMMENT:─────────────────────────┼\g' \
  'COMMENT:─────────────────────────┼\g' \
  'COMMENT:──────────────┼\g' \
  'COMMENT:──────────────────────\n' \
  'LINE1:energy#80808080:Energy consumption     │\g' \
  'GPRINT:min: %5.1lf\g' \
  'GPRINT:max: %5.1lf\g' \
  'GPRINT:last: %5.1lf kWh/d │\g' \
  'COMMENT:              │\g' \
  'GPRINT:cost1d: %4.1lf €/d\n' \
  'LINE2:trend30d#0000ffc0:30-day moving average  │\g' \
  'GPRINT:avg:             %5.1lf kWh/d │\g' \
  'GPRINT:total_m: %6.1lf kWh/m │\g' \
  'GPRINT:cost30d: %4.1lf €/d' \
  'GPRINT:cost30m: %5.1lf €/m\n' \
  "VRULE:${THIRTYDAYSAGO}#8080ffc0:30 days ago\n" \
  "COMMENT:<span size='small' foreground='darkgray'>generated ${NOW}</span>\r" \


rrdgraph energy-360d.png \
  --end now --start end-360d \
  --title "Stratum 0 energy consumption – last year" \
  'DEF:energy=energy.rrd:energy_kWh:AVERAGE:start=end-720d' \
  "SHIFT:energy:$((60*60*24))" \
  'VDEF:max=energy,MAXIMUM' \
  'VDEF:min=energy,MINIMUM' \
  'VDEF:last=energy,LAST' \
  "CDEF:trend30d=0,1,$((60*60*24*30)),energy,PREDICT" \
  "SHIFT:trend30d:$((60*60*24))" \
  "CDEF:trend180d=0,1,$((60*60*24*180)),energy,PREDICT" \
  "SHIFT:trend180d:$((60*60*24))" \
  'VDEF:avg30=trend30d,LAST' \
  'VDEF:avg180=trend180d,LAST' \
  'CDEF:_total_m=trend30d,30,*' \
  'VDEF:total_m=_total_m,LAST' \
  'CDEF:_total_y=trend180d,365,*' \
  'VDEF:total_y=_total_y,LAST' \
  "CDEF:_cost1d=energy,${COST_PER_KWH},*" \
  'VDEF:cost1d=_cost1d,LAST' \
  "CDEF:_cost30d=trend30d,${COST_PER_KWH},*" \
  "CDEF:_cost30m=trend30d,30,${COST_PER_KWH},*,*" \
  'VDEF:cost30d=_cost30d,LAST' \
  'VDEF:cost30m=_cost30m,LAST' \
  "CDEF:_cost180d=trend180d,${COST_PER_KWH},*" \
  "CDEF:_cost180m=trend180d,30,${COST_PER_KWH},*,*" \
  "CDEF:_cost180y=trend180d,365,${COST_PER_KWH},*,*" \
  'VDEF:cost180d=_cost180d,LAST' \
  'VDEF:cost180m=_cost180m,LAST' \
  'VDEF:cost180y=_cost180y,LAST' \
  'COMMENT:                         │\g' \
  'COMMENT:   Min   Max   Cur       │\g' \
  "COMMENT:  Projection   │\g" \
  "COMMENT: Cost (at ${COST_PER_KWH} €/kWh)\n" \
  'COMMENT:─────────────────────────┼\g' \
  'COMMENT:─────────────────────────┼\g' \
  'COMMENT:───────────────┼\g' \
  'COMMENT:───────────────────────────────────\n' \
  'LINE1:energy#80808080:Energy consumption     │\g' \
  'GPRINT:min: %5.1lf\g' \
  'GPRINT:max: %5.1lf\g' \
  'GPRINT:last: %5.1lf kWh/d │\g' \
  'COMMENT:               │\g' \
  'GPRINT:cost1d: %4.1lf €/d\n' \
  'LINE2:trend30d#0000ffc0: 30-day moving average │\g' \
  'GPRINT:avg30:             %5.1lf kWh/d │\g' \
  'GPRINT:total_m: %7.1lf kWh/m │\g' \
  'GPRINT:cost30d: %4.1lf €/d' \
  'GPRINT:cost30m: %5.1lf €/m\n' \
  "VRULE:${THIRTYDAYSAGO}#8080ffc0" \
  'LINE2:trend180d#ff0000c0:180-day moving average │\g' \
  'GPRINT:avg180:             %5.1lf kWh/d │\g' \
  'GPRINT:total_y: %7.1lf kWh/y │\g' \
  'GPRINT:cost180d: %4.1lf €/d' \
  'GPRINT:cost180m: %4.1lf €/m' \
  'GPRINT:cost180y: %6.1lf €/y  ' \
  "VRULE:${SIXMONTHSAGO}#ff8080c0" \
  "HRULE:$LIMIT"'#ff4040c0:contractual limit of 10,000 kWh/y = 27.3 kWh/d\n:dashes' \
  "COMMENT:<span size='small' foreground='darkgray'>generated ${NOW}</span>\r" \

# vim: set sw=2 ts=2 et:
