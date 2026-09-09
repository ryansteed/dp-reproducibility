use "table1-soil-climate.dta"
sum  lon lat alt rain soilblack soilalkaline soilalluvialriver soilred aquifermorethan150 aquifer100and150 phstrongalkali phslightalkali phneutral phslightacid topsoil25and50cm topsoil50and100cm topsoilmorethan300cm if op==1
sum  lon lat alt rain soilblack soilalkaline soilalluvialriver soilred aquifermorethan150 aquifer100and150 phstrongalkali phslightalkali phneutral phslightacid topsoil25and50cm topsoil50and100cm topsoilmorethan300cm if op==0

reg  lon op, robust
reg  lat op, robust
reg  alt op, robust
reg  rain op, robust
reg  soilblack op, robust
reg  soilalkaline op, robust
reg  soilalluvialriver op, robust
reg  soilred op, robust
reg  aquifermorethan150 op, robust
reg  aquifer100and150 op, robust
reg  phstrongalkali op, robust
reg  phslightalkali op, robust
reg  phneutral op, robust
reg  phslightacid op, robust
reg  topsoil25and50cm op, robust
reg  topsoil50and100cm op, robust
reg  topsoilmorethan300cm op, robust

clear

use "table1-population-and-census.dta"

sum poverty literacyrate  populationsize populationdensity fractionsc  permanenthouse pervilelec pervilroad pervilhealth pervilschool ger if op==1
sum poverty literacyrate  populationsize populationdensity fractionsc  permanenthouse pervilelec pervilroad pervilhealth pervilschool ger if op==0

reg poverty op, robust
reg literacyrate op, robust
reg populationsize op, robust
reg populationdensity op, robust
reg fractionsc op, robust

reg pervilelec op, robust
reg pervilroad op, robust
reg pervilhealth op, robust
reg pervilschool op, robust
reg permanenthouse op, robust
reg ger op, robust
clear

      


