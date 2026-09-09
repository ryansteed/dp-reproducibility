include ../utils.mk

source:
	unzip source.zip -d source/
	cd source
	mv YRBS\ Analysis.do yrbs_analysis.do
	mv Compulsory\ Schooling\ and\ Crime.do compulsory_schooling_and_crime.do
	mv YRBS\ Data.dta yrbs_data.dta
	unzip Compulsory\ Schooling\ and\ Crime\ Dataset.zip
	mv Compulsory\ Schooling\ and\ Crime\ Dataset.dta compulsory_schooling_and_crime.dta

results:
	mkdir -p results
	cd source
	bash $(PROJECT)/stata/statab.sh compulsory_schooling_and_crime.do | tee ../results/compulsory_schooling_and_crime.log
