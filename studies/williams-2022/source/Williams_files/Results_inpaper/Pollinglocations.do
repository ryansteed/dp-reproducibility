
clear

#delimit;

global infile = "Input_data";
global outfile = "Latex_files";

use "$infile/polllocation";


regress Sum_Count c.shareblack_tract##c.lynchcapitamob popdensity i.State_FIPS, cluster(County);
estimates store sum1;

** Table 7: Merge with polling location data;
esttab sum1 using "$outfile/tract.tex", nonum indicate("State Fixed Effects = *.State_FIPS") 
mlabels((1)) mgroups("Polling Locations", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant" c.shareblack_tract##c.lynchcapitamob "Proportion of Blacks*Black lynching rate") label 
cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("Number of observations" "R-Squared") fmt(%11.0gc %9.3f)) replace;
