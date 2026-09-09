




****************************************
****************Daily Wage**************
****************************************
version 12

clear

use wages-aer.dta




*******************************************
******TABLE 4******************************
*******************************************




cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4 longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop, cluster(hhid vid)

lincom marathaland+mlandc1



cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4    longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop if male==1 , cluster(hhid vid)

lincom marathaland+mlandc1



cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4    longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop if male==0 , cluster(hhid vid)

lincom marathaland+mlandc1



cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4 longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop if totlandown==0, cluster(hhid vid)

lincom marathaland+mlandc1




cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4    longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop if castegroup>=2 & castegroup<=6, cluster(hhid vid)

lincom marathaland+mlandc1







cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4    longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop if insurance==1 & castegroup>=2 & castegroup<=6 , cluster(hhid vid)

lincom marathaland+mlandc1



cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4    longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmahar marath   secoc  secph  secnit water  gppop if insurance==0  & castegroup>=2 & castegroup<=6 , cluster(hhid vid)

lincom marathaland+mlandc1



***************************************************
**********TABLE B2*********************************
***************************************************

cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3     longitude latitude elevation  wmahar marath    nolanddom  avgyrain jjarain jjrain     , cluster(hhid vid)

lincom marathaland+mlandc1

cgmreg  dailywage marathaland propc1 mlandc1  hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3     longitude latitude elevation  wmahar marath    nolanddom  avgyrain jjarain jjrain if male==1    , cluster(hhid vid)

lincom marathaland+mlandc1




***************************************************
**********TABLE B4*********************************
***************************************************






cgmreg  dailywage marathaland propc1 mlandc1 gppop hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4 longitude latitude elevation distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc  secph  secnit water  mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver, cluster(hhid vid)

lincom marathaland+mlandc1

cgmreg  dailywage marathaland propc1 mlandc1 gppop hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3 propc4 longitude latitude elevation distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc  secph  secnit water  mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver if male==1, cluster(hhid vid)


lincom marathaland+mlandc1


******************************************************************
******************Yields-Profits**********************************
******************************************************************

clear

use cultivators-aer.dta


*******************************************
******TABLE 4******************************
*******************************************




regress logyields marathaland  propc1 mlandc1 gppop hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless  land0  land1 land2 land3  propc4 longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain wmahar marath  evidar   secoc  secph  secnit   if totlandown>=5 & totlandown<200000000,  cluster (vid)

lincom marathaland+mlandc1

regress logprofit marathaland  propc1 mlandc1 gppop hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless  land0  land1 land2 land3  propc4 longitude latitude  elevation distancetowater  distancetorail distancetoroad water avgyrain wmahar marath  evidar   secoc  secph  secnit   if totlandown>=5 & totlandown<200000000,  cluster (vid)

lincom marathaland+mlandc1

regress plabourkharif marathaland propc1 mlandc1     jowar  rainfed  caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  nolanddom longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmahar marath    black clay salinity percolation drainage if totlandown>=6 & totlandown<200000000, cluster (vid)


lincom marathaland+mlandc1

***************************************************
**********TABLE B2*********************************
***************************************************



regress logyields marathaland  propc1 mlandc1  hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless  land0  land1 land2 land3   longitude latitude  elevation   wmahar marath  evidar     if totlandown>=5 & totlandown<200000000,  cluster (vid)

lincom marathaland+mlandc1

regress logprofit marathaland  propc1 mlandc1  hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless  land0  land1 land2 land3     wmahar marath  evidar     if totlandown>=5 & totlandown<200000000,  cluster (vid)

lincom marathaland+mlandc1




***************************************************
**********TABLE B4*********************************
***************************************************




regress logyields marathaland  propc1 mlandc1 gppop hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless  land0  land1 land2 land3  propc4 longitude latitude  elevation  distancetowater  distancetorail distancetoroad water  wmahar marath  evidar   secoc  secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if totlandown>=5 & totlandown<200000000,  cluster (vid)

lincom marathaland+mlandc1


regress logprofit marathaland  propc1 mlandc1 gppop hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless  land0  land1 land2 land3  propc4   distancetowater  distancetorail distancetoroad water  wmahar marath  evidar   secoc  secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if totlandown>=5 & totlandown<200000000,  cluster (vid)

lincom marathaland+mlandc1





**********Maratha Trader*************************************

clear

use trader-aer.dta


*******************************************
******TABLE 4******************************
*******************************************
 


dprobit marathatrade marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4    longitude latitude elevation distancetowater   distancetorail distancetoroad avgyrain wmahar marath evidar   secoc  secph secnit  if  castegroup>=2 & castegroup<=6 & trade==1, cluster(vid) nolog

probit marathatrade marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4    longitude latitude elevation distancetowater   distancetorail distancetoroad avgyrain wmahar marath evidar   secoc  secph secnit  if  castegroup>=2 & castegroup<=6 & trade==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1

dprobit marathatrade marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4    longitude latitude elevation distancetowater   distancetorail distancetoroad avgyrain wmahar marath evidar   secoc  secph secnit  if  castegroup==1 & trade==1, cluster(vid) nolog

probit marathatrade marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4    longitude latitude elevation distancetowater   distancetorail distancetoroad avgyrain wmahar marath evidar   secoc  secph secnit  if  castegroup==1 & trade==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



***************************************************
**********TABLE B2*********************************
***************************************************


dprobit marathatrade marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar   if  castegroup>=2 & castegroup<=6 & trade==1, cluster(vid) nolog

probit marathatrade marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar   if  castegroup>=2 & castegroup<=6 & trade==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



***************************************************
**********TABLE B4*********************************
***************************************************



dprobit marathatrade marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4   distancetowater   distancetorail distancetoroad  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver   if  castegroup>=2 & castegroup<=6 & trade==1, cluster(vid) nolog

probit marathatrade marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4   distancetowater   distancetorail distancetoroad  wmahar marath evidar   secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver   if  castegroup>=2 & castegroup<=6 & trade==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1




**********Outside Maratha Trader*****************************
clear

use outtrader-aer.dta


*******************************************
******TABLE 4******************************
*******************************************
 


dprobit marathoutvill marathaland propc1  mlandc1 gppop caste01 caste23  femprimless  maleprimless land0  land1 land2 land3  propc4   distancetowater distancetorail distancetoroad avgyrain wmahar marath evidar  secoc  secph   secnit water jjrain jjarain  if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

probit marathoutvill marathaland propc1  mlandc1 gppop caste01 caste23  femprimless  maleprimless land0  land1 land2 land3  propc4   distancetowater distancetorail distancetoroad avgyrain wmahar marath evidar  secoc  secph   secnit water jjrain jjarain  if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit marathoutvill marathaland propc1  mlandc1 gppop caste01 caste23  femprimless  maleprimless land0  land1 land2 land3  propc4   distancetowater distancetorail distancetoroad avgyrain wmahar marath evidar  secoc  secph   secnit water jjrain jjarain  if castegroup==1 , cluster(vid) nolog

probit marathoutvill marathaland propc1  mlandc1 gppop caste01 caste23  femprimless  maleprimless land0  land1 land2 land3  propc4   distancetowater distancetorail distancetoroad avgyrain wmahar marath evidar  secoc  secph   secnit water jjrain jjarain  if castegroup==1 , cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



***************************************************
**********TABLE B2*********************************
***************************************************


dprobit marathoutvill marathaland propc1  mlandc1  caste01 caste23  femprimless  maleprimless land0  land1 land2 land3     avgyrain wmahar  marath evidar  jjrain jjarain  if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

probit marathoutvill marathaland propc1  mlandc1  caste01 caste23  femprimless  maleprimless land0  land1 land2 land3     avgyrain wmahar  marath evidar  jjrain jjarain  if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



***************************************************
**********TABLE B4*********************************
***************************************************


dprobit marathoutvill marathaland propc1  mlandc1 gppop caste01 caste23  femprimless  maleprimless land0  land1 land2 land3  propc4  distancetowater distancetorail distancetoroad avgyrain wmahar marath evidar  secoc  secph   secnit water jjrain jjarain mpopsecoc mpopsecph mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

probit marathoutvill marathaland propc1  mlandc1 gppop caste01 caste23  femprimless  maleprimless land0  land1 land2 land3  propc4  distancetowater distancetorail distancetoroad avgyrain wmahar marath evidar  secoc  secph   secnit water jjrain jjarain mpopsecoc mpopsecph mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1




**********Maratha Lender************************************

clear

use lender-aer.dta




*******************************************
******TABLE 4******************************
*******************************************



dprobit mtradeborrowhh marathaland propc1 mlandc1 gppop  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit  if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit mtradeborrowhh marathaland propc1 mlandc1 gppop  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit  if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit mtradeborrowhh marathaland propc1 mlandc1 gppop  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit  if  castegroup==1, cluster(vid) nolog

probit mtradeborrowhh marathaland propc1 mlandc1 gppop  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit  if  castegroup==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



***************************************************
**********TABLE B2*********************************
***************************************************


dprobit mtradeborrowhh marathaland propc1 mlandc1   caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar  if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit mtradeborrowhh marathaland propc1 mlandc1   caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar  if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



***************************************************
**********TABLE B4*********************************
***************************************************





dprobit mtradeborrowhh marathaland propc1 mlandc1 gppop  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  distancetowater  distancetoroad distancetorail  wmahar marath evidar  secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit mtradeborrowhh marathaland propc1 mlandc1 gppop  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  distancetowater  distancetoroad distancetorail  wmahar marath evidar  secoc  secph  secnit   mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if  castegroup>=2 & castegroup<=6, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1




************Terms of Payment*********************

clear

use terms-aer.dta




*******************************************
******TABLE 4******************************
*******************************************

cgmreg payterm marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4    longitude latitude elevation distancetowater distancetoroad  distancetorail avgyrain wmahar marath   secoc  secph  secnit nolanddom  if  castegroup>=2 &  castegroup<=6 & input==1, cluster(hhid vid)


lincom marathaland+mlandc1

cgmreg payterm marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4    longitude latitude elevation distancetowater distancetoroad  distancetorail avgyrain wmahar marath   secoc  secph  secnit nolanddom     if  castegroup==1 & input==1, cluster(hhid vid)

lincom marathaland+mlandc1


***************************************************
**********TABLE B2*********************************
***************************************************


cgmreg payterm marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3      longitude latitude elevation  avgyrain wmahar marath    nolanddom     if  castegroup>=2 &  castegroup<=6 & input==1, cluster(hhid vid)


lincom marathaland+mlandc1

***************************************************
**********TABLE B4*********************************
***************************************************




cgmreg payterm marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3      longitude latitude elevation  avgyrain wmahar marath    nolanddom mpopsecoc mpopsecnit mpopdrail mpopdrail mpopdroad mpoppop mpoppopsc mpopriver water   if  castegroup>=2 &  castegroup<=6 & input==1, cluster(hhid vid)



lincom marathaland+mlandc1




***************************************************
************Interest Rate**************************
***************************************************

clear

use interest-aer.dta




*******************************************
******TABLE 4******************************
*******************************************



cgmreg  interest marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4   longitude latitude elevation distancetowater distancetoroad  distancetorail avgyrain wmahar marath evidar secoc  secph  secnit  if  castegroup>=3 & castegroup<=6, cluster(hhid vid)

lincom marathaland+mlandc1



cgmreg  interest marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4   longitude latitude elevation distancetowater distancetoroad  distancetorail avgyrain wmahar marath evidar secoc  secph  secnit  if  castegroup==1, cluster(hhid vid)

lincom marathaland+mlandc1



***************************************************
**********TABLE B2*********************************
***************************************************



cgmreg  interest marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3    wmahar marath evidar  if  castegroup>=3 & castegroup<=6, cluster(hhid vid)

lincom marathaland+mlandc1




***************************************************
**********TABLE B4*********************************
***************************************************



cgmreg  interest marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if  castegroup>=3 & castegroup<=6, cluster(hhid vid)

lincom marathaland+mlandc1

***************************************************
**********TABLE B6*********************************
***************************************************


************Daily Wage******************************

clear

use wages-aer.dta







regress  dailywage pmarathaland propc1 intmarathaland hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada distancetoroad  primoc secoc primph secph primnit secnit water, cluster(hhid)


lincom  pmarathaland+intmarathaland




regress  dailywage pmarathaland propc1 intmarathaland hhmembers caste01 caste23  male age illiterate land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada distancetoroad  primoc secoc primph secph primnit secnit water  if castegroup>=2 & castegroup<=6 , cluster(hhid)

lincom pmarathaland+intmarathaland


************Yields*****************



clear 
use cultivators-aer.dta





regress logyields   pmarathaland propc1 intmarathaland hhmembers jowar  rainfed  caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown>=5 & totlandown<200000000, cluster (vid)


lincom  pmarathaland+intmarathaland




**********Maratha Trader*************************************

clear

use trader-aer.dta


dprobit    marathatrade pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit if castegroup>=2 & castegroup<=6 & trade==1, cluster(vid)  nolog 

probit    marathatrade pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit if castegroup>=2 & castegroup<=6 & trade==1, cluster(vid)  nolog 

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland



**********Outside Maratha Trader*****************************

clear

use outtrader-aer.dta





dprobit marathoutvill  pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

probit marathoutvill  pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain if castegroup>=2 & castegroup<=6 , cluster(vid) nolog


margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland



**********Maratha Lender************************************

clear

use lender-aer.dta



dprobit mtradeborrowhh  pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain if castegroup>=2 & castegroup<=6 , cluster(vid) nolog

probit mtradeborrowhh  pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail distancetoroad avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain if castegroup>=2 & castegroup<=6 , cluster(vid) nolog


margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland




************Interest Rate**************************

clear

use interest-aer.dta




regress  interest pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit if castegroup>=4 & castegroup<=5, cluster(hhid) 

lincom pmarathaland+intmarathaland





