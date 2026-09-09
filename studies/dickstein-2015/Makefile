include ../utils.mk

source:
	unzip -d source/ source.zip
	mv source/Logs-and-do-files/county_analysis/* source/Logs-and-do-files/
	mv source/Logs-and-do-files/region_analysis/* source/Logs-and-do-files/
	rmdir source/Logs-and-do-files/county_analysis
	rmdir source/Logs-and-do-files/region_analysis
results:
	mkdir -p results
	
	cd source/Logs-and-do-files
	for i in "county_tables_main" \
			"region_do"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done