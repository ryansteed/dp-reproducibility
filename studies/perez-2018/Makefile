include ../utils.mk

source:
	unzip -d source/ source.zip
	mkdir source/Do_Files/4_output
	
results:
	mkdir -p results
	
	cd source/Do_Files/3_do-and-logfiles
	for i in \
		"Step2_State_Monthly_UnemploymentRate_2001-2010_BLS_LAU_8-19-17" \
		"Step3_create_file_NASBO_fiscal_shocks"\
		"Step4_StateLevelRegressions_MedicaidEligibilityRankings_on_StateUnemployment_8-20-17" \
		"Step5_StateLevelRegressions_MedicaidEligibilility_on_RainyDayShocks"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
