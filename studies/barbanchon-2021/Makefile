include ../utils.mk

source:
	unzip -d source/ source.zip
	echo "For this study, need to also run `make intermediate` to prep intermediate files."

intermediate:
	cd source/Code
	for i in "CreateFinalSample" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done

results:
	mkdir -p results
	
	cd source/Code
	for i in "Reg_DistrictLevel" \
		"Reg_MunicipalLevel" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
