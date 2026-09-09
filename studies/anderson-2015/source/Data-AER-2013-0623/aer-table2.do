

***********************************
*******Maratha Pradhan*************
***********************************

clear

version 12

use gp-aer.dta 




*****************************************
*****TABLE 2*****************************
*****************************************




dprobit pradhancaste1 marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust nolog

probit pradhancaste1 marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1


*****************************************
*****TABLE B1*****************************
*****************************************


dprobit pradhancaste1 marathaland propc1 mlandc1    wmahar marath evidar   , robust nolog

probit pradhancaste1 marathaland propc1 mlandc1    wmahar marath evidar   , robust nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1


*****************************************
*****TABLE B3*****************************
*****************************************


dprobit pradhancaste1 marathaland propc1 mlandc1 gppop  propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar secoc secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust nolog


probit pradhancaste1 marathaland propc1 mlandc1 gppop  propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar secoc secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1





******************************************
***Programs (village data)****************
******************************************

clear

use programs-vill-aer.dta





*****************************************
*****TABLE 2*****************************
*****************************************
*** EDITED by Donna
eststo clear

eststo all: regress tprog marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 

lincom marathaland+mlandc1

eststo poor: regress tptarget marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 

lincom marathaland+mlandc1

eststo: regress egs marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 

lincom marathaland+mlandc1

eststo income: regress incomeprog marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 

lincom marathaland+mlandc1

eststo nonincome: regress childelderprog marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 

lincom marathaland+mlandc1

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*****************************************
*****TABLE B1*****************************
*****************************************


regress tprog marathaland propc1 mlandc1  wmahar marath evidar , robust

lincom marathaland+mlandc1 

regress tptarget marathaland propc1 mlandc1  wmahar marath evidar , robust

lincom marathaland+mlandc1

regress egs marathaland propc1 mlandc1  wmahar marath evidar , robust

lincom marathaland+mlandc1

regress incomeprog marathaland propc1 mlandc1  wmahar marath evidar , robust

lincom marathaland+mlandc1

regress childelderprog marathaland propc1 mlandc1  wmahar marath evidar , robust

lincom marathaland+mlandc1



*****************************************
*****TABLE B3****************************
*****************************************


regress tprog marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1


regress tptarget marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1


regress egs marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1


regress incomeprog marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1


regress childelderprog marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1



****************************************************************
*********************GP Revenues/Expenses***********************
****************************************************************

*************Revenue(1)**************************************

clear

use gp-aer.dta 


	

*****************************************
*****TABLE 2*****************************
*****************************************


regress pcrevenu marathaland propc1 mlandc1 gppop reserved  nolanddom propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust 

lincom marathaland+mlandc1



*****************************************
*****TABLE B1****************************
*****************************************




regress pcrevenu marathaland propc1 mlandc1 nolanddom wmahar marath evidar , robust 

lincom marathaland+mlandc1



*****************************************
*****TABLE B3****************************
*****************************************





regress pcrevenu marathaland propc1 mlandc1 gppop nolanddom  propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1





******************Revenue(2)************************************

clear

use census-aer.dta 

 



*****************************************
*****TABLE 2*****************************
*****************************************



regress pcinc marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust 

lincom marathaland+mlandc1



*****************************************
*****TABLE B1****************************
*****************************************



regress pcinc marathaland propc1 mlandc1  wmahar marath evidar , robust 

lincom marathaland+mlandc1




*****************************************
*****TABLE B3****************************
*****************************************



regress pcinc marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1




**********************Expenditure***************************





*****************************************
*****TABLE 2*****************************
*****************************************



regress pcexp marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust 

lincom marathaland+mlandc1



*****************************************
*****TABLE B1****************************
*****************************************

regress pcexp marathaland propc1 mlandc1  wmahar marath evidar , robust 

lincom marathaland+mlandc1



*****************************************
*****TABLE B3****************************
*****************************************



regress pcexp marathaland propc1 mlandc1 gppop   propc4   distancetowater distancetoroad distancetorail water  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, robust 

lincom marathaland+mlandc1



***************************************************
********************GP Meetings********************
***************************************************

clear

use gp-aer.dta





*****************************************
*****TABLE 2*****************************
*****************************************


sureg (ceo marathaland propc1 mlandc1 gppop reserved pradhancaste1 propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath   secoc  secph  secnit ) (mp marathaland propc1 mlandc1 gppop pradhancaste1 reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath   secoc  secph  secnit ) (dc marathaland propc1 mlandc1 gppop reserved pradhancaste1 propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath   secoc  secph  secnit) 




lincom ([ceo]propc1+[mp]propc1+[dc]propc1)/3
lincom ([ceo]marathaland+[mp]marathaland+[dc]marathaland)/3
lincom ([ceo]mlandc1+[mp]mlandc1+[dc]mlandc1)/3


lincom (([ceo]marathaland+[mp]marathaland+[dc]marathaland)/3) + (([ceo]mlandc1+[mp]mlandc1+[dc]mlandc1)/3)



*****************************************
*****TABLE B1****************************
*****************************************

sureg (ceo marathaland propc1 mlandc1  reserved pradhancaste1  longitude latitude elevation  avgyrain wmahar marath   ) (mp marathaland propc1 mlandc1  reserved pradhancaste1   longitude latitude elevation  avgyrain wmahar marath   ) (dc marathaland propc1 mlandc1  reserved  pradhancaste1  longitude latitude elevation  avgyrain wmahar marath   )



lincom ([ceo]propc1+[mp]propc1+[dc]propc1)/3
lincom ([ceo]marathaland+[mp]marathaland+[dc]marathaland)/3
lincom ([ceo]mlandc1+[mp]mlandc1+[dc]mlandc1)/3

lincom (([ceo]marathaland+[mp]marathaland+[dc]marathaland)/3) + (([ceo]mlandc1+[mp]mlandc1+[dc]mlandc1)/3)




*****************************************
*****TABLE 2*****************************
*****************************************



regress ceo marathaland propc1 mlandc1 gppop reserved pradhancaste1 propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath   secoc  secph  secnit, robust

lincom marathaland+mlandc1

regress mp marathaland propc1 mlandc1 gppop reserved pradhancaste1 propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath   secoc  secph  secnit, robust

lincom marathaland+mlandc1

regress dc marathaland propc1 mlandc1 gppop reserved pradhancaste1 propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath   secoc  secph  secnit, robust

lincom marathaland+mlandc1

*****************************************
*****TABLE B1****************************
*****************************************



regress ceo marathaland propc1 mlandc1  reserved pradhancaste1  longitude latitude elevation  avgyrain wmahar marath , robust

lincom marathaland+mlandc1

regress dc marathaland propc1 mlandc1  reserved pradhancaste1  longitude latitude elevation  avgyrain wmahar marath , robust

lincom marathaland+mlandc1

regress mp marathaland propc1 mlandc1  reserved pradhancaste1  longitude latitude elevation  avgyrain wmahar marath , robust

lincom marathaland+mlandc1



**********************************************************************************
*********************Programs (household data)************************************
**********************************************************************************


clear

use programs-aer.dta 



*****************************************
*****TABLE 2*****************************
*****************************************

dprobit egs marathaland propc1 mlandc1 gppop reserved  caste01 caste23  femprimless maleprimless land0   land1 land2 land3  propc4   longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain  wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid)

probit egs marathaland propc1 mlandc1 gppop reserved  caste01 caste23  femprimless maleprimless land0   land1 land2 land3  propc4   longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain  wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid)

margins, dydx(*) atmeans post

lincom marathaland+mlandc1

regress tprog marathaland propc1 mlandc1 gppop reserved  caste01 caste23  femprimless maleprimless land0   land1 land2 land3  propc4   longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain  wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid)

lincom marathaland+mlandc1

regress tptarget marathaland propc1 mlandc1 gppop reserved  caste01 caste23  femprimless maleprimless land0   land1 land2 land3  propc4   longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain  wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid)


lincom marathaland+mlandc1

regress incomeprog marathaland propc1 mlandc1 gppop reserved  caste01 caste23  femprimless maleprimless land0   land1 land2 land3  propc4   longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain  wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid)

lincom marathaland+mlandc1

regress childelderprog marathaland propc1 mlandc1 gppop reserved  caste01 caste23  femprimless maleprimless land0   land1 land2 land3  propc4   longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain  wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid)

lincom marathaland+mlandc1







*************************************
*****TABLE B5************************
*************************************


***********************************
***Programs (household data)*******
***********************************

clear

use programs-aer.dta 



regress  tprog pmarathaland propc1 intmarathaland gppop reserved pradhancaste1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, cluster(vid)

lincom pmarathaland+intmarathaland




regress  tptarget pmarathaland propc1 intmarathaland gppop reserved pradhancaste1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, cluster(vid)

lincom pmarathaland+intmarathaland

regress  incomeprog pmarathaland propc1 intmarathaland gppop reserved pradhancaste1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, cluster(vid)

lincom pmarathaland+intmarathaland




dprobit egs pmarathaland propc1 intmarathaland gppop reserved pradhancaste1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, cluster(vid)

probit egs pmarathaland propc1 intmarathaland gppop reserved pradhancaste1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, cluster(vid)

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

*******************************************************
********************Maratha Pradhan********************
*******************************************************
clear
use gp-aer.dta 





dprobit pradhancaste1  pmarathaland propc1 intmarathaland gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust nolog


probit pradhancaste1  pmarathaland propc1 intmarathaland gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust nolog


margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland




*************************Meetings********************************

regress  ceo pmarathaland propc1 intmarathaland gppop reserved pradhancaste1  propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmaharshtra marathwada   primoc secoc primph secph primnit secnit jjrain jjarain , robust

lincom pmarathaland+intmarathaland



regress mp pmarathaland  propc1 intmarathaland gppop reserved pradhancaste1  propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmaharshtra marathwada   primoc secoc primph secph primnit secnit jjrain jjarain , robust

lincom pmarathaland+intmarathaland




regress dc pmarathaland propc1 intmarathaland gppop reserved pradhancaste1  propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmaharshtra marathwada   primoc secoc primph secph primnit secnit jjrain jjarain , robust

lincom pmarathaland+intmarathaland



***************************************************************
*********************GP Revenues/Expenses**********************
***************************************************************

*************Revenue(1)**************************************


regress pcrevenue pmarathaland propc1 intmarathaland reserved pradhancaste1  propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmaharshtra marathwada   primoc secoc primph secph primnit secnit jjrain jjarain , robust

lincom pmarathaland+intmarathaland




******************Revenue(2)************************************
clear

use census-aer.dta 





regress pcinc pmarathaland propc1 intmarathaland  reserved  nolanddom propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust 

lincom pmarathaland+intmarathaland



**********************Expenditure***************************


regress pcexp pmarathaland propc1 intmarathaland  reserved  nolanddom propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit  , robust 

lincom pmarathaland+intmarathaland






*******************************************
***************Programs (Village Data)*****
*******************************************

clear
 


use programs-vill-aer.dta








regress  tprog pmarathaland propc1 intmarathaland gppop reserved pradhancaste1  propc4  nolanddom longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain  wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, robust 

lincom pmarathaland+intmarathaland

regress  tptarget pmarathaland propc1 intmarathaland gppop reserved pradhancaste1  propc4  nolanddom longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain  wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, robust 

lincom pmarathaland+intmarathaland



regress  incomeprog pmarathaland propc1 intmarathaland gppop reserved pradhancaste1  propc4  nolanddom longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain  wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, robust 

lincom pmarathaland+intmarathaland



regress  egs pmarathaland propc1 intmarathaland gppop reserved pradhancaste1  propc4  nolanddom longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain  wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain, robust 

lincom pmarathaland+intmarathaland




