include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/data
	# "Intermediate Files/LAUS-JOLTS-UIB-Merge.do" \
	# 	"Intermediate Files/border counties.do" \
	# 	"Intermediate Files/Census-GIS-data.do" \
	# 	"Intermediate Files/Census-Pop-Data.do" \
	# 	"Intermediate Files/QCEW-data.do" \
	# 	"Intermediate Files/qwi_2017.do" \
	# 	"Intermediate Files/county-work-pop.do" \
	# 	"Intermediate Files/placebo-trigger-treat.do" \
	# 	"Intermediate Files/BBD-RD-data.do" \
	
	# This one works, but removing to save time, since we can't add DP to the data --- see study.py "Do/BBD-LODES-FE-Reg.do"
	for i in \
		"Do/BBD-RD-Log-Unemployment.do" ; \
	do \
		bash $(PROJECT)/stata/statab.sh "$$i"; \
	done
