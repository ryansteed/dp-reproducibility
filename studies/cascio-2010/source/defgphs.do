* defgphs.do

cap prog drop rfscat
prog def rfscat
	local data `1'
	local yvar `2'
	local zvar `3'
	local controls `4'
	local if `5'
	local wt `6'
	local name `7'
	local title `8'
	local out `9'	
	local label `10'
	local thresh `11'
	qui {
		use `data', clear

		reg `zvar' `controls' `if' `wt'
		predict residz `if', resid
		label var residz "Residual instrument"
		
		reg `yvar' `controls' `if' `wt'
		predict residy `if', resid
		label var residy "Residual `name'"

		if `label'==1 {
		gen residy2=residy
		replace residy2=. if abs(residy)<=`thresh'

            * label position variable
            gen labpos=3
            replace labpos=2 if agg_id==614550 
            replace labpos=9 if agg_id==622710 
            replace labpos=2 if agg_id==629850 

		gr two (scatter residy residz `if' `wt', ms(oh) title("`title'", size(medium))) ///
		(scatter residy2 residz `if' `wt', ms(none) mlab(dname) mlabc(black) mlabsize(vsmall) mlabvpos(labpos)) ///
                (lfit residy residz `if' `wt', lcolor(black)), legend(off) scheme(s1color) /// 
               	saving(`out'.gph, replace)  plotregion(lcolor(none)) xtitle(" ")

		}
		
		else {
		gr two (scatter residy residz `if' `wt', ms(oh) title("`title'", size(medium))) ///
                (lfit residy residz `if' `wt', lcolor(black)), legend(off) scheme(s1color) /// 
               	saving(`out'.gph, replace)  plotregion(lcolor(none)) xtitle(" ")
		}

	}
	
	tab dname `if'&residz>.15
	tab agg_id `if'&residz>.15
end
