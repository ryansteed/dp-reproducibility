#delimit;
clear all;


global infile = "Input_data";
global infile2 = "Analysis_data";
global outfile = "Latex_files";

use "$infile/collinswanamaker1910_30";

** Creates table B6;
** Merge with maindata file;
merge m:1 fips using "$infile2/maindata";
drop _merge;

global historical c.initial c.newscapita c.farmvalue c.sfarmprop1860 c.landineq1860 c.fbprop1860;
global cont_black c.Black_beyondhs c.Black_avgage c.Black_Earnings c.share_marital;

label variable REGIONALMIG "Outmigrant";
label variable lynchcapitamob "Black lynching rate"; 

regress lnrealIND28_10_X i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c1;

regress lnrealsbocc60_10_X i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c2;

regress age_1910_coded i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c3;

regress school_1910_coded i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c4;

regress lit_1910_coded i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c5;

regress empstatd_1910_coded i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c6;

regress classwkr_coded_1910 i.REGIONALMIG##c.lynchcapitamob 
$historical i.State_FIPS , cluster(County_FIPS);
estimates store c7;

** Table B6;
esttab c1 c2 c3 c4 c5 c6 c7 using "$outfile/collinsdata.tex", keep(1.REGIONALMIG#c.lynchcapitamob 1.REGIONALMIG lynchcapitamob) 
order(1.REGIONALMIG#c.lynchcapitamob 1.REGIONALMIG lynchcapitamob) 
indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS")
mlabels("\makecell{Earnings\\1928}" "\makecell{Earnings\\1960}" "Age" "\makecell{Own\\Home}" "School" "Literate"
"Employed" "\makecell{Worked\\Class}", lhs("\makecell[l]{Out-Migrants vs.\\Stayers}")) 
nomtitles collabels(none) varlabels(_cons "Constant" 1.REGIONALMIG "Outmigrant" 1.REGIONALMIG#c.lynchcapitamob "\makecell[l]{Black lynching rate*\\Outmigrant Status}") 
label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) stats(N r2, labels("\# of observations" "R-Squared") 
fmt(%11.0gc %9.3f)) replace;


