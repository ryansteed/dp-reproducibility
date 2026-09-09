
version 12

clear

use programs-aer.dta 


************Voted-Personal********************

****************************************
************TABLE 5*********************
****************************************



dprobit  votepersonal  marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath evidar   secoc   secph  secnit if castegroup>=4 & castegroup<=5, cluster(vid) nolog

probit  votepersonal  marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath evidar   secoc   secph  secnit if castegroup>=4 & castegroup<=5, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit  votepersonal  marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath evidar   secoc   secph  secnit if castegroup==1, cluster(vid) nolog

probit  votepersonal  marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath evidar   secoc   secph  secnit if castegroup==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1

****************************************
************TABLE B2********************
****************************************



dprobit  votepersonal  marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0  land1 land2 land3   wmahar marath evidar   if castegroup>=4 & castegroup<=5, cluster(vid) nolog

probit  votepersonal  marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0  land1 land2 land3   wmahar marath evidar   if castegroup>=4 & castegroup<=5, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1



********************************************************
************TABLE B4************************************
********************************************************




dprobit  votepersonal  marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  distancetowater   distancetorail distancetoroad water wmahar marath evidar  secoc   secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if castegroup>=4 & castegroup<=5, cluster(vid) nolog

probit  votepersonal  marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  distancetowater   distancetorail distancetoroad water wmahar marath evidar  secoc   secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if castegroup>=4 & castegroup<=5, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1





****************************************************************
**************Social Capital************************************
****************************************************************

**************************************************************
**************TABLE 5*****************************************
**************************************************************

clear


use trust-aer.dta





regress  trust23 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid)

lincom marathaland+mlandc1




dprobit  nocheathigher marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  nocheathigher marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1





dprobit  othrepair marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  othrepair marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1




dprobit  doncash marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  doncash marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit  donlabour marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  donlabour marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit  agree1 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog


probit  agree1 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



sureg (nocheathigher marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   longitude latitude elevation water distancetowater  distancetorail distancetoroad avgyrain wmahar marath evidar  secoc secph  secnit) (othrepair marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   longitude latitude elevation water distancetowater  distancetorail distancetoroad avgyrain wmahar marath evidar  secoc secph  secnit ) (doncash marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   longitude latitude elevation water distancetowater  distancetorail distancetoroad avgyrain wmahar marath evidar  secoc secph  secnit) (donlabour marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   longitude latitude elevation water distancetowater  distancetorail distancetoroad avgyrain wmahar marath evidar  secoc secph  secnit ) (trust23 marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   longitude latitude elevation water distancetowater  distancetorail distancetoroad avgyrain wmahar marath evidar  secoc secph  secnit ) (agree1 marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   longitude latitude elevation water distancetowater  distancetorail distancetoroad avgyrain wmahar marath evidar  secoc secph  secnit) if castegroup>=2 & castegroup<=6

lincom ([nocheathigher]propc1+[othrepair]propc1+[doncash]propc1+[donlabour]propc1+[trust23]propc1+[agree1]propc1)/6

lincom ([nocheathigher]marathaland+[othrepair]marathaland+[doncash]marathaland+[donlabour]marathaland+[trust23]marathaland+[agree1]marathaland)/6

lincom ([nocheathigher]mlandc1+[othrepair]mlandc1+[doncash]mlandc1+[donlabour]mlandc1+[trust23]mlandc1+[agree1]mlandc1)/6

lincom (([nocheathigher]marathaland+[othrepair]marathaland+[doncash]marathaland+[donlabour]marathaland+[trust23]marathaland+[agree1]marathaland)/6)+(([nocheathigher]mlandc1+[othrepair]mlandc1+[doncash]mlandc1+[donlabour]mlandc1+[trust23]mlandc1+[agree1]mlandc1)/6)




**********************************************************
************TABLE B2**************************************
**********************************************************




sureg (nocheathigher  marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar  ) (othrepair  marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar ) (doncash  marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar ) (donlabour  marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar ) (trust23  marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar ) (agree1  marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  wmahar marath evidar  ) if castegroup>=2 & castegroup<=6

lincom ([nocheathigher]propc1+[othrepair]propc1+[doncash]propc1+[donlabour]propc1+[trust23]propc1+[agree1]propc1)/6

lincom ([nocheathigher]marathaland+[othrepair]marathaland+[doncash]marathaland+[donlabour]marathaland+[trust23]marathaland+[agree1]marathaland)/6

lincom ([nocheathigher]mlandc1+[othrepair]mlandc1+[doncash]mlandc1+[donlabour]mlandc1+[trust23]mlandc1+[agree1]mlandc1)/6

lincom (([nocheathigher]marathaland+[othrepair]marathaland+[doncash]marathaland+[donlabour]marathaland+[trust23]marathaland+[agree1]marathaland)/6)+(([nocheathigher]mlandc1+[othrepair]mlandc1+[doncash]mlandc1+[donlabour]mlandc1+[trust23]mlandc1+[agree1]mlandc1)/6)


**********************************************************
************TABLE B4**************************************
**********************************************************



sureg (nocheathigher marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4  water distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (othrepair marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   water distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (doncash marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   water distancetowater  distancetorail distancetoroad wmahar marath evidar  secoc secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (donlabour marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4  water distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver)(agree1 marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   water distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (trust23 marathaland propc1   mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3  gppop propc4   water distancetowater  distancetorail distancetoroad  wmahar marath evidar  secoc secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) if castegroup>=2 & castegroup<=6


lincom ([nocheathigher]propc1+[othrepair]propc1+[doncash]propc1+[donlabour]propc1+[trust23]propc1+[agree1]propc1)/6

lincom ([nocheathigher]marathaland+[othrepair]marathaland+[doncash]marathaland+[donlabour]marathaland+[trust23]marathaland+[agree1]marathaland)/6

lincom ([nocheathigher]mlandc1+[othrepair]mlandc1+[doncash]mlandc1+[donlabour]mlandc1+[trust23]mlandc1+[agree1]mlandc1)/6

lincom (([nocheathigher]marathaland+[othrepair]marathaland+[doncash]marathaland+[donlabour]marathaland+[trust23]marathaland+[agree1]marathaland)/6)+(([nocheathigher]mlandc1+[othrepair]mlandc1+[doncash]mlandc1+[donlabour]mlandc1+[trust23]mlandc1+[agree1]mlandc1)/6)



**************Share Water**********************


**********************************************************
************TABLE 5***************************************
**********************************************************


clear

use water-aer.dta 






dprobit  sharemaratha marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  sharemaratha marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4  longitude latitude elevation distancetowater  distancetoroad distancetorail avgyrain wmahar marath evidar  secoc secph  secnit    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



**********************************************************
************TABLE B2**************************************
**********************************************************



dprobit  sharemaratha marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar     if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  sharemaratha marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar     if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1


**********************************************************
************TABLE B4**************************************
**********************************************************



dprobit  sharemaratha marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4   distancetowater  distancetoroad distancetorail  wmahar marath evidar  secoc  secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog

probit  sharemaratha marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3   propc4   distancetowater  distancetoroad distancetorail  wmahar marath evidar  secoc  secph  secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver    if  castegroup>=2 & castegroup<=6, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1



******************************************************
***************Target Village*************************
******************************************************

clear


use target-aer.dta 



**********************************************************
************TABLE 5***************************************
**********************************************************




mlogit targeted  marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath  evidar  secoc   secph  secnit  gppop if castegroup>=2 & castegroup<=6, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1

mlogit targeted  marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath  evidar  secoc   secph  secnit  gppop if castegroup==1, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1

**********************************************************
************TABLE B2**************************************
**********************************************************






mlogit targeted  marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   wmahar marath  evidar   if castegroup>=2 & castegroup<=6, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1

**********************************************************
************TABLE B4**************************************
**********************************************************





mlogit targeted   marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  distancetowater   distancetorail distancetoroad water wmahar marath  evidar  secoc   secph  secnit  gppop mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if castegroup>=2 & castegroup<=6, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1






***************Shared Funds********************

**********************************************************
************TABLE 5***************************************
**********************************************************



mlogit funds  marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath  evidar  secoc   secph  secnit  gppop if castegroup>=2 & castegroup<=6, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1

mlogit funds  marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  longitude latitude elevation distancetowater   distancetorail distancetoroad water avgyrain wmahar marath  evidar  secoc   secph  secnit  gppop if castegroup==1, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1

**********************************************************
************TABLE B2**************************************
**********************************************************






mlogit funds  marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   wmahar marath  evidar   if castegroup>=2 & castegroup<=6, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1





**********************************************************
************TABLE B4**************************************
**********************************************************



mlogit funds   marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0  land1 land2 land3   propc4  distancetowater   distancetorail distancetoroad water wmahar marath  evidar  secoc   secph  secnit  gppop mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if castegroup>=2 & castegroup<=6, cluster(vid) nolog

lincom [1]marathaland + [1]mlandc1




************************festivals**********************************

**********************************************************
************TABLE 5***************************************
**********************************************************

clear


use festivals-aer.dta



dprobit hhfacility8 marathaland propc1 mlandc1   caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   nolanddom longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid) 

probit hhfacility8 marathaland propc1 mlandc1   caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   nolanddom longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmahar marath evidar   secoc  secph  secnit jjrain jjarain, cluster(vid) 


margins, dydx(*) atmeans post

lincom marathaland + mlandc1 

clear
 








*****************************************************************
***************TABLE B6******************************************
*****************************************************************


******************************************
**************Social Capital**************
******************************************
clear

use trust-aer.dta



sureg (trust23 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit)  (nocheathigher pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit) (othrepair pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit) (doncash pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit) (donlabour pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit) (agree1 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit) if castegroup>=2 & castegroup<=6

lincom ([nocheathigher]propc1+[othrepair]propc1+[doncash]propc1+[donlabour]propc1+[trust23]propc1+[agree1]propc1)/6

lincom ([nocheathigher]pmarathaland+[othrepair]pmarathaland+[doncash]pmarathaland+[donlabour]pmarathaland+[trust23]pmarathaland+[agree1]pmarathaland)/6

lincom ([nocheathigher]intmarathaland+[othrepair]intmarathaland+[doncash]intmarathaland+[donlabour]intmarathaland+[trust23]intmarathaland+[agree1]intmarathaland)/6

lincom (([nocheathigher]pmarathaland+[othrepair]pmarathaland+[doncash]pmarathaland+[donlabour]pmarathaland+[trust23]pmarathaland+[agree1]pmarathaland)/6)+(([nocheathigher]intmarathaland+[othrepair]intmarathaland+[doncash]intmarathaland+[donlabour]intmarathaland+[trust23]intmarathaland+[agree1]intmarathaland)/6)


************Share Water*******************

clear

use water-aer.dta 


dprobit sharemaratha  pmarathaland  propc1 intmarathaland caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain if castegroup>=2 & castegroup<=6, cluster(vid)

probit sharemaratha  pmarathaland  propc1 intmarathaland caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain if castegroup>=2 & castegroup<=6, cluster(vid)


margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

******************************************************
***************Target Village*************************
******************************************************

clear 

use target-aer.dta 


 


mlogit targeted pmarathaland propc1 intmarathaland  caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4 longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain if castegroup>=2 & castegroup<=6, cluster(vid) nolog baseoutcome(2)


lincom  [1]pmarathaland + [1]intmarathaland 




***************Shared Funds********************


mlogit funds pmarathaland propc1 intmarathaland   caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain if castegroup>=2 & castegroup<=6, cluster(vid) nolog baseoutcome(0)

lincom [1]pmarathaland + [1]intmarathaland 

clear



*****************************
***Voted-Personal************
*****************************

use programs-aer.dta 




dprobit  votepersonal pmarathaland propc1 intmarathaland  caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain if castegroup>=4 & castegroup<=5, cluster(vid) nolog

probit  votepersonal pmarathaland propc1 intmarathaland  caste01 caste23  femprimless maleprimless land0  land1 land2 land3  propc4   longitude latitude elevation distancetowater  distancetorail distancetoroad water avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit jjrain jjarain if castegroup>=4 & castegroup<=5, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland




