
////////////////////////////////////////////////////////////////////////////////
/// 	
/// 	Replication for  "Do Police Maximize Arrests or Minimize Crime?"  
/// 	Allison Stashko  		
/// 	Created May 23, 2022
/// 							
////////////////////////////////////////////////////////////////////////////////

// See README.pdf
// The file 0_Main.do sets directories and calls this file


 
/// Load data, select sample

cd "$InputPath/"

use city_sample.dta, clear

*** EDITED by Ryan Steed --- want to use these variables to modify the sample when noisy
replace sample = (population >= 25000) & (pblack > .01) & (pblack != .) & (pwhite > .01) & (pwhite != .) & (population != .) & (exp_police != .) & (exp_police > 0) & (shrink != .) & (arr_drugsale_spread != .)
***
keep if sample==1 //final sample limited to cities with: population>=25000  & pblack>.01  & pblack!=. & pwhite>.01 & pwhite!=. &  population!=. & exp_police!=. & exp_police>0 & shrink!=.  & arr_drugsale_spread!=.
				

//SELECT COVARIATES
global x population pop2 phispanic pasian paian punemployed pnohsdiploma pbachelors page65_up page0_24 pfemale medhhinc povertyrate seg_thiel 

// SELECT FIXED EFFECTS
global fe_state fstate year
global fe_city  city   year

// SELECT SE CLUSTERING
global cl city

// SELECT SAMPLE (reghdfe drops singletons, use city FE sample for all regressions 
reghdfe exp_police pblack	 	hprime	 	shrink	$x  if sample==1 , a($fe_city) vce(cluster $cl)  
replace sample=0 if e(sample)!=1


////////////////////////////////////////////////////////////////////////////////
///
/// 						  Tables 
///   									 
////////////////////////////////////////////////////////////////////////////////
***Edited by Annie Qian
cd "../$TablesPath/"	
***

/// Table C1. Summary Statistics									 


local demog Pblack Pwhite Phispanic Pasian Paian
local arr  arr_drugsale_b_p1k arr_drugsale_w_p1k arr_drugsale_spread arr_drugsale_diff
local govfin  exp_police exp_policepc
local covariates Pfemale Punemployed Pnohsdiploma Pbachelors Page0_24 Page65_up seg_thiel


estpost sum population if sample==1
esttab using sumstats.tex, replace  ///
		cells((mean(fmt(0) label(Mean)) sd(fmt(0) label(St. Dev.)) min(fmt(0) label(Min)) max(fmt(0) label(Max)))) ///
		label booktabs  gaps f noobs nonum nomtitle plain

estpost sum `demog'	if sample==1	
esttab using sumstats.tex, append  ///
		cells((mean(fmt(3) label(Mean)) sd(fmt(3) label(St. Dev.)) min(fmt(3) label(Min)) max(fmt(3) label(Max)))) ///
		refcat( pblack "\emph{Race and Ethnicity}", nolabel) ///
		label booktabs  gaps f noobs nonum nomtitle plain collabels(none)

estpost sum hprime if sample==1
esttab using sumstats.tex, append ///
		cells((mean(fmt(4) label(Mean)) sd(fmt(4) label(St. Dev.)) min(fmt(4) label(Min)) max(fmt(4) label(Max)))) ///
		refcat( hprime "\emph{Income}", nolabel) ///
		label booktabs  gaps f noobs nonum nomtitle plain	collabels(none)
	
estpost sum medhhinc_dollar if sample==1
esttab using sumstats.tex, append ///
		cells((mean(fmt(0) label(Mean)) sd(fmt(0) label(St. Dev.)) min(fmt(0) label(Min)) max(fmt(0) label(Max)))) ///
		label booktabs  gaps f noobs nonum nomtitle plain	collabels(none)
		
estpost sum povertyrate if sample==1
esttab using sumstats.tex, append ///
		cells((mean(fmt(3) label(Mean)) sd(fmt(3) label(St. Dev.)) min(fmt(3) label(Min)) max(fmt(3) label(Max)))) ///
		label booktabs  gaps f noobs nonum nomtitle plain	collabels(none)
	
estpost sum `govfin' if sample==1
esttab using sumstats.tex, append ///
		cells((mean(fmt(3) label(Mean)) sd(fmt(3) label(St. Dev.)) min(fmt(3) label(Min)) max(fmt(3) label(Max)))) ///
		refcat( exp_police "\emph{Government Expenditures}", nolabel) ///
		label booktabs  gaps f noobs nonum nomtitle plain collabels(none)
		
estpost sum `arr' if sample==1
esttab using sumstats.tex, append ///
		cells((mean(fmt(3) label(Mean)) sd(fmt(3) label(St. Dev.)) min(fmt(3) label(Min)) max(fmt(3) label(Max)))) ///
		refcat(arr_drugsale_b_p1k "\emph{Arrests}", nolabel) ///
		label booktabs  gaps f noobs nonum nomtitle plain collabels(none)		

estpost sum `covariates' if sample==1
esttab using sumstats.tex, append ///
		cells((mean(fmt(2) label(Mean)) sd(fmt(2) label(St. Dev.)) min(fmt(2) label(Min)) max(fmt(2) label(Max)))) ///
		refcat( Pfemale "\emph{Other covariates}", nolabel) ///
		label booktabs  gaps f nonum nomtitle plain collabels(none)		
	
/// TABLE 1. Distance between Arrest Rates
	
reghdfe arr_drugsale_spread pblack	 				hprime shrink $x  	 if sample==1 , a($fe_state) vce(cluster $cl)
eststo A
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A

reghdfe arr_drugsale_spread pblack	pblackxshrink 	hprime shrink $x     if sample==1 , a($fe_state) vce(cluster $cl)
eststo B
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): B 

reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime   $x  	     if sample==1 , a($fe_state) vce(cluster $cl )
eststo C
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C


reghdfe arr_drugsale_spread pblack	 				hprime shrink $x     if sample==1 , a($fe_city) vce(cluster $cl )
eststo A_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A_FE
reghdfe arr_drugsale_spread pblack	pblackxshrink 	hprime shrink $x     if sample==1 , a($fe_city) vce(cluster $cl ) 
eststo B_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B_FE
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): B_FE

reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime   $x    		 if sample==1 , a($fe_city) vce(cluster $cl ) 
eststo C_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_FE

*** Edited by Annie
estout A B C A_FE B_FE C_FE using "../../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***

local name arr_shrink
estout A B C   using `name'.tex, replace ///
	labcol2("$-$ \quad \quad  $+$ " "$+$ \quad  \quad $-$" "$+$ \quad \quad $-$" "$+$/$-$ \quad \ $+$/$-$" "$+$/$-$ \quad \ $+$/$-$", title(" \specialcell{Predicted Sign \\ AMP \quad CMP}")) ///
	prehead("& \multicolumn{6}{c}{\textit{Panel A: State and year fixed effects}} \vspace{2mm} \\") ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(N r2 ymean   pF_shrink pF, fmt(0 2 2 3 3) labels("N" "\$R^2\$" "Dependent variable mean"  "p-value for \$H_0:\beta_1+\beta_2=0\$" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	mlabels("\specialcell{\\(1)}" "\specialcell{\\(2)}" "\specialcell{\\(3)}") ///
	varlabels(, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	order(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

estout A_FE B_FE C_FE   using `name'.tex, append ///
	labcol2("$-$ \quad \quad  $+$ " "$+$ \quad  \quad $-$" "$+$ \quad \quad $-$" "$+$/$-$ \quad \ $+$/$-$" "$+$/$-$ \quad \ $+$/$-$", title(" \specialcell{Predicted Sign \\ AMP \quad CMP}")) ///
	prehead("& \multicolumn{6}{c}{\specialcell{\\~\textit{Panel B: City and year fixed effects} \vspace{2mm}}} \\") ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(N r2 ymean   pF_shrink pF, fmt(0 2 2 3 3) labels("N" "\$R^2\$" "Dependent variable mean"  "p-value for \$H_0:\beta_1+\beta_2=0\$" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	mlabels("\specialcell{\\(1)}" "\specialcell{\\(2)}" "\specialcell{\\(3)}") ///
	varlabels(, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	order(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
/// TABLE 2. Police Spending

reghdfe exp_police pblack	 	hprime	 	shrink	$x  				if sample==1 , a($fe_state) vce(cluster $cl )  
eststo A
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A

reghdfe exp_police pblack pblackxshrink hprime 	shrink	$x  			if sample==1 , a($fe_state) vce(cluster $cl )
eststo B
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): B 

reghdfe exp_police pblack	pblackxhprime	hprime		$x  			if sample==1 , a($fe_state) vce(cluster $cl )
eststo C
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C
 
reghdfe exp_police pblack	 	hprime	 	shrink	$x    				if sample==1 , a($fe_city) vce(cluster $cl )  
eststo A_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A_FE

reghdfe exp_police pblack pblackxshrink hprime 	shrink	$x     			if sample==1 , a($fe_city) vce(cluster $cl )  
eststo B_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B_FE
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): B_FE

reghdfe exp_police pblack	pblackxhprime	hprime		$x   			if sample==1 ,  a($fe_city) vce(cluster $cl )  
eststo C_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_FE

*** Edited by Annie
estout A B C A_FE B_FE C_FE using "../../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***	
local name exp_shrink
estout A B C  using `name'.tex, replace ///
	labcol2("$+$ \quad \quad $+$/$-$ " "$-$ \quad \quad $+$/$-$" "$-$ \quad \quad $+$/$-$" "$+$/$-$ \quad \ $+$/$-$" "$+$/$-$ \quad \ $+$/$-$" , title("\specialcell{Predicted Sign \\ AMP \quad CMP}")) ///
	prehead("& \multicolumn{6}{c}{\textit{Panel A: State and year fixed effects}} \vspace{2mm} \\") ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(N r2 ymean   pF_shrink pF, fmt(0 2 2 3 3) labels("N" "\$R^2\$" "Dependent variable mean"  "p-value for \$H_0:\beta_1+\beta_2=0\$" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	mlabels("\specialcell{\\(1)}" "\specialcell{\\(2)}" "\specialcell{\\(3)}") ///
	varlabels(, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	order(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 


estout A_FE B_FE C_FE   using `name'.tex, append ///
	labcol2("$+$ \quad \quad $+$/$-$ " "$-$ \quad \quad $+$/$-$" "$-$ \quad \quad $+$/$-$" "$+$/$-$ \quad \ $+$/$-$" "$+$/$-$ \quad \ $+$/$-$" , title("\specialcell{Predicted Sign \\ AMP \quad CMP}")) ///
prehead("& \multicolumn{6}{c}{\specialcell{\\~\textit{Panel B: City and year fixed effects} \vspace{2mm}}} \\") ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(N r2 ymean   pF_shrink pF, fmt(0 2 2 3 3) labels("N" "\$R^2\$" "Dependent variable mean"  "p-value for \$H_0:\beta_1+\beta_2=0\$" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///	
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	mlabels("\specialcell{\\(1)}" "\specialcell{\\(2)}" "\specialcell{\\(3)}") ///
	varlabels(, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	order(pblack pblackxshrink pblackxhprime hprime shrink  ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
// Table 3. Other types of arrests	


reghdfe arr_prop_spread pblack pblackxhprime hprime				$x   if sample==1 , a($fe_state ) vce(cluster $cl )
	eststo A
	sum arr_prop_spread if e(sample)==1
	estadd scalar ymean=r(mean): A
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe arr_prop_spread pblack pblackxhprime hprime				$x   if sample==1 , a($fe_city ) vce(cluster $cl )
	eststo A_FE
	sum arr_prop_spread if e(sample)==1
	estadd scalar ymean=r(mean): A_FE
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE
	
reghdfe arr_viol_spread pblack pblackxhprime hprime				$x   if sample==1 , a($fe_state ) vce(cluster $cl )
	eststo B
	sum arr_viol_spread if e(sample)==1
	estadd scalar ymean=r(mean): B
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	
reghdfe arr_viol_spread pblack pblackxhprime hprime				$x   if sample==1 , a($fe_city ) vce(cluster $cl )
	eststo B_FE
	sum arr_viol_spread if e(sample)==1
	estadd scalar ymean=r(mean): B_FE
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE
	
local name otherarr_shrink
estout A A_FE B B_FE using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	mgroups("\specialcell{Property Crime}" "\specialcell{Violent Crime}", pattern(1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 


/// Table 4. Alternative Explanations (sub-sample analyses by racial animus, racial profiling ban, segregation)
		
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==1, a($fe_state ) vce(cluster $cl )
eststo A
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)

reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==1, a($fe_city ) vce(cluster $cl )
eststo A_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==0, a($fe_state ) vce(cluster $cl )
eststo B
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	

reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==0, a($fe_city ) vce(cluster $cl )
eststo B_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	

	
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==1, a($fe_state ) vce(cluster $cl )
eststo C
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==1, a($fe_city ) vce(cluster $cl )
eststo C_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
	
	
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==0, a($fe_state ) vce(cluster $cl )
eststo D
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==0, a($fe_city ) vce(cluster $cl )
eststo D_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)

	
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		        $x   if sample==1 & seg_high==1, a($fe_state ) vce(cluster $cl )
eststo E
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		        $x   if sample==1 & seg_high==1, a($fe_city ) vce(cluster $cl )
eststo E_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
		
reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & seg_high==0, a($fe_state ) vce(cluster $cl )
eststo F
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)

reghdfe arr_drugsale_spread pblack	pblackxhprime hprime		    	$x   if sample==1 & seg_high==0, a($fe_city ) vce(cluster $cl )
eststo F_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)
	
local name arr_altexp
estout A B C D E F using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(N r2 ymean, fmt(0 2 2) labels("N" "\$R^2\$" "Dependent variable mean")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(_cons Constant, end("" \addlinespace) nolast) ///
	prehead("& \multicolumn{6}{c}{\specialcell{ \textit{Panel A: State and year fixed effects}}} \vspace{2mm} \\") ///
	mgroups("\specialcell{Racial Animus}" "\specialcell{Racial\\Profiling Ban}"  "\specialcell{Segregation}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels("\$High\$" "\$Low\$" "\$Yes\$" "\$No\$" "\$High\$" "\$Low\$", titles span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) ///
	style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

estout A_FE B_FE C_FE D_FE E_FE F_FE using `name'.tex, append ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(N r2 ymean, fmt(0 2 2) labels("N" "\$R^2\$" "Dependent variable mean")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	prehead("& \multicolumn{6}{c}{\specialcell{~\\ \textit{Panel B: City and year fixed effects}}} \vspace{2mm} \\") ///
	mgroups("\specialcell{Racial Animus}" "\specialcell{Racial\\Profiling Ban}"  "\specialcell{Segregation}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels("\$High\$" "\$Low\$" "\$Yes\$" "\$No\$" "\$High\$" "\$Low\$", titles span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	
	
/// Table C2. Relative importance of observable and unobservable covariates

//ssc install psacalc

set emptycells drop

*use xtreg for psacalc to treat city FEs as nuisance parameters	
xtset city year, delta(5)

reghdfe arr_drugsale_spread pblack	 								  if sample==1 & shrink==0,  a($fe_city) vce(cluster $cl ) keepsin
eststo A
	
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): A
	estadd local cfe "Yes" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "No" : A

*for full model, use areg to record coefficients, R^2 , but use xtreg for psacalc in order to treat city FEs as nuisance parameters (see psacalc documentation)
reghdfe arr_drugsale_spread pblack		hprime	   $x    		 	  if sample==1 & shrink==0, a($fe_city)   vce(cluster $cl )  keepsin
eststo B


xtreg arr_drugsale_spread pblack	hprime 	   $x  YEAR2 YEAR3 YEAR4  if sample==1 & shrink==0, fe  vce(cluster $cl ) 	


	local  Rmax = min(1.3*e(r2),1) 
	psacalc delta pblack, rmax(`Rmax') mcontrol(YEAR2 YEAR3 YEAR4 )
	estadd scalar delta=r(delta) : B
	
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean) : B
	estadd local cfe "Yes" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B

reghdfe arr_drugsale_spread pblack	 								  if sample==1 & shrink==1,  a($fe_city ) vce(cluster $cl )  keepsin
eststo C
	
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): C
	estadd local cfe "Yes" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "No" : C

*for full model, use areg to record coefficients, R^2 , but use xtreg for psacalc, in order to treat city FEs as nuisance parameters (see psacalc documentation)
reghdfe arr_drugsale_spread pblack		hprime	   $x    		 	         if sample==1 & shrink==1, a($fe_city)   vce(cluster $cl )  keepsin
eststo D

xtreg arr_drugsale_spread pblack		hprime	   $x  YEAR2 YEAR3 YEAR4   	 if sample==1 & shrink==1, fe  vce(cluster $cl ) 

	local  Rmax = min(1.3*e(r2),1) 	
	psacalc delta pblack, rmax(`Rmax') mcontrol(YEAR2 YEAR3 YEAR4 )
	estadd scalar delta=r(delta) : D

	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): D
	estadd local cfe "Yes" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D

	
local name oster
estout A B C D using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(yfe cfe ctrl N  r2 ymean  delta, fmt(0 0 0 0 3 3 3) labels("Year FE" "City FE" "Controls" "N" "\$R^2\$" "Dependent variable mean"  "\$\delta\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	prehead("& \multicolumn{4}{c}{\textit{Panel A: Distance beetween Arrest Rates}} \\") ///
	varlabels(, end("" \addlinespace) nolast) ///
	mgroups("\$hprime<1\$" "\$hprime>1\$", pattern(1 0 1  0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) ///	
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
qui reghdfe exp_police pblack	 								 		if sample==1 & shrink==0,  a($fe_city) vce(cluster $cl ) keepsin
eststo A
	
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): A
	estadd local cfe "Yes" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "No" : A

*for full model, use areg to record coefficients, R^2 , but use xtreg for psacalc, in order to treat city FEs as nuisance parameters (see psacalc documentation)
reghdfe exp_police pblack	hprime 	   $x  								if sample==1 & shrink==0, a($fe_city)  vce(cluster $cl )  keepsin
eststo B
	
xtreg exp_police pblack	hprime 	   $x  YEAR2 YEAR3 YEAR4  				if sample==1 & shrink==0, fe  vce(cluster $cl ) 	


	local  Rmax = min(1.3*e(r2),1) 
	psacalc delta pblack, rmax(`Rmax') mcontrol(YEAR2 YEAR3 YEAR4 )
	estadd scalar delta=r(delta) : B
	
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): B
	estadd local cfe "Yes" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	

reghdfe exp_police arr_drugsale_spread pblack	 						if sample==1 & shrink==1,  a($fe_city ) vce(cluster $cl )  keepsin
eststo C
	
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): C
	estadd local cfe "Yes" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "No" : C

*for full model, use areg to record coefficients, R^2 , but use xtreg for psacalc, in order to treat city FEs as nuisance parameters (see psacalc documentation)
reghdfe exp_police pblack	hprime 	   $x  if sample==1 & shrink==1, a($fe_city)  vce(cluster $cl ) keepsin
eststo D
	
xtreg exp_police pblack		hprime	   $x  YEAR2 YEAR3 YEAR4   	 		if sample==1 & shrink==1, fe  vce(cluster $cl ) 

	local  Rmax = min(1.3*e(r2),1) 	
	psacalc delta pblack, rmax(`Rmax') mcontrol(YEAR2 YEAR3 YEAR4 )
	estadd scalar delta=r(delta) : D

	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): D
	estadd local cfe "Yes" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D


local name oster
estout A B C D using `name'.tex, append ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(yfe cfe ctrl N  r2 ymean  delta, fmt(0 0 0 0 3 3 3) labels("Year FE" "City FE" "Controls" "N" "\$R^2\$" "Dependent variable mean"  "\$\delta\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	prehead("& \multicolumn{4}{c}{\specialcell{ ~\\ \textit{Panel B: Police Spending}}} \\") ///
	varlabels(, end("" \addlinespace) nolast) ///
	mgroups("\$hprime<1\$" "\$hprime>1\$", pattern(1 0 1  0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) ///	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
/// Table C3. Cross-city variation in shrink (fixed effect city_shrink is unique to city and value of shrink) -- distsance between arrest rates


reghdfe arr_drugsale_spread pblack	pblackxshrink 	hprime shrink $x     	if sample==1 , a(city_shrink year) vce(cluster $cl )

eststo A
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): A
	estadd local sfe "No" : A
	estadd local cpfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
	
reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime   $x    			if sample==1 , a(city_shrink year) vce(cluster $cl)
eststo B
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B

	estadd local sfe "No" : B
	estadd local cpfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B

reghdfe arr_drugsale_spread pblack	pblackxshrink 	hprime shrink $x     	if sample==1 & nochangeshrink==1, a($fe_state) vce(cluster $cl )
eststo C
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): C

	estadd local sfe "Yes" : C
	estadd local cpfe "No" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	
reghdfe arr_drugsale_spread pblack	pblackxshrink 	hprime shrink $x    	if sample==1 & nochangeshrink==1, a($fe_city) vce(cluster $cl )
eststo D
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: D
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): D

	estadd local sfe "No" : D
	estadd local cpfe "No" : D
	estadd local cfe "Yes" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D

reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime   $x    			if sample==1 & nochangeshrink==1 , a($fe_state) vce(cluster $cl )
eststo E
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: E
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): E

	estadd local sfe "Yes" : E
	estadd local cpfe "No" : E
	estadd local cfe "No" : E
	estadd local yfe "Yes" : E
	estadd local ctrl "Yes" : E
	
	
reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime   $x    			if sample==1 & nochangeshrink==1 , a($fe_city) vce(cluster $cl )
eststo F
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: F
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): F

	estadd local sfe "No" : F
	estadd local cpfe "No" : F
	estadd local cfe "Yes" : F
	estadd local yfe "Yes" : F
	estadd local ctrl "Yes" : F

	
local name arr_city_shrink
estout A B C D E F  using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(cpfe sfe cfe yfe ctrl  N r2 ymean  pF_shrink pF, fmt(0 0 0 0 0 0 2 2 3 3) labels("City-period fixed effects" "State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N"  "\$R^2\$" "Dependent variable mean" "p-value for \$H_0:\beta_1+\beta_2=0\$" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" ) ///
	mgroups("Full sample" "\specialcell{Cities  with \\no variation in \$shrink\$}", pattern(1 0 1 0 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	varlabels(_cons Constant, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxshrink pblackxhprime hprime ) ///
	order(pblack pblackxshrink pblackxhprime hprime   ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
/// Table C4. Cross-city variation in shrink (fixed effect city_shrink is unique to city and value of shrink) - police spending

reghdfe exp_police pblack	pblackxshrink 	hprime shrink $x     if sample==1 , a(city_shrink year) vce(cluster $cl )

eststo A
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): A
	estadd local sfe "No" : A
	estadd local cpfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
	
reghdfe exp_police pblack	pblackxhprime	hprime   $x   		if sample==1 , a(city_shrink year) vce(cluster $cl)
eststo B
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B

	estadd local sfe "No" : B
	estadd local cpfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B

reghdfe exp_police pblack	pblackxshrink 	hprime shrink $x    if sample==1 & nochangeshrink==1, a($fe_state) vce(cluster $cl )
eststo C
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): C

	estadd local sfe "Yes" : C
	estadd local cpfe "No" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	
reghdfe exp_police pblack	pblackxshrink 	hprime shrink $x    if sample==1 & nochangeshrink==1, a($fe_city) vce(cluster $cl )
eststo D
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: D
	
	test pblack+pblackxshrink=0
	estadd scalar pF_shrink=r(p): D

	estadd local sfe "No" : D
	estadd local cpfe "No" : D
	estadd local cfe "Yes" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D

reghdfe exp_police pblack	pblackxhprime	hprime   $x    		if sample==1 & nochangeshrink==1 , a($fe_state) vce(cluster $cl )
eststo E
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: E
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): E

	estadd local sfe "Yes" : E
	estadd local cpfe "No" : E
	estadd local cfe "No" : E
	estadd local yfe "Yes" : E
	estadd local ctrl "Yes" : E
	
	
reghdfe exp_police pblack	pblackxhprime	hprime   $x    		if sample==1 & nochangeshrink==1 , a($fe_city) vce(cluster $cl )
eststo F
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: F
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): F

	estadd local sfe "No" : F
	estadd local cpfe "No" : F
	estadd local cfe "Yes" : F
	estadd local yfe "Yes" : F
	estadd local ctrl "Yes" : F
	
local name exp_city_shrink
estout A B C D E F  using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(cpfe sfe cfe yfe ctrl  N r2 ymean  pF_shrink pF, fmt(0 0 0 0 0 0 2 2 3 3) labels("City-period fixed effects" "State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N"  "\$R^2\$" "Dependent variable mean" "p-value for \$H_0:\beta_1+\beta_2=0\$" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) posthead("\midrule") prefoot("\midrule") label ///
	mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" ) ///
	mgroups("Full sample" "\specialcell{Cities  with \\no variation in \$shrink\$}", pattern(1 0 1 0 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	varlabels(_cons Constant, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxshrink pblackxhprime hprime ) ///
	order(pblack pblackxshrink pblackxhprime hprime   ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

 
	
/// Table C5. Other types of public spending

reghdfe exp_util pblack pblackxhprime hprime				$x    if sample==1  , a($fe_city ) vce(cluster $cl )
	eststo A_FE
	sum exp_util if e(sample)==1
	estadd scalar ymean=r(mean): A_FE
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE
	
	gen util_sample = e(sample)==1
	
reghdfe exp_util pblack pblackxhprime hprime				$x    if util_sample==1 , a($fe_state ) vce(cluster $cl )
	eststo A
	sum exp_util if e(sample)==1
	estadd scalar ymean=r(mean): A
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A


reghdfe exp_highway pblack pblackxhprime hprime				$x    if sample==1 , a($fe_city) vce(cluster $cl )
	eststo B_FE
	sum exp_highway if e(sample)==1
	estadd scalar ymean=r(mean): B_FE
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE
	
	gen highway_sample = e(sample)==1
		
reghdfe exp_highway pblack pblackxhprime hprime				$x    if highway_sample==1, a($fe_state) vce(cluster $cl )
	eststo B
	sum exp_highway if e(sample)==1
	estadd scalar ymean=r(mean): B
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B

reghdfe exp_pol_capcon pblack pblackxhprime hprime				$x if sample==1 , a($fe_city) vce(cluster $cl )
	eststo C_FE
	sum exp_pol_capcon if e(sample)==1
	estadd scalar ymean=r(mean): C_FE
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : C_FE
	estadd local sfe "No" : C_FE
	estadd local cfe "Yes" : C_FE
	estadd local yfe "Yes" : C_FE
	estadd local ctrl "Yes" : C_FE
	
	gen capcon_sample = e(sample)==1
	
reghdfe exp_pol_capcon pblack pblackxhprime hprime				$x if capcon_sample==1 , a($fe_state) vce(cluster $cl )
	eststo C
	sum exp_pol_capcon if e(sample)==1
	estadd scalar ymean=r(mean): C
	test pblack+pblackxhprime=0 
	estadd scalar pF_sum=r(p) : C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	
local name otherexp_shrink
estout A A_FE B B_FE C C_FE using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	mgroups( "\specialcell{Utilities}"  "\specialcell{Highways}"  "\specialcell{Police Capital}" , pattern(1 0 1 0 1 0  ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack  pblackxhprime  hprime) ///
	order(pblack pblackxhprime  hprime) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
/// Table C6. Placebo income measures -- distance between arrest rates

areg arr_drugsale_spread pblack pblackxmedhhinc_diff medhhinc_diff		$x  i.year   if sample==1 , a(fstate ) vce(cluster $cl )
	eststo C
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C

areg arr_drugsale_spread pblack pblackxp5010 p5010						$x  i.year  if sample==1 , a(fstate ) vce(cluster $cl )
	eststo D
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): D
	estadd local sfe "Yes" : D
	estadd local cfe "No" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D
	
areg arr_drugsale_spread pblack pblackxmedhhinc_diff medhhinc_diff		$x  i.year  if sample==1 , a(city ) vce(cluster $cl )
	eststo C_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): C_FE
	estadd local sfe "No" : C_FE
	estadd local cfe "Yes" : C_FE
	estadd local yfe "Yes" : C_FE
	estadd local ctrl "Yes" : C_FE

areg arr_drugsale_spread pblack pblackxp5010 p5010						$x  i.year   if sample==1 , a(city ) vce(cluster $cl )
	eststo D_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean): D_FE
	estadd local sfe "No" : D_FE
	estadd local cfe "Yes" : D_FE
	estadd local yfe "Yes" : D_FE
	estadd local ctrl "Yes" : D_FE
	
local name arr_otherincome
estout C C_FE D D_FE using `name'.tex, replace ///
	cells((b(fmt(4)star)) (se(fmt(4)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxmedhhinc_diff medhhinc_diff pblackxp5010 p5010) ///
	order(pblack pblackxmedhhinc_diff medhhinc_diff pblackxp5010 p5010) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

// Table C7. Placebo Income Measures -- Police spending

areg exp_police pblack pblackxmedhhinc_diff medhhinc_diff				$x  i.year  if sample==1 , a(fstate ) vce(cluster $cl )
	eststo A
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A

areg exp_police pblack pblackxp5010 	p5010							$x  i.year  if sample==1 , a(fstate) vce(cluster $cl )
	eststo B
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	
areg exp_police pblack pblackxmedhhinc_diff medhhinc_diff				$x  i.year  if sample==1 , a(city ) vce(cluster $cl )
	eststo A_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE

areg exp_police pblack pblackxp5010 p5010								$x  i.year  if sample==1 , a(city ) vce(cluster $cl )
	eststo B_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean): B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE
	

local name exp_otherincome
estout A A_FE B B_FE using `name'.tex, replace ///
	cells((b(fmt(4)star)) (se(fmt(4)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///	
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxmedhhinc_diff medhhinc_diff pblackxp5010 p5010) ///
	order(pblack pblackxmedhhinc_diff medhhinc_diff pblackxp5010 p5010) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

		
/// Table C8. Other races

* modify var labels
label variable hprime "\$hprime_b\$"
label variable pblackxshrink "Percent Black $\times$ \$shrink_b\$"
label variable pblackxhprime "Percent Black $\times$ \$hprime_b\$"

* modify covariates (to report all race coefficients in tables)
global xrace population pop2 phispanic punemployed pnohsdiploma pbachelors page65_up page0_24 pfemale medhhinc povertyrate seg_thiel

* use same sample across regressions
reghdfe exp_police pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw	$xrace   if sample==1 , a($fe_city) vce(cluster $cl )
gen otherrace_sample=(e(sample))==1 
	 
	
reghdfe arr_drugsale_spread_aw   pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw	 	$xrace  if otherrace_sample==1 , a($fe_state ) vce(cluster $cl )
eststo A
	sum arr_drugsale_spread_aw if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	test pasian+pasianxhprime=0
	estadd scalar pF=r(p): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe arr_drugsale_spread_aw  pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw		$xrace  if otherrace_sample==1 , a($fe_city) vce(cluster $cl )
eststo B
	sum arr_drugsale_spread_aw if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pasian+pasianxhprime=0
	estadd scalar pF=r(p): B
	estadd local sfe "No" : B
	estadd local cfe "Yes" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	
reghdfe arr_drugsale_spread_iw  pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw		$xrace  if otherrace_sample==1 , a($fe_state ) vce(cluster $cl )
eststo C
	sum arr_drugsale_spread_iw if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test paian+paianxhprime=0
	estadd scalar pF=r(p): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	
reghdfe arr_drugsale_spread_iw  pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw		$xrace if otherrace_sample==1 , a($fe_city) vce(cluster $cl )
eststo D
	sum arr_drugsale_spread_iw if e(sample)==1
	estadd scalar ymean=r(mean)	: D
	test paian+paianxhprime=0
	estadd scalar pF=r(p): D
	estadd local sfe "No" : D
	estadd local cfe "Yes" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D
	

reghdfe exp_police pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw						$xrace   if otherrace_sample==1 , a($fe_state ) vce(cluster $cl )
eststo E
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: E
	test pasian+pasianxhprime=0
	estadd scalar pF=r(p): E
	estadd local sfe "Yes" : E
	estadd local cfe "No" : E
	estadd local yfe "Yes" : E
	estadd local ctrl "Yes" : E
	
reghdfe exp_police pblack pasian paian pblackxhprime pasianxhprime paianxhprime hprime hprime_aw hprime_aiw						$xrace   if otherrace_sample==1 , a($fe_city) vce(cluster $cl )
eststo F
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: F
	test pasian+pasianxhprime=0
	estadd scalar pF=r(p): F
	estadd local sfe "No" : F
	estadd local cfe "Yes" : F
	estadd local yfe "Yes" : F
	estadd local ctrl "Yes" : F

	
local name arr_otherrace
estout A B C D E F   using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	mlabels(none) ///
	mgroups("\specialcell{Distance between \\White and Asian \\ Arrest Rates}" "\specialcell{Distance between \\ White and AI/AN \\Arrest Rates}" "\specialcell{Police Spending}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	varlabels(_cons Constant, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxhprime  pasian pasianxhprime paian paianxhprime  hprime hprime_aw hprime_aiw) ///
	order(pblack pblackxhprime  pasian pasianxhprime paian paianxhprime  hprime hprime_aw hprime_aiw)  ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

// modify var labels (back to original)
label variable hprime "\$hprime\$"
label variable pblackxshrink "Percent Black $\times$ \$shrink\$"
label variable pblackxhprime "Percent Black $\times$ \$hprime\$"


/// Table 1 in Online Appendix: Alternative specifications

areg arr_drugsale_spread pblack pblackxhprime hprime  	$x		i.fstate#c.year i.year if sample==1,  a(fstate ) vce(cluster $cl )
	eststo A
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local str "Yes" : A
	estadd local controls "Yes": A
	
areg arr_drugsale_spread pblack pblackxhprime hprime  	$x		i.fstate#c.year i.year if sample==1,  a(city) vce(cluster $cl )
	eststo B
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B
	estadd local sfe "No" : B
	estadd local cfe "Yes" : B
	estadd local yfe "Yes" : B
	estadd local str "Yes" : B
	estadd local controls "Yes": B
	
reghdfe logarr_drugsale_spread pblack pblackxhprime	hprime	$x     if sample==1,  a($fe_state ) vce(cluster $cl )
	eststo C
	sum logarr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local str "No" : C
	estadd local controls "Yes": C
	
reghdfe logarr_drugsale_spread pblack pblackxhprime	hprime	$x     if sample==1,  a($fe_city) vce(cluster $cl )
	eststo D
	sum logarr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: D
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): D
	estadd local sfe "No" : D
	estadd local cfe "Yes" : D
	estadd local yfe "Yes" : D
	estadd local str "No" : D
	estadd local controls "Yes": D	
	
areg exp_police pblack pblackxhprime hprime 		$x  i.fstate#c.year	i.year	 if sample==1,  a(fstate ) vce(cluster $cl )
	eststo E
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: E
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): E
	estadd local sfe "Yes" : E
	estadd local cfe "No" : E
	estadd local yfe "Yes" : E
	estadd local str "Yes" : E
	estadd local controls "Yes": E


areg exp_police pblack pblackxhprime hprime 		$x  i.fstate#c.year	i.year	 if sample==1,  a(city) vce(cluster $cl )
	eststo F
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: F
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): F
	estadd local sfe "No" : F
	estadd local cfe "Yes" : F
	estadd local yfe "Yes" : F
	estadd local str "Yes" : F
	estadd local controls "Yes": F
	
reghdfe logexp_police pblack pblackxhprime hprime  	$x	  if sample==1,  a($fe_state ) vce(cluster $cl )
	eststo G
	sum logexp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: G
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): G
	estadd local sfe "Yes" : G
	estadd local cfe "No" : G
	estadd local yfe "Yes" : G
	estadd local str "No" : G
	estadd local controls "Yes": G
	
reghdfe logexp_police pblack pblackxhprime hprime  	$x	  if sample==1,  a($fe_city) vce(cluster $cl )
	eststo H
	sum logexp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: H
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): H
	estadd local sfe "No" : H
	estadd local cfe "Yes" : H
	estadd local yfe "Yes" : H
	estadd local str "No" : H
	estadd local controls "Yes": H
	
local name robust
estout A B C D E F G H  using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(str sfe cfe yfe controls  N  r2 ymean  pF, fmt(0 0 0 0 0 0 2 2 3) labels("State time trends" "State Fixed Effects" "City Fixed Effects" "Year Fixed Effects" "Controls" "N"  "\$R^2\$" "Dependent variable mean" "p-value for \$H_0:\pi_1+\pi_2=0\$")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	mgroups("\specialcell{Dist. between \\Arrest Rates}" "\specialcell{Log of \\Dist. between \\ Arrest Rates}" "\specialcell{Police\\Spending}" "\specialcell{Log of\\Police\\ Spending}"  , pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	order(pblack pblackxhprime hprime) ///
	keep(pblack pblackxhprime hprime) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 

	
/// Table 3 in the Online Appendix:  Additional Controls -- distance between arrest rates

reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime	 repmayor 		$x  if sample==1 , a($fe_city ) vce(cluster $cl )
eststo A_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE
	
	gen repmayor_sample=(e(sample)==1)
	
reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime	  			    $x  if repmayor_sample==1, a($fe_state ) vce(cluster $cl )
eststo A_0
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A_0
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A_0
	estadd local sfe "Yes" : A_0
	estadd local cfe "No" : A_0
	estadd local yfe "Yes" : A_0
	estadd local ctrl "Yes" : A_0
	
reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime	 repmayor 		$x  if repmayor_sample==1 , a($fe_state ) vce(cluster $cl )
eststo A
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime	 mayor_b 		$x  if sample==1 , a($fe_city ) vce(cluster $cl )
eststo B_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE
	
	gen mayor_sample=(e(sample)==1)
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime	  					 $x if mayor_sample==1  , a($fe_state ) vce(cluster $cl )
eststo B_0
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B_0
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B_0
	estadd local sfe "Yes" : B_0
	estadd local cfe "No" : B_0
	estadd local yfe "Yes" : B_0
	estadd local ctrl "Yes" : B_0
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime	 mayor_b 			 $x if mayor_sample==1  , a($fe_state ) vce(cluster $cl )
eststo B
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
		

reghdfe arr_drugsale_spread pblack	pblackxhprime hprime	 swornpolpblack 	$x  if sample==1 , a($fe_city ) vce(cluster $cl )
eststo C_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_FE
	estadd local sfe "No" : C_FE
	estadd local cfe "Yes" : C_FE
	estadd local yfe "Yes" : C_FE
	estadd local ctrl "Yes" : C_FE
	
	gen sworn_sample=(e(sample)==1)
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime	  						$x if sworn_sample==1  , a($fe_state ) vce(cluster $cl )
eststo C_0
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C_0
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_0
	estadd local sfe "Yes" : C_0
	estadd local cfe "No" : C_0
	estadd local yfe "Yes" : C_0
	estadd local ctrl "Yes" : C_0
		

		
reghdfe arr_drugsale_spread pblack pblackxhprime hprime	 swornpolpblack 		$x if sworn_sample==1  , a($fe_state ) vce(cluster $cl )
eststo C
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C

local name arr_otherx
estout A_0 A A_FE B_0 B B_FE C_0 C C_FE using `name'.tex, replace ///
	title(Panel B: Distance Between Arrest Rates) ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) ///
	modelwidth(12) /// 
	delimiter(&) ///
	end(\\) ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	label ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	varlabels(_cons Constant, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	substitute(_ \_ "\_cons " \_cons) ///
	interaction(" $\times$ ") ///
	level(95) ///
	style(esttab) ///
	keep(pblack  pblackxhprime  hprime repmayor mayor_b swornpolpblack ) ///
	order(pblack  pblackxhprime  hprime repmayor mayor_b swornpolpblack ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	
	
/// Table 4 in the Online Appendix:  Additional Controls -- police spending

reghdfe exp_police pblack pblackxhprime	hprime	 repmayor 		$x  if sample==1 , a($fe_city ) vce(cluster $cl )
eststo A_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE
	
reghdfe exp_police pblack pblackxhprime	hprime	  		$x  		if repmayor_sample==1, a($fe_state ) vce(cluster $cl )
eststo A_0
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A_0
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A_0
	estadd local sfe "Yes" : A_0
	estadd local cfe "No" : A_0
	estadd local yfe "Yes" : A_0
	estadd local ctrl "Yes" : A_0
	
reghdfe exp_police pblack pblackxhprime	hprime	 repmayor 		$x  if repmayor_sample==1 , a($fe_state ) vce(cluster $cl )
eststo A
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe exp_police pblack pblackxhprime	hprime	 mayor_b 		$x  if sample==1 , a($fe_city ) vce(cluster $cl )
eststo B_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE
	

reghdfe exp_police pblack pblackxhprime hprime	  			$x 			if mayor_sample==1  , a($fe_state ) vce(cluster $cl )
eststo B_0
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B_0
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B_0
	estadd local sfe "Yes" : B_0
	estadd local cfe "No" : B_0
	estadd local yfe "Yes" : B_0
	estadd local ctrl "Yes" : B_0
	
reghdfe exp_police pblack pblackxhprime hprime	 mayor_b 	$x 			if mayor_sample==1  , a($fe_state ) vce(cluster $cl )
eststo B
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
		

reghdfe exp_police pblack pblackxhprime	hprime	 swornpolpblack 		$x  if sample==1 , a($fe_city ) vce(cluster $cl )
eststo C_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_FE
	estadd local sfe "No" : C_FE
	estadd local cfe "Yes" : C_FE
	estadd local yfe "Yes" : C_FE
	estadd local ctrl "Yes" : C_FE

reghdfe exp_police pblack pblackxhprime hprime	  							$x  if sworn_sample==1  , a($fe_state ) vce(cluster $cl )
eststo C_0
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C_0
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_0
	estadd local sfe "Yes" : C_0
	estadd local cfe "No" : C_0
	estadd local yfe "Yes" : C_0
	estadd local ctrl "Yes" : C_0
		

		
reghdfe exp_police pblack pblackxhprime hprime	 swornpolpblack 			$x  if sworn_sample==1  , a($fe_state ) vce(cluster $cl )
eststo C
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C

local name exp_otherx
estout A_0 A A_FE B_0 B B_FE C_0 C C_FE using `name'.tex, replace ///
	title(Panel B: Distance Between Arrest Rates) ///
	cells((b(fmt(2)star)) (se(fmt(2)par)star)) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	varlabels(, end("" \addlinespace) nolast) /// numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack  pblackxhprime  hprime repmayor mayor_b swornpolpblack ) ///
	order(pblack  pblackxhprime  hprime repmayor mayor_b swornpolpblack ) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	
	
/// Table 5 in the Online Appendix: check that interaction effects are statistically insignificant	
	
label variable prejudice_state "high animus"
label variable rpban "RP ban"
label variable seg_high "High Seg."

gen pblackxprej=pblack*prejudice_state
gen pblackxhprimexprej=pblack*hprime*prejudice_state

gen pblackxrpban=pblack*rpban
gen pblackxhprimexrpban=pblack*hprime*rpban

gen pblackxseg=pblack*seg_high
gen pblackxhprimexseg=pblack*hprime*seg_high

label variable pblackxprej "Percent Black $\times$ high animus"
label variable pblackxhprimexprej "Percent Black  $\times$ \$hprime\$ $\times$ high animus"

label variable pblackxrpban "Percent Black $\times$ RP ban"
label variable pblackxhprimexrpban "Percent Black  $\times$ \$hprime\$ $\times$  RP ban"

label variable pblackxseg "Percent Black $\times$ high seg."
label variable pblackxhprimexseg "Percent Black  $\times$ \$hprime\$ $\times$ high seg."


reghdfe arr_drugsale_spread pblack pblackxhprime hprime  pblackxprej pblackxhprimexprej   	$x   if sample==1 , a($fe_city ) vce(cluster $cl )
eststo A
	sum exp_util if e(sample)==1
	estadd scalar ymean=r(mean): A
	estadd local sfe "No" : A
	estadd local cfe "Yes" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime  pblackxrpban pblackxhprimexrpban   $x   if sample==1 , a($fe_city ) vce(cluster $cl )
eststo B
	sum exp_util if e(sample)==1
	estadd scalar ymean=r(mean): B
	estadd local sfe "No" : B
	estadd local cfe "Yes" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime  pblackxseg pblackxhprimexseg 		$x   if sample==1 , a($fe_city ) vce(cluster $cl )
eststo C
	sum exp_util if e(sample)==1
	estadd scalar ymean=r(mean): C
	estadd local sfe "No" : C
	estadd local cfe "Yes" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	

local name interaction_check
estout A B C using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean, fmt(0 0 0 0 0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls" "N" "\$R^2\$" "Dependent variable mean" )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	mlabels(none) ///
	numbers(\multicolumn{@span}{c}{( )}) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	interaction(" $\times$ ") ///
	drop($x _cons) ///
	order(pblack pblackxhprime hprime) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	
/// Table 6 in the Online Appendix: Alternative explanations 
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==1, a($fe_state ) vce(cluster $cl )
eststo A
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)

reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==1, a($fe_city ) vce(cluster $cl )
eststo A_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==0, a($fe_state ) vce(cluster $cl )
eststo B
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	

reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & prejudice_state==0, a($fe_city ) vce(cluster $cl )
eststo B_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	

	
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==1, a($fe_state ) vce(cluster $cl )
eststo C
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==1, a($fe_city ) vce(cluster $cl )
eststo C_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)
	
	
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==0, a($fe_state ) vce(cluster $cl )
eststo D
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & rpban==0, a($fe_city ) vce(cluster $cl )
eststo D_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)

	
reghdfe exp_police pblack	pblackxhprime hprime		        $x   if sample==1 & seg_high==1, a($fe_state ) vce(cluster $cl )
eststo E
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)
	
reghdfe exp_police pblack	pblackxhprime hprime		        $x   if sample==1 & seg_high==1, a($fe_city ) vce(cluster $cl )
eststo E_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)
		
reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & seg_high==0, a($fe_state ) vce(cluster $cl )
eststo F
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)

reghdfe exp_police pblack	pblackxhprime hprime		    	$x   if sample==1 & seg_high==0, a($fe_city ) vce(cluster $cl )
eststo F_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)

local name exp_altexp
estout A B C D E F using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(N r2 ymean, fmt(0 2 2) labels("N" "\$R^2\$" "Dependent variable mean")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	prehead("& \multicolumn{6}{c}{\specialcell{ \textit{Panel A: State and year fixed effects}}} \vspace{2mm} \\") ///
	mgroups("\specialcell{Racial Animus}" "\specialcell{Racial\\Profiling Ban}"  "\specialcell{Segregation}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels("\$High\$" "\$Low\$" "\$Yes\$" "\$No\$" "\$High\$" "\$Low\$", titles span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) ///
	style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	

estout A_FE B_FE C_FE D_FE E_FE F_FE using `name'.tex, append ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(N r2 ymean, fmt(0 2 2) labels("N" "\$R^2\$" "Dependent variable mean")) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	prehead("& \multicolumn{6}{c}{\specialcell{~\\ \textit{Panel B: City and year fixed effects}}} \vspace{2mm} \\") ///
	mgroups("\specialcell{Racial Animus}" "\specialcell{Racial\\Profiling Ban}"  "\specialcell{Segregation}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels("\$High\$" "\$Low\$" "\$Yes\$" "\$No\$" "\$High\$" "\$Low\$", titles span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
    starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	

	
// Table 2 in the online appendix

// load full dataset
***Edited by Annie Qian
cd "../$InputPath/"
***
use city_sample.dta, clear

cd "../$TablesPath/"
foreach i in 0 5000 25000 50000 100000 {
	gen sample_`i'=1  if  pblack>.01  & pblack!=. & pwhite>.01 & pwhite!=. & population>=`i' & population!=. & exp_police!=. & exp_police>0 & shrink!=.  & arr_drugsale_spread!=.
	}
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime		   		$x   if sample_0==1, a($fe_city) vce(cluster $cl)
	eststo A_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE
	
	replace sample_0=0 if e(sample)!=1
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime		 		$x   if sample_5000==1, a($fe_city ) vce(cluster $cl)
	eststo B_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE

	replace sample_5000=0 if e(sample)!=1
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime			   	$x  if sample_25000==1, a($fe_city) vce(cluster $cl)
	eststo C_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_FE
	estadd local sfe "No" : C_FE
	estadd local cfe "Yes" : C_FE
	estadd local yfe "Yes" : C_FE
	estadd local ctrl "Yes" : C_FE
	
	replace sample_25000=0 if e(sample)!=1
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime				$x  if sample_50000==1, a($fe_city) vce(cluster $cl)
	eststo D_FE
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: D_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): D_FE
	estadd local sfe "No" : D_FE
	estadd local cfe "Yes" : D_FE
	estadd local yfe "Yes" : D_FE
	estadd local ctrl "Yes" : D_FE
	
	replace sample_50000=0 if e(sample)!=1
	
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime		   		$x   if sample_0==1, a($fe_state) vce(cluster $cl )
	eststo A
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime		 		$x   if sample_5000==1, a($fe_state ) vce(cluster $cl)
	eststo B
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime			   	$x  if sample_25000==1, a($fe_state ) vce(cluster $cl )
	eststo C
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	
reghdfe arr_drugsale_spread pblack pblackxhprime hprime				$x  if sample_50000==1, a($fe_state ) vce(cluster $cl)
	eststo D
	sum arr_drugsale_spread if e(sample)==1
	estadd scalar ymean=r(mean)	: D
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): D
	estadd local sfe "Yes" : D
	estadd local cfe "No" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D

	
local name exp_relaxpop
estout A A_FE B B_FE C C_FE D D_FE using `name'.tex, replace ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean  , fmt(0 0 0 0  0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls"  "N" "\$R^2\$" "Dep. variable mean"  )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	prehead("& \multicolumn{8}{c}{\textit{Panel A: Distance between Arrest Rates}} \vspace{2mm} \\") ///
	mgroups("\specialcell{All}" "\specialcell{$>2500$}" "\specialcell{$>25000$}" "\specialcell{$>50000$}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	
	
reghdfe exp_police pblack pblackxhprime hprime		   		$x   if sample_0==1,  a($fe_city) vce(cluster $cl )
	eststo A_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A_FE
	estadd local sfe "No" : A_FE
	estadd local cfe "Yes" : A_FE
	estadd local yfe "Yes" : A_FE
	estadd local ctrl "Yes" : A_FE

reghdfe exp_police pblack pblackxhprime hprime		 		$x   if sample_5000==1, a($fe_city ) vce(cluster $cl )
	eststo B_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B_FE
	estadd local sfe "No" : B_FE
	estadd local cfe "Yes" : B_FE
	estadd local yfe "Yes" : B_FE
	estadd local ctrl "Yes" : B_FE

reghdfe exp_police pblack pblackxhprime hprime			   	$x  if sample_25000==1, a($fe_city ) vce(cluster $cl )
	eststo C_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C_FE
	estadd local sfe "No" : C_FE
	estadd local cfe "Yes" : C_FE
	estadd local yfe "Yes" : C_FE
	estadd local ctrl "Yes" : C_FE

reghdfe exp_police pblack pblackxhprime hprime				$x  if sample_50000==1, a($fe_city) vce(cluster $cl )
	eststo D_FE
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: D_FE
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): D_FE
	estadd local sfe "No" : D_FE
	estadd local cfe "Yes" : D_FE
	estadd local yfe "Yes" : D_FE
	estadd local ctrl "Yes" : D_FE

reghdfe exp_police pblack pblackxhprime hprime		   		$x   if sample_0==1,  a($fe_state ) vce(cluster $cl )
	eststo A
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: A
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): A
	estadd local sfe "Yes" : A
	estadd local cfe "No" : A
	estadd local yfe "Yes" : A
	estadd local ctrl "Yes" : A
	
reghdfe exp_police pblack pblackxhprime hprime		 		$x   if sample_5000==1, a($fe_state ) vce(cluster $cl )
	eststo B
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: B
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): B
	estadd local sfe "Yes" : B
	estadd local cfe "No" : B
	estadd local yfe "Yes" : B
	estadd local ctrl "Yes" : B
	
reghdfe exp_police pblack pblackxhprime hprime			   	$x  if sample_25000==1, a($fe_state ) vce(cluster $cl )
	eststo C
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: C
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): C
	estadd local sfe "Yes" : C
	estadd local cfe "No" : C
	estadd local yfe "Yes" : C
	estadd local ctrl "Yes" : C
	
reghdfe exp_police pblack pblackxhprime hprime				$x  if sample_50000==1, a($fe_state ) vce(cluster $cl)
	eststo D
	sum exp_police if e(sample)==1
	estadd scalar ymean=r(mean)	: D
	test pblack+pblackxhprime=0
	estadd scalar pF=r(p): D
	estadd local sfe "Yes" : D
	estadd local cfe "No" : D
	estadd local yfe "Yes" : D
	estadd local ctrl "Yes" : D

	
//local name arr_relaxpop
local name exp_relaxpop
estout A A_FE B B_FE C C_FE D D_FE using `name'.tex, append ///
	cells((b(fmt(2)star)) (se(fmt(2)par))) ///
	stats(sfe cfe yfe ctrl N r2 ymean  , fmt(0 0 0 0  0 2 2) labels("State fixed effects" "City fixed effects" "Year fixed effects" "Controls"  "N" "\$R^2\$" "Dep. variable mean"  )) ///
	varwidth(12) modelwidth(12) delimiter(&) end(\\) ///
	posthead("\midrule") prefoot("\midrule") label ///
	varlabels(, end("" \addlinespace) nolast) ///
	prehead("& \multicolumn{8}{c}{\specialcell{~\\ \textit{Panel B: Police Spending}}} \vspace{2mm} \\") ///
	mgroups("\specialcell{All}" "\specialcell{$>2500$}" "\specialcell{$>25000$}" "\specialcell{$>50000$}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
	collabels(none) ///
	eqlabels(, begin("\midrule" "") nofirst) ///
	level(95) style(esttab) ///
	keep(pblack pblackxhprime hprime) ///
	order(pblack pblackxhprime hprime) ///
	starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01, label(" \(p<@\)")) 
	