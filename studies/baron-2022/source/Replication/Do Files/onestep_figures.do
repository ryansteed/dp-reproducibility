/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates all figures in the paper that are derived
from the one-step estimator. These figures include the following:
Figure 1, Figure 2, Figure 5, Figure 6 in the main body of the paper.
Figure B.5, Figure B.6, Figure B.7, Figure B.8, Figure B.9, Figure B.10, 
Figure B.11, Figure B.12 in the online appendix.


DATA INPUTS: (1) onestep_panel_figures

*********************************/
clear
set more off

*Set globals

*Path
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*The model is as follows:
*I control for both types of measures on the ballot, polynomial controls in both
*vote shares (op and capital), the number of elections in any given year for both
*types, whether the op. election is for recurring and nonrecurring purposes. 
*Finally, I include year and district fixed effects.


*Cubic Specification
global cubic op_win_fut2 op_win_fut1 op_win_prev* ///
bond_win_fut2 bond_win_fut1 bond_win_prev* yrdums* ///
op_ismeas_fut* op_ismeas_prev* ///
bond_ismeas_fut* bond_ismeas_prev* ///
op_percent_fut* op_percent2_fut* op_percent3_fut* ///
op_percent_prev* op_percent2_prev* op_percent3_prev* ///
bond_percent_fut* bond_percent2_fut* bond_percent3_fut* ///
bond_percent_prev* bond_percent2_prev* bond_percent3_prev* ///
recurring_prev* recurring_fut* op_numelec_prev* bond_numelec_prev* ///
op_numelec_fut* bond_numelec_fut*


*Quadratic Specification
global quadratic op_win_fut2 op_win_fut1 op_win_prev* ///
bond_win_fut2 bond_win_fut1 bond_win_prev* yrdums* ///
op_ismeas_fut* op_ismeas_prev* ///
bond_ismeas_fut* bond_ismeas_prev* ///
op_percent_fut* op_percent2_fut*  ///
op_percent_prev* op_percent2_prev*  ///
bond_percent_fut* bond_percent2_fut*  ///
bond_percent_prev* bond_percent2_prev* ///
recurring_prev* recurring_fut* op_numelec_prev* bond_numelec_prev* ///
op_numelec_fut* bond_numelec_fut*


*Linear Specification
global linear op_win_fut2 op_win_fut1 op_win_prev* ///
bond_win_fut2 bond_win_fut1 bond_win_prev* yrdums* ///
op_ismeas_fut* op_ismeas_prev* ///
bond_ismeas_fut* bond_ismeas_prev* ///
op_percent_fut* op_percent_prev*  ///
bond_percent_fut* bond_percent_prev* ///
recurring_prev* recurring_fut* op_numelec_prev* bond_numelec_prev* ///
op_numelec_fut* bond_numelec_fut*


*Import one-step estimator panel
use "${path}Data\Final\onestep_panel_figures"

*Set confidence levels to 90% and set graph preferences
set level 90
set scheme s2color
grstyle init
grstyle yesno grid_draw_min yes
grstyle yesno grid_draw_max yes


*****************************************
******SECTION I: MAIN BODY FIGURES
*****************************************


*****************************************
******FIG 1 (A)
*****************************************
areg rev_lim_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Revenue Limits PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-500 (500) 1000)) ylabel (-500 ///
"-500" 0 "0" 500 "500" 1000 "1,000")
graph export "$path\Output\revlim.pdf", replace


*****************************************
******FIG 1 (B)
*****************************************
areg tot_exp_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J		
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Change in Total Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-500 (500) 1000)) ylabel (-500 ///
"-500" 0 "0" 500 "500" 1000 "1,000")
graph export "$path\Output\totexp.pdf", replace


*****************************************
******FIG 1 (C)
*****************************************
areg LT_debt_out_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J				
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Long-Term Debt PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-4000 (1000) 4000)) ylabel (-4000 "-4,000" -2000 "-2,000"  0 "0" 2000 "2,000" 4000 "4,000") 
graph export "$path\Output\new_longtermdebt1.pdf", replace


*****************************************
******FIG 1 (D)
*****************************************
areg interest_debt_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J			
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Interest Payments PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ylabel(-500 "-500" -250 "-250" 0 "0" 250 "250" 500 "500")
graph export "$path\Output\new_interestpay1.pdf", replace



*****************************************
******FIG 1 (E)
*****************************************
areg tot_capout_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J					
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Capital Outlays PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-2000 (500) 2000)) ylabel (-2000 "-2,000" -1000 "-1,000" 0 "0" 1000 "1,000" 2000 "2,000") 
graph export "$path\Output\capout1.pdf", replace


*****************************************
******FIG 1 (F)
*****************************************
areg ss_operation_maint_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J		
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-2000 (500) 2000)) ylabel (-2000 "-2,000" -1000 "-1,000" 0 "0" 1000 "1,000" 2000 "2,000") 
graph export "$path\Output\operationmaint.pdf", replace



*****************************************
******FIG 2 (A)
*****************************************
*Linear
areg dropout_rate $linear [aw=student_count], absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J

*Quadratic
areg dropout_rate $quadratic [aw=student_count], absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg dropout_rate $cubic [aw=student_count], absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ilcolor(white) ///
style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range(-1(.2)1)) ///
ylabel(-1 "-1" -.5 "-.5" 0 "0" .5 ".5" 1 "1")
graph export "$path\Output\newdropout.pdf", replace


*****************************************
******FIG 2 (B)
*****************************************
*Linear
areg advprof_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg advprof_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg advprof_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-5 (5) 15)) ///
ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15")
graph export "$path\Output\newadvprof10.pdf", replace


*****************************************
******FIG 2 (C)
*****************************************
*Linear
areg wkce_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg wkce_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P


*Cubic
areg wkce_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Change in Avg. Scale Score) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-5 (5) 15)) ///
ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15")
graph export "$path\Output\newwkcescale.pdf", replace


*****************************************
******FIG 2 (D)
*****************************************
*Linear
areg log_instate_enr $linear grade9lagged, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J

*Quadratic
areg log_instate_enr $quadratic grade9lagged, absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg log_instate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V


coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ///
ilcolor(white) style(none)) xtitle(Year (relative to election)) ///
xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
legend(label(2 "Linear") label(4 "Quadratic") label(6 "Cubic")) ///
ylabel (-.2 "-20" 0 "0" .2 "20" .4 "40") 
graph export "$path\Output\new_collegeenr.pdf", replace		



*****************************************
******FIG 5 (A)
*****************************************
areg tot_capout_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J	
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Capital Outlays PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ylabel(-2000 "-2,000" 0 "0" 2000 "2,000" 4000 "4,000" 6000 "6,000")
graph export "$path\Output\capoutfirst.pdf", replace



*****************************************
******FIG 5 (B)
*****************************************
areg interest $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J		
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Interest Payments PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10")  ylabel (0 "0" 100 "100" 200 "200" ///
300 "300" 400 "400")
graph export "$path\Output\interest.pdf", replace



*****************************************
******FIG 5 (C)
*****************************************
areg LT_debt_out $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J		
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Long-Term Debt PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ylabel (0 "0" 2000 "2,000" 4000 "4,000" 6000 "6,000" 8000 "8,000")
graph export "$path\Output\debt.pdf", replace


*****************************************
******FIG 5 (D)
*****************************************
areg tot_exp_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J		
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Operational Expenditures PP ($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-1000 (500) 1000)) ylabel (-1000 "-1,000" -500 ///
"-500" 0 "0" 500 "500" 1000 "1,000")
graph export "$path\Output\opexpcap.pdf", replace



*****************************************
******FIG 6 (A)
*****************************************
*Linear
areg dropout_rate $linear [aw=student_count], absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J

*Quadratic
areg dropout_rate $quadratic [aw=student_count], absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P

*Cubic
areg dropout_rate $cubic [aw=student_count], absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,21..22]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,23..32]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ilcolor(white) ///
style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range(-1(.2)1)) ///
ylabel(-1 "-1" -.5 "-.5" 0 "0" .5 ".5" 1 "1")
graph export "$path\Output\newdropoutcap.pdf", replace



*****************************************
******FIG 6 (B)
*****************************************
*Linear
areg advprof_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J

*Quadratic
areg advprof_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P

*Cubic
areg advprof_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,21..22]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,23..32]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-5 (5) 15)) ///
ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15")
graph export "$path\Output\newadvprof10cap.pdf", replace



*****************************************
******FIG 6 (C)
*****************************************
*Linear
areg wkce_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg wkce_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P

*Cubic
areg wkce_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,21..22]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,23..32]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Change in Avg. Scale Score) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-5 (5) 15)) ///
ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15")
graph export "$path\Output\newwkcescalecap.pdf", replace



*****************************************
******FIG 6 (D)
*****************************************
*Linear
areg log_instate_enr $linear grade9lagged, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg log_instate_enr $quadratic grade9lagged, absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P

*Cubic
areg log_instate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,21..22]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,23..32]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ///
ilcolor(white) style(none)) xtitle(Year (relative to election)) ///
xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
legend(label(2 "Linear") label(4 "Quadratic") label(6 "Cubic")) ///
ylabel (-.2 "-20" 0 "0" .2 "20" .4 "40") 
graph export "$path\Output\new_collegeenrcap.pdf", replace		



*****************************************
******SECTION II: ONLINE APPENDIX FIGURES
******************* **********************

*****************************************
******FIG B5 (A)
*****************************************
areg ss_pupils_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J						
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Expenditures PP($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-150 (50) 150)) ylabel (-150 "-150" -100 "-100" -50 "-50" ///
0 "0" 50 "50" 100 "100" 150 "150")
graph export "$path\Output\pupils.pdf", replace


*****************************************
******FIG B5 (B)
*****************************************
areg ss_transp_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J						
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Expenditures PP($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-150 (50) 150)) ylabel (-150 "-150" -100 "-100" -50 "-50" ///
0 "0" 50 "50" 100 "100" 150 "150")
graph export "$path\Output\transp.pdf", replace

*****************************************
******FIG B5 (C)
*****************************************
areg ss_schooladmin_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J							
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Expenditures PP($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-150 (50) 150)) ylabel (-150 "-150" -100 "-100" -50 "-50" ///
0 "0" 50 "50" 100 "100" 150 "150")
graph export "$path\Output\schooladmin.pdf", replace
			

*****************************************
******FIG B5 (D)
*****************************************
areg ss_instruction_mem $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J				
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
xtitle(Pre-Reform ACT Score) ytitle(Change in Expenditures PP($)) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-150 (50) 150)) ylabel (-150 "-150" -100 "-100" -50 "-50" ///
0 "0" 50 "50" 100 "100" 150 "150")
graph export "$path\Output\inst.pdf", replace	


*****************************************
******FIG B6 (A)
*****************************************
areg min_math10 $linear [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg min_math10 $quadratic [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg min_math10 $cubic [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V


coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-10 (5) 5)) ///
ylabel (-10 "-10" -5 "-5" 0 "0" 5 "5")
graph export "$path\Output\min_math10.pdf", replace


*****************************************
******FIG B6 (B)
*****************************************
*Linear
areg basic_math10 $linear [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg basic_math10 $quadratic [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg basic_math10 $cubic [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V


coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-10 (5) 5)) ///
ylabel (-10 "-10" -5 "-5" 0 "0" 5 "5")
graph export "$path\Output\basic_math10.pdf", replace


*****************************************
******FIG B6 (C)
*****************************************
*Linear
areg advprof_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg advprof_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg advprof_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())) ///
(matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Linear") ///
label(4 "Quadratic") label(6 "Cubic")) yscale(range (-5 (5) 15)) ///
ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15")
graph export "$path\Output\newadvprof10.pdf", replace


*****************************************
******FIG B7
*****************************************
*Linear
areg log_outofstate_enr $linear grade9lagged, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J

*Quadratic
areg log_outofstate_enr $quadratic grade9lagged, absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg log_outofstate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) (matrix(P[1]), ci((P[5] P[6])) ///
msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) ///
lwidth())) (matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ///
ilcolor(white) style(none)) xtitle(Year (relative to election)) ///
xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
legend(label(2 "Linear") label(4 "Quadratic") label(6 "Cubic")) ///
ylabel (-.6 "-60" -.4 "-40" -.2 "-20" 0 "0" .2 "20" .4 "40") 
graph export "$path\Output\new_collegeenr_out.pdf", replace	


*****************************************
******FIG B8 (A)
*****************************************
*Linear
areg log_instate_four $linear grade9lagged, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J

*Quadratic
areg log_instate_four $quadratic grade9lagged, absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg log_instate_four $cubic grade9lagged, absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) (matrix(P[1]), ci((P[5] P[6])) ///
msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) ///
lwidth())) (matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ///
ilcolor(white) style(none)) xtitle(Year (relative to election)) ///
xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
legend(label(2 "Linear") label(4 "Quadratic") label(6 "Cubic")) ///
ylabel (-.4 "-40" -.2 "-20" 0 "0" .2 "20" .4 "40") 
graph export "$path\Output\new_collegeenr_infour.pdf", replace	
 

*****************************************
******FIG B8 (B)
*****************************************
*Linear
areg log_instate_two $linear grade9lagged, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


*Quadratic
areg log_instate_two $quadratic grade9lagged, absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

*Cubic
areg log_instate_two $cubic grade9lagged, absorb(district_code) cluster(district_code)
matrix Q=r(table)
mat list Q
matrix R=Q[1..9,1..2]
mat list R
matrix S=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames S = "win_prev0"
matrix T = R,S //merges matrices together (concatenates)		
matlist T
matrix U=Q[1..9,3..12]
matlist U
matrix V =T,U
matlist V

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ///
ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) (matrix(P[1]), ci((P[5] P[6])) ///
msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) ///
lwidth())) (matrix(V[1]), ci((V[5] V[6]))),  recast(connected) lwidth(thick) ///
ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ///
ilcolor(white) fcolor(white) ifcolor(white)) plotregion(lcolor(none) ///
ilcolor(white) style(none)) xtitle(Year (relative to election)) ///
xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
legend(label(2 "Linear") label(4 "Quadratic") label(6 "Cubic")) ///
ylabel (-.4 "-40" -.2 "-20" 0 "0" .2 "20" .4 "40") 
graph export "$path\Output\new_collegeenr_intwo.pdf", replace	


*****************************************
******FIG B9 (A)
*****************************************
areg perc_econdis $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B 
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J			
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
ylabel (-6 "-6" -4 "-4" -2 "-2" 0 "0" 2 "2" 4 "4" 6 "6") 
graph export "$path\Output\perc_econdis.pdf", replace

*****************************************
******FIG B9 (B)
*****************************************
areg perc_min $cubic, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J					
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) ///
xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
ylabel (-6 "-6" -4 "-4" -2 "-2" 0 "0" 2 "2" 4 "4" 6 "6")  
graph export "$path\Output\perc_min.pdf", replace

*****************************************
******FIG B9 (C)
*****************************************
areg log_enr $cubic, ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J		
coefplot (matrix(J[1]), ci((J[5] J[6]))),  recast(connected) lwidth(thick) ciopts(recast(rline) lpattern(dash) lwidth() ) vert yline(0, lcolor(black)) ///
ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") /// 
ylabel(-.15 "-15" -.10 "-10" -.05 "-5" 0 "0" .05 "5" .1 "10" .15 "15")	
graph export "$path\Output\enrollment.pdf", replace

*****************************************
******FIG B10 (A)
*****************************************
areg dropout_rate $cubic if above_median==1 [aw=student_count], ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J	
		
		
areg dropout_rate $cubic if above_median==0 [aw=student_count], ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P	

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) ///
lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() ///
lwidth())) (matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) ///
lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") /// 
yscale(range(-1(.2)1)) ylabel(-1 "-1" -.5 "-.5" 0 "0" .5 ".5" 1 "1") ///
legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\newdropouthet.pdf", replace


*****************************************
******FIG B10 (B)
*****************************************
areg advprof_math10 $cubic if above_median==1 [aw=num_takers_math10], ///
    absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


areg advprof_math10 $cubic if above_median==0 [aw=num_takers_math10] , ///
    absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") /// 
yscale(range (-5 (5) 20)) ylabel (-10 "-10" 0 "0"  10 "10"  20 "20") ///
legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\newadvprofhet.pdf", replace


*****************************************
******FIG B10 (C)
*****************************************
areg wkce_math10 $cubic if above_median==1 [aw=num_takers_math10], ///
    absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J


areg wkce_math10 $cubic if above_median==0 [aw=num_takers_math10] , ///
    absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(Change in Scale Score) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") /// 
yscale(range (-5 (5) 20)) ylabel (-10 "-10" 0 "0"  10 "10"  20 "20") ///
legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\newwkcescalehet.pdf", replace

*****************************************
******FIG B10 (D)
*****************************************
areg log_instate_four $cubic grade9lagged if above_median==1, ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,1..2]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,3..12]
matlist I
matrix J =B,D,I
matlist J

areg log_instate_four $cubic grade9lagged if above_median==0, ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,1..2]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,3..12]
matlist O
matrix P =N,O
matlist P	

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") /// 
 ylabel (-.4 "-40" -.2 "-20" 0 "0" .2 "20"  .4 "40" .6 "60" .8 "80") ///
yscale(range (-.1 (.1) .4)) legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\new_collegeenrhet.pdf", replace

*****************************************
******FIG B11 (A)
*****************************************
areg dropout_rate $cubic [aw=student_count] if ///
	district_inf_cond==1|district_inf_cond==2 , ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J

		
areg dropout_rate $cubic [aw=student_count] if ///
	district_inf_cond==3|district_inf_cond==4  ///
	|district_inf_cond==5|district_inf_cond==6, ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P		
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Excellent or Good") ///
label(4 "Adequate, Fair, Poor, or Replace")) yscale(range(-1(.2)1)) ylabel(-1 "-1" -.5 "-.5" 0 "0" .5 ".5" 1 "1")
graph export "$path\Output\new_het_dropoutcap.pdf", replace


*****************************************
******FIG B11 (B)
*****************************************
areg advprof_math10 $cubic [aw=num_takers_math10] if district_inf_cond==1| ///
	district_inf_cond==2, absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J

areg advprof_math10 $cubic [aw=num_takers_math10] if district_inf_cond==3|district_inf_cond==4  ///
	|district_inf_cond==5|district_inf_cond==6, ///
    absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Excellent or Good") ///
label(4 "Adequate, Fair, Poor, or Replace")) yscale(range (-20 (5) 20)) ///
ylabel (-20 "-20" -10 "-10" 0 "0" 10 "10" 20 "20")
graph export "$path\Output\new_het_advprof10cap.pdf", replace


*****************************************
******FIG B11 (C)
*****************************************
areg wkce_math10 $cubic [aw=num_takers_math10] if district_inf_cond==1|district_inf_cond==2, ///
    absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J

areg wkce_math10 $cubic [aw=num_takers_math10] if district_inf_cond==3|district_inf_cond==4  ///
	|district_inf_cond==5|district_inf_cond==6, ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Excellent or Good") label(4 "Adequate, Fair, Poor, or Replace")) ///
yscale(range (-20 (5) 20)) ylabel (-20 "-20" -10 "-10" 0 "0" 10 "10" 20 "20")
graph export "$path\Output\new_het_std10cap.pdf", replace



*****************************************
******FIG B11 (D)
*****************************************
areg log_instate_enr $cubic grade9lagged if district_inf_cond==1|district_inf_cond==2, ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J


areg log_instate_four $cubic grade9lagged if district_inf_cond==3|district_inf_cond==4  ///
	|district_inf_cond==5|district_inf_cond==6, absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P	

coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") legend(label(2 "Excellent or Good") label(4 "Adequate, Fair, Poor, or Replace")) ///
ylabel (-.4 "-40" -.2 "-20" 0 "0" .2 "20" .4 "40" .6 "60") 
graph export "$path\Output\new_het_collegeenrcap.pdf", replace


*****************************************
******FIG B12 (A)
*****************************************
areg dropout_rate $cubic if above_median==1 [aw=student_count], ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J
		
areg dropout_rate $cubic if above_median==0 [aw=student_count], ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P	
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) ///
lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) ///
xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ///
yscale(range(-1(.2)1)) ylabel(-1 "-1" -.5 "-.5" 0 "0" .5 ".5" 1 "1") ///
legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\cap_newdropouthet.pdf", replace

*****************************************
******FIG B12 (B)
*****************************************
areg advprof_math10 $cubic if above_median==1 [aw=num_takers_math10], ///
    absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J


areg advprof_math10 $cubic if above_median==0 [aw=num_takers_math10] , ///
    absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P	
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(PP Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-5 (5) 20)) ylabel (-10 "-10" 0 "0"  10 "10"  20 "20") ///
legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\cap_advprofhet.pdf", replace


*****************************************
******FIG B12 (C)
*****************************************
areg wkce_math10 $cubic if above_median==1 [aw=num_takers_math10], ///
    absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J


areg wkce_math10 $cubic if above_median==0 [aw=num_takers_math10] , ///
    absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P	
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(Change in Scale Score) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") yscale(range (-5 (5) 20)) ylabel (-10 "-10" 0 "0"  10 "10"  20 "20") ///
legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\cap_newwkcescalehet.pdf", replace

*****************************************
******FIG B12 (D)
*****************************************
areg log_instate_four $cubic grade9lagged if above_median==1, ///
	absorb(district_code) cluster(district_code)
matrix A=r(table)
mat list A
matrix B=A[1..9,21..22]
mat list B
matrix D=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames D = "win_prev0"
matrix H = B,D //merges matrices together (concatenates)		
matlist H
matrix I=A[1..9,23..32]
matlist I
matrix J =B,D,I
matlist J

areg log_instate_four $cubic grade9lagged if above_median==0, ///
	absorb(district_code) cluster(district_code)
matrix K=r(table)
mat list K
matrix L=K[1..9,21..22]
mat list L
matrix M=J(9,1,0) //generates a vector 9X1 of zeroes
matrix colnames M = "win_prev0"
matrix N = L,M //merges matrices together (concatenates)		
matlist N
matrix O=K[1..9,23..32]
matlist O
matrix P =N,O
matlist P	
coefplot (matrix(J[1]), ci((J[5] J[6])) msymbol(diamond) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(triangle) lpattern() lwidth())) ///
(matrix(P[1]), ci((P[5] P[6])) msymbol(circle) recast(rcap) lwidth(thick) ciopts(recast(rcap) msymbol(circle) lpattern(longdash) lwidth())), ///
vert yline(0, lcolor(black)) ytitle(Percent Change) bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none)) xtitle(Year (relative to election)) xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" ///
5 "2" 6 "3" 7 "4" 8 "5" 9 "6" 10 "7" 11 "8" 12 "9" 13 "10") ylabel (-.4 "-40" -.2 "-20" 0 "0" .2 "20"  .4 "40" .6 "60") ///
yscale(range (-.1 (.1) .4)) legend(label(2 "Initially High Share") label(4 "Initially Low Share"))
graph export "$path\Output\cap_collegeenrhet.pdf", replace



