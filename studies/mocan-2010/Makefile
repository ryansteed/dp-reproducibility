include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source
	bash $(PROJECT)/stata/statab.sh Table_1.do

	#for i in Table_1 \
	# 	Table2_3_du \
	#	Tables4to7; \
	#do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	#done
