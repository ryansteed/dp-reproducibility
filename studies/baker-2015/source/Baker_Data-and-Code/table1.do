*****Last updated Jan 10, 2015
*****Constructs Table for AEA P&P: "Table 1. Legalizations and Crime"
clear all
use results_data

*** EDIT by Donna
eststo:areg lTotalAllCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
outreg2 using Table1, title(Table 1. Legalizations and Crime) tex(landscape pr frag) drop(yy* UnemploymentRate povrate logincome logemp lpop OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap) label  replace addtext(Year FE, YES, County FE, YES, Economic Controls, YES, Other Crime Controls, YES) ctitle("All Crime") nocons

eststo:areg lTotalAllCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20 if AllTimeWeightedImm~=0, absorb(cc) cluster(cc)
outreg2 using Table1, title(Table 1. Legalizations and Crime) tex(landscape pr frag) drop(yy* UnemploymentRate povrate logincome logemp lpop OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap) label addtext(Year FE, YES, County FE, YES, Economic Controls, YES, Other Crime Controls, YES) ctitle("Non-Zero IRCA")  nocons

eststo:areg lTotalViolentCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
outreg2 using Table1, title(Table 1. Legalizations and Crime) tex(landscape pr frag) drop(yy* UnemploymentRate povrate logincome logemp lpop OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap) label addtext(Year FE, YES, County FE, YES, Economic Controls, YES, Other Crime Controls, YES) ctitle("Violent Crime")  nocons

eststo:areg lTotalPropertyCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
outreg2 using Table1, title(Table 1. Legalizations and Crime) tex(landscape pr frag) drop(yy* UnemploymentRate povrate logincome logemp lpop OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap) label addtext(Year FE, YES, County FE, YES, Economic Controls, YES, Other Crime Controls, YES) ctitle("Property Crime")  nocons

areg lTotalAllCrimesPerCap sim_CumWeightedAllImmPerCap sim_diff  lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
outreg2 using Table1, title(Table 1. Legalizations and Crime) tex(landscape pr frag) keep(sim_CumWeightedAllImmPerCap sim_diff) label addtext(Year FE, YES, County FE, YES, Economic Controls, YES, Other Crime Controls, YES) ctitle("All Crime") nocons
*** EDIT by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace