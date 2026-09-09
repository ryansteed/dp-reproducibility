use "E:\table 6and7-teacher.dta"
**Table 6**
reg  tattendance     hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop, cluster(district)
lincom( op+.11*hrop+.099*unop+.076*rbop+.21*prop+.22*slop+.13*fzop+.09*gnop)
reg  tactivity     hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop, cluster(district)
lincom( op+.11*hrop+.099*unop+.076*rbop+.21*prop+.22*slop+.13*fzop+.09*gnop)

**Table 7**
**only taking the landlord districts and looking at difference between permanent and oudh districts**
reg tattendance hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop   slopperm perm if op==1, cluster(district)
lincom perm+slopperm*.27

reg tactivity hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop   slopperm perm if op==1, cluster(district)
lincom perm+slopperm*.27

clear


use "E:\table 6and7-student.dta"
**standardized score and student attendance**

**Table 6**
reg meanscore  hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop , cluster(district)
lincom( op+.11*hrop+.11*unop+.07*rbop+.19*prop+.19*slop+.12*fzop+.14*gnop)

reg sattendance hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop, cluster(district)
lincom( op+.11*hrop+.11*unop+.07*rbop+.19*prop+.19*slop+.12*fzop+.14*gnop)

**Table 7**
**only taking the landlord districts and looking at difference between permanent and oudh districts**
reg meanscore kh hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop  propperm perm if op==1, cluster(district)
lincom perm+propperm*.18

reg sattendance hr un rb pr sl fz gn op   hrop unop rbop prop slop fzop gnop  propperm perm if op==1, cluster(district)
lincom perm+propperm*.18
clear


use "E:\table 6-stipend.dta", clear

**Stipend**
**Table 6**
reg scholar hr un rb pr sl fz gn oudh   hro uno rbo pro slo fzo gno if caste2==0, cluster(district)
lincom( oudh+.13*hro+.17*uno+.08*rbo+.18*pro+.08*slo+.14*fzo+.13*gno)

clear

use "E:\table 6and7-school infrastructure.dta"

**index of infrastructure**
**Table 6**
reg index hr un rb pr sl fz gn op hrop unop rbop prop slop fzop gnop, cluster(district)
lincom( op+.11*hrop+.11*unop+.08*rbop+.19*prop+.19*slop+.11*fzop+.11*gnop)

**Table 7**
**only taking the landlord districts and looking at difference between permanent and oudh districts**
reg index kh hr un rb pr sl fz gn perm slopperm if op==1, cluster(district)
lincom perm+slopperm*.27
clear
