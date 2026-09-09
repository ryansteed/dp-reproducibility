include ../utils.mk

source:
	#Modified by Eduardo Schnadower because the file has a nested compressed file.
	unzip -d source/ source.zip
	cd source
	tar -xvf *.tar

results:
	mkdir -p results
	
	cd source/REStat_data_code
	bash $(PROJECT)/stata/statab.sh code/table1.do
	
