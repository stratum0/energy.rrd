#!/bin/sh
LC_ALL=C
rrdtool graph energy.png -a PNG \
	--end now-1d --start end-60d \
	--title "Stratum 0 energy consumption" \
	--width 800 --height 400 \
	--lower-limit 0 \
	-x 'DAY:1:DAY:7:DAY:7:0:%b %d' \
	--vertical-label 'energy (kWh)' \
	--right-axis 0.27:0 --right-axis-label 'cost (€)' \
	'DEF:energy=energy.rrd:energy_kWh:AVERAGE:start=end-180d' \
	'VDEF:max=energy,MAXIMUM' \
	'VDEF:min=energy,MINIMUM' \
	'VDEF:last=energy,LAST' \
	"CDEF:trend30d=0,1,$((60*60*24*30)),energy,PREDICT" \
	'VDEF:avg=trend30d,LAST' \
	'AREA:max#f0f0ff' \
	'COMMENT:                          ' \
	'COMMENT:    Min' \
	'COMMENT:    Avg' \
	'COMMENT:    Max' \
	'COMMENT:    Cur\\n' \
	'LINE1:energy#000000:Energy consumption per day' \
	'AREA:min#ffffff' \
	'GPRINT:min:%5.1lf %s' \
	'GPRINT:avg:%5.1lf %s' \
	'GPRINT:max:%5.1lf %s' \
	'GPRINT:last:%5.1lf %s kWh\\n' \
	'LINE1:trend30d#4040ff:30-day moving average' \

