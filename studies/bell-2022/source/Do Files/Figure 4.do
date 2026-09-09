*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"



********************************************************************************

***********************            Figure 4            *************************

********************************************************************************



*** Get Individual RD Estimates



clear all
clear matrix
set more off

qui{

use "Data\arrest_data_discontinuity_states.dta", clear 

sort fstate disc_id
egen disc_id2=group(fstate disc_id)
drop disc_id
rename disc_id2 disc_id

keep if time>=-5 & time<=4


forvalues i=1/30 {

qui:reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if disc_id==`i' & crime==1, a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) vce(robust)
matrix A = (nullmat(A)\_b[disc])
matrix B = (nullmat(B)\_se[disc])

}

matrix C=(A,B)

matrix colnames C = b se

matrix rownames C = Arizona Arkansas Arkansas California Colorado Connecticut Illinois Indiana Indiana Iowa Kentucky Louisiana Louisiana Maine Michigan Michigan Mississippi Missouri Nebraska Nevada New_Hampshire New_Mexico Rhode_Island South_Dakota Texas Texas Texas Virginia Washington Wyoming

}



matrix list C


clear



svmat C, names(col)


gen disc_id=_n


* Get the Reform Labels
qui{
gen state_name=	"Arizona"	 if disc_id==	1
replace state_name=	"Arkansas"	 if disc_id==	2
replace state_name=	"Arkansas"	 if disc_id==	3
replace state_name=	"California"	 if disc_id==	4
replace state_name=	"Colorado"	 if disc_id==	5
replace state_name=	"Connecticut"	 if disc_id==	6
replace state_name=	"Illinois"	 if disc_id==	7
replace state_name=	"Indiana"	 if disc_id==	8
replace state_name=	"Indiana"	 if disc_id==	9
replace state_name=	"Iowa"	 if disc_id==	10
replace state_name=	"Kentucky"	 if disc_id==	11
replace state_name=	"Louisiana"	 if disc_id==	12
replace state_name=	"Louisiana"	 if disc_id==	13
replace state_name=	"Maine"	 if disc_id==	14
replace state_name=	"Michigan"	 if disc_id==	15
replace state_name=	"Michigan"	 if disc_id==	16
replace state_name=	"Mississippi"	 if disc_id==	17
replace state_name=	"Missouri"	 if disc_id==	18
replace state_name=	"Nebraska"	 if disc_id==	19
replace state_name=	"Nevada"	 if disc_id==	20
replace state_name=	"New Hampshire"	 if disc_id==	21
replace state_name=	"New Mexico"	 if disc_id==	22
replace state_name=	"Rhode Island"	 if disc_id==	23
replace state_name=	"South Dakota"	 if disc_id==	24
replace state_name=	"Texas"	 if disc_id==	25
replace state_name=	"Texas"	 if disc_id==	26
replace state_name=	"Texas"	 if disc_id==	27
replace state_name=	"Virginia"	 if disc_id==	28
replace state_name=	"Washington"	 if disc_id==	29
replace state_name=	"Wyoming"	 if disc_id==	30


gen year=	1986	 if disc_id==	1
replace year=	1981	 if disc_id==	2
replace year=	1991	 if disc_id==	3
replace year=	1988	 if disc_id==	4
replace year=	2008	 if disc_id==	5
replace year=	2002	 if disc_id==	6
replace year=	2005	 if disc_id==	7
replace year=	1989	 if disc_id==	8
replace year=	1992	 if disc_id==	9
replace year=	1992	 if disc_id==	10
replace year=	1984	 if disc_id==	11
replace year=	1988	 if disc_id==	12
replace year=	2002	 if disc_id==	13
replace year=	1980	 if disc_id==	14
replace year=	1997	 if disc_id==	15
replace year=	2010	 if disc_id==	16
replace year=	1984	 if disc_id==	17
replace year=	2010	 if disc_id==	18
replace year=	2006	 if disc_id==	19
replace year=	2008	 if disc_id==	20
replace year=	2010	 if disc_id==	21
replace year=	1981	 if disc_id==	22
replace year=	2003	 if disc_id==	23
replace year=	2010	 if disc_id==	24
replace year=	1985	 if disc_id==	25
replace year=	1990	 if disc_id==	26
replace year=	1998	 if disc_id==	27
replace year=	1991	 if disc_id==	28
replace year=	1997	 if disc_id==	29
replace year=	1999	 if disc_id==	30
}




tostring year, replace
gen state_lab= state_name + " " + "(" + year + ")"

gen id=_n
labmask id, values(state_lab)


gen upper_b= b + 1.96*se
gen lower_b= b - 1.96*se


***Discontinuities

#delimit ;

tw 	rcap upper_b lower_b id, lcolor(black) || 
	scatter b id, color(black) 
	xlab(1(1)30,valuelabel labsize(small) angle(vertical)) 
	yline(0, lcolor(black)) graphregion(color(white)) bgcolor(white) legend(off) 
	ylab(, nogrid angle(horizontal)) 
	xtitle("") 
	ytitle("Reform Coefficient", size(medsmall)) 
	title("Regression Discontinuity", size(med) color(black));
#d cr