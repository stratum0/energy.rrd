#!/usr/bin/make -f

fetchdata: energy.rrd
	@echo 'Fetching data, this may take a while... (sorry, chrissi^!)'
	@wget 'http://shiny.tinyhost.de/php/energy.php?id[]=1' -O data.csv
	@./rrdupdate.sh data.csv

images: fetchdata
	@./rrdgraph.sh

energy.rrd:
	@./rrdcreate.sh

.PHONY: energy.png fetchdata
