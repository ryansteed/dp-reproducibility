* THIS FILE GENERATES THE TABULATIONS IN TABLE 2 AND FIGURE 2. THE DATA FILE USED HERE IS GENERATED IN THE DATA_SETUP.DO FILE *

clear
set mem 5g

use analysis_teacher, clear
gen treated_grades=1 if teach_3==1 | teach_6==1 | teach_8==1

	* Table 2, top panel *

summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix<=1
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix<=1
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix<=1
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix==2
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix==2
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix==2
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix==3
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix==3
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix==3
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix==4
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix==4
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix==4
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix==5
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix==5
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix==5
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=6 & exp_fix<=9
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=6 & exp_fix<=9
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=6 & exp_fix<=9
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=10 & exp_fix<=14
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=10 & exp_fix<=14
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=10 & exp_fix<=14
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=15 & exp_fix<=19
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=15 & exp_fix<=19
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=15 & exp_fix<=19
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=20 & exp_fix<=24
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=20 & exp_fix<=24
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=20 & exp_fix<=24
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=25 & exp_fix<=29
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=25 & exp_fix<=29
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=25 & exp_fix<=29
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=30 & exp_fix<=34
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=30 & exp_fix<=34
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=30 & exp_fix<=34
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=35 & exp_fix<=39
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=35 & exp_fix<=39
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=35 & exp_fix<=39
summ exit if year>1989 & year<1993 & treated_grades==1 & exp_fix>=40
summ exit if year>=1993 & year<=1994 & treated_grades==1 & exp_fix>=40
summ exit if year>=1995 & year<=1996 & treated_grades==1 & exp_fix>=40

	* Table 2, bottom pannel *

tab exp_fix if year>1989 & year<1993 & treated_grades==1 & exit==1
tab exp_fix if year>=1993 & year<=1994 & treated_grades==1 & exit==1
tab exp_fix if year>=1995 & year<=1996 & treated_grades==1 & exit==1

* FIGURE 2 *

tab exp_fix if year<=1993 & pct<.3566433 & treated_grades==1 
tab exp_fix if year>1993 & year<1996 & pct<.3566433 & treated_grades==1 

tab exp_fix if year<=1993 & pct<.5348837 & pct>=.3566433 & treated_grades==1
tab exp_fix if year>1993 & year<1996 & pct<.5348837 & pct>=.3566433 & treated_grades==1

tab exp_fix if year<=1993 & pct<.6904762 & pct>=.5348837 & treated_grades==1
tab exp_fix if year>1993 & year<1996 & pct<.6904762 & pct>=.5348837 & treated_grades==1

tab exp_fix if year<=1993 & pct>=.6904762 & treated_grades==1
tab exp_fix if year>1993 & year<1996 & pct>=.6904762 & treated_grades==1


