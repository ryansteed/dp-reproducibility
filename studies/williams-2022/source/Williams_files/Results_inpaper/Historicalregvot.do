clear


global infile = "Input_data";
global outfile = "Latex_files";


#delimit;
use "$infile/historicalreg";
regress lynchcapitamob shareblackvoter_1867 blackshare_1860 i.state;
estimates store c1;

label variable shareblackvoter_1867 "Percentage of black registered voters in 1867 and 1868";
label variable blackshare_1860 "Percentage of black residents in 1860";

** Table B1 lynching rate and black registered voters in 1867;
esttab c1 using "$outfile/historicalreg.tex", keep(shareblackvoter_1867 blackshare_1860) order(shareblackvoter_1867 blackshare_1860) 
nonum indicate("State Fixed Effects = *.state") 
mlabels((1))
mgroups("Black lynching rate", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("Number of observations" "R-Squared") fmt(%11.0gc %9.3f)) replace;

** Figure 1 lynching rate and black registered voters in 1867;
binscatter lynchcapitamob shareblackvoter_1867, controls(blackshare_1860) graphregion(color(white)) bgcolor(white)
ytitle("Black lynching rate") xtitle("Percentage of black registered voters") absorb(state);
graph export "$outfile/historicalreg.eps", as(eps) preview(off) replace;
