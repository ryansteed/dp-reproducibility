#delimit;
clear;
set more off;


********************************************************************************************************;
********************************************************************************************************;
*CODE POLICY EXPERIMENTATION AND REVERSALS (1996-2010);
*
*first definition: use direction of policy change to indicate experiment/reversal;
*                  (typically stricter/contractive = experiment, more liberal/expansive = reversal);
*         			
*					focus on large (restrictive) changes for a subset of the basic 13 rules (here N=9);
*
*second definition: 1st change = experiment, 2nd change in opposite direction = reversal; 
* 
* 					code only first change in each direction as experiment (reversal); 
* 					use broader set of rules with 2nd definition as well;
*
********************************************************************************************************;
********************************************************************************************************;

use "welfarereform_082013_v42_including_all_variables.dta", clear;

for var earndis1_type earndis2_type earndis3_type: replace X="Dollars" if X=="Dollar";
replace workenroll = 1 if state_name=="Kansas" & year==2003; 

*------------------------------------------------------------------------------------;
*------------------------------------------------------------------------------------;
*FIRST DEFINITION: use direction of policy change to indicate experiment/reversal;
*------------------------------------------------------------------------------------;
*------------------------------------------------------------------------------------;
cap drop temp_* tempr_* tempo_* tempor_*;


*--------------------------------------------------------;
*start with a narrow set of "important" rules (N=13-17);
*--------------------------------------------------------;
sort state year;
tsset state year;

*FAMILY CAPS;
*----------------;
*experiment = adopt family cap;
bysort state: gen temp_famcap = 1 if famcap==1 & L.famcap==0 & year>=1996;
replace temp_famcap = 0 if temp_famcap==. & year>=1996 & year<=2010;

*reversal = abolish family cap; 
bysort state: gen tempr_famcap = 1 if famcap==0 & L.famcap==1 & year>1996;
bysort state: gen temprr_famcap = tempr_famcap;
replace tempr_famcap = 0 if tempr_famcap==. & year>1996 & year<=2010;
*condition on years after experiment (get rid of false zeros);
gen test = year if temp_famcap==1; 
bysort state: egen test1 = mean(test);
replace temprr_famcap = 0 if year>=test1 & temprr_famcap!=1 & year>1996 & year<=2010;
drop test test1;


*WORK REQUIREMENTS;
*---------------------;
*federal guidelines hours requirement: recipient must be working when considered able by the state or after 24 months of benefit receipt;
*experiment: increase hours of work requirement;
bysort state: gen temp_hrsreq = 1 if hrsreq > L.hrsreq & hrsreq!=. & L.hrsreq!=. & year>=1996 & year<=2010;
replace temp_hrsreq = 0 if temp_hrsreq==. & year>=1996 & year<=2010;

*reversal: reduce hours of work requirement;
bysort state: gen tempr_hrsreq = 1 if hrsreq < L.hrsreq & hrsreq!=. & L.hrsreq!=. & year>1996 & year<=2010;
bysort state: gen temprr_hrsreq = tempr_hrsreq;
replace tempr_hrsreq = 0 if tempr_hrsreq==. & year>1996 & year<=2010;
*condition on years after experiment (get rid of false zeros);
gen test = year if temp_hrsreq==1; 		/*multiple experiments -ok if we just look after 1st one!*/;
bysort state: egen test1 = min(test);
replace temprr_hrsreq = 0 if year>=test1 & temprr_hrsreq==. & year>1996 & year<=2010;
drop test test1;


*experiment: immediate work enrollment;
bysort state: gen temp_enroll = 1 if workenroll==1 & L.workenroll==0 & year>=1996 & year<=2010;
replace temp_enroll = 0 if temp_enroll==. & year>=1996 & year<=2010;

*reversal: postpone work enrollment; 
bysort state: gen tempr_enroll = 1 if workenroll==0 & L.workenroll==1 & year>1996 & year<=2010;
bysort state: gen temprr_enroll = tempr_enroll;
replace tempr_enroll = 0 if tempr_enroll==. & year>1996 & year<=2010;
gen test = year if temp_enroll==1; 
bysort state: egen test1 = mean(test);
replace temprr_enroll = 0 if year>=test1 & temprr_enroll!=1 & year>1996 & year<=2010;
drop test test1;



*experiment: adopt worklimit;
*NOTE: little variation over time in worklimit!;
bysort state: gen temp_limit = 1 if worklimit==1 & L.worklimit==0 & year>=1996 & year<=2010;
replace temp_limit = 0 if temp_limit==. & year>=1996 & year<=2010;

*reversal: abolish worklimit;
bysort state: gen tempr_limit = 1 if worklimit==0 & L.worklimit==1 & year>1996 & year<=2010;
replace tempr_limit = 0 if tempr_limit==. & year>1996 & year<=2010;
replace tempr_limit=0 if state_code=="MI" & tempr_limit==1;
gen test = year if temp_limit==1; 
bysort state: egen test1 = mean(test);
bysort state: gen temprr_limit = 1 if worklimit==0 & L.worklimit==1 & year>1996;
replace tempr_limit=. if state_code=="MI" & tempr_limit==1;
replace temprr_limit = 0 if year>=test1 & temprr_limit!=1 & year>1996 & year<=2010;
drop test test1;


*NEW relative to old definition;
*experiment: reduce number of work requirement exemptions (under AFDC: all we coded were available);
bysort state: gen temp_exempt = 1 if workex_no < L.workex_no & workex_no!=. & L.workex_no !=. & year>=1996 & year<=2010;
replace temp_exempt = 0 if temp_exempt==. & year>=1996 & year<=2010;

*reversal: increase number of exemptions to work requirement; 
bysort state: gen tempr_exempt = 1 if workex_no > L.workex_no & workex_no!=. & L.workex_no !=. & year>1996 & year<=2010;
bysort state: gen temprr_exempt = tempr_exempt; 
replace tempr_exempt = 0 if tempr_exempt==. & year>1996 & year<=2010;
gen test = year if temp_exempt==1; 
bysort state: egen test1 = min(test);
replace temprr_exempt = 0 if year>=test1 & temprr_exempt==. & year>1996 & year<=2010;
drop test test1;




*SANCTIONS;
*-------------;
/*Until the early 1990s, sanctions did not involve terminating a family's entire Aid to Families with Dependent Children (AFDC) grant. 
Rather, the individual who failed to comply (usually the parent) was removed from the grant calculation, resulting in a lower grant 
and reflecting the view that children should not be punished for their parent's noncompliance. At the same time, however, 
noncompliance with eligibility-related requirements (for example, failure to appear for a redetermination interview at the welfare office) 
did result in closing the case and terminating benefits*/;
/*In the early 1990s, the federal government began granting waivers of AFDC rules, including waivers that allowed states to impose full-family 
sanctions. By mid-1996, nearly half the states had received such a waiver. Then the 1996 welfare reforms required states to terminate or reduce 
benefits "pro rata" when recipients failed to comply with work requirements, but the amount and duration of sanctions were not otherwise specified. 
The act also changed the food stamp rules so that benefits are no longer increased when the cash grant is cut, and required states to reduce 
(or, at state option, eliminate) the food stamp grant when a TANF sanction is imposed.*/;

sort state year;

*experiment: more reduction of benefits when sanctioned (most severe sanction);
*note: sanctionben = 1 under AFDC (removal of adult portion of the benefit); 
bysort state: gen temp_sanctionben = 1 if sanctionben > L.sanctionben & sanctionben>1 & sanctionben!=. & L.sanctionben!=.& year>=1996 & year<=2010;
replace temp_sanctionben = 0 if temp_sanctionben ==. & year>=1996 & year<=2010;

*reversal: less reduction of benefits when sanctioned (most severe sanction);
bysort state: gen tempr_sanctionben = 1 if sanctionben < L.sanctionben & L.sanctionben!=1 & sanctionben!=. & L.sanctionben!=.& year>1996 & year<=2010;
bysort state: gen temprr_sanctionben = tempr_sanctionben;
bysort state: replace tempr_sanctionben = 0 if tempr_sanctionben ==. & year>1996 & year<=2010;
gen test = year if temp_sanctionben==1; 
bysort state: egen test1 = min(test);
replace temprr_sanctionben = 0 if year>=test1 & temprr_sanctionben==. & year>1996 & year<=2010;
drop test test1; 

*NOTE: <=1996, most have sanctiondur=6 months (max(6 months, compliance), so the minimum is 6 months), states deviating <6 (until compliance); 
*experiment: longer sanctions (most severe sanction); 
bysort state: gen temp_sanctiondur = 1 if sanctiondur > L.sanctiondur & sanctiondur>6 & sanctiondur!=. & L.sanctiondur!=. & year>=1996 & year<=2010;
replace temp_sanctiondur = 0 if temp_sanctiondur==. & year>=1996 & year<=2010;
replace temp_sanctiondur = 0 if (state_code=="ID" | state_code=="MS" | state_code=="WI") & year==1997; 

*reversal: reduce length of sanctions (most severe sanction); 
bysort state: gen tempr_sanctiondur = 1 if sanctiondur < L.sanctiondur & sanctiondur!=. & L.sanctiondur!=. & year>1996 & year<=2010;
replace tempr_sanctiondur = 0 if (state_code=="NH" | state_code=="NM") & tempr_sanctiondur==1; 
replace tempr_sanctiondur = 0 if (state_code=="RI") & tempr_sanctiondur==1 & year==1997; 
bysort state: gen temprr_sanctiondur = tempr_sanctiondur;
replace temprr_sanctiondur =. if temprr_sanctiondur==0;
replace tempr_sanctiondur = 0 if tempr_sanctiondur==. & year>1996 & year<=2010;
replace tempr_sanctiondur = 0 if (state_code=="NH" | state_code=="NM") & tempr_sanctiondur==1; 
replace tempr_sanctiondur = 0 if (state_code=="RI") & tempr_sanctiondur==1 & year==1997; 
gen test = year if temp_sanctiondur==1; 
bysort state: egen test1 = min(test);
replace temprr_sanctiondur = 0 if year>=test1 & temprr_sanctiondur==. & year>1996 & year<=2010;
drop test test1; 


*Note: duration and severity of initial sanctions (sanction1dur und sanction1ben) available 1999-2010 only; 
*experiment: stricter sanctions (initial sanctions);
bysort state: gen tempo_sanction1dur = 1 if sanction1dur > L.sanction1dur & sanction1dur!=. & L.sanction1dur!=. & year>1999 & year<=2010;
replace tempo_sanction1dur = 0 if tempo_sanction1dur==. & year>1999 & year<=2010;

bysort state: gen tempo_sanction1ben = 1 if sanction1ben > L.sanction1ben & sanction1ben!=. & L.sanction1ben!=. & year>1999 & year<=2010;
replace tempo_sanction1ben = 0 if tempo_sanction1ben==. & year>1996 & year<=2010;

*reversal: weaker sanctions (initial sanctions); 
bysort state: gen tempor_sanction1dur = 1 if sanction1dur < L.sanction1dur & sanction1dur!=. & L.sanction1dur!=. & year>1999 & year<=2010;
replace tempor_sanction1dur = 0 if tempor_sanction1dur==. & year>1999 & year<=2010;

bysort state: gen tempor_sanction1ben = 1 if sanction1ben < L.sanction1ben & sanction1ben!=. & L.sanction1ben!=. & year>1999 & year<=2010;
replace tempor_sanction1ben = 0 if tempor_sanction1ben==. & year>1996 & year<=2010;


*NEW relative to old definition;
*reapply after sanction;
*experiment: unit has to reapply;
bysort state: gen temp_reapply = 1 if reapply==1 & L.reapply ==0 & year>=1996;
replace temp_reapply = 0 if temp_reapply==. & year>=1996 & year<=2010;

bysort state: gen tempo_dsanctionini = 1 if dsanctionini ==1 & L.dsanctionini ==0 & year>=1996;
replace tempo_dsanctionini = 0 if tempo_dsanctionini==. & year>=1996 & year<=2010;

*reversal: unit does not need to reapply; 
bysort state: gen tempr_reapply = 1 if reapply==0 & L.reapply==1 &  year>1996;
bysort state: gen temprr_reapply = tempr_reapply;
replace tempr_reapply = 0 if tempr_reapply==. &  year>1996 & year<=2010;
gen test = year if temp_reapply==1; 
bysort state: egen test1 = min(test);
replace temprr_reapply = 0 if year>=test1 & temprr_sanctiondur==. & year>1996 & year<=2010;
drop test test1; 

bysort state: gen tempor_dsanctionini = 1 if dsanctionini ==0 & L.dsanctionini ==1 & year>1996;
bysort state: gen temporr_dsanctionini = tempor_dsanctionini;
replace tempor_dsanctionini = 0 if tempor_dsanctionini==. &  year>1996 & year<=2010;
gen test = year if tempo_dsanctionini==1; 
bysort state: egen test1 = min(test);
replace temporr_dsanctionini = 0 if year>=test1 & temporr_dsanctionini==. & year>1996 & year<=2010;
drop test test1; 



*MANDATORY JOB SEARCH AND DIVERSION PAYMENT;
*--------------------------------------------;
sort state year;
*experimentation: adopt mandatory job search; 
bysort state: gen tempo_mandjob = 1 if mandjob==1 & L.mandjob==0 & year>=1996 & year<=2010; 
replace tempo_mandjob = 0 if tempo_mandjob==. & year>=1996 & year<=2010; 

*reversal: abolish mandatory job search;
bysort state: gen tempor_mandjob = 1 if mandjob==0 & L.mandjob==1 & year>1996 & year<=2010;
bysort state: gen temporr_mandjob = tempor_mandjob;
replace tempor_mandjob = 0 if tempor_mandjob==. & year>1996 & year<=2010; 
gen test = year if tempo_mandjob==1; 
bysort state: egen test1 = min(test);
replace temporr_mandjob = 0 if year>=test1 & temporr_mandjob==. & year>1996 & year<=2010;
drop test test1; 


*experimentation: adopt diversion payment (pay in return for family not applying for welfare);
bysort state: gen tempo_divpaymt = 1 if divpaymt==1 & L.divpaymt==0 & year>=1996 & year<=2010; 
replace tempo_divpaymt = 0 if tempo_divpaymt==. & year>=1996 & year<=2010; 

*reversal: abolish diversion payment;
bysort state: gen tempor_divpaymt = 1 if divpaymt==0 & L.divpaymt==1 & year>1996 & year<=2010;
bysort state: gen temporr_divpaymt = tempor_divpaymt;
replace tempor_divpaymt = 0 if tempor_divpaymt==. &  year>1996 & year<=2010; 
gen test = year if tempo_divpaymt==1; 
bysort state: egen test1 = min(test);
replace temporr_divpaymt = 0 if year>=test1 & temporr_divpaymt==. & year>1996 & year<=2010;
drop test test1; 



*TIME LIMITS;
*--------------;
/*for tl_duration: federal requirement = 60 months under TANF(1998-2010), under AFDC (until 1996) = no time limit (tl_duration=0)*/;
*(1993-1996) experiment: tl_duration >0 (the larger, the stricter);
bysort state: gen temp_tl_duration = 1 if tl_duration > L.tl_duration & tl_duration!=. & L.tl_duration!=. & year>=1996;
replace temp_tl_duration = 0 if temp_tl_duration == . & year>=1996;

*(1997) experiment: ambiguous because many adopt TANF in 1997 => define experiment=1 only if different from AFDC and TANF;
bysort state: replace temp_tl_duration = 1 if tl_duration !=60 & tl_duration!=0 & tl_duration!=. & tl_duration!=L.tl_duration & year==1997;
replace temp_tl_duration = 0 if temp_tl_duration==. & year==1997;

*(1998-2010) experiment: time limit below 60 months; 
bysort state: replace temp_tl_duration = 1 if tl_duration >60 & tl_duration>0 & tl_duration!=L.tl_duration & year>=1998 & year<=2010;
replace temp_tl_duration = 0 if temp_tl_duration==. & year>=1998 & year<=2010;


*define reversal for tl_duration = 1 if state abolishes time limits / increases #months (NEW);
bysort state: gen tempr_tl_duration = 0 if year>1996 & year < 1997;
bysort state: replace tempr_tl_duration = 1 if tl_duration==0 & L.tl_duration>0 & year>=1997 & year<=2010; /*abolish time limit again*/;
bysort state: replace tempr_tl_duration = 1 if tl_duration < L.tl_duration & tl_duration!=. & L.tl_duration!=.  & year>=1997 & year<=2010; /*increase #months*/;
bysort state: gen temprr_tl_duration = tempr_tl_duration;
replace tempr_tl_duration = 0 if tempr_tl_duration==. & year>=1997 & year<=2010;
gen test = year if temp_tl_duration==1; 
bysort state: egen test1 = min(test);
replace temprr_tl_duration = 0 if year>=test1 & temprr_tl_duration==. & year>1996 & year<=2010;
drop test test1; 


*experiment: reduce intermittent time limit (NEW); 

*fix interdur (NEW);
*rename interdur interdur_old;
*gen interdur = interdur_old; 
*note: interdur = 0 no intermittent time limit (most liberal rule);
replace interdur = 2 if interdur_old ==0; 
replace interdur = 36/96 if state_code=="TX" & interdur ==1;
replace interdur = 24/48 if state_code=="VA" & interdur ==1;
replace interdur = 24/60 if state_code=="NC" & (interdur ==1 | year==1999);
replace interdur = 18/21 if state_code=="TN" & interdur ==1;
replace interdur = 24/36 if state_code=="NV" & interdur ==1;
replace interdur = 0.28 if state_code=="OR" & year>=1996 &year<=1998;

bysort state: gen temp_interdur = 1 if interdur< L.interdur & interdur!=. & L.interdur!=. & year>1993 & year<=2010;
replace temp_interdur = 0 if temp_interdur==. & year>=1996 & year<=2010;

*reversals: increase (or abolish) intermittent time limit again (NEW);
bysort state: gen tempr_interdur = 1 if interdur > L.interdur & interdur!=. & L.interdur!=. & year>1996 & year<=2010;
bysort state: gen temprr_interdur = tempr_interdur;
replace tempr_interdur = 0 if tempr_interdur==. & year>1996 & year<=2010;
gen test = year if temp_interdur==1; 
bysort state: egen test1 = min(test);
replace temprr_interdur = 0 if year>=test1 & temprr_interdur==. & year>1996 & year<=2010;
drop test test1; 


*experiment:  sharp benefit reduction when intermittent time limit is reached; 
bysort state: gen temp_limitadult = 1 if limitadult> L.limitadult & limitadult!=. & L.limitadult!=. &  year>=1996 & year<=2010;
replace temp_limitadult = 0 if temp_limitadult==. &  year>=1996 & year<=2010;

*reversals: little benefit reduction when intermittent time limit is reached;
bysort state: gen tempr_limitadult = 1 if limitadult < L.limitadult & limitadult!=. & L.limitadult!=. & year>1996 & year<=2010;
bysort state: gen temprr_limitadult =tempr_limitadult;
replace tempr_limitadult = 0 if tempr_limitadult==. & year>1996 & year<=2010;
gen test = year if temp_limitadult==1; 
bysort state: egen test1 = min(test);
replace temprr_limitadult = 0 if year>=test1 & temprr_limitadult==. & year>1996 & year<=2010;
drop test test1; 


*experiment:  abolish tl extensions (tlext=1: any type of extensions); 
bysort state: gen temp_tlext = 1 if tlext==0 & L.tlext ==1 &  year>=1996 & year<=2010;
replace temp_tlext = 0 if temp_tlext==. &  year>=1996 & year<=2010;

*reversals: introduce tl extensions again (tlext=1: any type of extensions);
bysort state: gen tempr_tlext = 1 if tlext==1 & L.tlext ==0 & year>1996 & year<=2010;
bysort state: gen temprr_tlext = tempr_tlext;
replace tempr_tlext = 0 if tempr_tlext==. & year>1996 & year<=2010;
gen test = year if temp_tlext==1; 
bysort state: egen test1 = min(test);
replace temprr_tlext = 0 if year>=test1 & temprr_tlext==. & year>1996 & year<=2010;
drop test test1; 



*EARNINGS DISREGARDS;
*--------------------------------;
*Note: earnings disregards were very restrictive under AFDC (recipient could only keep $120, after that benefits were taxed 1:1);
*=> most states increased earnings disregards after 1996 = more liberal policy; 
*experiment: increase earnings disregards; 
gen tempo_earn = 1 if earndis_month5 > 1.2*L.earndis_month5 & earndis_month5!=. & L.earndis_month5!=. & year>=1996 & year<=2010;
replace tempo_earn = 0 if tempo_earn==. &  year>=1996 & year<=2010;

*reversal: reduce earnings disregards; 
gen tempor_earn = 1 if earndis_month5 < 1.2*L.earndis_month5 & earndis_month5!=. & L.earndis_month5!=. & year>1996 & year<=2010;
gen temporr_earn = tempor_earn;
replace tempor_earn = 0 if tempor_earn==. & year>1996 & year<=2010;
gen test = year if tempo_earn==1; 
bysort state: egen test1 = min(test);
replace temporr_earn = 0 if year>=test1 & temporr_earn==. & year>1996 & year<=2010;
drop test test1; 

*to define contractive versus expansive policies, we need to turn the definition for earndis around;
gen tempa_earn = 1-tempo_earn; 
gen tempar_earn = 1-tempor_earn; 
gen temparr_earn = 1-temporr_earn;


*------------------------------------------------------------------;
*focus on large changes (restrictive) of "important" rules (N=8);
*------------------------------------------------------------------;
*famcap (family caps): use temp_famcap and tempr_famcap; 
 
*workenroll (work requirements): use temp_enroll and tempr_enroll; 

*hrsreq (work requirements); 
bysort state: gen tempb_hrsreq = 1 if hrsreq > L.hrsreq & hrsreq>=30 & hrsreq<=40 & L.hrsreq>=0 & L.hrsreq<30 &  year>=1996 & year<=2010;
replace tempb_hrsreq = 0 if tempb_hrsreq==. &  year>=1996 & year<=2010;

bysort state: gen tempbr_hrsreq = 1 if hrsreq < L.hrsreq & hrsreq>0 & hrsreq<30 & L.hrsreq>=30 & L.hrsreq<=40 & hrsreq!=. & L.hrsreq!=. &  year>1996 & year<=2010;
replace tempbr_hrsreq = 0 if tempbr_hrsreq==. & year>1996 & year<=2010;

*dsanction (sanctions); 
bysort state: gen tempb_dsanction = 1 if dsanction==1 & L.dsanction==0 &  year>=1996 & year<=2010; 
replace tempb_dsanction = 0 if tempb_dsanction==. &  year>=1996 & year<=2010;

bysort state: gen tempbr_dsanction = 1 if dsanction==0 & L.dsanction==1 & year>1996 & year<=2010; 
replace tempbr_dsanction = 0 if tempbr_dsanction==. & year>1996 & year<=2010;

*reapply (sanctions): use temp_reapply and tempr_reapply;

*tl_duration (time limits); 
bysort state: gen tempb_tl_duration = 1 if tl_duration>60 & tl_duration<120 & tl_duration>L.tl_duration & year>=1996 & year<=2010; 
replace tempb_tl_duration = 0 if tempb_tl_duration==. & year>=1996 & year<=2010;

bysort state: gen tempbr_tl_duration = 1 if tl_duration>=0 & tl_duration<=60 & L.tl_duration>60 & L.tl_duration<=120 & year>1996 & year<=2010; 
replace tempbr_tl_duration = 0 if tempbr_tl_duration==. & year>1996 & year<=2010;

*limitadult (time limits); 
bysort state: gen tempb_limitadult = 1 if limitadult==2 & L.limitadult<2 & L.limitadult>=0 & year>=1996 & year<=2010; 
replace tempb_limitadult = 0 if tempb_limitadult==. & year>=1996 & year<=2010;

bysort state: gen tempbr_limitadult = 1 if limitadult>=0 & limitadult<2 & L.limitadult==2 & year>1996 & year<=2010; 
replace tempbr_limitadult = 0 if tempbr_limitadult==. & year>1996 & year<=2010;

*mandjob (eligibility): use tempo_mandjob and tempor_mandjob; 


*----------------------------------------------------;
*CONSTRUCT EXPERIMENTATION AND REVERSAL MEASURES;
*----------------------------------------------------;
cap drop experiment_base_old dexperiment_base_old reversal_base_old dreversal_base_old; 

*sum over all rules in the set;
cap drop experiment_base experiment_base1 experiment_base_alt;
egen experiment_base = rowtotal(temp_* tempo_dsanctionini) if year>=1996 & year<=2010;
label var experiment_base "Base Rules 1stDef(N=13)";
egen experiment_base1 = rowtotal(temp_* tempo_dsanctionini tempo_mandjob tempo_divpaymt tempo_earn) if year>=1996 & year<=2010;
label var experiment_base1 "Base+DivPay+MandJob+EarnDis (N=16)";
egen experiment_base_alt = rowtotal(temp_* tempo_sanction1ben tempo_sanction1dur) if year>=1996 & year<=2010;
label var experiment_base_alt "Base+InitialSanctions_alt(99)";

cap drop reversal_base reversal_base1 reversal_base_alt;
egen reversal_base = rowtotal(tempr_* tempor_dsanctionini) if year>=1996 & year<=2010;
label var reversal_base "Base Rules 1stDef (N=13)";
egen reversal_base1 = rowtotal(tempr_* tempor_dsanctionini tempor_mandjob tempor_divpaymt tempor_earn) if year>=1996 & year<=2010;
label var reversal_base1 "Base+DivPay+MandJob (N=16)";
egen reversal_base_alt = rowtotal(tempr_* tempor_sanction1ben tempor_sanction1dur) if year>=1996 & year<=2010;
label var reversal_base_alt "Base+InitialSanctions_alt(99)";

cap drop reversal_cond reversal_cond1;
egen reversal_cond = rowtotal(temprr_* temporr_dsanctionini) if year>=1996 & year<=2010;
label var reversal_cond "Base Rules 1stDef (N=13)";
egen reversal_cond1 = rowtotal(temprr_* temporr_dsanctionini temporr_mandjob temporr_divpaymt temporr_earn) if year>=1996 & year<=2010;
label var reversal_cond1 "Base+DivPay+MandJob (N=16)";


*dummy variables for experimentation and reversals;
drop dexperiment_base dexperiment_base1;
gen dexperiment_base=1 if experiment_base>=1 & experiment_base<100;
replace dexperiment_base=0 if experiment_base==0;
label var dexperiment_base "Base Rules 1stDef (N=13)";
gen dexperiment_base1=1 if experiment_base1>=1 & experiment_base1<100;
replace dexperiment_base1=0 if experiment_base1==0;
label var dexperiment_base1 "Base+DivPay+MandJob+EarnDis (N=16)";

cap drop dreversal_base dreversal_base1;
gen dreversal_base=1 if reversal_base>=1 & reversal_base<100;
replace dreversal_base=0 if reversal_base==0;
label var dreversal_base "Base Rules 1stDef (N=13)";
gen dreversal_base1=1 if reversal_base1>=1 & reversal_base1<100;
replace dreversal_base1=0 if reversal_base1==0;
label var dreversal_base1 "Base+DivPay+MandJob+EarnDis (N=16)";


cap drop dreversal_cond dreversal_cond1;
gen dreversal_cond=1 if reversal_cond>=1 & reversal_cond<100;
replace dreversal_cond=0 if reversal_cond==0;
label var dreversal_cond "Base Rules 1stDef (N=13)";
gen dreversal_cond1=1 if reversal_cond1>=1 & reversal_cond1<100;
replace dreversal_cond1=0 if reversal_cond1==0;
label var dreversal_cond1 "Base+DivPay+MandJob+EarnDis (N=16)";


*large changes in important rules only; 
cap drop experiment_large reversal_large;
egen experiment_large = rowtotal(temp_famcap temp_enroll tempb_hrsreq tempb_dsanction temp_reapply tempb_limitadult tempb_tl_duration tempo_mandjob) if year>=1996 & year<=2010;
label var experiment_large "Large Rule Changes 1stDef(N=8)";

egen reversal_large = rowtotal(tempr_famcap tempr_enroll tempbr_hrsreq tempbr_dsanction tempr_reapply tempbr_limitadult tempbr_tl_duration tempor_mandjob) if year>=1996 & year<=2010;
label var reversal_large "Large Rule Changes 1stDef(N=8)";


*contractive versus expansive reforms (as alternative measures for experiment);
cap drop reform_restrict reform_restrict1;
egen reform_restrict = rowtotal(temp_* tempo_dsanctionini) if year>=1996 & year<=2010;
label var reform_restrict "Restrictive Reform 1stDef (N=13)";
egen reform_restrict1 = rowtotal(temp_* tempo_dsanctionini tempa_earn tempo_mandjob tempo_divpaymt) if year>=1996 & year<=2010;
label var reform_restrict1 "Restrict+DivPay+MandJob+EarnDis (N=16)";

cap drop reform_expand reform_expand1;
egen reform_expand = rowtotal(tempr_* tempor_dsanctionini) if year>=1996 & year<=2010;
egen reform_expand_cond = rowtotal(temprr_* temporr_dsanctionini) if year>=1996 & year<=2010;
label var reform_expand "Expansive Reform (N=13)";
egen reform_expand1 = rowtotal(tempr_* tempor_dsanctionini tempar_earn tempor_mandjob tempor_divpaymt) if year>=1996 & year<=2010;
egen reform_expand1_cond = rowtotal(temprr_* temporr_dsanctionini temparr_earn temporr_mandjob temporr_divpaymt) if year>=1996 & year<=2010;
label var reform_expand1 "Expand+DivPay+MandJob+EarnDis (N=16)";


*------------------------------------------------------------------------------------;
*------------------------------------------------------------------------------------;
*SECOND DEFINITION: first change = experiment, second/opposite change = reversal;
*------------------------------------------------------------------------------------;
*------------------------------------------------------------------------------------;

* Basic Set of Rules;
*----------------------;
* FAMILY CAPS;
* WORK REQUIREMENTS;
* SANCTIONS;
* TIME LIMITS;
* MANDJOB DIVPAYMT;
*----------------------;
sort state year;

cap drop maxben_new;
gen maxben_new = maxben;
replace maxben_new = afdc_benfam if year<1996 & year>=1992;

cap drop test test1 testo testo1; 

local xvar "famcap hrsreq workenroll worklimit workex_no sanctionben sanctiondur reapply interdur limitadult tlext"; 

foreach X of local xvar {; 
	bysort state: gen test = year if `X' > L.`X' & `X'!=. & L.`X' !=. &year>=1996; 
	bysort state: egen testo =min(test); 

	bysort state: gen test1 = year if `X' < L.`X' & `X'!=. & L.`X' !=. & year>=1996; 
	bysort state: egen testo1 =min(test1);

	*all changes in policy: define first rule change as experiment, opposite direction as reversal (indep. of direction);
	cap drop temp_`X'; cap drop tempr_`X'; cap drop temprr_`X';		
	gen temp_`X' = 1 if testo < testo1 & test==year;     	*experiment;
	replace temp_`X' = 1 if testo1 < testo & test1==year;
	replace temp_`X' = 0 if temp_`X'==. & year>=1996&year<=2010; 
 
	gen tempr_`X' = 1 if testo > testo1 & test==year;		*reversal;
	replace tempr_`X' = 1 if testo1 > testo & test1==year;
	gen temprr_`X' = tempr_`X';
	replace tempr_`X' = 0 if tempr_`X'==. & year>=1996&year<=2010; 
	replace temprr_`X' = 0 if year>=testo & testo < testo1 & year>=1996&year<=2010;
	replace temprr_`X' = 0 if year>=testo1 & testo1 < testo & year>=1996&year<=2010;

	*focus on first change only; 
	cap drop temp1_`X'; cap drop tempr1_`X'; cap drop temprr_`X';		
	gen temp1_`X' = 1 if testo < testo1 & testo==year;
	replace temp1_`X' = 1 if testo1 < testo & testo1==year;
	replace temp1_`X' = 0 if temp1_`X'==. & year>=1996&year<=2010; 
 
	gen tempr1_`X' = 1 if testo > testo1 & testo==year;
	replace tempr1_`X' = 1 if testo1 > testo & testo1==year;
	replace tempr1_`X' = 0 if tempr1_`X'==. & year>=1996&year<=2010; 
	
	drop test test1 testo testo1; 
};


local xvar "dsanctionini mandjob divpaymt";

foreach X of local xvar {; 
	gen test = year if `X' > L.`X' & `X'!=. & L.`X' !=. & year>=1996; 
	bysort state: egen testo =min(test); 

	gen test1 = year if `X' < L.`X' & `X'!=. & L.`X' !=. & year>=1996; 
	bysort state: egen testo1 =min(test1);

	cap drop tempo_`X' tempor_`X'; cap drop temporr_`X';		
	gen tempo_`X' = 1 if testo < testo1 & test==year;
	replace tempo_`X' = 1 if testo1 < testo & test1==year;
	replace tempo_`X' = 0 if tempo_`X'==. & year>=1996&year<=2010; 
 
	gen tempor_`X' = 1 if testo > testo1 & test==year;
	replace tempor_`X' = 1 if testo1 > testo & test1==year;
	gen temporr_`X' = tempor_`X';
	replace tempor_`X' = 0 if tempor_`X'==. & year>=1996&year<=2010; 
	replace temporr_`X' = 0 if year>=testo & testo < testo1 & year>=1996&year<=2010;
	replace temporr_`X' = 0 if year>=testo1 & testo1 < testo & year>=1996&year<=2010;

	*focus on first change only; 
	cap drop tempo1_`X'; cap drop tempor1_`X';	
	gen tempo1_`X' = 1 if testo < testo1 & testo==year;
	replace tempo1_`X' = 1 if testo1 < testo & testo1==year;
	replace tempo1_`X' = 0 if tempo1_`X'==. & year>=1996&year<=2010; 
 
	gen tempor1_`X' = 1 if testo > testo1 & testo==year;
	replace tempor1_`X' = 1 if testo1 > testo & testo1==year;
	replace tempor1_`X' = 0 if tempor1_`X'==. & year>=1996&year<=2010; 

	drop test test1 testo testo1; 
};


local xvar "maxben_new earndis_month5"; 

foreach X of local xvar {; 
	gen test = year if `X' > 1.2*L.`X' & `X'!=. & L.`X' !=. & year>=1996; 
	bysort state: egen testo =min(test); 

	gen test1 = year if `X' < 1.2*L.`X' & `X'!=. & L.`X' !=. & year>=1996; 
	bysort state: egen testo1 =min(test1);

	cap drop temp_`X' tempr_`X'; cap drop temporr_`X';		
	gen tempo_`X' = 1 if testo < testo1 & test==year;
	replace tempo_`X' = 1 if testo1 < testo & test1==year;
	replace tempo_`X' = 0 if tempo_`X'==. & year>=1996&year<=2010; 
 
	gen tempor_`X' = 1 if testo > testo1 & test==year;
	replace tempor_`X' = 1 if testo1 > testo & test1==year;
	gen temporr_`X' = tempor_`X';
	replace tempor_`X' = 0 if tempor_`X'==. & year>=1996&year<=2010; 
	replace temporr_`X' = 0 if year>=testo & testo < testo1 & year>=1996&year<=2010;
	replace temporr_`X' = 0 if year>=testo1 & testo1 < testo & year>=1996&year<=2010;

	*focus on first change only; 
	cap drop tempo1_`X'; cap drop tempor1_`X';	
	gen tempo1_`X' = 1 if testo < testo1 & testo==year;
	replace tempo1_`X' = 1 if testo1 < testo & testo1==year;
	replace tempo1_`X' = 0 if tempo1_`X'==. & year>=1996&year<=2010; 
 
	gen tempor1_`X' = 1 if testo > testo1 & testo==year;
	replace tempor1_`X' = 1 if testo1 > testo & testo1==year;
	replace tempor1_`X' = 0 if tempor1_`X'==. & year>=1996&year<=2010; 

	drop test test1 testo testo1; 
};


local xvar "sanction1dur sanction1ben"; 

foreach X of local xvar {; 
	gen test = year if `X' > L.`X' & `X'!=. & L.`X' !=.; 
	bysort state: egen testo =min(test); 

	gen test1 = year if `X' < L.`X' & `X'!=. & L.`X' !=.; 
	bysort state: egen testo1 =min(test1);

	cap drop tempo_`X' tempor_`X'; cap drop temporr_`X';		
	gen tempo_`X' = 1 if testo < testo1 & test==year;
	replace tempo_`X' = 1 if testo1 < testo & test1==year;
	replace tempo_`X' = 0 if tempo_`X'==. & year>=1999&year<=2010; 
 
	gen tempor_`X' = 1 if testo > testo1 & test==year;
	replace tempor_`X' = 1 if testo1 > testo & test1==year;
	gen temporr_`X' = tempor_`X';
	replace tempor_`X' = 0 if tempor_`X'==. & year>=1999&year<=2010; 
	replace temporr_`X' = 0 if year>=testo & testo < testo1 & year>=1996&year<=2010;
	replace temporr_`X' = 0 if year>=testo1 & testo1 < testo & year>=1996&year<=2010;
	drop test test1 testo testo1; 
};


*TIME LIMIT; 
*>0 if year<=1996 /*a few cases in 1996*/
*go from 0 to 60 = no experiment /*>=1996*/

*stricter time limit;
gen test = year if tl_duration > L.tl_duration & tl_duration!=. & L.tl_duration !=.; 
*exception: jump to 60months to comply with federal guidelines;
replace test = . if tl_duration==60 & L.tl_duration==0; 
bysort state: egen testo =min(test); 

*laxer time limits; 
gen test1 = year if tl_duration < L.tl_duration & tl_duration!=. & L.tl_duration !=.; 
bysort state: egen testo1 =min(test1);

cap drop temp_tl_duration tempr_tl_duration; cap drop temprr_tl_duration;
gen temp_tl_duration = 1 if testo < testo1 & test==year;
replace temp_tl_duration = 1 if testo1 < testo & test1==year;
replace temp_tl_duration = 0 if temp_tl_duration==. & year>=1996&year<=2010; 
 
gen tempr_tl_duration = 1 if testo > testo1 & test==year;
replace tempr_tl_duration = 1 if testo1 > testo & test1==year;
gen temprr_tl_duration = tempr_tl_duration;
replace tempr_tl_duration = 0 if tempr_tl_duration==. & year>1996&year<=2010; 
replace temprr_tl_duration = 0 if year>=testo & testo < testo1 & year>=1996&year<=2010;
replace temprr_tl_duration = 0 if year>=testo1 & testo1 < testo & year>=1996&year<=2010;


*first change in rule only; 
gen temp1_tl_duration = 1 if testo < testo1 & testo==year;
replace temp1_tl_duration = 1 if testo1 < testo & testo1==year;
replace temp1_tl_duration = 0 if temp_tl_duration==. & year>=1996&year<=2010; 
 
gen tempr1_tl_duration = 1 if testo > testo1 & testo==year;
replace tempr1_tl_duration = 1 if testo1 > testo & testo1==year;
replace tempr1_tl_duration = 0 if tempr1_tl_duration==. & year>1996&year<=2010; 

drop test test1 testo testo1; 


*----------------------------------------------------;
*CONSTRUCT EXPERIMENTATION AND REVERSAL MEASURES;
*----------------------------------------------------;
*all changes; 
cap drop experimenta_base experimenta_base1 experimenta_base_alt;
egen experimenta_base = rowtotal(temp_* tempo_dsanctionini) if year>=1996 & year<=2010;
label var experimenta_base "Base Rules 2ndDef (N=13)"; 
egen experimenta_base1 = rowtotal(temp_* tempo_dsanctionini tempo_mandjob tempo_divpaymt tempo_earndis) if year>=1996 & year<=2010;
label var experimenta_base1 "Base+MandJob+DivPay+EarnDis 2ndDef (N=16)"; 
egen experimenta_base_alt = rowtotal(temp_* tempo_sanction1ben tempo_sanction1dur) if year>=1996 & year<=2010;

cap drop reversala_base reversala_base1 reversala_base_alt;
egen reversala_base = rowtotal(tempr_* tempor_dsanctionini) if year>1996 & year<=2010;
label var reversala_base "Base Rules 2ndDef (N=13)"; 
egen reversala_base1 = rowtotal(tempr_* tempor_dsanctionini tempor_mandjob tempor_divpaymt tempor_earndis) if year>1996 & year<=2010;
label var reversala_base1 "Base+MandJob+DivPay 2ndDef (N=16)"; 
egen reversala_base_alt = rowtotal(tempr_* tempor_sanction1ben tempor_sanction1dur) if year>1996 & year<=2010;

*conditional on experiment (drop false zeros);
egen reversala_cond = rowtotal(temprr_* temporr_dsanctionini) if year>1996 & year<=2010;
label var reversala_cond "Base Rules 2ndDef (N=13)"; 
egen reversala_cond1 = rowtotal(temprr_* temporr_dsanctionini temporr_mandjob temporr_divpaymt temporr_earndis) if year>1996 & year<=2010;
label var reversala_cond1 "Base+MandJob+DivPay 2ndDef (N=16)"; 


cap drop dexperimenta_base dexperimenta_base1 dreversala_base dreversala_base1;
gen dexperimenta_base=1 if experimenta_base>=1 & experimenta_base<100;
replace dexperimenta_base=0 if experimenta_base==0;
gen dexperimenta_base1=1 if experimenta_base1>=1 & experimenta_base1<100;
replace dexperimenta_base1=0 if experimenta_base1==0;

gen dreversala_base=1 if reversala_base>=1 & reversala_base<100;
replace dreversala_base=0 if reversala_base==0;
gen dreversala_base1=1 if reversala_base1>=1 & reversala_base1<100;
replace dreversala_base1=0 if reversala_base1==0;

*conditional on experiment (drop false zeros);
gen dreversala_cond=1 if reversala_cond>=1 & reversala_cond<100;
replace dreversala_cond=0 if reversala_cond==0;
gen dreversala_cond1=1 if reversala_cond1>=1 & reversala_cond1<100;
replace dreversala_cond1=0 if reversala_cond1==0;


*first change in rule only;
cap drop experiment1a_base; cap drop experiment1a_base1;
egen experiment1a_base = rowtotal(temp1_* tempo1_dsanctionini) if year>=1996 & year<=2010;
label var experiment1a_base "1st Base Rules 2ndDef (N=13)"; 
egen experiment1a_base1 = rowtotal(temp1_* tempo1_dsanctionini tempo1_mandjob tempo1_divpaymt tempo1_earndis) if year>=1996 & year<=2010;
label var experiment1a_base1 "1st Base+MandJob+DivPay+EarnDis 2ndDef (N=16)"; 

cap drop reversal1a_base; cap drop reversal1a_base1;
egen reversal1a_base = rowtotal(tempr1_* tempor1_dsanctionini) if year>1996 & year<=2010;
label var reversal1a_base "1st Base Rules 2ndDef (N=13)"; 
egen reversal1a_base1 = rowtotal(tempr1_* tempor1_dsanctionini tempor1_mandjob tempor1_divpaymt tempor1_earndis) if year>1996 & year<=2010;
label var reversal1a_base1 "1st Base+MandJob+DivPay 2ndDef (N=16)"; 

cap drop dexperiment1a_base dexperiment1a_base1 dreversal1a_base dreversal1a_base1;
gen dexperiment1a_base=1 if experiment1a_base>=1 & experiment1a_base<100;
replace dexperiment1a_base=0 if experiment1a_base==0;
gen dexperiment1a_base1=1 if experiment1a_base1>=1 & experiment1a_base1<100;
replace dexperiment1a_base1=0 if experiment1a_base1==0;

gen dreversal1a_base=1 if reversal1a_base>=1 & reversal1a_base<100;
replace dreversal1a_base=0 if reversal1a_base==0;
gen dreversal1a_base1=1 if reversal1a_base1>=1 & reversal1a_base1<100;
replace dreversal1a_base1=0 if reversal1a_base1==0;


*------------------------------------------------------------------------------------;
*USE BROADER SET OF RULES (+ 2nd definition);
*------------------------------------------------------------------------------------;
cap drop test test1 testo testo1; 

local xvar "schoolreq schoolbonus imreq healthreq eligpreg eligminor twoparwait twoparwkhist assets vehexapp"; 

foreach X of local xvar {; 
	gen test = year if `X' > L.`X' & `X'!=. & L.`X' !=.; 
	bysort state: egen testo =min(test); 

	gen test1 = year if `X' < L.`X' & `X'!=. & L.`X' !=.; 
	bysort state: egen testo1 =min(test1);

	*all changes in rules in same direction;
	cap drop temp_`X' tempr_`X';	
	gen temp_`X' = 1 if testo < testo1 & test==year;
	replace temp_`X' = 1 if testo1 < testo & test1==year;
	replace temp_`X' = 0 if temp_`X'==. & year>=1996&year<=2010; 
 
	gen tempr_`X' = 1 if testo > testo1 & test==year;
	replace tempr_`X' = 1 if testo1 > testo & test1==year;
	replace tempr_`X' = 0 if tempr_`X'==. & year>1996&year<=2010; 

	*first change in rule only;
	cap drop temp1_`X' tempr1_`X';	
	gen temp1_`X' = 1 if testo < testo1 & testo==year;
	replace temp1_`X' = 1 if testo1 < testo & testo1==year;
	replace temp1_`X' = 0 if temp1_`X'==. & year>=1996&year<=2010; 
 
	gen tempr1_`X' = 1 if testo > testo1 & testo==year;
	replace tempr1_`X' = 1 if testo1 > testo & testo1==year;
	replace tempr1_`X' = 0 if tempr1_`X'==. & year>=1996&year<=2010; 

	drop test test1 testo testo1; 
};

*all changes;
cap drop experimentb_base experimentb_base1 experimentb_base_alt;
egen experimentb_base = rowtotal(temp_* tempo_dsanctionini tempo_maxben) if year>=1996 & year<=2010;
egen experimentb_base1 = rowtotal(temp_* tempo_dsanctionini tempo_mandjob tempo_divpaymt tempo_earndis) if year>=1996 & year<=2010;
egen experimentb_base_alt = rowtotal(temp_* tempo_sanction1ben tempo_sanction1dur) if year>=1996 & year<=2010;

cap drop reversalb_base reversalb_base1 reversalb_base_alt;
egen reversalb_base = rowtotal(tempr_* tempor_dsanctionini tempor_maxben) if year>1996 & year<=2010;
egen reversalb_base1 = rowtotal(tempr_* tempor_dsanctionini tempor_mandjob tempor_divpaymt tempor_earndis) if year>1996 & year<=2010;
egen reversalb_base_alt = rowtotal(tempr_* tempor_sanction1ben tempor_sanction1dur) if year>1996 & year<=2010;

cap drop dexperimentb_base dexperimentb_base1 dreversalb_base dreversalb_base1;
gen dexperimentb_base=1 if experimentb_base>=1 & experimentb_base<100;
replace dexperimentb_base=0 if experimentb_base==0;
gen dexperimentb_base1=1 if experimentb_base1>=1 & experimentb_base1<100;
replace dexperimentb_base1=0 if experimentb_base1==0;

gen dreversalb_base=1 if reversalb_base>=1 & reversalb_base<100;
replace dreversalb_base=0 if reversalb_base==0;
gen dreversalb_base1=1 if reversalb_base1>=1 & reversalb_base1<100;
replace dreversalb_base1=0 if reversalb_base1==0;


*first change only;
cap drop experiment1b_base experiment1b_base1;
egen experiment1b_base = rowtotal(temp1_* tempo1_dsanctionini tempo1_maxben) if year>=1996 & year<=2010;
egen experiment1b_base1 = rowtotal(temp1_* tempo1_dsanctionini tempo1_mandjob tempo1_divpaymt tempo1_earndis) if year>=1996 & year<=2010;

cap drop reversal1b_base reversal1b_base1;
egen reversal1b_base = rowtotal(tempr1_* tempor1_dsanctionini tempor1_maxben) if year>1996 & year<=2010;
egen reversal1b_base1 = rowtotal(tempr1_* tempor1_dsanctionini tempor1_mandjob tempor1_divpaymt tempor1_earndis) if year>1996 & year<=2010;

cap drop dexperiment1b_base dexperiment1b_base1 dreversal1b_base dreversal1b_base1;
gen dexperiment1b_base=1 if experiment1b_base>=1 & experiment1b_base<100;
replace dexperiment1b_base=0 if experiment1b_base==0;
gen dexperiment1b_base1=1 if experiment1b_base1>=1 & experiment1b_base1<100;
replace dexperiment1b_base1=0 if experiment1b_base1==0;

gen dreversal1b_base=1 if reversal1b_base>=1 & reversal1b_base<100;
replace dreversal1b_base=0 if reversal1b_base==0;
gen dreversal1b_base1=1 if reversal1b_base1>=1 & reversal1b_base1<100;
replace dreversal1b_base1=0 if reversal1b_base1==0;


*also add rules for aliens;
*----------------------------; 
cap drop test test1 testo testo1; 

local xvar "alienpre_law alienpre_ref alienpre_dep alienpre_par alienpre_bat alienprenon_law alienprenon_par alienprenon_bat alienprenon_non alienpost5_law alienpost5_ref alienpost5_dep alienpost5_par alienpost5_bat"; 

foreach X of local xvar {; 
	gen test = year if `X' > L.`X' & `X'!=. & L.`X' !=.; 
	bysort state: egen testo =min(test); 

	gen test1 = year if `X' < L.`X' & `X'!=. & L.`X' !=.; 
	bysort state: egen testo1 =min(test1);

	cap drop temp_`X' tempr_`X';	
	gen temp_`X' = 1 if testo < testo1 & test==year;
	replace temp_`X' = 1 if testo1 < testo & test1==year;
	replace temp_`X' = 0 if temp_`X'==. & year>=1996&year<=2010; 
 
	gen tempr_`X' = 1 if testo > testo1 & test==year;
	replace tempr_`X' = 1 if testo1 > testo & test1==year;
	replace tempr_`X' = 0 if tempr_`X'==. & year>1996&year<=2010; 

	drop test test1 testo testo1; 
};

cap drop experimentc_base experimentc_base1; cap drop experimentc_base_alt;
egen experimentc_base = rowtotal(temp_* tempo_dsanctionini tempo_maxben) if year>=1996 & year<=2010;
egen experimentc_base1 = rowtotal(temp_* tempo_dsanctionini tempo_mandjob tempo_divpaymt tempo_earndis) if year>=1996 & year<=2010;
*egen experimentc_base_alt = rowtotal(temp_* tempo_sanction1ben tempo_sanction1dur) if year>=1996 & year<=2010;

cap drop reversalc_base reversalc_base1; cap drop reversalc_base_alt;
egen reversalc_base = rowtotal(tempr_* tempor_dsanctionini tempo_maxben) if year>1996 & year<=2010;
egen reversalc_base1 = rowtotal(tempr_* tempor_dsanctionini tempor_mandjob tempor_divpaymt tempor_earndis) if year>1996 & year<=2010;
*egen reversalc_base_alt = rowtotal(tempr_* tempor_sanction1ben tempor_sanction1dur) if year>=1996 & year<=2010;

cap drop dexperimentc_base dexperimentc_base1 dreversalc_base dreversalc_base1;
gen dexperimentc_base=1 if experimentc_base>=1 & experimentc_base<100;
replace dexperimentc_base=0 if experimentc_base==0;
gen dexperimentc_base1=1 if experimentc_base1>=1 & experimentc_base1<100;
replace dexperimentc_base1=0 if experimentc_base1==0;

gen dreversalc_base=1 if reversalc_base>=1 & reversalc_base<100;
replace dreversalc_base=0 if reversalc_base==0;
gen dreversalc_base1=1 if reversalc_base1>=1 & reversalc_base1<100;
replace dreversalc_base1=0 if reversalc_base1==0;

drop if state==.;

drop temp_* tempr_* tempo_* tempor_* tempa_* tempar_* tempb_* tempbr_* temp1_* tempr1_* tempo1_* tempor1_*;

*CHECK: how do different experimentation/reversal measures compare?;
bysort year: egen testa =mean(reversal_base);
bysort year: egen testb =mean(reversal_base1);
bysort year: egen testc =mean(reversal_large);
bysort year: egen testd =mean(reversala_base);
bysort year: egen teste =mean(reversala_base1);
bysort year: egen testf =mean(reversal1a_base);
label var testa "Direction of Change";
label var testb "Direction, Broader Set";
label var testc "Direction, Large Changes";
label var testd "1st/2nd, Base Set";
label var teste "1st/2nd, Broader Set";
label var testf "1st/2nd, First Change only";

graph twoway line testa year if year>=1995 & year<=2010 || line testb year if year>=1995 & year<=2010
		  || line testc year if year>=1995 & year<=2010 || line testd year if year>=1995 & year<=2010 
		  || line teste year if year>=1995 & year<=2010  || line testf year if year>=1995 & year<=2010, 
		  title("Reversal Measures 1996-2010") 
		  saving("$results\Reversals_062014.gph", replace);
*yes: they look pretty similar; 
drop test*;

bysort year: egen testa =mean(experiment_base);
bysort year: egen testb =mean(experiment_base1);
bysort year: egen testc =mean(experiment_large);
bysort year: egen testd =mean(experimenta_base);
bysort year: egen teste =mean(experimenta_base1);
bysort year: egen testf =mean(experiment1a_base);
label var testa "Direction of Change";
label var testb "Direction, Broader Set";
label var testc "Direction, Large Changes";
label var testd "1st/2nd, Base Set";
label var teste "1st/2nd, Broader Set";
label var testf "1st/2nd, First Change only";

graph twoway line testa year if year>=1995 & year<=2010 || line testb year if year>=1995 & year<=2010 
		  || line testc year if year>=1995  & year<=2010|| line testd year if year>=1995  & year<=2010
		  || line teste year if year>=1995  & year<=2010 || line testf year if year>=1995  & year<=2010, 
		  title("Experimentation Measures 1996-2010")
		  saving("$results\Experiments_062014.gph", replace);
drop test*;


*------------------------------------------------------------------------------------;
*------------------------------------------------------------------------------------;
*ALT FIRST DEFINITION: use code from treatment_reversal_old;
*= calculates measures using n-1 rather than L. -> check whether different!;
*------------------------------------------------------------------------------------;
*------------------------------------------------------------------------------------;

*start with a narrow set of "important" rules (N=11);
*-----------------------------------------------------;
cap drop temp_* tempr_* tempo_* tempor_*;
sort state year;

*family caps;
gen temp_famcap = 1 if famcap==1 & famcap[_n-1]==0 & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
replace temp_famcap = 0 if temp_famcap==. & year>=1996 & year<=2010;

gen tempr_famcap = 1 if famcap==0 & famcap[_n-1]==1 & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
replace tempr_famcap = 0 if tempr_famcap==. & year>=1997 & year<=2010;


*work requirements;
for var workenroll worklimit: gen temp_X = 1 if X==1 & X[_n-1]==0 & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
for var workenroll worklimit: replace temp_X = 0 if temp_X==. & year>=1996 & year<=2010;

for var workenroll worklimit: gen tempr_X = 1 if X==0 & X[_n-1]==1 & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var workenroll worklimit: replace temp_X = 0 if tempr_X==. & year>=1997 & year<=2010;

gen temp_hrsreq = 1 if hrsreq > hrsreq[_n-1] & hrsreq!=. & hrsreq[_n-1]!=. & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
replace temp_hrsreq = 0 if temp_hrsreq==. & year>=1996 & year<=2010;

gen tempr_hrsreq = 1 if hrsreq < hrsreq[_n-1] & hrsreq!=. & hrsreq[_n-1]!=. & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
replace tempr_hrsreq = 0 if tempr_hrsreq==. & year>=1997 & year<=2010;


*sanctions;
for var sanctionben sanctiondur: gen temp_X = 1 if X > X[_n-1] & X!=. & X[_n-1]!=.  & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
for var sanctionben sanctiondur: replace temp_X = 0 if temp_X==. & year>=1996 & year<=2010;

for var sanctionben sanctiondur: gen tempr_X = 1 if X < X[_n-1]==1 & X!=. & X[_n-1]!=.  & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var sanctionben sanctiondur: replace tempr_X = 0 if tempr_X==. & year>=1997 & year<=2010;

/*
*could add: duration and severity of initial sanctions;
for var sanction1ben sanction1dur: gen temp_X = 1 if X > X[_n-1] & X!=. & X[_n-1]!=.  & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var sanction1ben sanction1dur: replace temp_X = 0 if temp_X==. & year>=1996 & year<=2010;

for var sanction1ben sanction1dur: gen tempr_X = 1 if X < X[_n-1]==1 & X!=. & X[_n-1]!=.  & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var sanction1ben sanction1dur: replace tempr_X = 0 if tempr_X==. & year>=1996 & year<=2010;
*/;

*could add: dsanction (0/1 whether most severe sanction takes away full family benefit);
for var reapply dsanctionini: gen temp_X = 1 if X==1 & X[_n-1]==0 & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
for var reapply dsanctionini: replace temp_X = 0 if temp_X==. & year>=1996 & year<=2010;

for var reapply dsanctionini: gen tempr_X = 1 if X==0 & X[_n-1]==1 & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var reapply dsanctionini: replace tempr_X = 0 if tempr_X==. & year>=1997 & year<=2010;


*time limits;
*for tl_duration: federal requirement = 60 months under TANF(1998-2010), under AFDC 0 months (until 1996);
*1997 ambiguous because many adopt TANF in 1997 => define experiment=1 only if different from AFDC and TANF;
gen temp_tl_duration = 1 if duration >0 & duration<60 & duration!=duration[_n-1] & duration!=. & duration[_n-1]!=. & year>=1993 & year<=1996 & state==state[_n-1];
replace temp_tl_duration = 0 if duration == 0 & year>=1993 & year<=1996;

replace temp_tl_duration = 1 if duration !=60 & duration!=0 & duration!=. & duration!=duration[_n-1] & year==1997 & state==state[_n-1];
replace temp_tl_duration = 0 if duration==duration[_n-1] & year==1997 & state==state[_n-1];

replace temp_tl_duration = 1 if duration <60 & duration>0 & duration!=duration[_n-1] & year>=1998 & year<=2010 & state==state[_n-1];
replace temp_tl_duration = 0 if duration==duration[_n-1] & year>=1998 & year<=2010 & state==state[_n-1];

*define reversal for tl_duration = 1 if state abolishes time limits / increases #months;
gen tempr_tl_duration = 0 if year>=1997 & year<=1997;
replace tempr_tl_duration = 1 if duration==0 & duration[_n-1]>0 & year>=1998 & year<=2010 & state==state[_n-1]; /*abolish time limit again*/;
replace tempr_tl_duration = 1 if duration > duration[_n-1] & duration!=. & duration[_n-1]!=.  & year>=1998 & year<=2010 & state==state[_n-1]; /*increase #months*/;
replace tempr_tl_duration = 0 if tempr_tl_duration==. & year>=1998 & year<=2010;


for var limitadult interdur: gen temp_X = 1 if X > X[_n-1] & X!=. & X[_n-1]!=.  & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
for var limitadult interdur: replace temp_X = 0 if temp_X==. & year>=1996 & year<=2010;

for var limitadult interdur: gen tempr_X = 1 if X < X[_n-1] & X!=. & X[_n-1]!=. & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var limitadult interdur: replace tempr_X = 0 if tempr_X==. & year>=1996 & year<=2010;

for var tlext: gen temp_X = 1 if X==1 & X[_n-1]==0 & year-1==year[_n-1] & year>=1996 & state==state[_n-1];
for var tlext: replace temp_X = 0 if temp_X==. & year>=1996 & year<=2010;

for var tlext: gen tempr_X = 1 if X==0 & X[_n-1]==1 & year-1==year[_n-1] & year>=1997 & state==state[_n-1];
for var tlext: replace tempr_X = 0 if tempr_X==. & year>=1997 & year<=2010;


*sum over all rules in the set;
egen experiment_test = rowtotal(temp_*) if year>=1996 & year<=2010;
egen reversal_test = rowtotal(tempr_*) if year>=1997 & year<=2010;
gen dexperiment_test=1 if experiment_test>=1 & experiment_test<100;
replace dexperiment_test=0 if experiment_test==0;
gen dreversal_test=1 if reversal_test>=1 & reversal_test<100;
replace dreversal_test=0 if reversal_test==0;


save "welfarereform_062014_v43_experimentreversal_newmeasures.dta", replace;
