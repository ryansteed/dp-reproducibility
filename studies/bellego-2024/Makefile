include ../utils.mk

source:
	mkdir -p source
	7z x source.zip -o./source

results:
	mkdir -p results
	
	cd source/code
	for i in "0_macro_libraries" \
		"1_build_main_data" \
		"2_descriptive_stat_and_main_analysis"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
