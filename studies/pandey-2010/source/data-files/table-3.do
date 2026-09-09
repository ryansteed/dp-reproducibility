use  "table3.dta"


**Table 3**

sum  highparty1 highparty12 if op==1
sum highparty1 highparty12 if op==0
reg highparty1 op , cluster(district)
reg highparty12 op , cluster(district)

**end table 3**

**fraction votes won by high or mid caste parties**

reg frhm op , cluster(district)

  
use "pradhan-election-table3.dta"

**Table 3**
**Pradhan caste**
sum pradhanhighcaste if op==1 & reserv==0
sum pradhanhighcaste if op==0 & reserv==0

reg pradhanhighcaste  op if reserv==0, cluster(district)

**end table 3**
clear
