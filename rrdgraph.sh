#!/bin/sh
LC_ALL=C
COST_PER_KWH="0.27"

rrdtool graph energy-60d.png -a PNG \
	--end now --start end-60d \
	--title "Stratum 0 energy consumption – last two months" \
	--width 800 --height 400 \
	--lower-limit 0 \
	-x 'DAY:1:WEEK:1:WEEK:1:0:%b %d' \
	--vertical-label 'energy (kWh)' \
	--right-axis 0.27:0 --right-axis-label 'cost (€)' \
  --right-axis-format '%3.2lf' \
	'DEF:energy=energy.rrd:energy_kWh:AVERAGE:start=end-180d' \
  "SHIFT:energy:$((60*60*24))" \
	'VDEF:max=energy,MAXIMUM' \
	'VDEF:min=energy,MINIMUM' \
	'VDEF:last=energy,LAST' \
	"CDEF:trend30d=0,1,$((60*60*24*30)),energy,PREDICT" \
  "SHIFT:trend30d:$((60*60*24))" \
	'VDEF:avg=trend30d,LAST' \
  "CDEF:_cost1d=energy,${COST_PER_KWH},*" \
  'VDEF:cost1d=_cost1d,LAST' \
  "CDEF:_cost30d=trend30d,${COST_PER_KWH},*" \
  "CDEF:_cost30m=trend30d,30,${COST_PER_KWH},*,*" \
  'VDEF:cost30d=_cost30d,LAST' \
  'VDEF:cost30m=_cost30m,LAST' \
	'AREA:max#f0f0ff' \
  'COMMENT:                         │\g' \
  'COMMENT:   Min\g' \
  'COMMENT:   Max\g' \
  'COMMENT:   Cur       │\g' \
  "COMMENT: Cost (at ${COST_PER_KWH} €/kWh)\n" \
  'COMMENT:─────────────────────────┼─────────────────────────┼\g' \
  'COMMENT:──────────────────────\n' \
  'LINE1:energy#80808080:Energy consumption     │\g' \
	'AREA:min#ffffff' \
  'GPRINT:min: %5.1lf\g' \
  'GPRINT:max: %5.1lf\g' \
  'GPRINT:last: %5.1lf kWh/d │\g' \
  'GPRINT:cost1d: %4.1lf €/d\n' \
  'LINE1:trend30d#4040ffc0:30-day moving average  │\g' \
  'GPRINT:avg:             %5.1lf kWh/d │\g' \
  'GPRINT:cost30d: %4.1lf €/d' \
  'GPRINT:cost30m: %5.1lf €/m\n' \

rrdtool graph energy-360d.png -a PNG \
	--end now --start end-360d \
	--title "Stratum 0 energy consumption – last year" \
	--width 800 --height 400 \
	--lower-limit 0 \
	-x 'WEEK:1:MONTH:1:MONTH:1:0:%b %d' \
	--vertical-label 'energy (kWh)' \
	--right-axis ${COST_PER_KWH}:0 --right-axis-label 'cost (€)' \
  --right-axis-format '%3.2lf' \
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
	'AREA:max#f0f0ff' \
  'COMMENT:                         │\g' \
  'COMMENT:   Min\g' \
  'COMMENT:   Max\g' \
  'COMMENT:   Cur       │\g' \
  "COMMENT: Cost (at ${COST_PER_KWH} €/kWh)\n" \
  'COMMENT:─────────────────────────┼─────────────────────────┼\g' \
  'COMMENT:───────────────────────────────────\n' \
  'LINE1:energy#80808080:Energy consumption     │\g' \
	'AREA:min#ffffff' \
  'GPRINT:min: %5.1lf\g' \
  'GPRINT:max: %5.1lf\g' \
  'GPRINT:last: %5.1lf kWh/d │\g' \
  'GPRINT:cost1d: %4.1lf €/d\n' \
  'LINE1:trend30d#4040ffc0: 30-day moving average │\g' \
  'GPRINT:avg30:             %5.1lf kWh/d │\g' \
  'GPRINT:cost30d: %4.1lf €/d' \
  'GPRINT:cost30m: %5.1lf €/m\n' \
  'LINE1:trend180d#ff4040c0:180-day moving average │\g' \
  'GPRINT:avg180:             %5.1lf kWh/d │\g' \
  'GPRINT:cost180d: %4.1lf €/d' \
  'GPRINT:cost180m: %4.1lf €/m' \
  'GPRINT:cost180y: %6.1lf €/y\n' \

