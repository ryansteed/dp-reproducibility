version 14


clear

capture log close

*** EDIT by Donna
global 	DATA 	"../2_data"
global	LOG		"./"
global	DOFILE	"./"

global 	POVLEVEL	newpovlv
global	STATE		statefip
	

# delimit;				

log using "$LOG\CreatingSimulatedMedicaidEligibility2003-2012_8-17-17.log", replace;				



/*==============================================================================
	1	CREATING THE IV FOR SIMULATED MEDICAID ELIGIBILITY...
===============================================================================*/
*** EDIT by Donna;
		/* use "$DATA/cps_00019";
						
			gen male = sex==1;
						
			gen female =  male==0; 
				*	drop if age <= 17;
						
			sample 6000, count by(year male);
						
				table year, c(n male mean male);
					generate adultsfull_ivsample = 1;
		
	quietly save "$DATA/adults_ivsample.dta", replace; */
		/* Calulate Medicaid & SCHIP Eligibility for Sim_elig_adults */
***;

use "$DATA/adults_ivsample.dta", clear;
			egen mcfam=mean(caid),by(hiuid);

/*==============================================================================
	2	DETERMINE MEDICAID ELIGIBILITY
===============================================================================*/

	gen mcd_elig = 0;

		gen gestcen = statecensus;
			label var gestcen "State Census Code";
			
		generate newpovlv = (ftotval/cutoff)*100;
			sum newpovlv, detail;
			generate povlev1=(newpovlv<=100);
			generate povlev2=(newpovlv>100 & newpovlv<=200);
			generate povlev3=(newpovlv>200 & newpovlv<=300);
			generate povlev4=(newpovlv>300 & newpovlv<=400);
			generate povlev5=(newpovlv>400 & newpovlv < .);
		
		generate unempl = empstat==21;
			replace unempl = 1 if empstat==22;
			label var unempl "=1 if Unemployed (in Labor Force); =0 if Otherwise";
			
		generate theType = spmnewfam + 1;
			replace theType = . if age<18;
		
		gen infant=0;
			replace infant=1 if age<1 & theType==3;

		egen inprs=mean(infant),by(year spmfamunit);
				
	generate temp_gestcen = gestcen;

	
	*STOP.......................................................................
	
;				 
capture program drop iv_state_eligibility_loop;
program define iv_state_eligibility_loop;
	generate temp_gestcen = gestcen;
	replace gestcen = `1';
		quietly do "$DOFILE/mcd2003elig.do";
		quietly do "$DOFILE/mcd2004elig.do";
		quietly do "$DOFILE/mcd2005elig.do";
		quietly do "$DOFILE/mcd2006elig.do";
		quietly do "$DOFILE/mcd2007elig.do";
		quietly do "$DOFILE/mcd2008elig.do";
		quietly do "$DOFILE/mcd2009elig.do";
		quietly do "$DOFILE/mcd2010elig.do";
		quietly do "$DOFILE/mcd2011elig.do";
 
	drop gestcen;	
	rename temp_gestcen gestcen;
	capture drop temp;
	egen temp = mean(mcd_elig ) if age >=18, by(year);

	 replace sim_mcd_elig = temp if gestcen == `1' & age>=18;
	
	capture drop temp;
	
	replace mcd_elig = 0;

end;
		
		drop gestcen;	
				
			rename temp_gestcen gestcen;
				
				capture drop temp;
				
					capture program drop state_loop;
						program define state_loop;
							iv_state_eligibility_loop 11; /* ME */
							iv_state_eligibility_loop 12; /* NH */
							iv_state_eligibility_loop 13; /* VT */
							iv_state_eligibility_loop 14; /* MA */
							iv_state_eligibility_loop 15; /* RI */
							iv_state_eligibility_loop 16; /* CT */
							iv_state_eligibility_loop 21; /* NY */
							iv_state_eligibility_loop 22; /* NJ */
							iv_state_eligibility_loop 23; /* PA */
							iv_state_eligibility_loop 31; /* OH */
							iv_state_eligibility_loop 32; /* IN */
							iv_state_eligibility_loop 33; /* IL */
							iv_state_eligibility_loop 34; /* MI */
							iv_state_eligibility_loop 35; /* WI */
							iv_state_eligibility_loop 41; /* MN */
							iv_state_eligibility_loop 42; /* IA */
							iv_state_eligibility_loop 43; /* MO */
							iv_state_eligibility_loop 44; /* ND */
							iv_state_eligibility_loop 45; /* SD */
							iv_state_eligibility_loop 46; /* NE */
							iv_state_eligibility_loop 47; /* KS */
							iv_state_eligibility_loop 51; /* DE */
							iv_state_eligibility_loop 52; /* MD */
							iv_state_eligibility_loop 53; /* DC */
							iv_state_eligibility_loop 54; /* VA */
							iv_state_eligibility_loop 55; /* WV */
							iv_state_eligibility_loop 56; /* NC */
							iv_state_eligibility_loop 57; /* SC */
							iv_state_eligibility_loop 58; /* GA */
							iv_state_eligibility_loop 59; /* FL */
							iv_state_eligibility_loop 61; /* KY */
							iv_state_eligibility_loop 62; /* TN */
							iv_state_eligibility_loop 63; /* AL */
							iv_state_eligibility_loop 64; /* MS */
							iv_state_eligibility_loop 71; /* AR */
							iv_state_eligibility_loop 72; /* LA */
							iv_state_eligibility_loop 73; /* OK */
							iv_state_eligibility_loop 74; /* TX */
							iv_state_eligibility_loop 81; /* MT */
							iv_state_eligibility_loop 82; /* ID */
							iv_state_eligibility_loop 83; /* WY */
							iv_state_eligibility_loop 84; /* CO */
							iv_state_eligibility_loop 85; /* NM */
							iv_state_eligibility_loop 86; /* AZ */
							iv_state_eligibility_loop 87; /* UT */
							iv_state_eligibility_loop 88; /* NV */
							iv_state_eligibility_loop 91; /* WA */
							iv_state_eligibility_loop 92; /* OR */
							iv_state_eligibility_loop 93; /* CA */
							iv_state_eligibility_loop 94; /* AK */
							iv_state_eligibility_loop 95; /* HI */
								
					capture drop temp2;
					capture drop temp3;
					end;

				
drop if age < 18;
drop if age >=65;
sample 1000, count by(year age);
generate sim_mcd_elig = .;
state_loop;
drop if sim_mcd_elig == .;
keep year gestcen sim_mcd_elig;
sort year gestcen;
quietly by year gestcen: drop if _n > 1;

				
					sort year gestcen;
					
						quietly by year gestcen: drop if _n > 1;

rename year cps_year;

gen year = cps_year-1;

drop if year>2010;		/*2010 is the last year of analysis for our project (i.e. post-recession/pre-ACA) */
		

/*==============================================================================
	ADD IN STATE FIPS CODES
==============================================================================*/
	
	gen st_fips = .	;			
		replace st_fips = 	1	 if gestcen ==	63;	   /*Alabama */
		replace st_fips = 	2	 if gestcen ==	94;   /*Alaska */
		replace st_fips = 	4	 if gestcen ==	86;	   /*Arizona */
		replace st_fips = 	5	 if gestcen ==	71;	   /*Arkansas */
		replace st_fips = 	6	 if gestcen ==	93;	   /*California */
		replace st_fips = 	8	 if gestcen ==	84;	   /*Colorado */
		replace st_fips = 	9	 if gestcen ==	16;	   /*Connecticut */
		replace st_fips = 	10	 if gestcen ==	51;	   /*Delaware */
		replace st_fips = 	11	 if gestcen ==	53;	   /*District of Columbia */
		replace st_fips = 	12	 if gestcen ==	59;	   /*Florida */
		replace st_fips = 	13	 if gestcen ==	58;	   /*Georgia */
		replace st_fips = 	15	 if gestcen ==	95;	   /*Hawaii */
		replace st_fips = 	16	 if gestcen ==	82;	   /*Idaho */
		replace st_fips = 	17	 if gestcen ==	33;	   /*Illinois */
		replace st_fips = 	18	 if gestcen ==	32;	   /*Indiana */
		replace st_fips = 	19	 if gestcen ==	42;	   /*Iowa */
		replace st_fips = 	20	 if gestcen ==	47;	   /*Kansas */
		replace st_fips = 	21	 if gestcen ==	61;	   /*Kentucky */
		replace st_fips = 	22	 if gestcen ==	72;	   /*Louisiana */
		replace st_fips = 	23	 if gestcen ==	11;	   /*Maine */
		replace st_fips = 	24	 if gestcen ==	52;	   /*Maryland */
		replace st_fips = 	25	 if gestcen ==	14;	   /*Massachusetts */
		replace st_fips = 	26	 if gestcen ==	34;	   /*Michigan */
		replace st_fips = 	27	 if gestcen ==	41;	   /*Minnesota */
		replace st_fips = 	28	 if gestcen ==	64;	   /*Mississippi */
		replace st_fips = 	29	 if gestcen ==	43;	   /*Missouri */
		replace st_fips = 	30	 if gestcen ==	81;	   /*Montana */
		replace st_fips = 	31	 if gestcen ==	46;	   /*Nebraska */
		replace st_fips = 	32	 if gestcen ==	88;	   /*Nevada */
		replace st_fips = 	33	 if gestcen ==	12;	   /*New Hampshire */
		replace st_fips = 	34	 if gestcen ==	22;	   /*New Jersey */
		replace st_fips = 	35	 if gestcen ==	85;	   /*New Mexico */
		replace st_fips = 	36	 if gestcen ==	21;	   /*New York */
		replace st_fips = 	37	 if gestcen ==	56;	   /*North Carolina */
		replace st_fips = 	38	 if gestcen ==	44;	   /*North Dakota */
		replace st_fips = 	39	 if gestcen ==	31;	   /*Ohio */
		replace st_fips = 	40	 if gestcen ==	73;	   /*Oklahoma */
		replace st_fips = 	41	 if gestcen ==	92;	   /*Oregon */
		replace st_fips = 	42	 if gestcen ==	23;	   /*Pennsylvania */
		replace st_fips = 	44	 if gestcen ==	15;	   /*Rhode Island */
		replace st_fips = 	45	 if gestcen ==	57;	   /*South Carolina */
		replace st_fips = 	46	 if gestcen ==	45;	   /*South Dakota */
		replace st_fips = 	47	 if gestcen ==	62;	   /*Tennessee */
		replace st_fips = 	48	 if gestcen ==	74;	   /*Texas */
		replace st_fips = 	49	 if gestcen ==	87;	   /*Utah */
		replace st_fips = 	50	 if gestcen ==	13;	   /*Vermont */
		replace st_fips = 	51	 if gestcen ==	54;	   /*Virginia */
		replace st_fips = 	53	 if gestcen ==	91;	   /*Washington */
		replace st_fips = 	54	 if gestcen ==	55;	   /*West Virginia */
		replace st_fips = 	55	 if gestcen ==	35;	   /*Wisconsin */
		replace st_fips = 	56	 if gestcen ==	83;	   /*Wyoming */
						
/*==============================================================================
	SAVE FILE FOR LATER USE [i.e. merge w/ other files]
==============================================================================*/
		save "$DATA/sim_elig_adults2.dta",  replace;

clear;

