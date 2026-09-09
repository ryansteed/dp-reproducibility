Replication Files

openicpsr-142641
"Why is the Rent so Darn High? The Role of Growing Demand to Live in Housing-Supply-Inelastic Cities"
Greg Howard and Jack Liebersohn

The master.do file will run all the requisite other .do files in order to replicate the paper. 
If your only interest is in replicating the figures, make sure the current directory is in the "dofiles" folder, and run "master.do"

We have also included in the data folder, a stata file that includes the new rent index we created for this paper, along with related measures of uncertainty. If that is what you are interested in, you will find it at "data/rent_index_msa00_2001.dta"

The files were created using Stata 14.2 and was run in Windows. Several standard packages, including ftools and ivreg2 are necessary to run the do-files. The entire code took about 20 minutes to run on a PC running Windows 10 with 16 GB of RAM.

CONTENTS OF THIS FOLDER

(1) data folder
	This folder contains combineddata.dta, which is the main data used to create most of the 
	exhibits and tables. It also contains data from the qcew which contains industry shares, which 	
	is used for only a handful of exhibits.

	A detailed description of where our data is from can be found in Appendix B of the paper.
	
(2) exhibits folder
	This folder stores the exhibits and tables that are created by the dofiles. 
	
(3) dofiles folder
	This contains the dofiles. master.do describes which dofiles create which figures.