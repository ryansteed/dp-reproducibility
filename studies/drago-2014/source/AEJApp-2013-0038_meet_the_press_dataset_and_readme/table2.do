clear

use meet_the_press_data_elections, clear

***********
**TABLE 2
**********

sort id_city_istat_2009 year



gen transition="11" if news_TOT==1 & news_TOT[_n-1]==1 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="12" if news_TOT==2 & news_TOT[_n-1]==1 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="13" if news_TOT==3 & news_TOT[_n-1]==1 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="14" if news_TOT==4 & news_TOT[_n-1]==1 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="15" if news_TOT>=5 & news_TOT[_n-1]==1 & id_city_istat_2009==id_city_istat_2009[_n-1]


replace transition="21" if news_TOT==1 & news_TOT[_n-1]==2 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="22" if news_TOT==2 & news_TOT[_n-1]==2 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="23" if news_TOT==3 & news_TOT[_n-1]==2 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="24" if news_TOT==4 & news_TOT[_n-1]==2 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="25" if news_TOT>=5 & news_TOT[_n-1]==2 & id_city_istat_2009==id_city_istat_2009[_n-1]


replace transition="31" if news_TOT==1 & news_TOT[_n-1]==3 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="32" if news_TOT==2 & news_TOT[_n-1]==3 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="33" if news_TOT==3 & news_TOT[_n-1]==3 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="34" if news_TOT==4 & news_TOT[_n-1]==3 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="35" if news_TOT>=5 & news_TOT[_n-1]==3 & id_city_istat_2009==id_city_istat_2009[_n-1]


replace transition="41" if news_TOT==1 & news_TOT[_n-1]==4 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="42" if news_TOT==2 & news_TOT[_n-1]==4 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="43" if news_TOT==3 & news_TOT[_n-1]==4 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="44" if news_TOT==4 & news_TOT[_n-1]==4 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="45" if news_TOT>=5 & news_TOT[_n-1]==4 & id_city_istat_2009==id_city_istat_2009[_n-1]


replace transition="51" if news_TOT==1 & news_TOT[_n-1]>=5 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="52" if news_TOT==2 & news_TOT[_n-1]>=5 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="53" if news_TOT==3 & news_TOT[_n-1]>=5 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="54" if news_TOT==4 & news_TOT[_n-1]>=5 & id_city_istat_2009==id_city_istat_2009[_n-1]
replace transition="55" if news_TOT>=5 & news_TOT[_n-1]>=5 & id_city_istat_2009==id_city_istat_2009[_n-1]


tab transition


