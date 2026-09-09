***********
**FIGURE 1
**********
clear

use meet_the_press_data_newspapers, clear



sort id_city_istat_2009 year
bys id_city_istat_2009: g entry= news_TOT>news_TOT[_n-1] if news_TOT!=.&news_TOT[_n-1]!=.
recode entry .=0
bys id_city_istat_2009: g exit= news_TOT<news_TOT[_n-1] if news_TOT!=.&news_TOT[_n-1]!=.
recode exit .=0


label var entry "Gaining Newspapers" 
label var exit "Losing Newspapers" 

graph bar (sum) entry exit,label over(year) ytitle(Number of Municipalities) bar(1,color(gs1)) bar(2,color(gs10))


