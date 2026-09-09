include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/AEJApp-2013-0038_meet_the_press_dataset_and_readme
	for i in "table1" \
		"table2" \
		"table3" \
		"table4" \
		"table5" \
		"table6" \
		"table7" \
		"table8" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
