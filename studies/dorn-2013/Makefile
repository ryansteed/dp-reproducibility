include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	cd source/Autor-Dorn-LowSkillServices-FileArchive/do
	bash $(PROJECT)/stata/statab.sh czone_analysis.do;
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
