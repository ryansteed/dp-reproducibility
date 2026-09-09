clear
set more off
set matsize 2000

*------------------------------------------------------------------------------------
*Clean up missings and coding errors in Welfare Policy Rules
*
*start from latest dataset (before creating indices): welfarereform_v10.dta
*-----------------------------------------------------------------------------------

use welfarereform_062012_v12.dta, clear 
drop if state==0

*mandjob and divpaymt
replace mandjob = 0 if year>=1993 & year<=2010 & mandjob==.
replace divpaymt = 0 if year>=1993 & year<=2010 & divpaymt==.


*demographic eligibility
*note: 2 observations (NJ in 1997 and 1998) have "varies" 
replace eligstparent = "O" if eligstparent=="varies"
replace eligstparent = "M" if state==8 & year>=1999&year<=2005		  /*Colorado*/
replace eligstparent = "M" if state==28 & (year>=1997 & year<=2010)	  /*Mississippi*/

gen eligstpar = 2 if eligstparent=="O"
replace eligstpar = 3 if eligstparent=="P"
replace eligstpar = 1 if eligstparent=="M"
rename eligstparent eligstparent_string
rename eligstpar eligstparent
label define elig 1 "Mandatory" 2 "Optional" 3 "Prohibited"
label values eligstparent elig


*financial eligibility
replace elthresh = 0 if state==55 & year>=1998 & year<=2010		 /*Wisconsin*/
replace elthresh = 655 if state==25 & year>=1996 & year<=2010	 	/*Massachusetts*/

replace vehexapp = 14 if state==39 & year>=1996 & year<=2010	  	/*Ohio*/

replace assets = 7000 if state==39 & year>=1996 & year<=2010	 	/*Ohio: no asset test*/
replace assets =20000  if state==51 & year>=2006 & year<=2010		/*Virginia*/


*immigrants
replace alienpre_law = 2 if (year==1997 | year==1998) & state==27	 /*Minnesota*/
replace alienpre_ref = 2 if (year==1997 | year==1998) & state==27 
replace alienpre_dep = 2 if (year==1997 | year==1998) & state==27 
replace alienpre_dep = 0 if (year==1996) & state==5 			/*Arkansas*/
replace alienpre_par = 2 if (year==1996) & state==5 
replace alienpre_par = 2 if (year==1997 | year==1998) & state==27 
replace alienpre_bat = 0 if (year==1997 | year==1998) & state==27 
replace alienpre_bat = 1 if (year==1998) & state==17  		    /*Illinois*/
replace alienpre_bat = 2 if (year>=1999 & year<=2003) & state==13  /*Georgia: missing*/

replace alienpost5_law =2 if year==1998 & state ==10 /*Delaware*/
replace alienpost5_law =2 if year==1998 & state ==27 /*Minnesota*/
replace alienpost5_ref =2 if year==1998 & state ==10 /*Delaware*/
replace alienpost5_ref =0 if year==1998 & state ==27 /*Minnesota*/
replace alienpost5_dep =2 if year==1998 & state ==10 /*Delaware*/
replace alienpost5_dep =0 if year==1998 & state ==27 /*Minnesota*/
replace alienpost5_par =2 if year==1998 & state ==10 /*Delaware*/
replace alienpost5_par =2 if year==1998 & state ==27 /*Minnesota*/
replace alienpost5_bat =0 if year==1998 & state ==10 /*Delaware*/
replace alienpost5_bat =0 if year==1998 & state ==27 /*Minnesota*/

*legal permanent residents were treated equally to citizens under AFDC
replace alienpre_bat = 2 if alienpre_bat==. & (year==1996|year==1997|year==1998)
replace alienpost5_bat = 2 if alienpost5_bat ==. & (year==1996|year==1997|year==1998)
replace alienpost5_ref = 2 if alienpost5_ref ==. & (year==1996|year==1997)
replace alienpost5_law = 2 if alienpost5_law ==. & (year==1996|year==1997)
replace alienpost5_dep = 2 if alienpost5_dep ==. & (year==1996|year==1997)
replace alienpost5_par = 2 if alienpost5_par ==. & (year==1996|year==1997)



*work requirements
replace hrsreq=0 if year>=1993&year<=1995&hrsreq==.			/*missings for 1993-1995, note: Fang/Keane coded more hrsreq in that period*/
replace hrsreq=32 if state==6 &year>=1995&year<=2000 & hrsreq==.	/*Information on existence of hrsreq from Fang/Keane, use hours of later years*/
replace hrsreq=40 if state == 13 & year==1996 & hrsreq==.		/*Georgia*/
replace hrsreq=20 if state == 47 & year==1996 & hrsreq==.		/*Tennessee*/
replace hrsreq=0 if state == 54 &  year==1996 & hrsreq==.		/*West Virginia*/
replace hrsreq=22 if state == 8 & year>=1994&year<=1997 & hrsreq==.	/*Colorado*/
replace hrsreq=10 if state == 9 & year>=1996&year<=1998 & hrsreq==.	/*Connecticut*/
replace hrsreq=20 if state == 29 & year>=1995&year<=1997 & hrsreq==.	/*Missouri*/
replace hrsreq=20 if state == 45 & year>=1996&year<=1997 & hrsreq==.	/*South Carolina*/
replace hrsreq=30 if state ==48 &year>=1996&year<=1998 & hrsreq==.	/*Texas*/

replace hrsreq = 10 if state ==4 & year>=2006 & year<=2010 		/*Arizona: case-by-case basis*/
replace hrsreq = 10 if state ==9 & year>=2006 & year<=2010 		/*Connecticut: case-by-case basis*/
replace hrsreq = 10 if state ==18 & year>=2006 & year<=2010 		/*Indiana: case-by-case basis*/
replace hrsreq = 10 if state ==41 & year>=2006 & year<=2010 		/*Oregon: case-by-case basis*/
replace hrsreq = 10 if state ==49 & year>=2006 & year<=2007 		/*Utah: case-by-case basis*/
replace hrsreq = 10 if state ==38 & year==2006				/*North Dakota: case-by-case basis*/
replace hrsreq = 32 if state ==53 & year==2006	 			/*Washington: Tables by Year = 32*/
replace hrsreq = 32 if state ==6 & year==2000 				/*California: Tables by Year = 32*/

replace hrsreq = 10 if state ==25 & year>=1996 & year<=1999 		/*Massachusetts: depends on activity*/
replace hrsreq = 30 if state ==25 & year>=2006 & year<=2010 		/*Massachusetts: nonexempt = 30*/
replace hrsreq = 24 if state ==25 & year==2005		 		/*Massachusetts: nonexempt = 24*/
replace hrsreq = 20 if state ==25 & (year>=2000 & year<=2004) 		/*Massachusetts: nonexempt = 20*/

*workenroll: many in 1996, CO,GE,MS,TX for most years 
replace workenroll = 0 if state == 25 & year>=1997 & year<=2005 	 	/*Massachusetts*/
replace workenroll = 1 if state ==13 & year >=2000 & year<=2002			/*Georgia*/
replace workenroll=0 if state ==48 &year>=1996&year<=2010 & workenroll==.	/*Texas*/
replace workenroll = 0 if (year==1996|year==1997)&workenroll==.
replace workenroll =0  if state==8 & year>=1998 & year<=2010			/*Colorado*/
replace workenroll = 0 if state==13 & year==1998				/*Georgia*/
 
replace workex_no=5 if year>=1993&year<=1995 &workex_no ==. 		  /*assign AFDC exemptions (=max) if no other waiver provision*/
replace workex_no=5 if state==25 &year>=1996&year<=2005 & workex_no==.	 /*In Massachusetts, people with any of the characteristics are placed into exempt category*/


*time limits
replace duration = 0 if state_name=="South Carolina" & year==1995
*duration: 0=no time limit, large values=lax => recode! 
gen tl_duration=0 if duration==0 
replace tl_duration = 120 - duration if duration>0&duration<100
label variable duration "0=no tl, >0=#months"
label variable tl_duration "0=no tl, 120-#months (larger values=stricter)"


*code limitadult = 2 if whole benefit gets terminated
replace limitadult = 2 if limitadult ==0 

*states with no time limit (Mass, Maine, Michigan, Vermont) are coded as 0
replace limitadult = 0 if (state==23 | state == 25 | state == 26 | state == 50) & (year>=1997&year<=2010)

*adult portion in DC
replace limitadult = 1 if state ==11 & year>=1999 & year<=2010		/*DC uses local money to finance recipients beyond the 60 months time limit*/
replace limitadult=1 if year==2003 & state_name=="Arizona"

replace limitadult=1 if year==2003 & state==53				/*Washington*/
replace limitadult=0 if year>=2004 & year<=2010 &state==53	

*In NY, units can still get noncash assistance = code as 1
replace limitadult = 1 if state == 36 & year >=2002 & year<=2010 	/*NY*/

*from 1996-1999, many states have not yet implemented an intermittent time limit 
replace limitadult = 0 if year ==1999 & limitadult==. 	
replace limitadult = 0 if year ==1998 & limitadult==. 	
replace limitadult = 0 if year ==1997 & limitadult==. 	
replace limitadult = 0 if year ==1996 & limitadult==. 	
label variable limitadult "0=no tl, 1=adult, 2=whole unit"


*time limit exemptions 
replace tlexemp_no=7 if year>=1993&year<=1996
replace tlexemp_no=7 if state==11 &year>=2001&year<=2010 & tlexemp_no==.				/*DC*/			
replace tlexemp_no=7 if state==25 &year>=1997&year<=2010 & tlexemp_no==.				/*Massachusetts*/		
replace tlexemp_no=7 if state==26 & year>=1996&year<=2010 & tlexemp_no==.   				/*Michigan*/
replace tlexemp_no=7 if state == 50 & year>=1996&year<=2010  & tlexemp_no==.  				/*Vermont*/
replace tlexemp_no=7 if state== 23 & year>=1996&year<=2010 & tlexemp_no==.  				/*Maine*/

*some states have missings in 1997 because they implemented lifetime limits retroactively =>use exemptions for that period for 1997 
replace tlexemp_no=7 if state == 31 & year==1997  & tlexemp_no==. 		/*Nebraska: tl exempt category if "mentally, empotionally or physically unable to work" =>preg, ill, care, child, domviol, old=6 extensions*/
replace tlexemp_no=0 if state==6 & year==1997 					/*California: no time limit then, 1998 intermittent, 2000 federal lifetime limit*/
replace tlexemp_no=0 if year==1997 & state == 32   				/*Nevada*/
replace tlexemp_no=0 if year==1997 & state == 40				/*Oklahoma*/
replace tlexemp_no=1 if year==1997 & state == 53				/*Washington*/
replace tlexemp_no=3 if state == 27 & year==1997				/*Minnsota*/

*individual categories (still missing for 1996-2001) 
replace tlexemp_ill = 1 if (year>=2004 & year<=2005) & (state==25 | state == 23) /*Maine, Massachusetts*/
*replace tlexemp_cil = 1 if (year>=2004 & year<=2005) & (state==25 | state == 23) 
replace tlexemp_cba = 1 if (year>=2004 & year<=2005) & (state==25 | state == 23) 
replace tlexemp_pre = 1 if (year>=2004 & year<=2005) & (state==25 | state == 23) 
replace tlexemp_mip = 1 if (year>=2004 & year<=2005) & (state==25 | state == 23) 
replace tlexemp_age = 1 if (year>=2004 & year<=2005) & (state==25 | state == 23) 
replace tlexemp_job = 1 if (year>=2004 & year<=2005) &  state == 23 
replace tlexemp_coo = 1 if (year>=2004 & year<=2005) &  state == 23 

replace tlexemp_ill = 1 if (year>=2002 & year<=2003) & (state==25) /*Massachusetts*/
*replace tlexemp_cil = 1 if (year>=2002 & year<=2005) & (state==25) 
replace tlexemp_cba = 1 if (year>=2002 & year<=2005) & (state==25) 
replace tlexemp_pre = 1 if (year>=2002 & year<=2005) & (state==25) 
replace tlexemp_mip = 1 if (year>=2002 & year<=2005) & (state==25) 
replace tlexemp_age = 1 if (year>=2002 & year<=2005) & (state==25) 

replace tlexemp_ill = 1 if (year>=2004 & year<=2005) & state == 31  /*Nebraska*/
*replace tlexemp_cil = 1 if (year>=2004 & year<=2005) & state == 31  
replace tlexemp_cba = 1 if (year>=2004 & year<=2005) & state == 31  
replace tlexemp_pre = 1 if (year>=2004 & year<=2005) & state == 31  
replace tlexemp_age = 1 if (year>=2004 & year<=2005) & state == 31  
replace tlexemp_vio = 1 if (year>=2004 & year<=2005) & state == 31  

replace tlexemp_ill = 1 if (year>=2004 & year<=2005) & state == 33  /*New Hampshire*/
*replace tlexemp_cil = 1 if (year>=2004 & year<=2005) & state == 33  
replace tlexemp_age = 1 if (year>=2004 & year<=2005) & state == 33  

replace tlexemp_ill = 1 if year==2004 & state == 45		  /*South Carolina*/
*replace tlexemp_cil = 1 if year==2004 & state == 45  

replace tlexemp_ill = 1 if year>=2004 & year<=2005 & state == 51	  /*Virginia*/
*replace tlexemp_cil = 1 if year>=2004 & year<=2005 & state == 51  
replace tlexemp_cba = 1 if year>=2004 & year<=2005 & state == 51  
replace tlexemp_pre = 1 if year>=2004 & year<=2005 & state == 51  
replace tlexemp_mip = 1 if year>=2004 & year<=2005 & state == 51  
replace tlexemp_age = 1 if year>=2004 & year<=2005 & state == 51  
replace tlexemp_vio = 1 if year>=2004 & year<=2005 & state == 51  

cap drop temp
egen temp = rsum(tlexemp_job tlexemp_coo tlexemp_ill tlexemp_age tlexemp_cba tlexemp_vio tlexemp_mip)
replace tlexemp_no = temp if tlexemp_no<temp
 
*code extensions and exemptions at max value if no time limit or state exempts recipients in these categories from time limits
replace tlext_no=7 if year>=1993&year<=1996
replace tlext_no=7 if state==6 & year==1997 					/*California: no time limit then, 1998 intermittent, 2000 federal lifetime limit*/
replace tlext_no=7 if state==11 &year>=2001&year<=2010 & tlext_no==.		/*DC*/
replace tlext_no=7 if state== 23 & year>=1996&year<=2010 & tlext_no==.  	/*Maine*/
replace tlext_no=7 if state== 25 & year>=1996&year<=2010  & tlext_no==. 	/*Massachusetts*/
replace tlext_no=7 if state==26 & year>=1996&year<=2010 & tlext_no==.   	/*Michigan*/
replace tlext_no=7 if state == 50 & year>=1996&year<=2010  & tlext_no==.  	/*Vermont*/
replace tlext_no = . if state==8 & year>= 1997& year<= 2001			   /*Colorado: no information =? about several time limits extensions prior to 2002*/
replace tlext_no=7 if state == 31 & year==1997  & tlext_no==.	  		/*Nebraska*/

*many missings in 1996 => sum over individual variables 
cap drop temp
egen temp=rsum(tlext_old tlext_cba tlext_ill tlext_cil tlext_vio tlext_job tlext_coo) if year==1996
replace tlext_no = temp if year==1996
drop temp

*some states have missings in 1997 because they implemented lifetime limits retroactively =>use extensions for that period for 1997 
replace tlext_no=5 if year==1997&state==32					/*Nevada*/
for var tlext_coo tlext_job : replace X=0 if state==32 & year==1997

replace tlext_no=0 if year==1997&state==40					/*Oklahoma*/
for var tlext_job tlext_coo tlext_cil tlext_cba tlext_old tlext_ill tlext_vio: replace X=0 if state==40 & year==1997

replace tlext_no=0 if year==1997&state == 53					/*Washington*/
for var tlext_job tlext_coo tlext_cil tlext_cba tlext_old tlext_ill tlext_vio: replace X=0 if state==53 & year==1997

replace tlext_no=1 if state==27 &year==1997					/*Minnesota*/
for var tlext_job tlext_coo tlext_cil tlext_cba tlext_old tlext_ill: replace X=0 if state==27 & year==1997

replace tlext_no = 7 if state== 8 & year>=1996 & year<=2001 			/*Colorado: ? -code AFDC provisions*/

*individual categories
replace tlext_ill = 1 if year==2010 & state==45  		/*South Carolina*/
replace tlext_cil = 1 if year==2010 & state==45

replace tlext_job = 1 if year==2010 & (state==50 | state==53) 	/*Vermont, Washington*/
replace tlext_coo = 1 if year==2010 & (state==50 | state==53)
replace tlext_ill = 1 if year==2010 & (state==50 | state==53)
replace tlext_cil = 1 if year==2010 & (state==50 | state==53)
replace tlext_cba = 1 if year==2010 & (state==50 | state==53)
*replace tlext_pre = 1 if year==2010 & (state==50 | state==53)
replace tlext_old = 1 if year==2010 & (state==50 | state==53)
replace tlext_vio = 1 if year==2010 & (state==50 | state==53)

*fill variable "any extension" using information from tlext_no
*(not fully correct since there are other categories not in tlext_no) 
replace tlext=0 if tlext_no==0 & tlext==.
replace tlext=1 if tlext_no>0&tlext_no<10 & tlext==.


*family caps
replace famcap = 0 if year>=1993 & year<=2010 & famcap==.


*earnings disregards
replace earndis_month5 = 416 if year==2005 & state ==1 


*sanctions
replace dsanctionini = 1 if year>=1997 & year<=2010 & state==16 & dsanctionini==.  /*Iowa*/
replace dsanctionini = 1 if year>=1997 & year<=2010 & state==20 & dsanctionini==.  /*Kansas*/
replace dsanctionini = 1 if year>=1997 & year<=2010 & state==24 & dsanctionini==.  /*Maryland*/
replace dsanctionini = 1 if year>=1997 & year<=2010 & state==28 & dsanctionini==.  /*Mississippi*/
replace dsanctionini = 1 if year>=1998 & year<=2010 & state==31 & dsanctionini==.  /*Nebraska*/
replace dsanctionini = 1 if year>=1997 & year<=2010 & state==47 & dsanctionini==.  /*Tennesse*/
replace dsanctionini = 1 if year>=1995 & year<=2010 & state==51 & dsanctionini==.  /*Virginia*/
replace dsanctionini = 0 if dsanctionini==. & year>=1993 & year<=1998

replace reapply = 1 if sanctionben==3 & reapply==0
replace reapply = 0 if year<=1995 & year>=1993
replace reapply = 1 if year == 2006 & (state==46)/*Texas*/
replace reapply = 1 if year == 2007 & (state==9 | state==45 | state==35) /*Connecticut, South Carolina, New Mexico*/
replace reapply = 1 if (year==2010 | year==2009 | year==2008) & state==49 /*Utah*/
replace reapply = 0 if reapply == . & (year>=1996 & year<=2010)

replace sanctiondur = 60 if sanctiondur==99 /*Permanent sanctions are recoded to last 5 years*/

drop sanctionben_level
gen sanctionben_level = 100 if sanctionben==2 | sanctionben==3 	/*full family benefits or case closed*/
replace sanctionben_level = 50 if sanctionben==1 		/*adult portion of the benefits*/
replace sanctionben_level = 25 if sanctionben==0 		/*benefits reduced by 25% or less*/

replace sanction1ben = 0 if sanction1ben == 4 
replace sanction1ben = 2 if (year>=2008 & year <=2010) & state ==5 /*Arkansas*/
replace sanction1ben = 1 if state == 17 & year>=1996&year<=2010    /*Illinois*/
replace sanction1ben = 0 if (year>=1999 & year<=2010) & (state==25 | state==46) /*Massachusetts, South Dakota*/

replace sanction1dur = 0 if (year>=2001 & year<=2010) & (state==25 | state==46) /*Massachusetts, South Dakota*/
replace sanction1dur = 99 if (year>= 2000 & year<=2007) & state==45 /*South Carolina: Must reapply and comply for 30 days*/



*CLEAN UP CODING ERRORS

*mandjob
*-----------
replace mandjob= 0 if state==48 & year==2006 /*Texas*/
replace mandjob= 0 if state==6 & year==2006 /*CA*/
replace mandjob = 1 if state==37 & year==2006 /*North Carolina*/
replace mandjob = 0 if state==37 & year==2010


*divpaymt
*----------
replace divpaymt =0 if state==22 & year>=2004& year<=2010  	/*Tables code it as zero! Although it still exists in the law, Louisiana's diversion program has not received funding since September 2002*/

/*Minnesota: Statewide Diversionary Assistance Program was repealed in 2003, along with several other statewide programs. ///
  These programs were replaced with a block grant given to the counties called the Consolidated Fund. /// 
  Counties will still be able to fund Diversion Assistance from the Consolidated Fund, but will not be required to.*/


*famcap 
*-----------
replace famcap = 0 if state==31 & year==1995 /*Nebraska*/
replace famcap = 1 if state==55 & year>=1998 & year<=2010 /*Wisconsin: provides a flat benefit regardless of family size*/ 


*twoparhours   SHOULD WE CODE THIS AS MAXIMUM SINCE NEVER ELIGIBLE????
*------------
replace twoparhours = 1 if state==38 & year>=1998 & year<=2010	/*North Dakota*/
/*State=38: In order for a child and therefore the unit to be eligible, the child must be deprived of parental support. ///
  Deprivation of parental support occurs only if one or both parents are deceased, continuously absent for the home, ///
  or mentally or physically incapacitated. Therefore, the only two-parent families that are eligible are two-parent ///
  families in which one or both of the parents are mentally or physically incapacitated. If one of the parent is ///
  mentally or physically incapacitated, none of the requirements captured in this record must be fulfilled in order ///
  for the unit to be eligible. -> code hours = 0 because only disabled parents are eligible*/

*twoparwait
*------------
replace twoparwait = 0 if state==6 & year==1999		/*CA*/
replace twoparwait = 0 if state==17 & year==1999	/*Illinois*/

*twoparwkhistory   
*-------------------
replace twoparwkhistory = 2 if state==38 & year>=1998 & year<=2010 /*North Dakota: see notes for twoparhours*/
replace twoparwkhistory = 1 if state==46 & year>=1998 & year<=1999 /*South Dakota*/


*workenroll
*------------
replace workenroll = 0 if state==6 & year==2006 
replace workenroll = 0 if state==48 & year==2007 

*hrsreq
*-----------
replace hrsreq = 35 if state==1 & year>=2007 & year<=2010
replace hrsreq=40 if state==13 & year>=1997 & year<=2010
replace hrsreq=40 if state==16 & year==1996
replace hrsreq=25 if state==18 & year>=1997 & year<=1999
replace hrsreq=30 if state==18 & year>=2000 & year<=2010
replace hrsreq=40 if state==24 & year>=2007 & year<=2010
replace hrsreq=30 if state==33 & year==2006
replace hrsreq=20 if state==42 & year>=1997 & year<=2005
replace hrsreq=30 if state==42 & year>=2006 & year<=2007
replace hrsreq=20 if state==47 & year==2006
replace hrsreq=30 if state==49 & year==2007
replace hrsreq=10 if state==50 & year>=2001 & year<=2010
replace hrsreq=30 if state==54 & year==2006


*duration
*---------------
cap replace tl_duration = 60 if state==39 & year==1999
replace duration = 60 if state==39 & year==1999

*interdur
*------------
replace interdur =0 if state==6 & year==1999
replace interdur =0 if state==10 & year==1999
replace interdur =0 if state==18 & year==1999
replace interdur =0 if state==29 & year==1999
replace interdur =0.6 if state==39 & year>=1998 & year<=2010
replace interdur =0.2 if state==45 & year==2004
replace interdur =0.54 if state==49 & year>=1999 & year<=2010

*limitadult
*------------
replace limitadult = 1 if state==36 & year>=2002 & year<=2010
replace limitadult = 0 if state==36 & year==1999
replace limitadult = 0 if state==53 & year>=2003 & year<=2005
replace limitadult = 0 if state==53 & year==1999


*tlext_no
*---------
replace tlext_cba=1 if state==5 & year==2003
for var tlext_old tlext_cba tlext_cil tlext_ill tlext_vio tlext_job tlext_coo: replace X= 1 if (year==2004 | year==2005) & state==11
replace tlext_no=7 if state==11 &year>=2001 & year<=2005 
replace tlext_no=7 if state==11 & year==1996
replace tlext_coo = 0 if state==13 & year>=2002 & year<=2008
replace tlext_cil=0 if state==22 & year==1998
replace tlext_old=1 if state==38 & year==2008 
replace tlext_cil=1 if state==38 & year==2008 
replace tlext_vio=1 if state==38 & year==2008 
replace tlext_cil=0 if state==45 & year>=2008 & year<=2010
replace tlext_coo=1 if state==45 & year>=2002 & year<=2010
for var tlext_old tlext_cba tlext_cil tlext_ill tlext_vio tlext_job tlext_coo: replace X= 1 if (year>=2006 &  year==2010) & state==53
drop tlext_no 
egen tlext_no = rowtotal(tlext_old tlext_cba tlext_cil tlext_ill tlext_vio tlext_job tlext_coo) if year>=1996 & year<=2010, missing

*tlexemp_no
*-----------
replace tlexemp_vio = 1 if state==10 & year==1997
replace tlexemp_no = 4 if state==10 & year==2006
replace tlexemp_cil = 0 if state==8 & year>=2002 & year<=2010
replace tlexemp_chil = 0 if state==8 & year>=2002 & year<=2010
replace tlexemp_cil = 1 if state==12 & year>=2002 & year<=2010
replace tlexemp_chi = 1 if state==12 & year>=2002 & year<=2010
replace tlexemp_coo = 0 if state==12 & year>=2003 & year<=2006
replace tlexemp_mip = 1 if state==12 & year>=1997 & year<=2010
replace tlexemp_no = 3 if state==12 & year==2006
replace tlexemp_no = 3 if state==12 & year==2008
replace tlexemp_no = 3 if state==12 & year==2009
replace tlexemp_mip = 1 if state==15 & year>=1997 & year<=2010
replace tlexemp_cil = 1 if state==15 & year>=2002 & year<=2010
replace tlexemp_chi = 1 if state==15 & year>=2002 & year<=2010
replace tlexemp_mip = 1 if state==21 & year>=1999 & year<=2001
replace tlexemp_mip = 0 if state==21 & year>=1997 & year<=1998
replace tlexemp_cil = 0 if state==21 & year>=2002 & year<=2010
replace tlexemp_chi = 0 if state==21 & year>=2002 & year<=2010
replace tlexemp_no = 2 if state==21 & year>=1997 & year<=1999
*Maine: Units who are in compliance with TANF program rules may continue to receive benefits beyond 60 months -> code all extensions/exemptions ok 
replace tlexemp_cil = 1 if state==23 & year>=2002 & year<=2010
replace tlexemp_chi = 1 if state==23 & year>=2002 & year<=2010
for var tlexemp_vio tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill: replace X=1 if state==23 & year==1996 | (year>=2002 & year<=2005)
replace tlexemp_no = 7 if state==23 & year>=1996 & year<=2010
*Michigan: no time limit until 2007
for var tlexemp_vio tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=1 if state==26 & year>=1996 & year<=2007
replace tlexemp_no = 7 if state==26 & year>=1996 & year<=2007
for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=0 if year>=2008 & year<=2010
replace tlexemp_no = 1 if state==26 & year>=2008 & year<=2010
replace tlexemp_vio = 1 if state==26 & year>=2008 & year<=2010
replace tlexemp_mip=1 if state==30 & year>=1996 & year<=2001
replace tlexemp_cil = 0 if state==30 & year>=2002 & year<=2010
replace tlexemp_chi = 0 if state==30 & year>=2002 & year<=2010

for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=1 if state==31 & year>=1996 & year<=1997
replace tlexemp_no=7 if state==31 & year>=1996 & year<=1997
for var tlexemp_vio tlexemp_mip tlexemp_chil : replace X=1 if state==31 & year>=2002 & year<=2010
for var tlexemp_cil tlexemp_ill tlexemp_age : replace X=0 if state==31 & year>=2002 & year<=2007
replace tlexemp_age=1 if year>=2008&year<=2010 & state==31
for var tlexemp_ill tlexemp_cil: replace X=1 if year==2004 & year<=2010

for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=1 if state==33 & year==1996
replace tlexemp_no=7 if year==1996 & state==33
replace tlexemp_mip = 0 if state==33 & year>=1997 & year<=2001
replace tlexemp_age = 1 if state==33 & year>=2001 & year<=2010
for var tlexemp_ill tlexemp_cil: replace X= 1 if state==33 & year>=2004 & year<=2010
for var tlexemp_chi tlexemp_cil: replace X= 0 if state==33 & year>=2002 & year<=2003
replace tlexemp_chi = 0 if state==33 & year>=2004 & year<=2010

for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=1 if state==36 & year==1996
replace tlexemp_no=7 if state==36 & year==1996
replace tlexemp_mip=0 if state==36 & year>=1997 & year<=2001
for var tlexemp_cil tlexemp_chi: replace X= 0 if state==36 & year>=2002 & year<=2010
replace tlexemp_no=0 if state==36 & year>=2007 & year<=2009

replace tlexemp_mip=0 if state==38 & year>=1997 & year<=2001
for var tlexemp_cil tlexemp_chi: replace X= 0 if state==38 & year>=2002 & year<=2010
for var tlexemp_no tlexemp_age tlexemp_ill tlexemp_vio: replace X=0 if state==38 & year==2008

replace tlexemp_mip=0 if state==45 & year>=1997 & year<=1998
replace tlexemp_mip=1 if state==45 & year>=1999 & year<=2001
replace tlexemp_vio=1 if state==45 & year>=2002 & year<=2010
replace tlexemp_chil=0 if state==45 & year>=2002 & year<=2010
replace tlexemp_ill = 1 if state==45 & year>=2008 & year<=2010
replace tlexemp_cil = 1 if state==45 & year>=1998 & year<=2007
replace tlexemp_cil = 0 if state==45 & year>=2008 & year<=2010

for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi tlexemp_vio: replace X=1 if state==47 & year==1996
replace tlexemp_mip=1 if state==47 & year>=1997 & year<=2001
replace tlexemp_age= 1 if state==47 & year>=2004 & year<=2006
replace tlexemp_ill= 0 if state==47 & year==2007 
replace tlexemp_cil= 1 if state==47 & year>=2002 & year<=2006
replace tlexemp_cil= 0 if state==47 & year>=2007 & year<=2010
replace tlexemp_chil= 1 if state==47 & year>=2002 & year<=2006
replace tlexemp_chil= 0 if state==47 & year>=2007 & year<=2010

replace tlexemp_mip=0 if state==48 & year>=1997 & year<=2001
for var tlexemp_job tlexemp_ill: replace X=0 if state==48 & year>=2002 & year<=2003
for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi tlexemp_vio: replace X=1 if state==48 & year==1996
replace tlexemp_no= 7 if state==48 & year==1996 
replace tlexemp_cil=0 if state==48 & year>=2002 & year<=2010
replace tlexemp_chil=0 if state==48 & year>=2002 & year<=2010

replace tlexemp_mip=0 if state==51 & year>=1997 & year<=2002
for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi tlexemp_vio: replace X=1 if state==51 & year==1996
replace tlexemp_no= 7 if state==51 & year==1996 
for var tlexemp_cil tlexemp_chil: replace X=0 if state==51 & year>=2008 & year<=2010
for var tlexemp_ill tlexemp_chil tlexemp_cil tlexemp_age: replace X=1 if state==51 & year>=2004 & year<=2007
for var tlexemp_ill tlexemp_chil tlexemp_cil tlexemp_age: replace X=0 if state==51 & year>=2002 & year<=2003
replace tlexemp_mip=1 if year>=2003 & year<=2007
replace tlexemp_job=0 if year>=2002 & year<=2007
replace tlexemp_coo=0 if year>=2002 & year<=2007
replace tlexemp_vio=0 if year>=2002 & year<=2007

replace tlexemp_mip= 1 if state==56 & year>=1996 & year<=2001
for var tlexemp_cil tlexemp_chil: replace X= 0 if state==56 & year>=2002 & year<=2010
for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi tlexemp_vio: replace X=1 if state==56 & year==1996

*Vermont has no time limit: all exemptions/extensions are present
for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi tlexemp_vio: replace X=1 if state==50 & year>=1996 & year<=2010
replace tlexemp_no= 7 if state==50 & year>=1996 & year<=2010

*DC uses local money to finance families who reach the 60-month time limit -> code as no time limit + all extemptions/extensions are present
for var tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=1 if state==11 & year>=1997 & year<=2000
replace tlexemp_vio= 1 if state==11 & year>=1997 & year<=2000
for var tlexemp_vio tlexemp_age tlexemp_job tlexemp_coo tlexemp_mip tlexemp_ill tlexemp_cil tlexemp_chi: replace X=1 if state==11 & year>=2001 & year<=2010
replace tlexemp_no = 7 if state==11 & year>=2001 & year<=2010
replace tlexemp_no = 1 if state==11 & year>=1997 & year<=2000

cap drop temp
egen temp = rowtotal(tlexemp_age tlexemp_chil tlexemp_cil tlexemp_ill tlexemp_vio tlexemp_job tlexemp_coo tlexemp_mip) if year>=1996 & year<=2010, missing
replace tlexemp_no = temp if tlexemp_no==. | (temp!=tlexemp_no)


*schoolreq
*-------------
replace schoolreq = 0 if state==2 & year==1996
replace schoolreq = 1 if state==2 & year>=1997 & year<=2001

*healthreq
*-------------
replace healthreq = 1 if state==8 & year==1999
replace healthreq = 1 if state==54 & year==1999

*othreq
*-----------
replace othreq = 0 if state==23 & year==1999

*schoolbonus
*------------
replace schoolbonus=0 if state==47 & year>=2000 & year<=2002

*imreq
*-----------
replace imreq=1 if state==23 & year==1999
replace imreq=1 if state==34 & year>=2000& year<=2010
replace imreq=1 if state==35 & year==1999


*eligminor
*--------------
replace eligminor = 1 if year>=1999&year<=2010 & state==39   /*Ohio*/

*eligstparent
*-------------
replace eligstparent = 3 if state==29 & year>=1999 & year<=2003  /*Missouri*/
replace eligstparent = 2 if state==34 & year==1999		 /*New Jersey*/
replace eligstparent = 3 if state==56 & year>=2006 & year<=2007  /*Wyoming*/


*assets
*---------
replace assets = 5000 if state==19 & year>=1996 & year<=2010  	/*Iowa*/
replace assets = 5000 if state==27 & year>=1998 & year<=2010  	/*Minnesota*/
replace assets = 5000 if state==29 & year>=1999 & year<=2010  	/*Missouri*/
replace assets = 5000 if state==29 & year>=1996 & year<=1999      	
replace assets = 2000 if state==33 & year>=1997 & year<=2010  	/*New Hampshire*/
replace assets = 8000 if state==38 & year>=1998 & year<=2000  	/*North Dakota*/
replace assets = 6000 if state==38 & year>=2001 & year<=2010  	

*vehexapp
*---------
replace vehexapp = 11.6 if state==12 & year==2009	  	/*Florida*/
replace vehexapp = 22.5 if state==26 & year>=1997 & year<=2001	/*Michigan*/
replace vehexapp = 22.5 if (state==2) & year >=1997 & year<=2003
replace vehexapp = 7.6 if state==6 & year>=1996 & year<=1997
replace vehexapp = 7.75 if state==6 & year>=1998 & year<=2003
replace vehexapp = 4.65 if state==6 & year>=2004 & year<=2010
replace vehexapp = 7.75 if state==10 & year>=2005 & year<=2009
replace vehexapp = 4.6 if state==11 & year==1998
replace vehexapp = 11.6 if state==12 & year==2009
replace vehexapp = 7.75 if state==13 & year>=1997 & year<=2010
replace vehexapp = 15 if state==16 & year>=2007 & year<=2010
replace vehexapp = 4.6 if state==18 & year>=1993 & year<=1995
replace vehexapp = 6.98 if state==19 & year>=1996 & year<=1998
replace vehexapp = 7.016 if state==19 & year==1999
replace vehexapp = 7.059 if state==19 & year==2000
replace vehexapp = 7.142 if state==19 & year==2001
replace vehexapp = 7.215 if state==19 & year>=2002 & year<=2003
replace vehexapp = 4.6 if state==22 & year>=1993 & year<=1997
replace vehexapp = 10 if state==25 & year>=2005 & year<=2010
replace vehexapp = 22.5 if state==26 & year>=1997 & year<=2001
replace vehexapp = 7.75 if state==27 & year==1997
replace vehexapp = 7.5 if state==27 & year>=1998 & year<=2007
replace vehexapp = 9.3 if state==28 & year>=1999 & year<=2002
replace vehexapp = 13.1 if state==41 & year>=1996 & year<=1998

replace vehexapp = 4.6 if state==42 & year>=1997 & year<=2000
replace vehexapp = 4.65 if state==42 & year>=2001 & year<=2003

replace vehexapp = 9.3 if state==28 & year>=1999 & year<=2002


*maxben
*--------
replace maxben = 364 if state==32 & year>=1998 & year<=1999 	/*Nebraska*/
replace maxben = 457 if state==38 & year==1999 			/*North Dakota*/
replace maxben = 503 if state==41 & year>=1996 & year<=2001 	/*Oregon*/
replace maxben = 474 if state==49 & year==2009 			/*Utah*/


*sanctionben
*--------------
replace sanctionben = 3 if state==30 & year==1999  			/*Montana*/
replace sanctionben = 3 if state==34 & year>=1999 & year<=2000 		/*NJ*/
replace sanctionben = 2 if state==37 & year>=2001 & year<=2002		/*NC*/
replace sanctionben = 2 if state==38 & year==1999			/*ND*/	
replace sanctionben = 2 if state==39 & year==2006			/*Ohio*/
replace sanctionben = 2 if state==41 & year==2000			/*Oregon*/
replace sanctionben = 2 if state==42 & year>=1999 & year<=2000		/*Penn*/
replace sanctionben = 1 if state==50 & year==1999 			/*VT*/

*sanctiondur
*--------------
replace sanctiondur = 6 if state==30 & year>=1996 & year<=2001		
replace sanctiondur = 0 if state==32 & year==2010			/*NV*/
replace sanctiondur = 99 if state==34 & year>=2001 & year<=2010		/*NJ*/
replace sanctiondur = 99 if state==37 & year>=2000 & year<=2000		/*NC*/
replace sanctiondur = 3 if state==38 & year>=1996 & year<=2002		/*ND*/
replace sanctiondur = 6 if state==54 & year>=2004 & year<=2004		/*WV*/
replace sanctiondur = 3 if state==54 & year>=2005 & year<=2008		

*reapply
*------------
*data missing 0s for 2006-2010
replace reapply = 1 if year==2006 & (state== 48)					/*TX*/ 
replace reapply = 1 if year==2007 & (state== 9 | state==35|state==45|state==49)		/*Conn,New Mex, SC, Utah*/ 
replace reapply = 1 if year==2008 & (state==49)						/*Utah*/ 
replace reapply = 1 if year==2009 & (state==49)		 
replace reapply = 1 if year==2010 & (state==49)	
replace reapply = 0 if (year>=2006 & year<=2010) & reapply==.

replace reapply=0 if state==5 & (year==1997 | year==1998)
replace reapply=0 if state==18 & (year>=2003 & year<=2005)
replace reapply=0 if state==26 & (year>=2002 & year<=2005)
replace reapply=0 if state==27 & (year>=2003 & year<=2005)
*Wisconsin: Unit is ineligible for benefits in that component for life. Unit may receive benefits again if s/he becomes eligible for a different component => has to reapply.
replace reapply= 1 if state==55 & year>=1997 & year<=2010



*dsanction
*-----------
replace dsanction =1 if state==30 & year==1999
replace dsanction =1 if state==38 & year==1999
replace dsanction =1 if state==42 & year==1999
replace dsanction =1 if state==49 & (year==1999 | year==1997)

*sanction1dur
*------------
replace sanction1dur = 0.5 if state==5 & year==2007

*workex_no
*----------
replace workex_preg=0 if state==12 & year==1999
replace workex_no=2 if state==12 & year==1999
replace workex_ill = 0 if state==13 & year>=1997 & year<=2007
replace workex_no = 1 if state==13 & year>=1997 & year<=2007
replace workex_ill = 0 if state==17 & year>=1997 & year<=2010
replace workex_no = 2 if state==17 & year>=1997 & year<=2010
replace workex_job = 0 if state==21 & year>=1997 & year<=2008
replace workex_ill = 0 if state==21 & year>=1998 & year<=2006
replace workex_no = 2 if state==21 & year>=1998 & year<=2006
replace workex_preg=12 if state==24 & year==2000
replace workex_no=3 if state==24 & year==2000
replace workex_age=65 if state==24 & year>=1999 & year<=2010
replace workex_ill=0 if state==27 & year==2006
replace workex_age=60 if state==27 & year>=2004 & year<=2006
replace workex_no=2 if state==27 & year>=2004 & year<=2006
replace workex_ill = 1 if state==31 & year>=2004 & year<=2010
replace workex_age = 60 if state==31 & year>=2004 & year<=2007
replace workex_age = 65 if state==31 & year>=2008 & year<=2010
replace workex_preg = 6 if state==31 & year>=2004 & year<=2007
replace workex_preg = 8 if state==31 & year>=2008 & year<=2010
replace workex_child = 3 if state==31 & year>=2004 & year<=2010
replace workex_no = 4 if state==31 & year>=2004 & year<=2010
replace workex_age = 60 if state==32 & year>=2004 & year<=2010
replace workex_preg = 1 if state==32 & year>=2004 & year<=2010
replace workex_no = 5 if state==32 & year>=2004 & year<=2010
replace workex_ill = 0 if state==39 & year>=1999 & year<=2006
replace workex_age = 0 if state==39 & year>=1999 & year<=2006
replace workex_preg = 0 if state==39 & year>=1999 & year<=2006
replace workex_no = 2 if state==39 & year>=1999 & year<=2006
replace workex_job=0 if state==42 & year>=1997 & year<=2010
replace workex_preg=0 if state==42 & year>=1999 & year<=1999
replace workex_no=2 if state==42 & year>=1997 & year<=2007
replace workex_ill=0 if state==45 & year>=1997 & year<=2010
replace workex_preg=0 if state==45 & year>=1997 & year<=2010
replace workex_no=1 if state==45 & year>=1997 & year<=2010
replace workex_ill=1 if state==46 & year==1999
replace workex_no=2 if state==46 & year==1999
replace workex_job=0 if state==51 & year==1999
replace workex_child=12 if state==51 & year==2007
replace workex_preg=0 if state==51 & year==2007
replace workex_no =4  if state==51 & year==1999
replace workex_no =3  if state==51 & year==2007

*alienpre
*-----------
replace alienpre_dep = 0 if state==35 & year>=2008 & year<=2009
replace alienpre_bat=2 if state==26 & year==2003
replace alienpre_bat=2 if state==32 & year>=2004 & year<=2006
replace alienpre_bat=0 if state==35 & year>=2008 & year<=2009
replace alienpre_bat=0 if state==54 & year==2003

*alienprenon
*--------------
replace alienprenon_law=1 if state==2 & year>=1997 & year<=2010
replace alienprenon_law=1 if state==9 & year==2003
replace alienprenon_law=1 if state==42 & year>=1998 & year<=1999
replace alienprenon_law=1 if state==50 & year>=2008 & year<=2009
replace alienprenon_par=1 if state==9 & year==2003
replace alienprenon_par=1 if state==42 & year>=1998 & year<=1999
replace alienprenon_par=1 if state==50 & year>=2008 & year<=2009
replace alienprenon_bat=0 if state==11 & year>=2000 & year<=2002
replace alienprenon_bat=1 if state==23 & year>=2007 & year<=2007
replace alienprenon_bat=1 if state==35 & year>=2007 & year<=2007
replace alienprenon_bat=1 if state==50 & year>=2008 & year<=2009
replace alienprenon_bat=0 if state==54 & year>=2003 & year<=2003
replace alienprenon_non=0 if state==44 & year>=2003 & year<=2003
replace alienprenon_non=1 if state==50 & year>=2008 & year<=2009

*alienpost5
*------------
replace alienpost5_ref=2 if state==27 & year>=1997 & year<=1998
replace alienpost5_ref=0 if state==48 & year==1997
replace alienpost5_dep=0 if state==27 & year>=1997 & year<=1998
replace alienpost5_par=0 if state==48 & year==1997
replace alienpost5_par=2 if state==51 & year>=2003 & year<=2005

replace alienpost5_bat=1 if state==2 & year>=2008 & year<=2009
replace alienpost5_bat=0 if state==10 & year>=1997 & year<=1998
replace alienpost5_bat=1 if state==11 & year>=1999 & year<=1999
replace alienpost5_bat=2 if state==32 & year>=2003 & year<=2006
replace alienpost5_bat=2 if state==37 & year>=2003 & year<=2010
replace alienpost5_bat=0 if state==54 & year>=2003 & year<=2003


save "welfarereform_062012_v12c.dta", replace