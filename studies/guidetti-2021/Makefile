include ../utils.mk

source:
	unzip source.zip -d source/

results:
	mkdir -p results
	bash $(PROJECT)/stata/statab.sh source/reg.do 
