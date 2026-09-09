




global year = "2011"

 /*AL*/
global state =  "63"
global mcd_preg_women =  "133"
global mcd_parent =  "24"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*AK*/
global state =  "94"
global mcd_preg_women =  "175"
global mcd_parent =  "81"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*AZ*/
global state =  "86"
global mcd_preg_women =  "150"
global mcd_parent =  "106"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*AR*/
global state =  "71"
global mcd_preg_women =  "200"
global mcd_parent =  "17"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*CA*/
global state =  "93"
global mcd_preg_women =  "300"
global mcd_parent =  "106"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*CO*/
global state =  "84"
global mcd_preg_women =  "250"
global mcd_parent =  "106"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*CT*/
global state =  "16"
global mcd_preg_women =  "250"
global mcd_parent =  "191"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*DE*/
global state =  "51"
global mcd_preg_women =  "200"
global mcd_parent =  "120"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*DC*/
global state =  "53"
global mcd_preg_women =  "300"
global mcd_parent =  "207"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*FL*/
global state =  "59"
global mcd_preg_women =  "185"
global mcd_parent =  "59"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*GA*/
global state =  "58"
global mcd_preg_women =  "200"
global mcd_parent =  "50"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*HI*/
global state =  "95"
global mcd_preg_women =  "185"
global mcd_parent =  "100"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*ID*/
global state =  "82"
global mcd_preg_women =  "133"
global mcd_parent =  "39"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*IL*/
global state =  "33"
global mcd_preg_women =  "200"
global mcd_parent =  "191"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*IN*/
global state =  "32"
global mcd_preg_women =  "200"
global mcd_parent =  "36"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*IA*/
global state =  "42"
global mcd_preg_women =  "300"
global mcd_parent =  "83"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*KS*/
global state =  "47"
global mcd_preg_women =  "150"
global mcd_parent =  "32"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*KY*/
global state =  "61"
global mcd_preg_women =  "185"
global mcd_parent =  "62"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*LA*/
global state =  "72"
global mcd_preg_women =  "200"
global mcd_parent =  "25"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*ME*/
global state =  "11"
global mcd_preg_women =  "200"
global mcd_parent =  "200"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MD*/
global state =  "52"
global mcd_preg_women =  "250"
global mcd_parent =  "116"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MA*/
global state =  "14"
global mcd_preg_women =  "200"
global mcd_parent =  "133"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MI*/
global state =  "34"
global mcd_preg_women =  "185"
global mcd_parent =  "64"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MN*/
global state =  "41"
global mcd_preg_women =  "275"
global mcd_parent =  "215"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MS*/
global state =  "64"
global mcd_preg_women =  "185"
global mcd_parent =  "44"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MO*/
global state =  "43"
global mcd_preg_women =  "185"
global mcd_parent =  "37"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*MT*/
global state =  "81"
global mcd_preg_women =  "150"
global mcd_parent =  "56"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NE*/
global state =  "46"
global mcd_preg_women =  "185"
global mcd_parent =  "58"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NV*/
global state =  "88"
global mcd_preg_women =  "185"
global mcd_parent =  "88"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NH*/
global state =  "12"
global mcd_preg_women =  "185"
global mcd_parent =  "49"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NJ*/
global state =  "22"
global mcd_preg_women =  "200"
global mcd_parent =  "200"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NM*/
global state =  "85"
global mcd_preg_women =  "235"
global mcd_parent =  "67"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NY*/
global state =  "21"
global mcd_preg_women =  "200"
global mcd_parent =  "150"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*NC*/
global state =  "56"
global mcd_preg_women =  "185"
global mcd_parent =  "49"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*ND*/
global state =  "44"
global mcd_preg_women =  "133"
global mcd_parent =  "59"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*OH*/
global state =  "31"
global mcd_preg_women =  "200"
global mcd_parent =  "90"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*OK*/
global state =  "73"
global mcd_preg_women =  "185"
global mcd_parent =  "53"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*OR*/
global state =  "92"
global mcd_preg_women =  "185"
global mcd_parent =  "40"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*PA*/
global state =  "23"
global mcd_preg_women =  "185"
global mcd_parent =  "46"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*RI*/
global state =  "15"
global mcd_preg_women =  "250"
global mcd_parent =  "181"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*SC*/
global state =  "57"
global mcd_preg_women =  "185"
global mcd_parent =  "93"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*SD*/
global state =  "45"
global mcd_preg_women =  "133"
global mcd_parent =  "52"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*TN*/
global state =  "62"
global mcd_preg_women =  "250"
global mcd_parent =  "127"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*TX*/
global state =  "74"
global mcd_preg_women =  "200"
global mcd_parent =  "26"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*UT*/
global state =  "87"
global mcd_preg_women =  "133"
global mcd_parent =  "44"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*VT*/
global state =  "13"
global mcd_preg_women =  "200"
global mcd_parent =  "191"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*VA*/
global state =  "54"
global mcd_preg_women =  "200"
global mcd_parent =  "31"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*WA*/
global state =  "91"
global mcd_preg_women =  "185"
global mcd_parent =  "74"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*WV*/
global state =  "55"
global mcd_preg_women =  "150"
global mcd_parent =  "33"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*WI*/
global state =  "35"
global mcd_preg_women =  "300"
global mcd_parent =  "200"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

 /*WY*/
global state =  "83"
global mcd_preg_women =  "133"
global mcd_parent =  "52"
							
	/*Pregnant mothers & infants*/	replace mcd_elig=1  if inprs>0 	& age<=64 & (theType==1 | theType==2) 	& female == 1 	& newpovlv<=$mcd_preg_women & gestcen==$state & year==$year	
	/*Parents*/						replace mcd_elig=1 	if age>=18 	& age<=64 & newpovlv<=$mcd_parent		& gestcen==$state & year==$year		
					
					

