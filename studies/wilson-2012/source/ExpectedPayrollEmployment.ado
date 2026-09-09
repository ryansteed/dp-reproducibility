program define ExpectedPayrollEmployment
	local window = `1'
	local finaldate = `2'
	* Next, I make the expected payroll employment growth variable.
	* This is based on a previous variable that was created in the Job Credit paper. Specifically,
	* \[EG_{i, t} = \Sigma_s \omega_{i,s,pre} [ln(L_{s,post} - L_{i,s,post}) - ln(L_{s,pre} - L_{i,s,pre})] \]
	* \[ \mbox{where } \omega_{i,s,pre} = \frac{L_{i,s,pre}}{L_{i,pre}}\]

	* This will give us a predicted growth rate in state i's employment from pre
	* to post based on national industry employment growth (in particular, national growth independent of that particular state)
	* and the proportion of a state's employment that is in that industry.

	* Similarly, we can generate a predicted change in the level of employment,
	* \[EdL_{i, t} = EG_{i, t} L_{i,pre}\]

	* The industries that we are using are the ones that were in the job credit paper,
	* LNRMN LCONS LMANU LWTRD LRTRD LTPUT LINFO LFIRE LPBSV LEDUH LLEIH LSRVO.

	/* rename the national variables */
	rename LACONS national_LCONS
	rename LAEDUH national_LEDUH
	rename LAFIRE national_LFIRE
	rename LAINFO national_LINFO
	rename LALEIH national_LLEIH
	rename LAMANU national_LMANU
	rename LANTRM national_LNRMN
	rename LAPBSV national_LPBSV
	rename LARTRD national_LRTRD
	rename LASRVO national_LSRVO
	rename LAWTRD national_LWTRD

	*	The state industry LTPUT is transportation, warehousing, and utilities.
	*	However, the national series from Haver takes those apart and gives a variable for transportation and warehousing and a separate
	*	variable for utilities.

	*	Note that the BLS web site said that aggregating from the state series is dangerous (\url{"http://www.bls.gov/sae/790over.htm#intro"})
	*	``Caution on aggregating state data. State estimation procedures are
	*	designed to produce accurate data for each individual state. BLS
	*	independently develops a national employment series; state
	*	estimates are not forced to sum to national totals nor vice
	*	versa. Because each state series is subject to larger sampling
	*	and nonsampling errors than the national series, summing them
	*	cumulates individual state level errors and can cause
	*	significant distortions at an aggregate level. Due to these
	*	statistical limitations, BLS does not compile a “sum-of-states”
	*	employment series, and cautions users that such a series is
	*	subject to a relatively large and volatile error structure.''

	*   so, what I'm going to do is just sum the transportation and warehousing 
	*	variable along with the utilities variable to get the analagous
	*   national variable.

	gen national_LTPUT = LATTUL + LAUTIL
		  tsset state time
		  sort state time
			foreach sector in LNRMN LCONS LMANU LWTRD LRTRD LTPUT LINFO LFIRE LPBSV LEDUH LLEIH LSRVO {
			gen egs_`sector' = (L`window'.`sector'/L`window'.StateEmployment)*(ln(national_`sector' - `sector') - ln(L`window'.national_`sector' - L`window'.`sector'))
		   }
		  gen sumegs = egs_LNRMN + egs_LCONS + egs_LMANU + egs_LWTRD + egs_LRTRD + egs_LTPUT + egs_LINFO + egs_LFIRE + egs_LPBSV + egs_LEDUH + egs_LLEIH + egs_LSRVO
		  gen EdL = sumegs*L`window'.StateEmployment
		  gen emp_state_growth = ln(StateEmployment) - ln(L`window'.StateEmployment)
		  gen emp_state_change = StateEmployment - L`window'.StateEmployment
		  list state if time == `finaldate'& sumegs == .

	* These missing states are all missing egs\_LNRMN and egs\_LCONS - However, this is because in Haver
	* the corresponding industries (Mining and Construction) have been combined to form LNRMC (Natural Resources, Mining, and Construction).
	* So, I make a national LNMRC figure, which is the sum of mining and construction nationally. Then, I recalculate the sumegs value for each
	* of these states.
	/* states that are missing:
	10, 11, 15, 24, 31, 46, 47
	*/

	gen national_LNRMC = national_LCONS + national_LNRMN
	gen egs_LNRMC = .
	replace egs_LNRMC = (L`window'.LNRMC/L`window'.StateEmployment)*(ln(national_LNRMC - LNRMC) - ln(L`window'.national_LNRMC - L`window'.LNRMC))

	foreach state in 10 11 15 24 31 46 47 {
		replace sumegs = egs_LNRMC + egs_LMANU + egs_LWTRD + egs_LRTRD + egs_LTPUT + egs_LINFO + egs_LFIRE + egs_LPBSV + egs_LEDUH + egs_LLEIH + egs_LSRVO if state == `state'
		replace EdL = sumegs*L`window'.StateEmployment
	}
	* The \verb=sumegs= variable gives the expected percent change in state employment. I also construct a variable that gives the expected change in
	* employment, \verb=EdL=.



	order state time emp* sumegs emp_state_growth EdL emp_state_change

	* I also calculated the actual percent change in State Employment over the same time period. Here is how the
	* expected values of these variables compare to their realized values.

	list state time sumegs emp_state_growth if state <= 20 & time == `finaldate'
	reg emp_state_growth sumegs 
	reg emp_state_change EdL
end
