
#delimit;
clear;
set mem 60m;
set matsize 400;
set more off;
set seed 50;

log using regressions/main_results/logs/matching.log,replace;

******************************************************************************;
**** This files creates the matched pairs of border and non-border cities ****;
**** that are used in the matching estimation in main_results.do           ****;
******************************************************************************;

**** Use data;

clear;
use regressions/main_results/data/RemotenessAER_Main.dta;

**** Create dummy for the border cities;

gen bzone=0;
replace bzone=1 if dist_gg_border<75;

**** Keep only the essential variables (We are going to match on 1939 values of pop emp and ind);

keep if year==1939;

keep city cities bzone pop emp1939 ind1939 agriculture1939 mining1939 minerals1939 steel1939 chemicals1939 
textiles1939 paper1939 print1939 leather1939 wood1939 food1939 apparel1939 shoes1939 construction1939 
utilities1939 business_services1939 transport1939 restaurants1939 public1939 education1939
clerical1939 consulting1939 medical1939 veterinary1939 beauty1939 entertainment1939 domestic1939
support1939 dist_gg_border laender_2000;
drop if pop==.;
drop if emp1939==.;
drop if ind1939==.;
so city; 

ren business_services1939 business1939;

**** Count cities in bzone;

egen temp=count(city) if bzone==1;
egen n_bcity=max(temp);
so city;

**** Create indicator variable for treatment cities;

gen treatment=1 if bzone==1;

**********************************************;
***** Create matching indicator variables ****;
**********************************************;

**** Variable definitions;

**** The con variables are dummy variables which equal 1 for ;
**** a non-border control city that is matched with a;
**** border treatment city;

**** 1) conpop matches on total population;
**** 2) conemp matches on total employment;
**** 3) conind matches on industry employment;
**** 4) coniscore matches on employment in disaggregated manufacturing industries;
**** 5) conaiscore matches on employment in all disaggregated industries;
**** 6) concaiscore matches on employment in all disaggregated industries and geography;

**** We consider each treatment city in turn and match it with the control city;
**** that is closest in terms of observed characteristics;

**** The code works by sorting treatment and control cities in terms of their;
**** relevant observed characteristics and picking those that are most;
**** similar in terms of the observed characteristics;

**** Matching is one-to-one so that once a control city has been matched with a;
**** treatment city it is excluded from being matched with other treatment cities;

**** The unique variables are used to exclude non-border cities that have; 
**** already been matched with a border city;
**** Unique starts off equal to zero and is set to 1000 once a non-border;
**** city has been matched;

gen conpop=0;
gen conemp=0;
gen conind=0;
gen coniscore=0;
gen conaiscore=0;
gen concaiscore=0;

gen uniquepop=0;
gen uniqueemp=0;
gen uniqueind=0;
gen uniqueiscore=0;
gen uniqueaiscore=0;
gen uniquecaiscore=0;

**** Some cities have missing disaggregated employment data;
**** Replace unique==1000 so that non-border cities with missing data;
**** cannot be matched with a border city;

replace uniquepop=1000 if mining1939==.;
replace uniqueemp=1000 if mining1939==.;
replace uniqueind=1000 if mining1939==.;
replace uniqueiscore=1000 if mining1939==.;
replace uniqueaiscore=1000 if mining1939==.;
replace uniquecaiscore=1000 if mining1939==.;

**** Saarland cities are excluded from our regression sample and so;
**** are excluded from the control group in the matching estimation;
**** Replace unique==1000 so that non-border Saarland cities ;
**** cannot be matched with a border city;

replace uniquepop=1000 if laender_2000=="SL";
replace uniqueemp=1000 if laender_2000=="SL";
replace uniqueind=1000 if laender_2000=="SL";
replace uniqueiscore=1000 if laender_2000=="SL";
replace uniqueaiscore=1000 if laender_2000=="SL";
replace uniquecaiscore=1000 if laender_2000=="SL";

**** Create the variable ibzone;
**** Sorting on ibzone will list the treatment cities first;

gen ibzone=bzone*-1;

**** Create a dummy variable for the geographic location of control cities;
**** that will be used in the concaiscore matching;

gen czone=1;
replace czone=0 if dist_gg_border>=100&dist_gg_border<175;

*****************************************************;
**** Code to sequentially pick out border cities ****;
**** and match them with non-border cities       ****;
*****************************************************;

**** Sort the data so that the treatment cities come first;
**** and are sorted in terms of population;

so ibzone pop;
gen order=_n;
gen report=.;

local x = 0;

while `x' < n_bcity {;

local x = `x' + 1;

**** Select the 20 border cities one by one and create a variable;
**** f... that is equal to the relevant characteristic for the;
**** selected border city;

gen fpop=pop                        if order==`x';
gen femp=emp1939                    if order==`x';
gen find=ind1939                    if order==`x';
gen fagriculture=agriculture1939     if order==`x';
gen fmining=mining1939               if order==`x';
gen fminerals=minerals1939           if order==`x';
gen fsteel=steel1939                 if order==`x';
gen fchemicals=chemicals1939         if order==`x';
gen ftextiles=textiles1939           if order==`x';
gen fpaper=paper1939                 if order==`x';
gen fprint=print1939                 if order==`x';
gen fleather=leather1939             if order==`x';
gen fwood=wood1939                   if order==`x';
gen ffood=food1939                   if order==`x';
gen fapparel=apparel1939             if order==`x';
gen fshoes=shoes1939                 if order==`x';
gen fconstruction=construction1939   if order==`x';
gen futilities=utilities1939         if order==`x';
gen fbusiness=business1939           if order==`x';
gen ftransport=transport1939         if order==`x';
gen frestaurants=restaurants1939     if order==`x';
gen fpublic=public1939               if order==`x';
gen feducation=education1939         if order==`x';
gen fclerical=clerical1939           if order==`x';
gen fconsulting=consulting1939       if order==`x';
gen fmedical=medical1939             if order==`x';
gen fveterinary=veterinary1939       if order==`x';
gen fbeauty=beauty1939               if order==`x';
gen fentertainment=entertainment1939 if order==`x';
gen fdomestic=domestic1939           if order==`x';
gen fsupport=support1939             if order==`x';

**** Currently these variables are only non-missing for the selected observation;
**** Create a variable f...all that is non-missing everywhere;

egen fpopall               =max(fpop);
egen fempall               =max(femp);
egen findall               =max(find);
egen fagricultureall       =max(fagriculture);
egen fminingall            =max(fmining);
egen fmineralsall          =max(fminerals);
egen fsteelall             =max(fsteel);
egen fchemicalsall         =max(fchemicals);  
egen ftextilesall          =max(ftextiles);  
egen fpaperall             =max(fpaper);  
egen fprintall             =max(fprint);  
egen fleatherall           =max(fleather);
egen fwoodall              =max(fwood);
egen ffoodall              =max(ffood);
egen fapparelall           =max(fapparel);
egen fshoesall             =max(fshoes);
egen fconstructionall      =max(fconstruction);
egen futilitiesall         =max(futilities);
egen fbusinessall          =max(fbusiness);
egen ftransportall         =max(ftransport);
egen frestaurantsall       =max(frestaurants);
egen fpublicall            =max(fpublic);
egen feducationall         =max(feducation);
egen fclericalall          =max(fclerical);
egen fconsultingall        =max(fconsulting);
egen fmedicalall           =max(fmedical);  
egen fveterinaryall        =max(fveterinary);
egen fbeautyall            =max(fbeauty);    
egen fentertainmentall     =max(fentertainment);
egen fdomesticall          =max(fdomestic);  
egen fsupportall           =max(fsupport);   

so ibzone pop;

**** Create a variable that is equal to the difference between the characteristic;
**** for each city in our sample and the characteristic for the selected border;
**** city. This variable is called ...diff;

gen popdiff =abs(pop-fpopall);
gen empdiff =abs(emp1939-fempall);
gen inddiff =abs(ind1939-findall);
gen agriculturediff    =abs(agriculture1939-fagricultureall);
gen miningdiff         =abs(mining1939-fminingall);
gen mineralsdiff       =abs(minerals1939-fmineralsall);
gen steeldiff          =abs(steel1939-fsteelall);
gen chemicalsdiff      =abs(chemicals1939-fchemicalsall);
gen textilesdiff       =abs(textiles1939-ftextilesall);
gen paperdiff          =abs(paper1939-fpaperall);
gen printdiff          =abs(print1939-fprintall);
gen leatherdiff        =abs(leather1939-fleatherall);
gen wooddiff           =abs(wood1939-fwoodall);
gen fooddiff           =abs(food1939-ffoodall);
gen appareldiff        =abs(apparel1939-fapparelall);
gen shoesdiff          =abs(shoes1939-fshoesall);
gen constructiondiff   =abs(construction1939-fconstructionall);
gen utilitiesdiff      =abs(utilities1939-futilitiesall);
gen businessdiff       =abs(business1939-fbusinessall);
gen transportdiff      =abs(transport1939-ftransportall);
gen restaurantsdiff    =abs(restaurants1939-frestaurantsall);
gen publicdiff         =abs(public1939-fpublicall);
gen educationdiff      =abs(education1939-feducationall);
gen clericaldiff       =abs(clerical1939-fclericalall);
gen consultingdiff     =abs(consulting1939-fconsultingall);
gen medicaldiff        =abs(medical1939-fmedicalall);
gen veterinarydiff     =abs(veterinary1939-fveterinaryall);
gen beautydiff         =abs(beauty1939-fbeautyall);
gen entertainmentdiff  =abs(entertainment1939-fentertainmentall);
gen domesticdiff       =abs(domestic1939-fdomesticall);
gen supportdiff        =abs(support1939-fsupportall);

**** Calculate the sum of squared deviations between the characteristics for;
**** each city in our sample and the characteristics for the selected border city;

gen iscore=(miningdiff^2)+(mineralsdiff^2)+(steeldiff^2)+(chemicalsdiff^2)+(textilesdiff^2)+(paperdiff^2)
+(printdiff^2)+(leatherdiff^2)+(wooddiff^2)+(fooddiff^2)+(appareldiff^2)+(shoesdiff^2)+(constructiondiff^2)
+(utilitiesdiff^2);

gen aiscore=iscore+(agriculturediff^2)+(businessdiff^2)+(transportdiff^2)+(restaurantsdiff^2)
+(publicdiff^2)+(educationdiff^2)+(clericaldiff^2)+(consultingdiff^2)+(medicaldiff^2)+(veterinarydiff^2)
+(beautydiff^2)+(entertainmentdiff^2)+(domesticdiff^2)+(supportdiff^2);

**** Sorting FIRST on uniquepop means that cities that have not already been matched come first;
**** Sorting SECOND on bzone ensures that of the unmatched cities the; 
**** non-border cities come first and the border cities come at the end;
**** Sorting THIRD on ...diff means that of these non-border cities the one;
**** that comes first has the most similar value of the characteristic;
**** to the selected border city;
**** Select the non-border city with the most similar value of the characteristic and;
**** create the dummy variable to indicate that it is part of the matched control group;
**** As there are 99 non-border cities and only 20 border cities, this algorithm;
**** ensures that only non-border cities will be matched to the selected border cities;

so uniquepop bzone popdiff;
replace conpop=1 if _n==1;
replace report=1 if _n==1;
replace uniquepop=1000 if conpop==1;

so uniqueemp bzone empdiff;
replace conemp=1 if _n==1;
replace report=1 if _n==1;
replace uniqueemp=1000 if conemp==1;

so uniqueind bzone inddiff;
replace conind=1 if _n==1;
replace report=1 if _n==1;
replace uniqueind=1000 if conind==1;

so uniqueiscore bzone iscore;
replace coniscore=1 if _n==1;
replace report=1 if _n==1;
replace uniqueiscore=1000 if coniscore==1;

so uniqueaiscore bzone aiscore;
replace conaiscore=1 if _n==1;
replace report=1 if _n==1;
replace uniqueaiscore=1000 if conaiscore==1;

so uniquecaiscore bzone czone aiscore;
replace concaiscore=1 if _n==1;
replace report=1 if _n==1;
replace uniquecaiscore=1000 if concaiscore==1;

**** List the non-border cities that are matched with the selected border city;
**** depending on the characteristic considered;

di "Border city";
di `x';
list cities bzone pop conpop conemp conind coniscore conaiscore concaiscore if order==`x'|report==1;

**** Drop the temporary variables for each selected border city and repeat the analysis;
**** for the next border city;

drop fpop fpopall popdiff femp fempall empdiff find findall inddiff  
fmining fminingall miningdiff fminerals fmineralsall mineralsdiff fsteel fsteelall steeldiff 
fchemicals fchemicalsall chemicalsdiff ftextiles ftextilesall textilesdiff fpaper fpaperall paperdiff 
fprint fprintall printdiff fleather fleatherall leatherdiff fwood fwoodall wooddiff 
ffood ffoodall fooddiff fapparel fapparelall appareldiff fshoes fshoesall shoesdiff
fconstruction fconstructionall constructiondiff futilities futilitiesall utilitiesdiff
fbusiness fbusinessall businessdiff ftransport ftransportall transportdiff
frestaurants frestaurantsall restaurantsdiff fpublic fpublicall publicdiff 
feducation feducationall educationdiff fclerical fclericalall clericaldiff
fconsulting fconsultingall consultingdiff fmedical fmedicalall medicaldiff
fveterinary fveterinaryall veterinarydiff fbeauty fbeautyall beautydiff
fentertainment fentertainmentall entertainmentdiff fdomestic fdomesticall domesticdiff
fsupport fsupportall supportdiff fagriculture fagricultureall agriculturediff iscore aiscore;
replace report=.;
};

**** Now the matching process is complete;
**** Keep only the city indicator and the dummies denoting that a non-border;
**** city is a member of the matched control group for each characteristic;

keep city con*;
drop construction* consulting*;
so city;

lab var conpop "Control Group Based on Population";
lab var conemp "Control Group Based on Total Employment";
lab var conind "Control Group Based on Industry Employment";
lab var coniscore "Control Group Based on Disaggregated Industrial Sector Employment";
lab var conaiscore "Control Group Based on Disaggregated All Sector Employment";
lab var concaiscore "Control Group Based on Geography and Disaggregated All Sector Employment";

so city;
save regressions/main_results/temp/matchpairs.dta,replace;

log close;
