
use Data_AEJ_Replication.dta,clear
set more off
global user="."
*global user="."
local work="."

cd "$user"
global date="09-09-2013"

//lists of controls
global controls_short="log_distance_full logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2  r1-r5" 
global controls_short_IV="log_distance_full logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2 r1-r5" 

//global controls_short="r1-r5 logpop log_Croats log_Serbs disable_share2 ec_active prim_share second_share log_distance_full male_share youth_share senior_share catholic_share orthodox_share"
global controls_long= "log_distance_full logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2 war mon name_of_the_streets_c name_of_the_streets_i pivo_S r1-r5 bliz"
global controls_long_IV="log_distance_full logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2 war mon name_of_the_streets_c name_of_the_streets_i pivo_S r1-r5 bliz"


//outreg file names
global Nazi_share_file="nazi_"+"$date"+".xls"
global others_share_file="others_"+"$date"+".xls"
global hdz_share_file="hdz_"+"$date"+".xls"
global sdp_share_file="sdp_"+"$date"+".xls"
global turnout_file="turnout_"+"$date"+".xls"
global graffiti_file="graffiti_"+"$date"+".xls"
global graffiti_file_OLS="graffiti_OLS_"+"$date"+".xls"
global venec_file="venec_"+"$date"+".xls"
global availability_file="availability_"+"$date"+".xls"
global interaction_file="interaction_"+"$date"+".xls"
global out_file="out_"+"$date"+".xls"
global out_file_linear="out_"+"$date"+"_linear"+".xls"
global out_file_linear_2003="out_2003_"+"$date"+"_linear"+".xls"
global out_file_linear_2011="out_2011_"+"$date"+"_linear"+".xls"
global out_file_robustness="out_"+"$date"+"_linear"+".xls"
global File_2003_2011="File_2003_2011"+"$date"+".xls"
global baseline_file="baseline_"+"$date"+".xls"
global others_share_out="others_out_"+"$date"+".xls"
global turnout_out="turnout_out_"+"$date"+".xls"
global AET_file="AET_main"+"$date"+".xls"
global Robustness_file_main ="robustness_main"+"$date"+".xls"


local q=""

local xxx=subinstr("$controls_short_IV"," r1-r5","",1)
global controls_short_list=subinstr("`xxx'"," ","=",.)

local xxx=subinstr("$controls_long_IV"," r1-r5","",1)
global controls_long_list=subinstr("`xxx'"," ","=",.)

global controls_short_list_nod=subinstr("$controls_short_list","log_distance_full=","",1)
global controls_long_list_nod=subinstr("$controls_long_list","log_distance_full=","",1)
global controls_long_list_nod=subinstr("$controls_long_list_nod","=bliz","",1)

global controls_short_geo_list="log_distance_full"
global controls_long_geo_list="log_distance_full=bliz_forest"
global controls_manual_list="war=mon=name_of_the_streets_c=name_of_the_streets_i=pivo_S"



local l=length("$controls_long_list")-5
global controls_long_list=substr("$controls_long_list",1,`l')

** Dummies for quantiles of signal strength in baseline sample
qui centile s1 if radio1!=., centile(20(20)80) 
forvalues x =1/4 {
gen byte s_dum_`x'=(s1>=r(c_`x'))
}



local cond="[aweight=people_listed]"

*******************************************************************************************************
*Table 2 Panel A

local opt="replace"
local i=1 
		reg radio`i'  $controls_long `cond',  cluster (Opsina2)
		test $controls_long_list_nod=0
		outreg2 using $availability_file, replace bracket se lab nocons drop (r1 r2) bdec(3) addstat("p-value of F-stat for other controls", r(p),"F-stat for other controls", r(F))
* controls_short
	foreach list in controls_long {
		reg radio`i' s`i' $`list' `cond',  cluster (Opsina2)

		test s`i'=0
		local p_elev=r(p)
		local F_elev=r(F)
		local F_forest=0
		local p_forest=0
		
		if !regexm("`list'","short") {
			reg radio`i' s`i' $`list',  cluster (Opsina2)

			test s`i'=bliz_f=0 
			local F_forest=r(F)
			local p_forest=r(p)
		}
		test $`list'_list=0
		outreg2 using $availability_file, append bracket se lab nocons drop (r1 r2)  bdec(3) addstat("p-value of F-stat for signal strength", `p_elev', "F-stat for signal strength", `F_elev', "p-value of F-stat for signal strength and forest", `p_forest', "F-stat for signal strength and forest", `F_forest',"p-value of F-stat for other controls", r(p),"F-stat for other controls", r(F))
	}
	
		reg s1  $controls_long `cond',  cluster (Opsina2)
		test $controls_long_list_nod=0
		outreg2 using $availability_file, append bracket se lab nocons drop (r1 r2)  bdec(4) addstat("p-value of F-stat for other controls", r(p),"F-stat for other controls", r(F))
	
		reg s1 $controls_short `cond' if Nazi_share!=. & distance<75,  cluster (Opsina2)

		test $controls_short_list_nod=0
		outreg2 using $availability_file, append bracket se lab nocons drop (r1 r2)  bdec(3) addstat("p-value of F-stat for other controls", r(p),"F-stat for other controls", r(F))
	



*** Table 2, Panel B

local opt="replace"

qui reg radio1   $controls_long `cond'
predict radio1_p, xb
label var radio1_p "AET all, binary"
qui reg s1   $controls_long `cond'
predict s1_p, xb
label var s1_p "AET all, strength"
reg  Nazi_share radio1_p `cond', cluster (Opsina2)
outreg2 using $AET_file, `opt' bdec(3) bracket se lab nocons 
local opt="append"
reg  Nazi_share s1_p if radio1!=. `cond', cluster (Opsina2)
outreg2 using $AET_file, `opt' bdec(3) bracket se lab nocons 




qui reg s1 $controls_short `cond'
predict s1_pp if e(sample), xb
label var s1_pp "AET census and geographical"
reg  Nazi_share s1_pp if distance<75 `cond', cluster (Opsina2)
outreg2 using $AET_file, `opt' bdec(3) bracket se lab nocons 





********************************************************************************************************
*Table for the shares of parties in main sample (TABLE 3)

quietly sum s1 if radio1!=.
local s_sd1=r(sd)

local coef_radio=0.313
local coef_predict=2.534
local coef_linear=51.325

foreach dep_var in Nazi_share  {
	local opt="replace"
	forval i=1/1 {	
	local temp="`dep_var'_file"
				
	*OLS with regions and geography only 
	
			reg `dep_var' radio`i'  log_distance_full  r1-r5 `cond', cluster (Opsina2)
			//persuasion rates
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)
			drop tmp	
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)
			local ATT=_b[radio`i']/`coef_radio'			
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  addstat ("Persuasion rates", `persuasion_rate', "ATT", `ATT') drop (r1-r5) //keep (radio`i')
			local opt="append"
	
	*OLS with all the controls
	
		foreach list in  controls_short controls_long {
			eststo `list': reg `dep_var' radio`i'   $`list' `cond', cluster (Opsina2)
			quietly test $controls_short_list=0
			local F1=r(F)
			local p1=r(p)
			quietly test $`list'_geo_list=0
			local F2=r(F)
			local p2=r(p)
//			if !regexm("`list'","short") {		
			//	quietly test log_elevation_full=bliz=log_distance_full=0
			//	local F2=r(F)
			//	local p2=r(p)
			//}
			local F3=0
			local p3=0
			if regexm("`list'","long") {
				test $controls_manual_list=0
				local F3=r(F)
				local p3=r(p)
			}
			//persuasion rates
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
						
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)		
			local ATT=_b[radio`i']/`coef_radio'
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'			
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  addstat ("F-stat, census", `F1',"F-stat, geographic",`F2', "F-stat, manual", `F3',"p-value, census", `p1',"p-value, geographic", `p2',"p-value, manual", `p3',   "Persuasion rates", `persuasion_rate', "ATT", `ATT') drop (r1-r5) //keep (radio`i')
			local opt="append"	
		}
		
		*Two dummies for radio availability
		local list="controls_long"
			reg `dep_var' radio1 radio2 $`list' `cond', cluster (Opsina2)
			quietly test $controls_short_list=0
			local F1=r(F)
			local p1=r(p)
			quietly test $`list'_geo_list=0
			local F2=r(F)
			local p2=r(p)
//			if !regexm("`list'","short") {		
			//	quietly test log_elevation_full=bliz=log_distance_full=0
			//	local F2=r(F)
			//	local p2=r(p)
			//}
			local F3=0
			local p3=0
			if regexm("`list'","long") {
				test $controls_manual_list=0
				local F3=r(F)
				local p3=r(p)
			}
			//persuasion rates
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)
			drop tmp		
						
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)			
			local ATT=_b[radio`i']/`coef_radio'
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  addstat ("F-stat, census", `F1',"F-stat, geographic",`F2', "F-stat, manual", `F3',"p-value, census", `p1',"p-value, geographic", `p2',"p-value, manual", `p3', "Persuasion rates", `persuasion_rate', "ATT", `ATT') drop (r1-r5) //keep (radio`i')
	
		*Reduced form, linear in  signal strength
			reg `dep_var' s`i'_1   log_distance_full  r1-r5  `cond' if radio1!=., cluster (Opsina2)
					
			qui sum  s`i'_1
			local sd`i'_1=r(sd)
			local sd_effect=`sd`i'_1'*_b[ s`i'_1]
			
			//persuasion rates
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i'_1]*s`i'_1
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)*`turn'
			drop tmp 
			local ATT=_b[s`i'_1]/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'_1])/(`share_to_be_persuaded'*`coef_linear')
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  addstat ( "Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "ATT", `ATT')  drop(r1-r5) //keep (ss`i')
						
		foreach list in controls_short controls_long {
			reg `dep_var' s`i'_1 $`list' `cond'  if radio1!=., cluster (Opsina2)
			quietly test $controls_short_list=0
			local F1=r(F)
			local p1=r(p)
			quietly test $`list'_geo_list=0
			local F2=r(F)
			local p2=r(p)
			local F3=0
			local p3=0
			if regexm("`list'","long") {
				test $controls_manual_list=0
				local F3=r(F)
				local p3=r(p)
			}
			
			qui sum  s`i'_1
			local sd`i'_1=r(sd)
			local sd_effect=`sd`i'_1'*_b[ s`i'_1]
			
			//persuasion rates
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i'_1]*s`i'_1
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)*`turn'
			
			drop tmp 
			local ATT=_b[s`i'_1]/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'_1])/(`share_to_be_persuaded'*`coef_linear')
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  addstat ("F-stat, census", `F1',"F-stat, geographic",`F2', "F-stat, manual", `F3',"p-value, census", `p1',"p-value, geographic", `p2',"p-value, manual", `p3', "Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "ATT", `ATT')  drop(r1-r5) 
		}
	}
}
*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*******************************************************************************************************
***Table 4 (and Table 4 in Online Appendix)

local opt="replace"
foreach dep_var in Nazi_share hdz_share  sdp_share turnout{
	forval i=1/1 {

		reg `dep_var' radio`i'  $controls_long `cond', cluster (Opsina2)
		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)
			drop tmp
di "share to be persuaded  " `share_to_be_persuaded'
			local ATT=_b[radio`i']/`coef_radio'		
			
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
	
		outreg2 using $baseline_file, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "Persuasion rates", `persuasion_rate', "ATT", `ATT')

		local opt="append"


		reg `dep_var' s`i' $controls_long `cond', cluster (Opsina2)

		//effect of 1 sd change
			qui sum  s`i'_1
			local sd`i'=r(sd)
			local sd_effect=`sd`i''*_b[ s`i']
		
		// persuasion rate
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i']*s`i'
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)*`turn'
			di "share to be persuaded  " `share_to_be_persuaded'			
			local ATT=_b[s`i']/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'])/(`share_to_be_persuaded'*`coef_linear')			
			drop tmp
			
		outreg2 using $baseline_file, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
		local opt="append"
		
			
	}
}

***************************************************************************
*Table 5

local cond=""

local coef_linear=51.325

eststo clear
foreach dep_var in graffiti {
	local temp="`dep_var'_file"
	local opt="replace"
	forval i=1/1 {
	
	*No controls
			eststo: dprobit `dep_var' radio`i'  log_distance_full  r1-r5  `cond', cluster (Opsina2) 
		outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  
			local opt="append"	
	
	*Actual availability		
		foreach list in controls_short controls_long {
			eststo: dprobit `dep_var' radio`i' $`list'  `cond', cluster (Opsina2) 			
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons   
			local opt="append"
		}	
		
	*BOth dummies at the same time	
			local list="controls_long"
			dprobit `dep_var' radio1 radio2 $`list' `cond', cluster (Opsina2)
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons   
			local opt="append"		
				
	*Signal strength
	
			dprobit `dep_var' s`i'  log_distance_full  r1-r5 `cond', cluster (Opsina2)   
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  	
			foreach list in controls_short controls_long {
			dprobit `dep_var' s`i' $`list'  `cond', cluster (Opsina2) 
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons 	
				}

	}
}
*** EDITED by Ryan
estout using "../../results/table5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***


*******************************************************************************************************
*Table 6
 
*Robustness to controlling for Hungarian Radio
local opt="replace"
local i=1
reg Nazi_share radio_hung  radio1 $controls_long  `cond', cluster (Opsina2)
		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio_hung]*radio_hung
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
			local ATT=_b[radio`i']/`coef_radio'	
		
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio_hung]/`coef_radio'	
	

		outreg2 using $Robustness_file_main, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "Persuasion rates", `persuasion_rate', "ATT", `ATT')
		local opt="append"

reg Nazi_share hung1  s1 $controls_long  `cond', cluster (Opsina2)
		
			//persuasion rates
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i']*s`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)*`turn'

			drop tmp 
			local ATT=_b[s`i']/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'])/(`share_to_be_persuaded'*`coef_linear')
	outreg2 using $Robustness_file_main, `opt' bdec(3) bracket se lab nocons drop(r1-r5)   addstat( "Persuasion rates", `persuasion_rate',  "ATT", `ATT')	



*Controlling for  Croatian radio signal strength 
local i=1
	
	reg Nazi_share radio1 eloss5050powerHKR  eloss5050powerHR1   $controls_long `cond', cluster (Opsina2)
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
			local ATT=_b[radio`i']/`coef_radio'	
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	

	outreg2 using $Robustness_file_main, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Persuasion rates", `persuasion_rate',  "ATT", `ATT')  	

	reg Nazi_share s1 eloss5050powerHKR  eloss5050powerHR1  $controls_long `cond', cluster (Opsina2)
			//persuasion rates
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i']*s`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)*`turn'

			drop tmp 
			local ATT=_b[s`i']/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'])/(`share_to_be_persuaded'*`coef_linear')
	outreg2 using $Robustness_file_main, `opt' bdec(3) bracket se lab nocons drop(r1-r5)   addstat( "Persuasion rates", `persuasion_rate',  "ATT", `ATT')	


**Spacial correlation is done in a separate file


*Controlling for  free-space loss
foreach dep_var in  Nazi_share{
	forval i=1/1 {
		reg `dep_var' radio`i' floss_1 $controls_long `cond', cluster (Opsina2)		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
			local ATT=_b[radio`i']/`coef_radio'	
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
			outreg2 using $Robustness_file_main, `opt' bdec(4) bracket se lab nocons drop(r1-r5)  addstat( "Persuasion rates", `persuasion_rate', "ATT", `ATT')

		reg `dep_var' s`i' floss_1  $controls_long    `cond', cluster (Opsina2)
		//effect of 1 sd change
			qui sum  s`i'
			local sd`i'=r(sd)
			local sd_effect=`sd`i''*_b[ s`i']		
			//persuasion rates
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i']*s`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)*`turn'

			drop tmp 
			local ATT=_b[s`i']/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'])/(`share_to_be_persuaded'*`coef_linear')	
			outreg2 using $Robustness_file_main, `opt' bdec(4) bracket se lab nocons drop(r1-r5) addstat( "Persuasion rates", `persuasion_rate', "ATT", `ATT')
		local opt="append"						
	}
}


********************************************************************************************************
*Table 7

local x=75

local opt="replace"
foreach dep_var in Nazi_share hdz_share  sdp_share turnout{
	forval i=1/1 {
		reg `dep_var' s1_1 $controls_short if distance<`x' `cond', cluster (Opsina2)
		gen sample=e(sample)
		qui sum s1_1
		local sd`i'_1=r(sd)
		reg `dep_var' s1_1 log_distance_full  r1-r5 if sample  `cond', cluster (Opsina2)
		local sd_effect=`sd`i'_1'*_b[s1_1]
		drop sample 
		// persuasion rate
		quietly predict tmp
		replace tmp=tmp-_b[s1_1]*s1_1
		sum tmp if e(sample)  [aweight=people_listed]
		local share_to_be_persuaded=1-r(mean)
		drop tmp			
		sum turnout if e(sample) [aweight=people_listed]
		local turn=r(mean)
		local ATT=_b[s1_1]/`coef_linear'		
		local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[s1_1]/`coef_linear'		
		outreg2 using `x'$out_file_linear, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat("Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "ATT", `ATT')

		local opt="append"
		reg `dep_var' s1_1 $controls_short  if distance<`x' `cond', cluster (Opsina2)
		quietly test $controls_short_list=0
		local Fcens=r(F)
		local pcens=r(p)
		//effect of 1 sd change
		
		local sd_effect=`sd`i'_1'*_b[s1_1]		
		// persuasion rate
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s1_1]* s1_1
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)*`turn'
			drop tmp
			local ATT=_b[s1_1]/`coef_linear'
			local persuasion_rate=(`turn'*_b[s1_1])/(`share_to_be_persuaded'*`coef_linear')
		quietly test $controls_short_geo_list=0	
		outreg2 using `x'$out_file_linear, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat("F-stat, census", `Fcens',"p-value for Census",`pcens', "F-stat, geographic controls", r(F), "p", r(p), "Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "ATT", `ATT') //keep (ss`i')
			
	}
 }

*******************************************************************************************************
*Table for summary of the shares of parties in baseline sample in 2003 and 2011 (Table 8)
local opt="replace"
foreach x in 2003 2011 {
local file="File_2003_2011"


local cond="[aweight=people_listed`x']"

foreach dep_var in Nazi_share`x'  {
	forval i=1/1 {
	
			qui sum `dep_var'
			local mean_dep=r(mean)	
		reg `dep_var' radio`i'  $controls_long `cond', cluster (Opsina2)

		    *persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=people_listed2003]
			local share_to_be_persuaded=1-r(mean)
			sum turnout2003 if e(sample) [aweight=people_listed2003]
			local turn=r(mean)
			drop tmp
di "share to be persuaded  " `share_to_be_persuaded'
			local ATT=_b[radio`i']/`coef_radio'		
			
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
	
		outreg2 using $`file', `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "Mean of dependent", `mean_dep', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
		local opt="append"

				
		reg `dep_var' s`i' $controls_long `cond', cluster (Opsina2)

		//effect of 1 sd change
			sum  s`i'_1
			local sd`i'=r(sd)
			local sd_effect=`sd`i''*_b[ s`i']	
		* persuasion rate
			sum turnout if e(sample) [aweight=people_listed`x']
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s`i']*s`i'
			sum tmp if e(sample) [aweight=people_listed`x']
			local share_to_be_persuaded=1-r(mean)*`turn'
			di "share to be persuaded  " `share_to_be_persuaded'
			di "BR1"			
			local ATT=_b[s`i']/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'])/(`share_to_be_persuaded'*`coef_linear')			
			drop tmp			
			di "BR2"
			outreg2 using  $`file', `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Mean of dependent", `mean_dep', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
				local opt="append"				
	}
   }






foreach y in 75 {

foreach dep_var in Nazi_share`x' {
	forval i=1/1 {
	
			qui sum `dep_var'
			local mean_dep=r(mean)	
	 			
di		"reg `dep_var' s1_1 $controls_short  if distance<`x' `cond', cluster (Opsina2)"

		reg `dep_var' s1_1 $controls_short  if distance<`y' `cond', cluster (Opsina2)

		quietly test $controls_short_list=0
		local Fcens=r(F)
		local pcens=r(p)
		//effect of 1 sd change
		
		local sd_effect=`sd`i'_1'*_b[s1_1]
		
		// persuasion rate
			sum turnout if e(sample) [aweight=people_listed]
			local turn=r(mean)			
			quietly predict tmp
			replace tmp=tmp-_b[s1_1]* s1_1
			sum tmp if e(sample) [aweight=people_listed]
			local share_to_be_persuaded=1-r(mean)*`turn'
			drop tmp
			local ATT=_b[s1_1]/`coef_linear'
			local persuasion_rate=(`turn'*_b[s1_1])/(`share_to_be_persuaded'*`coef_linear')
		
		outreg2 using $`file', `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Mean of dependent", `mean_dep', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
		local opt="append"
			
	}
 }

}
}




******Figures
*Figure 4a
reg Nazi_share  $controls_long [aweight=people_listed]
predict Nazi_share_baseline_resid, r
predict Nazi_share_baseline_mean if e(sample), xb
qui sum Nazi_share_baseline_mean
gen Nazi_share_baseline_resid_mean= Nazi_share_baseline_resid+r(mean)

*cdfplot Nazi_share_baseline_resid_mean if radio1!=. & Nazi_share<0.3, by(radio1) xtitle ("Vote share of HSP et al, with controls") legend(lab(1 "No Serbian Radio") lab( 2 "Serbian Radio"))


**Figure 5
reg  Nazi_share s1  $controls_long if radio1!=. [aweight=people_listed] 
avplot s1, xtitle ("Predicted Probability of RTS; with Controls") ytitle ("Mean Vote Share of HSP et al.; with Controls")


