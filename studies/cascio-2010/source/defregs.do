* defregs.do

cap prog drop means0
prog def means0
	local data `1'
	local yvar `2'
	local if `3'
	local wt `4'
	local out `5'

	qui {
		use `data', clear
		reg `yvar' `if' `wt'
		estimates store `out'0
	}
	
end

cap prog drop means
prog def means
	local data `1'
	local yvar `2'
	local if `3'
	local wt `4'
	local out `5'

	qui {
		use `data', clear
		reg `yvar'1970 `if' `wt', cluster(smsa90)
		estimates store `out'0
	}
	
end

cap prog drop fsregs
prog def fsregs
	local data `1'
	local yvar `2'
	local xvar `3'
	local zvar `4'
	local controls `5'
	local if `6'
	local wt `7'
	local out `8'
	local lag `9'
  	local samp `10'

	qui {
		use `data', clear

		ivreg `xvar' `zvar' `controls' `if'&`yvar'~=. `wt', cluster(smsa90)
		estimates store `out'1

		ivreg `xvar' `zvar' `controls' medfaminc `if'&`yvar'~=. `wt', cluster(smsa90)
		estimates store `out'2

		ivreg `xvar' `zvar' `controls' ${controls1`samp'} `if'&`yvar'~=. `wt', cluster(smsa90)
		estimates store `out'3

		ivreg `xvar' `zvar' `controls' ${controls1`samp'} `lag' `if'&`yvar'~=. `wt', cluster(smsa90)
		estimates store `out'4

	}
	
end


cap prog drop regs
prog def regs
	local data `1'
	local yvar `2'
	local xvar `3'
	local zvar `4'
	local controls `5'
	local if `6'
	local wt `7'
	local out `8'
	local samp `9'
	local s `10'

	qui {
		use `data', clear

		ivreg `yvar' (`xvar'=`zvar') `controls' `if' `wt', cluster(smsa90)
		estimates store `out'1

		ivreg `yvar' (`xvar'=`zvar') `controls' medfaminc `if' `wt', cluster(smsa90)
		estimates store `out'2

		ivreg `yvar' (`xvar'=`zvar') `controls' ${controls1`samp'} `if' `wt', cluster(smsa90)
		estimates store `out'3

		ivreg `yvar' (`xvar'=`zvar') `controls' ${controls1`samp'} ${controls2${`yvar'}} `if' `wt', cluster(smsa90)
		estimates store `out'4

	}
	
	* show reduced form scatter plot, if requested
	if lower("`s'")=="y" {
		gr two (scatter `yvar' `zvar' `if' `wt', ms(oh)) ///
                   (scatter `yvar' `zvar' `if' `wt', mlab(fipst) mlabpos(0) ms(none)) ///
                   (lfit `yvar' `zvar' `if' `wt'),  ytitle("`yvar'") ///
               legend(off) 
 
		dis "Press Enter to Continue", _request(yesno)
	}

end

