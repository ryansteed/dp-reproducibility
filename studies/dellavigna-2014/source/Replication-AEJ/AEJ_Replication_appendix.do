
*use Data_AEJ_Replication.dta
set more off
global user="/Users/mac/Documents"
*global user="C:\Users\renikolopov\"
local work="work/Media/"

cd "$user/Dropbox/work/Media/Yugoslavia Media/Replication"
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
global baseline_file2003="baseline_2003_"+"$date"+".xls"
global baseline_file2011="baseline_2011_"+"$date"+".xls"
global baseline_file="baseline_"+"$date"+".xls"
global others_share_out="others_out_"+"$date"+".xls"
global turnout_out="turnout_out_"+"$date"+".xls"
global AET_file_OA="AET_OA"+"$date"+".xls"
global Robustness_file_OA ="robustness_OA"+"$date"+".xls"


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

local coef_radio=0.313
local coef_predict=2.534
local coef_linear=51.325

local cond="[aweight=people_listed]"



*Figures 6

reg Nazi_share  $controls_short `cond'
predict Nazi_share_short_resid, r
predict Nazi_share_short_mean if e(sample), xb
qui sum Nazi_share_short_mean
gen Nazi_share_short_resid_mean= Nazi_share_short_resid+r(mean)


foreach var of varlist Nazi_share graffiti hdz_share  sdp_share turnout { 
reg `var'  $controls_long `cond'
predict `var'_baseline_resid, r
predict `var'_baseline_mean if e(sample), xb
sum `var'_baseline_mean
gen `var'_baseline_resid_mean= `var'_baseline_resid+r(mean)
}


*Figure 6a
*cdfplot Nazi_share if radio1!=. & Nazi_share<0.3, by(radio1) xtitle ("Vote share of HSP et al, no controls") legend(lab(1 "No Serbian Radio") lab( 2 "Serbian Radio"))
*Figure 6b
*cdfplot hdz_share_baseline_resid_mean , by(radio1) xtitle ("Vote share of HDZ et al, with controls") legend(lab(1 "No Serbian Radio") lab( 2 "Serbian Radio"))
*Figure 6c
*cdfplot sdp_share_baseline_resid_mean , by(radio1) xtitle ("Vote share of SDP et al, with controls") legend(lab(1 "No Serbian Radio") lab( 2 "Serbian Radio"))
*Figure 6d
*cdfplot turnout_baseline_resid_mean , by(radio1) xtitle ("Turnout, with controls")  legend(lab(1 "No Serbian Radio") lab( 2 "Serbian Radio"))
*Figure 6e
*cdfplot graffiti_baseline_resid_mean , by(radio1) xtitle ("Offensive graffiti, with controls") legend(lab(1 "No Serbian Radio") lab( 2 "Serbian Radio"))


********************************************************************************************************
*OA Table 1
//sum radio1 radio2 ss1 ss2 s1 s2 Nazi_share others_share sdp_share turnout graffiti venec $controls_long if radio1!=., sep(100)
gen radio=radio1
replace radio=2 if radio2==1
replace Serbs=Serbs*100
replace Croats=Croats*100
tabstat radio1 radio2 s1  Nazi_share hdz_share sdp_share turnout graffiti pop Croats disable_share2 ec_active higher_educ male_share z2 z3 z6 distance_full bliz monument name_of_the_street*  pivo_Serb war if radio1!=. [aweight=people_listed], stat(mean sd count) columns(statistics) format(%9.3f)
qui 		reg s1 $controls_short `cond' if Nazi_share!=. & distance<75,  cluster (Opsina2)
tabstat  s1  Nazi_share hdz_share sdp_share turnout graffiti pop Croats disable_share2 ec_active higher_educ male_share z2 z3 z6 distance_full  if e(sample) [aweight=people_listed], stat(mean sd count) columns(statistics) format(%9.3f)

***
*OA Table 5
local opt="replace"

qui reg radio1   log_distance_full r1-r5 if radio1!=. `cond'
predict radio1_p_geo if e(sample), xb
label var radio1_p_geo "AET geographical only, binary"
qui reg s1   log_distance_full r1-r5 if radio1!=.  `cond'
predict s1_p_geo if e(sample), xb
label var s1_p_geo "AET geographical only, strength"
reg  Nazi_share radio1_p_geo `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons
local opt="append" 
reg  Nazi_share s1_p_geo if radio1!=. `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 



qui reg radio1   logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2  `cond'
predict radio1_census_only, xb
label var radio1_census_only "AET census only, binary"
qui reg s1   logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2 `cond'
predict s1_census_only, xb
label var s1_census_only "AET census only, strength"
reg  Nazi_share radio1_census_only `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 
reg  Nazi_share s1_census_only if radio1!=. `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 


qui reg radio1  war mon name_of_the_streets_c name_of_the_streets_i pivo_S bliz `cond'
predict radio1_additional_only, xb
label var radio1_additional_only "AET additional only, radio"
qui reg s1   war mon name_of_the_streets_c name_of_the_streets_i pivo_S bliz `cond'
predict s1_additional_only, xb
label var s1_additional_only "AET additional only, strength"
reg  Nazi_share radio1_additional_only `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 
reg  Nazi_share s1_additional_only if radio1!=. `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 


qui reg s1 $controls_short `cond'
qui reg s1 log_distance_full r1-r5 `cond' if e(sample)
predict s1_pp_geo if e(sample), xb
label var s1_pp_geo "AET geographical only"
reg  Nazi_share s1_pp_geo if distance<75 `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 

qui reg s1  logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2  `cond'
predict s1_pp_census_only if e(sample), xb
label var s1_pp_census_only "AET census only"
reg  Nazi_share s1_pp_census_only if distance<75 `cond', cluster (Opsina2)
outreg2 using $AET_file_OA, `opt' bdec(3) bracket se lab nocons 


******************************
* OA Table 5 

local cond=""
foreach dep_var in graffiti {
	local opt="replace"
	forval i=1/1 {
	
	*No controls
			reg `dep_var' radio`i'   log_distance_full  r1-r5 `cond', cluster (Opsina2) 
			local temp="`dep_var'_file_OLS"
			
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  
			local opt="append"	
	
		
		foreach list in controls_short controls_long {
			reg `dep_var' radio`i' $`list' `cond', cluster (Opsina2)   

			
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  
			local opt="append"
		}	
		
	*BOth dummies at the same time	
			local list="controls_long"
			reg `dep_var' radio1 radio2 $`list' bliz `cond', cluster (Opsina2) 
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons  
			local opt="append"		
		
			
*Signal strength			
			reg `dep_var' s`i'  log_distance_full  r1-r5  `cond', cluster (Opsina2)   
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons keep (s`i') 
			
		foreach list in controls_short controls_long {
			reg `dep_var' s`i' $`list'  `cond', cluster (Opsina2)   
			outreg2 using $`temp', `opt' bdec(3) bracket se lab nocons keep (s`i') 	
				}
				
   }
	
}



*********************************
***********OA Table 6
local cond="[aweight=people_listed]"
		local opt="replace"
*CHecking for robustness of the definition of nazi parties as HSP only
foreach dep_var in hsp_share   {
	forval i=1/1 {

		reg `dep_var' radio`i'  $controls_long `cond', cluster (Opsina2)
		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
		
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
			local ATT=_b[radio`i']/`coef_radio'		

		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "Persuasion rates", `persuasion_rate', "ATT", `ATT')

		local opt="append"


		reg `dep_var' s`i' $controls_long `cond', cluster (Opsina2)

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


		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
		local opt="append"
		
	}
}

*Controlling for Serbian Krajina


foreach dep_var in  Nazi_share{
	forval i=1/1 {

		reg `dep_var' radio`i' kraina $controls_long `cond', cluster (Opsina2)


		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
		
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
			local ATT=_b[radio`i']/`coef_radio'		
di `ATT'

		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "ATT", `ATT',  "Persuasion rates", `persuasion_rate')




		reg `dep_var' s`i'  kraina   $controls_long    `cond', cluster (Opsina2)

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


		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Effect of 1 st. dev. change", `sd_effect', "ATT", `ATT',  "Persuasion rates", `persuasion_rate') 
		local opt="append"
		
				
	}
}





*Controlling for log distance to transmitters and elevation
gen ln_distance_transmitter=ln(distance_transmitter)

foreach dep_var in  Nazi_share{
	forval i=1/1 {

		reg `dep_var' radio`i' ln_distance_transmitter log_elevation_full $controls_long `cond', cluster (Opsina2)


		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
		
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
	

		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "ATT", `ATT',  "Persuasion rates", `persuasion_rate')

		local opt="append"


		reg `dep_var' s`i'  ln_distance_transmitter log_elevation_full   $controls_long    `cond', cluster (Opsina2)

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


		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Effect of 1 st. dev. change", `sd_effect', "ATT", `ATT',  "Persuasion rates", `persuasion_rate') 
		local opt="append"
		
				
	}
}




/*Additional controls for distance to Serbia and war experience
*This part can not be replicated since Google have changed API in March 2013, which is no longer compatible with traveltime function 


gen lat1=45.523252
gen long1=19.086422

gen lat2=45.844266
gen long2=18.857595

gen lat3=45.233019
gen long3=19.401702


gen lat4=45.216489
gen long4=19.431408

gen lat5=45.168811
gen long5=19.378155

gen lat6=45.179915
gen long6=19.354085

gen lat7= 45.175038
gen long7=19.262389


gen lat8=45.155501
gen long8=19.174128

gen lat9=45.047559
gen long9=19.106198

gen lat10=44.897060
gen long10=19.074860
sort radio1
forvalues y
forvalues x=1/10 {
traveltime3, start(latitude,longitude) end(lat`x', long`x') 
gen time`x'= days*24*60+hours*60+mins
rename traveltime_dist traveltime_dist`x'
drop days hours mins
}

egen traveltime=rowmin(time1-time10)
egen traveltime_dist=rowmin(traveltime_dist*)
 


local i=1

		reg Nazi_share radio`i' Incident_within_3km traveltime distance_full_*  logpop Croats higher_educ male_share ec_active z2 z3 z6 disable_share2 war  mon name_of_the_streets_c name_of_the_streets_i pivo_S r1-r5 bliz `cond', cluster (Opsina2)
		
		// persuasion rate
			quietly predict tmp
			replace tmp=tmp-_b[radio`i']*radio`i'
			sum tmp if e(sample) [aweight=1]
			local share_to_be_persuaded=1-r(mean)
			drop tmp
			
			sum turnout if e(sample) [aweight=1]
			local turn=r(mean)
			
			local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[radio`i']/`coef_radio'	
			local ATT=_b[radio`i']/`coef_radio'		
		test distance_full_1= distance_full_2= distance_full_3= distance_full_4= distance_full_5=0
		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5)  addstat( "Persuasion rates", `persuasion_rate', "Distance F", r(F), "ATT", `ATT')

		local opt="append"


		reg Nazi_share s`i' Incident_within_3km  traveltime  distance_full_*  logpop Croats higher_educ male_share ec_active z2 z3 z6 disable_share2 war  mon name_of_the_streets_c name_of_the_streets_i pivo_S r1-r5 bliz  `cond', cluster (Opsina2)

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

		test distance_full_1= distance_full_2= distance_full_3= distance_full_4= distance_full_5=0

		outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Effect of 1 st. dev. change", `sd_effect', "Persuasion rates", `persuasion_rate', "Distance F", r(F), "ATT", `ATT') 
		local opt="append"

*/

**NNMatch

gen Name_c =name_of_the_streets_c
gen Name_i=name_of_the_streets_i
foreach m in 5 {
nnmatch Nazi_share radio1  log_distance_full  logpop Croats higher_educ male_share ec_active z2 z3 z6 disable_share2 war  mon Name_c Name_i pivo_S  bliz r1,  bias(bias) robusth(1) tc(att) m(`m') replace
	local persuasion_rate=1/`share_to_be_persuaded'*`turn'*_b[SATT]/`coef_radio'	
	local ATT=_b[SATT]/`coef_radio'		

	outreg2 using $Robustness_file_OA, `opt' bdec(3) bracket se lab nocons drop(r1-r5) ctitle ("nnmatch with `m' matches") addstat("Persuasion rates", `persuasion_rate', "ATT", `ATT')


}

*Adding villages in the same region that didn't make it into baseline sample
local i=1
local dep_var="Nazi_share"
		qui sum distance if radio1!=.
		local maxdist=r(max)
		reg `dep_var' s`i'  $controls_short if distance<`maxdist'   `cond', cluster (Opsina2)

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

		outreg2 using $Robustness_file_OA, `opt' bdec(4) bracket se lab nocons drop(r1-r5) addstat( "Persuasion rates", `persuasion_rate', "ATT", `ATT')
		local opt="append"
	

********************************************************************************************************
*OA Table 8

local x=50

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

*** OA Tables 9 and 11


foreach x in 2003 2011 {
local file="baseline_file`x'"


local cond="[aweight=people_listed`x']"
local opt="replace"
foreach dep_var in Nazi_share`x'  hdz_share`x'  sdp_share`x' turnout`x'{
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
			local ATT=_b[s`i']/`coef_linear'			
			local persuasion_rate=(`turn'*_b[s`i'])/(`share_to_be_persuaded'*`coef_linear')			
			drop tmp
*/			
		outreg2 using  $`file', `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Mean of dependent", `mean_dep', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
				local opt="append"
		
			
	}
}

}


** OA Tables 10 and 12

foreach y in 2003 2011 {
local file="out_file_linear_`y'"


local cond="[aweight=people_listed`y']"
foreach x in 50 75 {

local opt="replace"
foreach dep_var in Nazi_share`y' hdz_share`y'  sdp_share`y' turnout`y' {
	forval i=1/1 {

			qui sum `dep_var' if distance<`x'
			local mean_dep=r(mean)				
			
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
		
		outreg2 using `x'$`file', `opt' bdec(3) bracket se lab nocons drop(r1-r5) addstat( "Mean of dependent", `mean_dep', "Persuasion rates", `persuasion_rate', "ATT", `ATT') 
		local opt="append"
			
	}
 }

}
}


*OA Table 13 

foreach var in log_distance_full logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2 war mon name_of_the_streets_c name_of_the_streets_i pivo_S {
	qui sum `var'
	gen radio1_`var'=radio1*(`var'-r(mean))
	gen s1_`var'=s1*(`var'-r(mean))
}

local cond="[aweight=people_listed]"
local opt="replace"

foreach signal_var in radio1 s1 {
foreach dep_var in Nazi_share {
*	local dep_var="Nazi_share"
	foreach var in log_distance_full logpop Croats higher_educ male_share ec_active  z2 z3 z6 disable_share2 war mon name_of_the_streets_c name_of_the_streets_i pivo_S {

		reg `dep_var' `signal_var' `signal_var'_`var' $controls_long `cond', cluster (Opsina2)
		outreg2 using $interaction_file, `opt' bdec(3) bracket se lab nocons drop(r1-r5) 
		local opt="append"
			}
	}
}


