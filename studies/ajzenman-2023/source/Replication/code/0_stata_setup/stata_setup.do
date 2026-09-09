clear all
set more off

*** Install required packages from SSC ***
local packages "groups outreg2 ivreg2 reg_ss ivreg_ss weakiv ranktest avar"

foreach pkg in `packages' {
	
	dis "Installing `pkg'"
	ssc install `pkg', replace
	
}

net install sg97_5, from("http://www.stata-journal.com/software/sj12-4/")
