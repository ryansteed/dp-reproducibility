***********
**FIGURE 3
**********

clear


use meet_the_press_data_maps, clear


spmap    tot_news_1993 using maps_coordinates, id(id)  title("1993" " ",linegap(3) ) name(news_1993) clmethod(custom) nodraw clbreaks(0 1 2 3 5)

spmap    diff_2010_1993_tot using maps_coordinates, id(id)  title("2010-1993", linegap(3)) name(diff) nodraw clmethod(custom) clbreaks(0 2 4 6 9)
 
graph combine news_1993 diff


