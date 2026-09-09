
*use "Survey Replication Data.dta", clear
tab serbianradio if serbianradio<=3, gen(sr)
tab croatianradio if croatianradio <=3, gen(cr)
tab bosnianradio if bosnianradio <=3, gen(bos_rec)
tab songsafter2000, gen (lband)

tab listeningtoserbian, gen(lr)
tab peopleinvillage, gen(pr)
tab listeningtocroatian, gen(lc)
tab listeningtobosnian, gen (bos)

tab listeningtoserbian radio
tab serbianradio radio
tab peopleinvillage radio

gen byte cr2=(croatianradio==2) 
gen byte cr3=(croatianradio==3) 

gen lsr1=lr1+lr2
gen lsr2=lr4+lr3
gen lsr3=lr5

gen lcr1=lc1+lc2
gen lcr2=lc4+lc3
gen lcr3=lc5


gen lbr1=bos1
gen lbr2=bos3+bos2
gen lbr3=bos4

gen lsr1_2= lsr1+ lsr2
label var lsr1 "Listen Often"
label var lsr1_2 "Listen Rarely or Often"


gen lcr1_2= lcr1+ lcr2
label var lcr1 "Listen Often, Croatian"
label var lcr1_2 "Listen Rarely or Often, Croatian"

gen lbr1_2= lbr1+ lbr2
label var lbr1 "Listen Often, Bosnian"
label var lbr1_2 "Listen Rarely or Often, Bosnian"



label var lband1 "Yes"
label var lband2 "No"

tab gender, gen (g)
tab occupation, gen (o)
tab education, gen (e)
tab age, gen(a)
*tab radio_m, gen(r)

global controls="g1 o1-o4 e1-e4 a1-a4"


//some important variables

*gen radio1=r2+r3
*gen radio2=r3
forval i=1/2 {
	gen radio`i'_new=radio`i'*new
}

gen serbianradio_available=1-serbianradio if serbianradio<=2
gen people_listen=1-peopleinvillage if peopleinvillage<=2

encode place, gen(Place)


gen notasked=0 
replace notasked=1 if (artist=="Not asked" | artist=="")
gen moreartistupd=0 if notasked!=1
replace moreartistupd=1 if moreartist=="YES"|moreartist=="Yes"|moreartist=="yes"

gen concertyes=0 if concert!=.
replace concertyes=1 if concert==1

replace songsafter=2-songsafter

//outreg files
global main_file="survey_main.xls"
global cr_file="survey_cr.xls"
global music_file="survey_music.xls"

**************************************************************
* Replication of results in the main text
**************************************************************
* Table 1
local opt="replace"
foreach dep_var in lsr1_2 lsr1 {
		reg `dep_var' radio , robust 
		outreg2 using "$main_file", bracket `opt' label dec(3) 
		local opt="append"		
		reg `dep_var' radio $controls new, robust 
		outreg2 using "$main_file", bracket `opt' label dec(3) 

		reg `dep_var' s1 new, robust 
		qui sum s1 if e(sample)
		local sd_effect=r(sd)*_b[s1]
		outreg2 using "$main_file", bracket `opt' label dec(3) addstat("Effect of 1 st. dev. change", `sd_effect') 

		reg `dep_var' s1 $controls new, robust 
		qui sum s1 if e(sample)
		local sd_effect=r(sd)*_b[s1]
		outreg2 using "$main_file", bracket `opt' label dec(3) addstat("Effect of 1 st. dev. change", `sd_effect') 

}

*Figure 2a
graph bar sr1 sr2 sr3, over(radio, relabel (1 "% reporting reception of Serbian radio" 2 "% reporting no reception of Serbian radio" 3 "% who don't know if there is reception of Serbian radio")) asyvars legend(cols(1) si(small)) blabel(bar, format(%9.2f)) 

*Figure 2b
graph bar lsr1 lsr2 lsr3, over(radio, relabel (1 "% listening to Serbian radio at least once per week" 2 "% listening to Serbian radio several times per month or rarely" 3 "%  who never listen to Serbian radio or don't know about radio reception")) asyvars legend(cols(1) si(vsmall)) blabel(bar, format(%9.2f)) 

*Figure 2c
preserve
gen byte observations=1
gen  Serbianradio=(serbianradio<2) if serbianradio!=.
collapse lsr1_2 lcr1_2 lcr1 s1 radio1 Serbianradio (count) observations, by (place)
twoway (scatter lsr1_2 s1  [aweight = observations] if radio1==0, mcolor(blue) ) (scatter lsr1_2 s1  [aweight = observations] if radio1, msymbol(circle_hollow) mfcolor(white) mlcolor(maroon) mlwidth(thick)) , ytitle("Share of respondents listening to Serbian radio") xtitle("Signal strength of RTS")
restore



**************************************************************
* Replication of results in the Online Appendix
**************************************************************

*OA Figure 3a
preserve
gen byte observations=1
gen  Serbianradio=(serbianradio<2) if serbianradio!=.
collapse lsr1_2 lcr1_2 lcr1 s1 radio1 Serbianradio (count) observations, by (place)
twoway (scatter Serbianradio s1  [aweight = observations] if radio1==0, mcolor(blue) ) (scatter Serbianradio s1  [aweight = observations] if radio1, msymbol(circle_hollow) mfcolor(white) mlcolor(maroon) mlwidth(thick)) , ytitle("Reported Reception of Serbian radio") xtitle("Signal strength of RTS")
restore



*OA Figure 3b
graph bar pr1 pr2 pr3, over(radio, relabel (1 "% reporting that people in their village listen to Serbian radio" 2 "% reporting that people in their village do not listen to Serbian radio" 3 "% who don't know if people in their village listen to Serbian radio")) asyvars legend(cols(1) si(small))  blabel(bar, format(%9.2f)) 
*OA Figure 3c
graph bar lband1 lband2 , over(radio, relabel (1 "% Heard the band" 2 "% Have not heard the band" 3 "% who don't know if there is reception of Croatian radio")) asyvars legend(cols(1) si(small)) blabel(bar, format(%9.2f)) 
*OA Figure 4a
graph bar bos_rec1 bos_rec2 bos_rec3, over(radio, relabel (1 "% reporting reception of Bosnian radio" 2 "% reporting no reception of Bosnian radio" 3 "% who don't know if there is reception of Bosnian radio")) asyvars legend(cols(1) si(small)) blabel(bar, format(%9.2f)) 
*OA Figure 4b
graph bar lbr1  lbr2 lbr3, over(radio, relabel (1 "% listening to Bosnian radio at least once per week" 2 "% listening to Bosnian radio several times per month or rarely" 3 "%  who never listen to Bosnian radio or don't know about radio reception")) asyvars legend(cols(1) si(vsmall)) blabel(bar, format(%9.2f)) 
*OA Figure 4c
graph bar cr1 cr2 cr3, over(radio, relabel (1 "% reporting reception of Croatian radio" 2 "% reporting no reception of Croatian radio" 3 "% who don't know if there is reception of Croatian radio")) asyvars legend(cols(1) si(small)) blabel(bar, format(%9.2f)) 
*OA Figure 4e
graph bar lcr1 lcr2 lcr3, over(radio, relabel (1 "% listening to Croatian radio at least once per week" 2 "% listening to Croatian radio several times per month or rarely" 3 "%  who never listen to Croatian radio or don't know about radio reception")) asyvars legend(cols(1) si(vsmall)) blabel(bar, format(%9.2f)) 

*OA Figure 4e
preserve
gen byte observations=1
gen  Serbianradio=(serbianradio<2) if serbianradio!=.
collapse lsr1_2 lcr1_2 lcr1 s1 radio1 Serbianradio (count) observations, by (place)
twoway (scatter lcr1 s1  [aweight = observations] if radio1==0, mcolor(blue) ) (scatter lcr1 s1  [aweight = observations] if radio1, msymbol(circle_hollow) mfcolor(white) mlcolor(maroon) mlwidth(thick)) , ytitle("Share of respondents often listening to Croatian radio") xtitle("Signal strength of RTS")
restore



* OA Table 2
local opt="replace"
foreach dep_var in lcr1_2 lcr1 {
		reg `dep_var' radio , robust 
		outreg2 using "$cr_file", bracket `opt' label dec(3) 
		local opt="append"		
		reg `dep_var' radio $controls new, robust 
		outreg2 using "$cr_file", bracket `opt' label dec(3) 

		reg `dep_var' s1 new, robust 
		qui sum s1 if e(sample)
		local sd_effect=r(sd)*_b[s1]
		outreg2 using "$cr_file", bracket `opt' label dec(3) addstat("Effect of 1 st. dev. change", `sd_effect') 

		reg `dep_var' s1 $controls new, robust 
		qui sum s1 if e(sample)
		local sd_effect=r(sd)*_b[s1]
		outreg2 using "$cr_file", bracket `opt' label dec(3) addstat("Effect of 1 st. dev. change", `sd_effect') 

}

*OA Table 3

local opt="replace"
foreach dep_var in concertyes songsafter moreartistupd  {
	foreach i in 1_2 1 {
		reg `dep_var' lsr`i' lcr`i' lbr`i', robust
		outreg2 using "$music_file", bracket `opt' label dec(3) 
		local opt="append"
		sum `dep_var' if e(sample)
	}	
}

