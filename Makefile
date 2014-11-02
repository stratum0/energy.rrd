#!/usr/bin/make -f

energy.png: energy.rrd
	@echo 'Fetching data, this may take a while... (sorry, chrissi^!)'
	@wget 'http://shiny.tinyhost.de/php/energy.php?id[]=1' -O data.csv
	@./rrdupdate.sh data.csv
	@./rrdgraph.sh

energy.rrd:
	@./rrdcreate.sh

.PHONY: energy.png
