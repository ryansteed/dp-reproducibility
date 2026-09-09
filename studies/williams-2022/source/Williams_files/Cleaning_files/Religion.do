clear

#delimit;

*** CLEANING FILE ***;
** Input data file: USReligionCensus2010.DTA from the 2010 Census (Religious Census: Religious Congregations Membership Study);
** Creates analysis data file: religion to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/USReligionCensus2010.DTA";

merge 1:1 fips using "$outfile/POP_2010_NHGIS";

** Church variables;
egen holder = rowtotal(ameadh amezadh cmeadh cgcadh nbcaadh nbcadh nmbcadh pnbcadh);
generate blackmemrate = (holder/Black_POP_2010)*1000;

keep fips blackmemrate;

save "$outfile/religion", replace;
