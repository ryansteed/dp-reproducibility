include ../utils.mk

source:
	unzip source.zip
	mv turnout_data_programs_aej/ source/
	cd source & mkdir data & mv *.dta data

results:
	mkdir -p results
	cd source
	# first call prep_aej_public to create cleaned data file automatically
	bash $(PROJECT)/stata/statab.sh prep_aej_public.do 
	mv data/voting_paper_cleaned_public.dta data/voting_paper_cleaned.dta
	for i in \
		"table1_-_online_appendix_table1_aej" \
		"table2_aej" "table3_aej" \
		"table4_aej" "table5_aej" "table6_aej" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do ; \
	done
