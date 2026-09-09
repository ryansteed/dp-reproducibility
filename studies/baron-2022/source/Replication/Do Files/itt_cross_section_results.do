/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates all figures and tables in the paper that are derived
from the ITT estimator. These figures and tables include the following:

Figure 3 and Figure 4 in the main body of the paper as well as Table B2,
Figure C1, Figure C2, Figure C3, Table C2, Table C3, Table C4 in the Online Appendix.


DATA INPUTS: (1) itt_cross_section

*********************************/
clear
set more off

*Set globals

*Path
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*Call cross-sectional ITT dataset
use "${path}\Data\Final\itt_cross_section", clear

*Re-center vote share
replace perc= perc-50

*****************************************
******SECTION I: MAIN BODY FIGURES
*****************************************

*****************************************
******FIG 3 (A)
*****************************************
rdplot rev_lim_mem perc if (perc>=-10&perc<=10)&dyear==-2, p(2) nbins(5 5) graph_options(yscale(r(9000 11000)) ylabel(9000 10000 11000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Revenue Limits PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_rev_pre.pdf", replace 


*****************************************
******FIG 3 (B)
*****************************************
rdplot rev_lim_mem perc if (perc>=-10&perc<=10)&dyear>0, p(2) nbins(5 5) graph_options(yscale(r(9000 11000)) ylabel(9000 10000 11000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Revenue Limits PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_rev_post.pdf", replace 


*****************************************
******FIG 3 (C)
*****************************************
rdplot tot_exp_mem perc if (perc>=-10&perc<=10)&dyear==-2, p(2) nbins(5 5) graph_options(yscale(r(10000 12000)) ylabel(10000 11000 12000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Total Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_exp_pre.pdf", replace 


*****************************************
******FIG 3 (D)
*****************************************
rdplot tot_exp_mem perc if (perc>=-10&perc<=10)&dyear>0, p(2) nbins(5 5) graph_options(yscale(r(10000 12000)) ylabel(10000 11000 12000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Total Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_exp_post.pdf", replace 


*****************************************
******FIG 4 (A)
*****************************************
rdplot advprof_math10 perc if (perc>=-10&perc<=10) & dyear==-2, p(2) nbins(5 5) cov(yrdums*) graph_options(yscale(r(40 50)) ylabel(40 45 50) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_wkce10_pre.pdf", replace 

*****************************************
******FIG 4 (B)
*****************************************
rdplot advprof_math10 perc if (perc>=-10&perc<=10) & dyear>0, p(2) nbins(5 5) cov(yrdums*) graph_options(yscale(r(40 50)) ylabel(40 45 50) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_wkce10_post.pdf", replace 

*****************************************
******FIG 4 (C)
*****************************************
rdplot advprof_math8 perc if (perc>=-10&perc<=10) & dyear==-2, p(2) nbins(5 5) cov(yrdums*) graph_options(yscale(r(40 50)) ylabel(40 45 50) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_wkce8_pre.pdf", replace 

*****************************************
******FIG 4 (D)
*****************************************
rdplot advprof_math8 perc if (perc>=-10&perc<=10) & dyear>0, p(2) nbins(5 5) cov(yrdums*) graph_options(yscale(r(40 50)) ylabel(40 45 50) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_wkce8_post.pdf", replace 

*****************************************
******FIG 4 (E)
*****************************************
rdplot dropout_rate perc if (perc>=-10&perc<=10) & dyear==-2, p(2) nbins(5 5) graph_options(yscale(r(0.5 1)) ylabel(0.5 0.75 1) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% of Students who Drop Out) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_drop_pre.pdf", replace

*****************************************
******FIG 4 (F)
*****************************************
rdplot dropout_rate perc if (perc>=-10&perc<=10) & dyear>0, p(2) nbins(5 5)graph_options(yscale(r(0.5 1)) ylabel(0.5 0.75 1) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% of Students who Drop Out) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_drop_post.pdf", replace

*****************************************
******FIG 4 (G)
*****************************************
rdplot perc_instate perc if (perc>=-10&perc<=10) & dyear==-2, p(2) nbins(5 5) cov(yrdums* grade9lagged)  ///
graph_options(xtitle(Re-Centered % in Favor of the Measure) ylabel(.35 .4 .45) ytitle(% of Students in In-State Postsec. Education) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white))) 
graph export "${path}\Output\rdplot_enroll_pre.pdf", replace

*****************************************
******FIG 4 (H)
*****************************************
rdplot perc_instate perc if (perc>=-10&perc<=10) & dyear>0, p(2) nbins(5 5) cov(yrdums* grade9lagged) ///
graph_options(xtitle(Re-Centered % in Favor of the Measure) ylabel(.35 .4 .45) ytitle(% of Students in In-State Postsec. Education) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\rdplot_enroll_post.pdf", replace



*****************************************
******SECTION II: ONLINE APPENDIX FIGURES
*****************************************

*****************************************
******FIG C1 (A)
*****************************************
rdplot rev_lim_mem perc if (perc>=-10&perc<=10)&dyear==-2, p(2) ///
graph_options(yscale(r(9000 12000)) ylabel(9000 10000 11000 12000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Revenue Limits PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\revlim_cross_1.pdf", replace 

*****************************************
******FIG C1 (B)
*****************************************
rdplot rev_lim_mem perc if (perc>=-10&perc<=10)&dyear==1, p(2) graph_options(yscale(r(9000 12000)) ylabel(9000 10000 11000 12000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Revenue Limits PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\revlim_cross_2.pdf", replace 

*****************************************
******FIG C1 (C)
*****************************************
rdplot tot_exp_mem perc if (perc>=-10&perc<=10)&dyear==-2, p(2) graph_options(yscale(r(9000 12000)) ylabel(9000 10000 11000 12000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Total Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\totexp_cross_1.pdf", replace 

*****************************************
******FIG C1 (D)
*****************************************
rdplot tot_exp_mem perc if (perc>=-10&perc<=10)&dyear==1, p(2) graph_options(yscale(r(9000 12000)) ylabel(9000 10000 11000 12000) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(Total Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\totexp_cross_2.pdf", replace 


*****************************************
******FIG C2 (A)
*****************************************
rdplot advprof_math10 perc if (perc>=-10&perc<=10) & dyear==-2, p(2) cov(yrdums*) graph_options(yscale(r(30 60)) ylabel(30 40 50 60) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\advprof10_cross_1.pdf", replace

*****************************************
******FIG C2 (B)
*****************************************
rdplot advprof_math10 perc if (perc>=-10&perc<=10) & dyear==4, p(2) cov(yrdums*) graph_options(yscale(r(30 60)) ylabel(30 40 50 60) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\advprof10_cross_2.pdf", replace

*****************************************
******FIG C2 (C)
*****************************************
rdplot advprof_math8 perc if (perc>=-10&perc<=10) & dyear==-2, p(2) cov(yrdums*) graph_options(yscale(r(30 60)) ylabel(30 40 50 60) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\advprof8_cross_1.pdf", replace

*****************************************
******FIG C2 (D)
*****************************************
rdplot advprof_math8 perc if (perc>=-10&perc<=10) & dyear==4, p(2) cov(yrdums*) graph_options(yscale(r(30 60)) ylabel(30 40 50 60) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\advprof8_cross_2.pdf", replace

*****************************************
******FIG C2 (E)
*****************************************
rdplot advprof_math4 perc if (perc>=-10&perc<=10) & dyear==-2, p(2) cov(yrdums*) graph_options(yscale(r(30 60)) ylabel(30 40 50 60) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\advprof4_cross_1.pdf", replace


*****************************************
******FIG C2 (F)
*****************************************
rdplot advprof_math4 perc if (perc>=-10&perc<=10) & dyear==4, p(2) cov(yrdums*) graph_options(yscale(r(30 60)) ylabel(30 40 50 60) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% Adv. or Prof.) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\advprof4_cross_2.pdf", replace


*****************************************
******FIG C3 (A)
*****************************************
rdplot dropout_rate perc if (perc>=-10&perc<=10) & dyear==-2, p(2) graph_options(yscale(r(0 1.5)) ylabel(0 0.5 1 1.5) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% of Students who Drop Out) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\dropout_cross_1.pdf", replace

*****************************************
******FIG C3 (B)
*****************************************
rdplot dropout_rate perc if (perc>=-10&perc<=10) & dyear==5, p(2) graph_options(yscale(r(0 1.5)) ylabel(0 0.5 1 1.5) ///
xtitle(Re-Centered % in Favor of the Measure) ytitle(% of Students who Drop Out) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\dropout_cross_2.pdf", replace

*****************************************
******FIG C3 (C)
*****************************************
rdplot perc_instate perc if (perc>=-10&perc<=10) & dyear==-2, p(2) cov(yrdums* grade9lagged)  ///
graph_options(xtitle(Re-Centered % in Favor of the Measure) ylabel(.35 .4 .45 .5) ytitle(% of Students in Postsec. Education) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white))) 
graph export "${path}\Output\postsec_cross_1.pdf", replace
 
*****************************************
******FIG C3 (D)
*****************************************
rdplot perc_instate perc if (perc>=-10&perc<=10) & dyear==5, p(2) cov(yrdums* grade9lagged) ///
graph_options(xtitle(Re-Centered % in Favor of the Measure) ylabel(.35 .4 .45 .5) ytitle(% of Students in Postsec. Education) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)))
graph export "${path}\Output\postsec_cross_2.pdf", replace


*****************************************
******SECTION III: ONLINE APPENDIX TABLES
*****************************************

*****************************************
******TABLE B2 (A)
*****************************************
rdrobust advprof_math10 perc if dyear==-2, all
rdrobust advprof_math10 perc if dyear>=0, all

*****************************************
******TABLE B2 (B)
*****************************************
rdrobust advprof_math8 perc if dyear==-2, all
rdrobust advprof_math8 perc if dyear>=0, all

*****************************************
******TABLE B2 (C)
*****************************************
rdrobust dropout_rate perc if dyear==-2, all
rdrobust dropout_rate perc if dyear>=0, all

*****************************************
******TABLE B2 (D)
*****************************************
rdrobust perc_instate perc if dyear==-2, all
rdrobust perc_instate perc if dyear>=0, all

*****************************************
******TABLE C2 (A)
*****************************************
rdrobust rev_lim_mem perc if dyear==-2, all
rdrobust rev_lim_mem perc if dyear>=0, all

*****************************************
******TABLE C2 (B)
*****************************************
rdrobust tot_exp_mem perc if dyear==-2, all
rdrobust tot_exp_mem perc if dyear>=0, all


*****************************************
******TABLE C3 (A)
*****************************************
rdrobust advprof_math10 perc if dyear==-2, all
rdrobust advprof_math10 perc if dyear>=0, all

*****************************************
******TABLE C3 (B)
*****************************************
rdrobust advprof_math8 perc if dyear==-2, all
rdrobust advprof_math8 perc if dyear>=0, all

*****************************************
******TABLE C3 (C)
*****************************************
rdrobust advprof_math4 perc if dyear==-2, all
rdrobust advprof_math4 perc if dyear>=0, all


*****************************************
******TABLE C4 (A)
*****************************************
rdrobust dropout_rate perc if dyear==-2, all
rdrobust dropout_rate perc if dyear>=0, all

*****************************************
******TABLE C4 (B)
*****************************************
rdrobust perc_instate perc if dyear==-2, all
rdrobust perc_instate perc if dyear>=0, all