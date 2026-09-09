***********
**FIGURE 2
**********


clear

use meet_the_press_data_newspapers, clear
sort id_city_istat_2009 year


****************NUMBER OF CITIES BY NUMBER OF NEWSPAPERS BY YEAR
gen one_news=1 if news_TOT==1
gen two_news=1 if news_TOT==2
gen three_news=1 if news_TOT==3
gen four_news=1 if news_TOT>=4

graph bar (sum)  one_news  two_news three_news four_news, stack over( year) ytitle(Number of municipalities) bar(1,color(gs1)) bar(2,color(dkgreen)) bar(3,color(gs10)) bar(4,color(gs12))

