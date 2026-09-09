include ../utils.mk

source:
	unzip -d source/ source.zip
	mv "source/Baker_Data-and-Code/1.-Creates-Results-Table.do" source/Baker_Data-and-Code/table1.do
results:
	mkdir -p results

	cd source/Baker_Data-and-Code
	for i in "table1"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
