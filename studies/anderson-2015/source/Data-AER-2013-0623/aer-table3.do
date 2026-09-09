

************************************
***************Insured**************
************************************

version 12

clear

use trust-aer.dta



*********************************
*******TABLE 3*******************
*********************************

dprobit  trust1 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog

probit  trust1 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1





dprobit  trust2 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog

probit  trust2 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit  trust3 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog

probit  trust3 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1




dprobit  trust4 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog

probit  trust4 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1


dprobit  trust5 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog

probit  trust5 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1




dprobit  trust6 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog

probit  trust6 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit   if totlandown==0, cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1






sureg (trust1 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust2 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust3 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust4 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust5 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust6 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  )  if totlandown==0


lincom ([trust1]propc1+[trust2]propc1+[trust3]propc1+[trust4]propc1+[trust5]propc1+[trust6]propc1)/6
lincom ([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6
lincom ([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6


lincom (([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6) + (([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6)


sureg (trust1 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust2 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust3 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust4 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust5 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  ) (trust6 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3  longitude latitude elevation  avgyrain wmahar marath evidar  )  if castegroup>=3 & castegroup<=6 


lincom ([trust1]propc1+[trust2]propc1+[trust3]propc1+[trust4]propc1+[trust5]propc1+[trust6]propc1)/6
lincom ([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6
lincom ([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6


lincom (([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6) + (([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6)


***********************************************************
************TABLE B2***************************************
***********************************************************




sureg (trust1 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar) (trust2 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar) (trust3 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar) (trust4 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar) (trust5 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar) (trust6 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3   wmahar marath evidar) if totlandown==0

lincom ([trust1]propc1+[trust2]propc1+[trust3]propc1+[trust4]propc1+[trust5]propc1+[trust6]propc1)/6
lincom ([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6
lincom ([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6


lincom (([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6) + (([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6)



***********************************************************
************TABLE B4***************************************
***********************************************************




sureg (trust1 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4   distancetowater distancetoroad distancetorail water    wmahar marath evidar   secoc  secph secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (trust2 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4   distancetowater distancetoroad distancetorail water    wmahar marath evidar   secoc  secph secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (trust3 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4   distancetowater distancetoroad distancetorail water    wmahar marath evidar   secoc  secph secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (trust4 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4   distancetowater distancetoroad distancetorail water    wmahar marath evidar   secoc  secph secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (trust5 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4   distancetowater distancetoroad distancetorail water     wmahar marath evidar   secoc  secph secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) (trust6 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4   distancetowater distancetoroad distancetorail water     wmahar marath evidar   secoc  secph secnit mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver) if totlandown==0




lincom ([trust1]propc1+[trust2]propc1+[trust3]propc1+[trust4]propc1+[trust5]propc1+[trust6]propc1)/6
lincom ([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6
lincom ([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6


lincom (([trust1]marathaland+[trust2]marathaland+[trust3]marathaland+[trust4]marathaland+[trust5]marathaland+[trust6]marathaland)/6) + (([trust1]mlandc1+[trust2]mlandc1+[trust3]mlandc1+[trust4]mlandc1+[trust5]mlandc1+[trust6]mlandc1)/6)






************************************
***************Insurer**************
************************************





****************************************************
**********************TABLE 3***********************
****************************************************




dprobit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if castegroup>=3 & castegroup<=6 & totlandown>=0 & totlandown<=2.5 , cluster(vid) nolog

probit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if castegroup>=3 & castegroup<=6 & totlandown>=0 & totlandown<=2.5 , cluster(vid) nolog


margins, dydx(*) atmeans post

lincom marathaland+mlandc1






dprobit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if castegroup==1 & totlandown>=0 & totlandown<=2.5 , cluster(vid) nolog

probit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if castegroup==1 & totlandown>=0 & totlandown<=2.5 , cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1





dprobit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if  totlandown>5 & totlandown<=1000000 , cluster(vid) nolog

probit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if  totlandown>5 & totlandown<=1000000 , cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if  totlandown>5 & totlandown<=1000000 & castegroup==1 , cluster(vid) nolog

probit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if  totlandown>5 & totlandown<=1000000 & castegroup==1, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



dprobit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if  totlandown>5 & totlandown<=1000000 & castegroup>=2 & castegroup<=5 , cluster(vid) nolog

probit  trust15 marathaland propc1 mlandc1 caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4 gppop    longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar nolanddom secnit secph secoc    if  totlandown>5 & totlandown<=1000000 & castegroup>=2 & castegroup<=5, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1



*****************************************************************
*************TABLE B2********************************************
*****************************************************************


dprobit trust15 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3 wmahar marath evidar    if totlandown>=5 & totlandown<10000, cluster(vid) nolog

probit trust15 marathaland propc1 mlandc1  caste01 caste23  femprimless maleprimless land0 land1 land2 land3 wmahar marath evidar    if totlandown>=5 & totlandown<10000, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1

*****************************************************************
*************TABLE B4********************************************
*****************************************************************




dprobit  trust15 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  distancetowater distancetoroad distancetorail water  wmahar marath evidar secoc  secph  secnit  mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if totlandown>=5 & totlandown<10000, cluster(vid) nolog


probit  trust15 marathaland propc1 mlandc1 gppop caste01 caste23  femprimless maleprimless land0 land1 land2 land3 propc4  distancetowater distancetoroad distancetorail water  wmahar marath evidar secoc  secph  secnit  mpopsecoc  mpopsecph  mpopsecnit mpopdwater mpopdrail mpopdroad mpoppop mpoppopsc mpopriver  if totlandown>=5 & totlandown<10000, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom marathaland+mlandc1


************************************************
********TABLE B6********************************
************************************************

************************************
***************Insured**************
************************************



dprobit  trust1 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

probit  trust1 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland


dprobit  trust2 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

probit  trust2 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

dprobit  trust3 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

probit  trust3 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

dprobit  trust4 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

probit  trust4 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

dprobit  trust5 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

probit  trust5 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

dprobit  trust6 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

probit  trust6 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown==0, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland






************************************
***************Insurer**************
************************************


dprobit  trust15 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown>=5 & totlandown<=10000, cluster(vid) nolog

probit  trust15 pmarathaland propc1 intmarathaland caste01 caste23  femprimless maleprimless land0 land1 land2 land3  propc4  longitude latitude elevation distancetowater  distancetorail avgyrain wmaharshtra marathwada  primoc secoc primph secph primnit secnit  if totlandown>=5 & totlandown<=10000, cluster(vid) nolog

margins, dydx(*) atmeans post

lincom pmarathaland+intmarathaland

test  pmarathaland+intmarathaland=0
