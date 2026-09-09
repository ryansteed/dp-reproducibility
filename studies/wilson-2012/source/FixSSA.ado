program define FixSSA
	local pre `1'
	* Fixing the Social Security Administration Amounts

	* As Per Dan's email from 2/08/2010, I am changing the Social Security Administrations payments figure to reflect the
	* one-time payment that occured in May of 2009.

	* According to \url{www.socialsecurity.gov/payment/} the 13 billion of SSA payments were all made in May 2009.
	* So if we do indeed have SSA announcements by state, we can assume that the FLOW of SSA Payments is:
	
	* payments(state i) = 0 for months prior to May 09,
	* payments(state i)(May 09) = cumulative announcements(state i) 
	*	as of now (which should be roughly the same as they were as of the end-of-May/beginning-of-June),
	* payments(state i) = 0 for months after May 09.

	*  And so cumulative payments will look like a step function:  0 thru April 09, then positive (totaling 13b across states) and fixed forever after.

	sort state time
	drop if state == .
	gen tmp_SSA_announced = AnnouncedSSA if state ~= state[_n+1]
	bysort state: egen tmp_SSA_announced_min = min(tmp_SSA_announced)

	cap drop finaltotalpd_dlrSSA finaltotalobl_dlrSSA
	
	gen finaltotalpd_dlrSSA = 0 if time <= ym(2009,4)
	replace finaltotalpd_dlrSSA = tmp_SSA_announced_min if time > tm(2009, 4)

	*  From Dan's email from 2/12/2010:
	*  Let's change the SSA announcement by state to 0 (from missing) for
	*  months prior to Aug. 2009.  (Even though the payments were made in
	*  May, it is still true that the allocation across states was not
	*  officially announced until August.)  Also, I think we should set the
	*  time series of SSA obligations equal to that of SSA payments -- i.e.,
	*  no payments or obligations until May at which time both become
	*  positive.  (After May, the flows of payments and obligations return to
	*  zero, with cumulative-to-date payments and obligations staying fixed at
	*  that positive level.)


	replace AnnouncedSSA = 0 if time <= ym(2009,8) & time >= `pre'
	gen finaltotalobl_dlrSSA = finaltotalpd_dlrSSA
	
end
