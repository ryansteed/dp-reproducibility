/******
* 01. *
******/

libname input  "C:\input"; run;
libname output "C:\output"; run;
libname bs "D:\bs"; run;
%let input = C:\input;
%let output = C:\output;
%let bs = D:\bs;


*el.cq_election_raw is the raw election data from obtained from CQ and imported into sas.
***********************************************************************************************************************************;
proc import datafile="&input.\cq_election.xlsx"	
			out=cq_election_raw
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
/*Drop Alaska - election results by precincts not county*/
data election; set cq_election_raw; where racedate^=. & state^="Alaska" & Area^="Votes Not Reported by County" & area^="Federal Ballots" &
area^="OVERSEAS VOTE" & area^="Special Ballots" & area^="Special Absentee" & area^="Federal Absentees" & totalvotes^=. & totalvotes^=0; run; 
/*Drop 17 duplicated entries for Wyoming in 1992*/
proc sort nodup data=election; by state area racedate; run;
/*Getting county fips*/
/*State abb*/
proc sql;                 
	create table election as
	select distinct a.*,upcase(b.st) as st
	from election a left join input.state_ab b
	on a.state=b.state_name;
quit;
data election; set election; year=int(racedate/10000); month=int((racedate-year*10000)/100); day=racedate-year*10000-month*100; date=mdy(month,day,year); format date date9.; run;
*Cities in VA after 2016;
data election; 
	set election;
	if st="VA" & year>=2016 then area2=propcase(area); 
if st="VA" & year>=2016 & area2="Alexandria" then do area="Alexandria City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Bristol" then do area="Bristol City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Buena Vista" then do area="Buena Vista City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Charlottesville" then do area="Charlottesville City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Chesapeake" then do area="Chesapeake City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Colonial Heights" then do area="Colonial Heights City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Covington" then do area="Covington City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Danville" then do area="Danville City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Emporia" then do area="Emporia City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Falls Church" then do area="Falls Church City"; AreaType="City"; end;
if st="VA" & year>=2016 & area2="Fredericksburg" then do area="Fredericksburg City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Galax" then do area="Galax City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Hampton" then do area="Hampton City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Harrisonburg" then do area="Harrisonburg City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Hopewell" then do area="Hopewell City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Lexington" then do area="Lexington City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Lynchburg" then do area="Lynchburg City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Manassas" then do area="Manassas City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Manassas Park" then do area="Manassas Park City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Martinsville" then do area="Martinsville City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Newport News" then do area="Newport News City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Norton" then do area="Norton City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Petersburg" then do area="Petersburg City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Poquoson" then do area="Poquoson City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Portsmouth" then do area="Portsmouth City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Radford" then do area="Radford City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Salem" then do area="Salem City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Staunton" then do area="Staunton City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Suffolk" then do area="Suffolk City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Virginia Beach" then do area="Virginia Beach City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Waynesboro" then do area="Waynesboro City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Williamsburg" then do area="Williamsburg City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Winchester" then do area="Winchester City"; AreaType="City"; end;	
if st="VA" & year>=2016 & area2="Bedford City" then AreaType="City";
if st="VA" & year>=2016 & area2="Fairfax City" then AreaType="City";
if st="VA" & year>=2016 & area2="Norfolk City" then AreaType="City";
if st="VA" & year>=2016 & area2="Franklin City" then AreaType="City";
if st="VA" & year>=2016 & area2="Richmond City" then AreaType="City";
if st="VA" & year>=2016 & area2="Roanoke City" then AreaType="City";
run;
*Cities in Virginia before 2016;
data election; set election; if AreaType="City" & year<2016 then area2=transtrn(area, " CITY", ""); run;
data election; set election; if AreaType="City" & year<2016 & area2^="" then area=area2; run;
data election; set election; if (AreaType="County" | (year>=2016 & areatype^="City")) & st^="LA" then do area3=strip(propcase(area)); county=catx(' ',area3," County"); end;
else if year>=2016 & areatype="City" then do area3=strip(propcase(area)); county=area3; end;
else if year<2016 & AreaType="City" then do area3=strip(propcase(area)); county=catx(' ',area3," City"); end; 
else if st="LA" then do area3=strip(propcase(area)); county=catx(' ',area3," Parish"); end; run; 
proc sql;                 
	create table election as
	select distinct a.*, b.fips_st*1000+b.fips_cn as fips
	from election a left join input.county_name_fips b
	on a.st=b.state_ab & lowcase(a.county)=lowcase(b.county);
quit;
data election; set election; if st="MD" & area3="Baltimore City" then fips=24510; if st="MO" & area3="St. Louis City" then fips=29510; run;
data election; set election; repvote=input(repvotes,best12.); demvote=input(demvotes,best12.); drop repvotes demvotes; run;
proc sort data=election; by fips state county year; run;
/*Aggregate wards in DC*/
data DC; set election; where state="District of Columbia"; run;
proc sql;                 
	create table dc as
	select distinct state, racedate, st, date, year, month, sum(TotalVotes) as TotalVotes, sum(RepVote) as RepVote, sum(DemVote) as DemVote, fips
	from dc
	group by year;
quit;
data dc; set dc; fips=11001; run;
data election2; set election; where state^="District of Columbia"; run;
data election3; set election2 dc; run;
/*Manually filling in missing fips*/
data election3; set election3; 
if state="Virginia" & county="South Boston City" then fips=51780; 
if state="Texas" & county="De Witt County" then fips=48123;
if state="North Dakota" & county="La Moure County" then fips=38045;
if state="Nevada" & county="Carson City County" then fips=32510;
if state="Virginia" & county="Clifton Forge City" then fips=51560;
if state="Mississippi" & county="De Soto County" then fips=28033;
if state="Maryland" & county="St. Marys County" then fips=24037;
if state="Maryland" & county="Queen Annes County" then fips=24035;
if state="Maryland" & county="Prince Georges County" then fips=24033;
if state="Indiana" & county="La Porte County" then fips=18091;
if state="Illinois" & county="La Salle County" then fips=17099;
if state="Illinois" & county="Du Page County" then fips=17043;
run;
data election3; set election3; where fips^=.; run; *9 observations dropped for miscellaneous reasons including several with area = Kansas or Kansas city;
*check the no of years each fips appears in the sample;
proc sql;                 
	create table election3 as
	select distinct *, count(year) as no_year
	from election3
	group by fips
	order by no_year, fips, year;
quit;
***********************************************************************************************************************************;
/*Changes in vote share*/
proc sql;                 
	create table election3 as
	select distinct a.*, b.repvote as repvote_last,b.demvote as demvote_last,b.totalvotes as totalvotes_last,b.date as date_last, 
	b.thirdvotes as thirdvotes_last, b.othervotes as othervotes_last
	from election3 a left join election3 b
	on a.year=b.year+4 & a.fips=b.fips
	where a.fips^=.;
quit;

data output.vote_cny; set election3; where year>=1992; keep year st date date_last fips repvote demvote totalvotes repvote_last demvote_last totalvotes_last; run;
proc sort data=output.vote_cny; by fips year; run;









/******
* 02. *
******/

data output.irs_cnty_8916; set input.irs_cnty_8916_raw;
				if fips=11000 then fips=11001; /*DC*/
				if fips=12025 then fips=12086; /*Miami-Dade county*/
				if adjusted_gross_income<=0 | dividend<0 then delete;
				if state="county income" then state="";
				if fips=13235 & state="MISSOURI" then delete; *error, duplicate;
				state_fips=int(fips/1000); 
				if year=1989 & (state_fips=6 | state_fips=18 | state_fips=51) then adjusted_gross_income=adjusted_gross_income/10; /*Correcting errors in the gross income data*/
run; 








/******
* 03. *
******/


*Data from NBER https://www.nber.org/data/census-intercensal-county-population-age-sex-race-hispanic.html;
*************************************************************************************
*1990 to 1999;
data stch1999; set input.stch1999; where racesex^=1 & racesex^=2 & ethnic=2; run;
data cnty90_99; set input.stch1990 input.stch1991 input.stch1992 input.stch1993 input.stch1994 input.stch1995 input.stch1996 input.stch1997 input.stch1998 input.stch1999; run;

proc sql;                 
	create table cnty90_99_pop as
	select distinct state,county as fips,year,sum(pop) as tot_pop
	from cnty90_99
	group by county,year;
	*age;
	create table cnty90_99_under20 as
	select distinct state,county as fips,year,sum(pop) as pop_under20
	from cnty90_99
	where agegroup<=4
	group by county,year;

	create table cnty90_99_above65 as
	select distinct state,county as fips,year, sum(pop) as pop_above65
	from cnty90_99
	where agegroup>=14 & agegroup<=18
	group by county,year;
	*race;
	create table cnty90_99_white as
	select distinct state,county as fips,year,sum(pop) as pop_white
	from cnty90_99 
	where (racesex=1 | racesex=2) & ethnic=1
	group by county, year;

	create table cnty90_99_black as
	select distinct state,county as fips,year, sum(pop) as pop_black
	from cnty90_99
	where (racesex=3 | racesex=4) & ethnic=1
	group by county, year;
	
	create table cnty90_99_hispanic as
	select distinct state,county as fips,year, sum(pop) as pop_hispanic
	from cnty90_99 
	where ethnic=2
	group by county, year;
quit;
data cnty90_99_age_race;
	merge cnty90_99_pop cnty90_99_under20 cnty90_99_above65 cnty90_99_white cnty90_99_black cnty90_99_hispanic;
run;
*************************************************************************************
*2000 to 2010;
data cnty00_10; set input.coest00intalldata; where yearref^=1 & yearref^=12; age=agegrp; if yearref=2 then year=2000; if yearref=3 then year=2001; if yearref=4 then year=2002;
if yearref=5 then year=2003; if yearref=6 then year=2004; if yearref=7 then year=2005; if yearref=8 then year=2006; if yearref=9 then year=2007; 
if yearref=10 then year=2008; if yearref=11 then year=2009; if yearref=13 then year=2010; run;
data cnty00_10_pop; set cnty00_10; where age=99; pop_white=nhwa_male+nhwa_female; pop_black=nhba_male+nhba_female; pop_hispanic=h_male+h_female; fips=county;
keep year fips tot_pop pop_white pop_black pop_hispanic; run;
*age;
proc sql;
	create table cnty00_10_age_race as
	select distinct a.*,sum(b.tot_pop) as pop_under20
	from cnty00_10_pop a left join cnty00_10 b 
	on a.fips=b.county & a.year=b.year
	where b.agegrp<=4
	group by a.fips,a.year;

	create table cnty00_10_age_race as
	select distinct a.*,sum(b.tot_pop) as pop_above65
	from cnty00_10_age_race a left join cnty00_10 b 
	on a.fips=b.county & a.year=b.year
	where b.agegrp>=14 & b.agegrp<=18
	group by a.fips,a.year;
quit;

*2010-2020;
proc import datafile="&input\cc-est2020-alldata.xlsx"	out=cnty20 DBMS=xlsx REPLACE; GETNAMES=YES; Run;
data cnty_1120; set cnty20; where year>=4; if year=4 then year2=2011; else if year=5 then year2=2012; else if year=6 then year2=2013;
else if year=7 then year2=2014; else if year=8 then year2=2015; else if year=9 then year2=2016; else if year=10 then year2=2017; 
else if year=11 then year2=2018; else if year=12 then year2=2019; else if year=13 then year2=2020;
fips=state*1000+county; tot_pop2=input(tot_pop, comma10.); run;

data cnty1120_pop; set cnty_1120; where agegrp=0; nhwa_male2=input(nhwa_male, comma10.); nhwa_female2=input(nhwa_female, comma10.); nhba_male2=input(nhba_male, comma10.);
 nhba_female2=input(nhba_female, comma10.); h_male2=input(h_male, comma10.); h_female2=input(h_female, comma10.); drop tot_pop; rename tot_pop2=tot_pop; run;

data cnty1120_pop; set cnty1120_pop; pop_white=nhwa_male+nhwa_female; pop_black=nhba_male+nhba_female; pop_hispanic=h_male+h_female; 
keep year2 fips tot_pop pop_white pop_black pop_hispanic; run;
*age;
proc sql;
	create table cnty1120_age_race as
	select distinct a.*,sum(b.tot_pop2) as pop_under20
	from cnty1120_pop a left join cnty_1120 b 
	on a.fips=b.fips & a.year2=b.year2
	where b.agegrp<=4 & b.agegrp^=0 
	group by a.fips,a.year2; 

	create table cnty1120_age_race as
	select distinct a.*,sum(b.tot_pop2) as pop_above65
	from cnty1120_age_race a left join cnty_1120 b 
	on a.fips=b.fips & a.year2=b.year2
	where b.agegrp>=14 & b.agegrp<=18 
	group by a.fips,a.year2;
quit;
data cnty1120_age_race; set cnty1120_age_race; rename year2=year; run;

data cnty90_99_age_race; set cnty90_99_age_race; fips2=input(fips, comma5.); drop fips; rename fips2=fips; run;
data cnty00_10_age_race; set cnty00_10_age_race; fips2=input(fips, comma5.); drop fips; rename fips2=fips; run;

data output.cnty_age_race; set cnty90_99_age_race cnty00_10_age_race cnty1120_age_race; run;


******************************************************************************************************************************
*Urban & education in 1990 and 2010;
*Urbanicity data 1990;
proc import datafile="&input.\urban1990_CDC.xlsx"	
			out=urban_1990
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
data urban_1990; set urban_1990; fips2=input(fips, best5.); if fips2=12025 then fips2=12086; run; 
*Urban population 2010;
proc import datafile="&input.\PctUrbanRural_County_2010.xlsx"	
			out=urban_2010
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
data urban_2010; set urban_2010; fips=state*1000+county; keep fips poppct_urban; run;

*Education attainment 1990;
proc import datafile="&input.\Education_attainment_usda_90_20_145yearACS.xlsx"	
			out=edu_1990
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
data edu_1990; set edu_1990; rename Percent_of_adults_with_a_bachelo=bachelor_pct_1990; rename FIPS_Code=fips; run;
*Education attainment 2010;
proc import datafile="&input.\Education_attainment_ACS_2010_5year_estimate.xlsx"	
			out=edu_2010
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
data edu_2010; set edu_2010; rename VAR31=bachelor_pct_2010; id2=substr(id,10,5); fips=input(id2,best5.); run;

proc sql;
	create table edu as
	select distinct a.fips, a.bachelor_pct_1990, b.bachelor_pct_2010
	from edu_1990 a left join edu_2010 b
	on a.fips=b.fips;

	create table edu_urban1990 as
	select distinct a.*, (b.P0060001+b.P0060002)/b.P0010001*100 as poppct_urban1990
	from edu a left join urban_1990 b
	on a.fips=b.fips2;

	create table edu_urban as
	select distinct a.*, poppct_urban as poppct_urban2010
	from edu_urban1990 a left join urban_2010 b
	on a.fips=b.fips;
quit;

data output.edu_urban_90_10; set edu_urban; 
label poppct_urban2010="poppct_urban2010"; 
label bachelor_pct_1990="bachelor_pct_1990";
label bachelor_pct_2010="bachelor_pct_2010";
if poppct_urban2010=. & poppct_urban1990=. then delete;
if bachelor_pct_1990=. & bachelor_pct_2010=. then delete;
run;





/******
* 04. *
******/


*Firm characteristics;



* remote connect to WRDS to download and merge data;
/*
rsubmit;
libname crsp '/wrds/crsp/sasdata/a_ccm'; 
libname comp '/wrds/comp/sasdata/naa';
libname comp2 "/wrds/comp/sasdata/naa/company";
libname crsp2 '/wrds/crsp/sasdata/a_stock';
data work.funda;
   set comp.funda;
   where fyear>=1987;
   if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C';
  * create begin and end dates for fiscal year;
   format endfyr begfyr date9.;
   endfyr= datadate;
   begfyr= intnx('month',endfyr,-11,'beg');  
   keep cik gvkey cusip datadate conm fyear endfyr; 
run;  
proc sql;
	  create table work.funda as select *
	  from work.funda as a, crsp.ccmxpf_linktable as b
	  where a.gvkey = b.gvkey and
	  b.LINKTYPE in ("LU","LC","LD","LN","LS","LX") and
	  b.usedflag=1 and 
  	  (b.LINKDT <= a.endfyr or b.LINKDT = .B) and (a.endfyr <= b.LINKENDDT or b.LINKENDDT = .E);   
quit; 
proc sql;
	 create table work.funda as
	 select a.*, b.costat, b.city,b.state,b.loc,b.county,b.addzip
	 from work.funda a left join crsp.comphead b
	 on a.gvkey=b.gvkey;
quit;
proc sql;
	 create table work.msf as
	 select a.date, a.permno, a.hsiccd, a.prc, a.shrout, a.ret, b.city,b.state,b.loc,b.county,b.addzip
	 from crsp2.msf a left join work.funda b
	 on a.permno=b.lpermno & year(a.date)=b.fyear
	 where year(a.date)>=1987;
quit;
proc sql;
	 create table work.msf as
	 select a.*,b.naics
	 from work.msf a left join crsp2.msenames b
	 on a.permno=b.permno & b.namedt<=a.date<=b.nameendt;
quit;
proc download data=work.msf out=input.msf; run;
endrsubmit;
*/

*value weighted monthly returns by state;
data msf2018; set input.msf; where year(date)=2018 & month(date)=12; keep state permno; run;
proc sql;
	 create table msf as
	 select a.*,b.state as state2018
	 from input.msf a left join msf2018 b
	 on a.permno=b.permno;
quit;
data msf; set msf; if year(date)=2019 | year(date)=2020 then state=state2018; run;

data msf; set msf; where state^=""; run; 
proc sql;
	 create table msf as
	 select a.date, a.permno, a.state, a.ret, a.prc, b.shrout as shrout_m1, b.prc as prc_m1
	 from msf a left join msf b
	 on a.permno=b.permno & intck('month',b.date,a.date)=1
	 order by a.permno,a.date;
quit;
proc sql;
	 create table state_return as
	 select date, state, sum(shrout_m1*abs(prc_m1)*ret)/sum(shrout_m1*abs(prc_m1)) as ret
	 from msf
	 group by date,state;
quit;
proc sql;                 
	create table state_return as
	select distinct a.*, b.CPI_all_urban as cpi
	from state_return a left join input.cpi_monthly b
	on year(a.date)=year(b.observation_date) & month(a.date)=month(b.observation_date);
	
	create table state_return as
	select distinct a.*, b.CPI_all_urban as cpi_l1
	from state_return a left join input.cpi_monthly b
	on (year(a.date)=year(b.observation_date) & month(a.date)=month(b.observation_date)+1) | (year(a.date)=year(b.observation_date)+1 & month(a.date)=1 & month(b.observation_date)=12);
quit;
data output.state_return; set state_return;  ret_real=(1+ret)*cpi_l1/cpi-1; run;

/**********************************Local return based on industry employment ******************/
proc import datafile="&input.\2002_NAICS_to_1987_SIC.xlsx"	
			out=NAICS2002_to_1987_SIC
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
data NAICS2002_to_1987_SIC; set NAICS2002_to_1987_SIC; sic2=input(sic, best4.); naics_4d=int(input(_2002_NAICS, best6.)/100); 
naics_2d=int(input(_2002_NAICS, best6.)/10000); naics2=input(naics_2002, best6.); sic_2d=int(sic2/100); run;
proc sql;
	 create table msf_naics as
	 select distinct a.date, a.permno, abs(a.prc)*a.shrout as mv, a.ret, a.hsiccd, a.naics, b.naics_4d
	 from input.msf a left join NAICS2002_to_1987_SIC b
	 on a.hsiccd=b.sic2; 
quit;
data msf_naics; set msf_naics; if naics_4d=. & naics^=. then naics_4d=int(naics/100); run;
proc sort data=msf_naics; by naics_4d date permno; run;

proc sql;
	 create table monthly_ret_naics_4d as
	 select distinct date, naics_4d, sum(mv*ret)/sum(mv) as ret_naics4d
	 from msf_naics
	 where naics_4d^=.
	 group by naics_4d, date;
quit;

*County employment by industry;
data singlefile; set empty; run;
%macro loop;
%do year=1990 %to 2019;
proc import datafile="&input.\&year..annual.singlefile.csv"	
			out=singlefile&year
			DBMS=csv
			REPLACE;
		    GETNAMES=YES;
Run;
data singlefile&year; set singlefile&year; where (agglvl_code="76") & (own_code="5" | own_code="2" | own_code="3" | own_code="4" | own_code="1"); 
keep area_fips industry_code year annual_avg_emplvl; if annual_avg_emplvl=0 then delete; run;
data singlefile; set singlefile singlefile&year; run;
%end;
%mend;
%loop;

data qcew_cnty_naics4d; set singlefile; fips=input(area_fips, best5.); naics_4d=input(industry_code, best4.); year2=input(year, best4.);
if naics_4d<1100 then delete; run;

proc sql;
	 create table qcew_cnty_naics4d as
	 select distinct *, sum(annual_avg_emplvl) as emp_sum
	 from  qcew_cnty_naics4d 
	 group by fips, year; 
quit;

proc sql;
	 create table cnty_ret_ind_w as
	 select distinct b.date, a.fips, a.emp_sum, sum(a.annual_avg_emplvl*b.ret_naics4d)/sum(a.annual_avg_emplvl) as ret_ind_w, sum(annual_avg_emplvl) as emp_sum_nonmising_ret
	 from  qcew_cnty_naics4d a, monthly_ret_naics_4d b
	 where a.naics_4d=b.naics_4d & ((year(b.date)=a.year2+1 & year(b.date)>1990) | (year(b.date)<=1990 & a.year2=1990))
	 group by a.fips, b.date;
quit;

data cnty_ret_ind_w; set cnty_ret_ind_w; where emp_sum_nonmising_ret/emp_sum>0.7; run;

proc sql;                 
	create table cnty_ret_ind_w as
	select distinct a.*, b.CPI_all_urban as cpi
	from cnty_ret_ind_w a left join input.cpi_monthly b
	on year(a.date)=year(b.observation_date) & month(a.date)=month(b.observation_date);
	
	create table cnty_ret_ind_w as
	select distinct a.*, b.CPI_all_urban as cpi_l1
	from cnty_ret_ind_w a left join input.cpi_monthly b
	on (year(a.date)=year(b.observation_date) & month(a.date)=month(b.observation_date)+1) | (year(a.date)=year(b.observation_date)+1 & month(a.date)=1 & month(b.observation_date)=12);
quit;
data output.cnty_ret_ind_w; set cnty_ret_ind_w;  ret_ind_w_real=(1+ret_ind_w)*cpi_l1/cpi-1; run;
proc sort data=output.cnty_ret_ind_w; by fips date; run; 














/******
* 05. *
******/




/*Program to obtain corporate headquarters from Compustat to produce the dataset funda_head
rsubmit;
libname crsp '/wrds/crsp/sasdata/a_ccm'; 
libname comp '/wrds/comp/sasdata/naa';
data work.funda;
   set comp.funda;
   where fyear>=1988;
   if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C';
  * create begin and end dates for fiscal year;
   format endfyr begfyr date9.;
   endfyr= datadate;
   begfyr= intnx('month',endfyr,-11,'beg');  
   keep cik gvkey datadate conm fyear endfyr cusip at emp csho prcc_f sich exchg dv; 
run;  
proc sql;
	  create table work.funda as select *
	  from work.funda as a, crsp.ccmxpf_linktable as b
	  where a.gvkey = b.gvkey and
	  b.LINKTYPE in ("LU","LC","LD","LN","LS","LX") and
	  b.usedflag=1 and 
  	  (b.LINKDT <= a.endfyr or b.LINKDT = .B) and (a.endfyr <= b.LINKENDDT or b.LINKENDDT = .E);    
quit;  
proc sql;
	 create table work.funda as
	 select a.*, b.costat, b.city,b.state,b.loc,b.county,b.addzip
	 from work.funda a left join crsp.comphead b
	 on a.gvkey=b.gvkey;
quit;
proc sort data=work.funda nodupkey; by gvkey datadate; run; 
proc download data=work.funda out=input.funda_head; run; 
endrsubmit; 
*/

data funda_head; set input.funda_head; where cik^="" & state^="" & LOC="USA"; zip=input(substr(addzip,1,5),comma9.); ind=1;
cik2=input(cik,best10.); run; 

/*Using 10k headquarter data to correct for HQ changes*/
proc sql;
	 create table funda_head as
	 select a.*,b.zip as zip_10k
	 from funda_head a left join input.HQ_10k b
	 on a.cik2=b.cik & a.datadate=b.datadate;
quit;
proc sort data=funda_head; by cik desending datadate; run;

data funda_head2;
  set funda_head;
  by cik;
  if first.cik then zip_10k2=zip_10k;
  else zip_10k2=coalesce(zip_10k,zip_10k2);
  retain zip_10k2;
run;
proc sort data=funda_head2; by cik datadate; run;

data funda_head2; set funda_head2; zip_final=zip; if zip_10k2^=. then zip_final=zip_10k2; run;

data funda_head2; set funda_head2; 
if cik2=49401 then zip_final=1961;
if cik2=63541 then zip_final=50208;
if cik2=85812 then zip_final=35001;
if cik2=95953 then zip_final=29304;
if cik2=797917 then zip_final=6484;
if cik2=812796 then zip_final=58104;
if cik2=834365 then zip_final=20850;
if cik2=846876 then zip_final=3051;
if cik2=909990 then zip_final=80301;
if cik2=1084384 then zip_final=33558;
if cik2=1316898 then zip_final=94608;
if cik2=65312 & fyear<=1998 then zip_final=11753;
if cik2=814562 & fyear<=1996 then zip_final=10281;
if cik2=829608 & fyear<=2001 then zip_final=92103;
if cik2=846876 & fyear<=2005 then zip_final=3051;
run;

/*Zip-county cross walk from HUD;
proc import datafile="&input.\ZIP_COUNTY_032010.xlsx"	
			out=zip_county
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;

proc import datafile="&input.\zip_code_county_mannual.xlsx"	
			out=zip_code_county_mannual
			DBMS=xlsx
			REPLACE;
		    GETNAMES=YES;
Run;
data zip_county; set zip_county; zip2=input(zip,comma9.); fips=input(county,comma9.); run; 
data input.zip_county; set zip_code_county_mannual zip_county; run;*/

proc sql;
	 create table work.cnty_head_count as
	 select a.fips, b.fyear as year_hq, sum(b.ind) as head_count, sum(b.at) as total_at, sum(b.emp) as total_emp, sum(b.prcc_f*csho) as total_mv
	 from input.zip_county a left join funda_head2 b
	 on a.zip2=b.zip_final & a.tot_ratio>0.1 & zip_final^=.
	 where a.fips^=.
	 group by a.fips, b.fyear
	 order by a.fips, b.fyear;
quit;

proc export data=work.cnty_head_count outfile="&output.\cnty_head_count" dbms=stata replace; run;
















/******
* 06. *
******/



***********************************************************************************************************************************;
/*Transform return to real return;*/
proc sql;                 
	create table msi as
	select distinct a.*, b.CPI_all_urban as cpi
	from input.msi a left join input.cpi_monthly b
	on year(a.date)=year(b.observation_date) & month(a.date)=month(b.observation_date);
	
	create table msi as
	select distinct a.*, b.CPI_all_urban as cpi_l1
	from msi a left join input.cpi_monthly b
	on (year(a.date)=year(b.observation_date) & month(a.date)=month(b.observation_date)+1) | (year(a.date)=year(b.observation_date)+1 & month(a.date)=1 & month(b.observation_date)=12);
quit;
data output.msi_real; set msi; ret=(1+vwretd)*cpi_l1/cpi-1; run;
/*Stock returns*/
proc sql;                 
	create table vote_cny as
	select distinct a.*, exp(sum(log(1+b.ret)))-1 as ret
	from output.vote_cny a left join output.msi_real b
	on b.date>a.date_last & b.date<a.date /*cumulative return from November of the previous election year to October of the current election year*/
	where a.date_last^=.
	group by a.fips,a.date; 

	create table vote_cny as
	select distinct a.*, exp(sum(log(1+b.ret)))-1 as ret1
	from vote_cny a left join output.msi_real b
	on year(a.date)=year(b.date) & b.date<a.date
	where a.date_last^=.
	group by a.fips,a.date;

	create table vote_cny as
	select distinct a.*, exp(sum(log(1+b.ret)))-1 as ret4
	from vote_cny a left join output.msi_real b
	on year(a.date)=year(b.date)+3 | (year(a.date)=year(b.date)+4 & month(b.date)>=11)
	where a.date_last^=.
	group by a.fips,a.date;
quit;
***************************************************************************************************************************************************
***************************************************************************************************************************************************;

proc export data=output.msi_real outfile="&output.\msi_real" dbms=stata replace; run; 

***************************************************************************************************************************************************
***************************************************************************************************************************************************;

/*Merge with IRS dividend income data*/
proc sql;                 
	create table vote_cny2 as
	select distinct a.*, b.dividend, b.adjusted_gross_income 
	from vote_cny a left join output.irs_cnty_8916 b
	on a.fips=b.fips & a.year=b.year+4
	order by a.fips,a.year;
quit;
*use 1989 dividend income ratio for 1992 election;
proc sql;                 
	create table vote_cny2 as
	select distinct a.*, b.dividend as dividends1989, b.adjusted_gross_income as adjusted_gross_income_1989
	from vote_cny2 a left join output.irs_cnty_8916 b
	on a.fips=b.fips & b.year=1989;
quit;
data vote_cny2; set vote_cny2; if year=1992 then do; dividend=dividends1989; adjusted_gross_income=adjusted_gross_income_1989; end; run;
proc sort data=vote_cny2; by adjusted_gross_income fips year; run;

***************************************************************************************************************************************************
Other county level data;
*Combined areas in Virginia in the BEA data;
data vote_cny2; set vote_cny2;
fips_bea=99999;
if fips=	15009	then fips_bea=	15901; *Maui;
if fips=    46113   then fips_bea=  46102; *Shannon/Oglala Lakota, SD;
if fips=	51003	then fips_bea=	51901;
if fips=	51005	then fips_bea=	51903;
if fips=	51015	then fips_bea=	51907;
if fips=	51031	then fips_bea=	51911;
if fips=	51035	then fips_bea=	51913;
if fips=	51053	then fips_bea=	51918;
if fips=	51059	then fips_bea=	51919;
if fips=	51069	then fips_bea=	51921;
if fips=	51081	then fips_bea=	51923;
if fips=	51089	then fips_bea=	51929;
if fips=	51095	then fips_bea=	51931;
if fips=	51121	then fips_bea=	51933;
if fips=	51143	then fips_bea=	51939;
if fips=	51149	then fips_bea=	51941;
if fips=	51153	then fips_bea=	51942;
if fips=	51161	then fips_bea=	51770;
if fips=	51163	then fips_bea=	51945;
if fips=	51165	then fips_bea=	51947;
if fips=	51175	then fips_bea=	51949;
if fips=	51177	then fips_bea=	51951;
if fips=	51191	then fips_bea=	51953;
if fips=	51195	then fips_bea=	51955;
if fips=	51199	then fips_bea=	51958;
if fips=	51515	then fips_bea=	51019;
if fips=	51520	then fips_bea=	51953;
if fips=	51530	then fips_bea=	51945;
if fips=	51540	then fips_bea=	51901;
if fips=	51570	then fips_bea=	51918;
if fips=	51580	then fips_bea=	51903;
if fips=	51590	then fips_bea=	51939;
if fips=	51595	then fips_bea=	51923;
if fips=	51600	then fips_bea=	51919;
if fips=	51610	then fips_bea=	51919;
if fips=	51620	then fips_bea=	51949;
if fips=	51630	then fips_bea=	51951;
if fips=	51640	then fips_bea=	51913;
if fips=	51660	then fips_bea=	51947;
if fips=	51670	then fips_bea=	51941;
if fips=	51678	then fips_bea=	51945;
if fips=	51680	then fips_bea=	51911;
if fips=	51683	then fips_bea=	51942;
if fips=	51685	then fips_bea=	51942;
if fips=	51690	then fips_bea=	51929;
if fips=	51720	then fips_bea=	51955;
if fips=	51730	then fips_bea=	51918;
if fips=	51735	then fips_bea=	51958;
if fips=	51750	then fips_bea=	51933;
if fips=	51775	then fips_bea=	51944;
if fips=	51790	then fips_bea=	51907;
if fips=	51820	then fips_bea=	51907;
if fips=	51830	then fips_bea=	51931;
if fips=	51840	then fips_bea=	51921;
run;
proc sql;           
	create table vote_cny3 as
	select distinct a.*, b.value as ipc, log(b.value) as ipc_ln
	from vote_cny2 a left join input.county_income b
	on (a.fips=b.fips | a.fips_bea=b.fips) & b.linecode=3 & a.year=b.year; *income per capita; 

	create table vote_cny3 as
	select distinct a.*, b.value as ipc_l4, log(b.value) as ipc_l4_ln
	from vote_cny3 a left join input.county_income b
	on (a.fips=b.fips | a.fips_bea=b.fips) & b.linecode=3 & a.year=b.year+4; *lagged income per capita;

	create table vote_cny3 as
	select distinct a.*, b.value as pop, log(b.value) as pop_ln
	from vote_cny3 a left join input.county_income b
	on (a.fips=b.fips | a.fips_bea=b.fips) & b.linecode=2 & a.year=b.year; *population;

	create table vote_cny3 as
	select distinct a.*, b.value as pop_l4, log(b.value) as pop_l4_ln
	from vote_cny3 a left join input.county_income b
	on (a.fips=b.fips | a.fips_bea=b.fips) & b.linecode=2 & a.year=b.year+4; *lagged population;
quit;

proc sql;                 
	create table vote_cny4 as
	select distinct a.*, b.unemploy_rate/100 as unemp_rate
	from vote_cny3 a left join input.cnty_unem b
	on (a.fips=b.fips | (a.fips_bea=51019 & b.fips=51019) | (a.fips_bea=46102 & b.fips=46102)) & a.year=b.year2; 
            
	create table vote_cny4 as
	select distinct a.*, b.unemploy_rate/100 as unemp_rate_l4
	from vote_cny4 a left join input.cnty_unem b
	on (a.fips=b.fips | (a.fips_bea=51019 & b.fips=51019) | (a.fips_bea=46102 & b.fips=46102)) & a.year=b.year2+4; 

	create table vote_cny4 as
	select distinct a.*, b.unemploy_rate/100 as unemp_rate_1990
	from vote_cny4 a left join input.cnty_unem b
	on (a.fips=b.fips | (a.fips_bea=51019 & b.fips=51019) | (a.fips_bea=46102 & b.fips=46102)) & b.year2=1990; 
quit;

**********************************************************************************************************;
*Merge with wage growth and employment growth;
proc sql;                 
	create table vote_cny5 as
	select distinct a.*, b.average_weekly_wage
	from vote_cny4 a left join input.qcew_8820 b
	on a.fips=b.fips & a.year=b.yr; 
            
	create table vote_cny5 as
	select distinct a.*, b.average_weekly_wage as average_weekly_wage_l4
	from vote_cny5 a left join input.qcew_8820 b
	on a.fips=b.fips & a.year=b.yr+4; 

	create table vote_cny5 as
	select distinct a.*, b.average_weekly_wage as average_weekly_wage_1990
	from vote_cny5 a left join input.qcew_8820 b
	on a.fips=b.fips & b.yr=1990; 
quit;
****************************************************************************************************************;
*Demographic (race and age) controls;
proc sql;                 
	create table vote_cny6 as
	select distinct a.*, b.*
	from vote_cny5 a left join output.cnty_age_race b
	on a.fips=b.fips & a.year=b.year; 

	create table vote_cny6 as
	select distinct a.*, b.tot_pop as tot_pop_l4, b.pop_white as pop_white_l4, b.pop_black as pop_black_l4, b.pop_hispanic as pop_hispanic_l4, 
	b.pop_under20 as pop_under20_l4, b.pop_above65 as pop_above65_l4
	from vote_cny6 a left join output.cnty_age_race b
	on a.fips=b.fips & a.year=b.year+4; 

	create table vote_cny6 as
	select distinct a.*, b.tot_pop as tot_pop1990, b.pop_white as pop_white1990, b.pop_black as pop_black1990, b.pop_hispanic as pop_hispanic1990, 
	b.pop_under20 as pop_under20_1990, b.pop_above65 as pop_above65_1990
	from vote_cny6 a left join output.cnty_age_race b
	on a.fips=b.fips & b.year=1990; 
quit;
data vote_cny6; set vote_cny6; if year=1992 then do tot_pop_l4=tot_pop1990; pop_white_l4=pop_white1990; pop_black_l4=pop_black1990; pop_hispanic_l4=pop_hispanic1990; 
	pop_under20_l4=pop_under20_1990; pop_above65_l4=pop_above65_1990; end; 
run;
*Education attainment and urban population in 1990 and 2010;
proc sql;
	create table vote_cny7 as
	select distinct a.*, b.*
	from vote_cny6 a left join output.edu_urban_90_10 b 
	on a.fips=b.fips; 
quit;
/*Local returns*/
proc sql;           
	create table vote_cny8 as
	select distinct a.*, exp(sum(log(1+b.ret_real)))-1 as ret_state
	from vote_cny7 a left join output.state_return b
	on a.st=b.state & b.date>a.date_last & b.date<a.date
	where a.date_last^=.
	group by a.fips,a.date;

	create table vote_cny8 as
	select distinct a.*, exp(sum(log(1+b.ret_ind_w_real)))-1 as ret_ind_w
	from vote_cny8 a left join output.cnty_ret_ind_w b 
	on a.fips=b.fips & b.date>a.date_last & b.date<a.date
	group by a.fips, a.year;
quit;
*County job types June 14, 2018;
data allhlcn; set input.allhlcn; where quarter=4 & fips^=.; keep fips yr industry employment naics; run;
proc sort data=allhlcn; by fips yr; run;
proc transpose data=allhlcn out=cnty_job prefix=industry; by fips yr; id naics; var employment; run; 
data cnty_job; set cnty_job; natural=industry1011/industry10; construction=industry1012/industry10; manufacturing=industry1013/industry10; trade=industry1021/industry10;
information=industry1022/industry10; financial=industry1023/industry10; professional=industry1024/industry10; education=industry1025/industry10; 
leisure=industry1026/industry10; other_service=industry1027/industry10; run;
proc sql;                 
	create table vote_cny9 as
	select distinct a.*, b.natural,b.construction,b.manufacturing,b.trade,b.information,b.financial,b.professional,b.education,b.leisure,b.other_service
	from vote_cny8 a left join cnty_job b
	on a.year=b.yr+1 & a.fips=b.fips;
quit;
*Aggregate variables;
proc sql;                 
	create table vote_cny10 as
	select distinct a.*, exp(sum(log(1+b.change/400)))-1 as gdp_growth
	from vote_cny9 a left join input.quarterly_real_GDP_growth b
	on year(b.date)>year(a.date_last) & (year(b.date)<year(a.date) | (year(b.date)=year(a.date) & qtr(b.date)<=3))
	group by a.fips,a.date;
quit; 
*Wage;
proc sql;                 
	create table vote_cny10 as
	select distinct a.*, b.weekly_wage as agg_weekly_wage 
	from vote_cny10 a left join input.wage_aggregate b
	on year(a.date)=year(b.observation_date) & qtr(b.observation_date)=3; /*July 1, for third quarter*/

	create table vote_cny10 as
	select distinct a.*, b.weekly_wage as agg_weekly_wage_l4
	from vote_cny10 a left join input.wage_aggregate b
	on year(a.date)=year(b.observation_date)+4 & qtr(b.observation_date)=4; 
quit; 
*Unemployment rate;
proc sql;                 
	create table vote_cny10 as
	select distinct a.*, b.unrate as agg_unemployment_rate
	from vote_cny10 a left join input.unrate_aggregate_monthly b
	on year(a.date)=year(observation_date) & month(observation_date)=10; 

	create table vote_cny10 as
	select distinct a.*, b.unrate as agg_unemployment_rate_l4
	from vote_cny10 a left join input.unrate_aggregate_monthly b
	on year(a.date)=year(observation_date)+4 & month(observation_date)=12;
quit; 
*Federal funds rate;
proc sql;                 
	create table vote_cny10 as
	select distinct a.*,  b.fedfunds as ffrate
	from vote_cny10 a left join input.fed_fund b
	on year(a.date)=year(b.observation_date) & month(b.observation_date)=10;

	create table vote_cny10 as
	select distinct a.*,  b.fedfunds as ffrate_l4
	from vote_cny10 a left join input.fed_fund b
	on year(a.date)=year(b.observation_date)+4 & month(b.observation_date)=12;
quit; 
/*Moody's Seasoned Baa Corporate Bond Yield-Moody's Seasoned Aaa Corporate Bond Yield*/
proc sql;                 
	create table vote_cny10 as
	select distinct a.*,  b.BAA_AAA_moody as credit_spread
	from vote_cny10 a left join input.Credit_spread_moody b
	on year(a.date)=year(b.observation_date) & month(b.observation_date)=10; 

	create table vote_cny10 as
	select distinct a.*,  b.BAA_AAA_moody as credit_spread_l4
	from vote_cny10 a left join input.Credit_spread_moody b
	on year(a.date)=year(b.observation_date)+4 & month(b.observation_date)=12;
quit; 
proc export data=vote_cny10 outfile="&output.\merged_data" dbms=stata replace; run; 







/******
* 07. *
******/


***************************************************************************************************************
***************************************************************************************************************
*Measuring dividend ratio excluding the highest income group;

data incyallagi; set input.incyallagi; fips=statefips*1000+countyfips; keep fips year state countyname agi_stub A00100 N00600 A00600; run;

proc sql;                 
	create table div_ratio_excltop1017 as
	select distinct fips, countyname, year, sum(A00600)/sum(A00100) as div_ratio_exctop
	from incyallagi 
	where (agi_stub<8 & agi_stub>0 & year>=2012) | (agi_stub<7 & agi_stub>0 & year<=2011)
	group by fips, year
	order by fips, year;
quit;

*zip code level in 2006-2009, no agi above 200,000 in 2004 and 2005;
proc sql;                 
	create table zip_agi0609 as
	select distinct a.*, b.fips, b.res_ratio
	from input.zip_agi0409 as a, input.zip_county as b
	where a.year>=2006 & a.zipcode=b.zip2;
quit;
proc sql;                 
	create table cnty_exctop0609 as
	select distinct fips, year, agi_class, sum(a00100*res_ratio) as a00100, sum(a00600*res_ratio) as a00600
	from zip_agi0609 
	group by fips, year, agi_class;
quit;

proc sql;                 
	create table div_ratio_excltop0609 as
	select distinct fips, year, sum(A00600)/sum(A00100) as div_ratio_exctop
	from cnty_exctop0609
	where (agi_class<7 & agi_class>0 & year<=2008) | (agi_class<6 & agi_class>0 & year=2009)
	group by fips, year
	order by fips, year;
quit;

data div_ratio_excltop; set div_ratio_excltop0609 div_ratio_excltop1017; rename year=div_year; if div_ratio_exctop<0 then delete; run;
proc sort data=div_ratio_excltop nodupkey; by fips div_year; run;

*use 2006 values for the 2008 and prior elections;
data div_ratio_excltop; set div_ratio_excltop; if div_year=2006 then div_year=2004; run;
proc export data=div_ratio_excltop outfile="&output.\div_ratio_excltop" dbms=stata replace; run; 
***************************************************************************************************************
***************************************************************************************************************
*Fraction of tax returns that report dividend income;
*county data 10-18;
proc sql;                 
	create table cnty1017 as
	select distinct statefips*1000+countyfips as fips, state, countyname, year as div_year, sum(N00600) as div_return, sum(n1) as total_return
	from input.incyallagi
	where agi_stub>=1
	group by fips, year;
quit;
*zip code level 0409;
proc sql;                 
	create table zip_level0409 as
	select distinct state, zipcode, year, sum(n1) as no_returns, sum(n00600) as no_div_returns
	from input.zip_agi0409
	group by zipcode, year;
quit;

proc sql;                 
	create table zip_agi0409 as
	select distinct a.*, b.fips, b.res_ratio
	from zip_level0409 as a, input.zip_county as b
	where a.zipcode=b.zip2;
quit;

proc sql;                 
	create table cnty0409 as
	select distinct fips, year as div_year, state, sum(no_div_returns*res_ratio) as div_return, sum(no_returns*res_ratio) as total_return
	from zip_agi0409
	group by fips, year;
quit;

data cnty0417; set cnty0409 cnty1017; no_report_ratio=div_return/total_return;drop state; run;

*2008 values not available, use 2009 values for 2012 election;
data cnty0417; set cnty0417; where no_report_ratio^=.; if div_year=2009 then div_year=2008; run;

proc sort data=cnty0417 nodupkey; by fips div_year; run; 
proc export data=cnty0417 outfile="&output.\part_county0417" dbms=stata replace; run;









/******
* 08. *
******/



data election_date;
input elec_date :yymmdd10. elec_date_last :yymmdd10.;
format elec_date yymmddd10. elec_date_last :yymmdd10.;
datalines;
1992-11-03 1988-11-08
1996-11-05 1992-11-03
2000-11-07 1996-11-05
2004-11-02 2000-11-07
2008-11-04 2004-11-02
2012-11-06 2008-11-04
2016-11-08 2012-11-06
2020-11-03 2016-11-08
;
run;
*1 and 3-month returns;
proc sql; 
	create table election_ret_m as
	select distinct a.*, b.ret as ret_1m_c
	from election_date a left join output.msi_real b
	on year(a.elec_date)=year(b.date) & month(a.elec_date)=month(b.date)+1;

	create table election_ret_m as
	select distinct a.*, exp(sum(log(1+b.ret)))-1 as ret_3m_c
	from election_ret_m a left join output.msi_real b
	on year(a.elec_date)=year(b.date) & (month(a.elec_date)=month(b.date)+1 | month(a.elec_date)=month(b.date)+2 | month(a.elec_date)=month(b.date)+3)
	group by a.elec_date;

	create table election_ret_m as
	select distinct a.*, b.ret as ret_1m_l
	from election_ret_m  a left join output.msi_real b
	on year(a.elec_date_last)=year(b.date) & month(a.elec_date_last)=month(b.date);

	create table election_ret_m as
	select distinct a.*, exp(sum(log(1+b.ret)))-1 as ret_3m_l
	from election_ret_m a left join output.msi_real b
	on (year(a.elec_date_last)=year(b.date) & (month(a.elec_date_last)=month(b.date) | month(a.elec_date_last)=month(b.date)-1)) |  (year(a.elec_date_last)=year(b.date)-1 & month(b.date)=1)
	group by a.elec_date;
quit;

*First and last week returns;
proc sql;
	create table election_ret_m as
	select distinct a.*, exp(sum(log(1+b.vwretd)))-1 as ret_w_l
	from election_ret_m a left join input.dsi b
	on -1<=intck('day', a.elec_date_last, b.date)<=3
	group by a.elec_date;

	create table election_ret_m as
	select distinct a.*, exp(sum(log(1+b.vwretd)))-1 as ret_w_c
	from election_ret_m a left join input.dsi b
	on 4<=intck('day', b.date,a.elec_date)<=8
	group by a.elec_date;
quit;

data election_ret_m; set election_ret_m; year=year(elec_date); run;

proc export data=election_ret_m outfile="&output.\election_ret_m" dbms=stata replace; run; 

