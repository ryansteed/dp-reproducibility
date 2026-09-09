include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/Programs
	for i in "table_1" \
		"table_2" \
		"table_3" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
