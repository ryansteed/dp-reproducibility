version 10.1
clear
set more off
#delimit;
set mem 300m;
estimates clear;

/*************************************************************************************************************
This do-file tests for a break in S&L employment in July.  

In particular, this code helps verify the following statement: "Historic aggregate time series confirm that employment changes are especially large in July. In unreported regressions, we compared the historical mean of the absolute value and square of state and local government employment changes for each month..."

1. Load data 
2. Absolute value and square of change regressions
	
*************************************************************************************************************/
cd "$dir";
/*************************************************************************************************************
1. Load data 
*************************************************************************************************************/
qui freduse CES9093000001 CES9092000001, clear;

rename CES9093000001 Local;
rename CES9092000001 State;

qui gen SL = State+Local;

qui gen monthly = mofd(daten);
qui tsset monthly, monthly;

qui gen DSL = D.SL; *Monthly change;
label variable DSL "S&L employment monthly change";

qui gen month = month(daten);

char month[omit] 7;
qui xi i.month, prefix(M); *Creates monthly dummy variables, with July omitted;

local F0 1955m1;
local F1 2011m5;;
local P0 1990m1;
local P1 2007m12;

/*************************************************************************************************************
4. Absolute value of change regressions
*************************************************************************************************************/
qui gen dSL = 100*(log(SL)-log(L.SL));
qui gen dSLAbsolute = abs(dSL);
qui gen dSLSquared = dSL^2;
foreach period in F P {;
	foreach depvar in Absolute Squared {;
		qui reg dSL`depvar' M* if tin(``period'0',``period'1');
		estimates store `depvar'`period';
	};
};


estout * using "output\onlineappendixtable1.txt", replace cells(b(fmt(%9.2f) star) se(par fmt(%9.2f) abs)) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(20) modelwidth(10) 
label varlabel(_cons "Constant") stats(N, fmt(%9.0f) labels("Observations")) mgroup("1955-2011" "1990-2007", pattern(1 0 0 1 0 0) span) 
prehead("Breaks in S&L Employment Change.") postfoot("Note: In columns marked 'Absolute value', the dependent variable is the absolute value of the log monthly change in S&L 
government employment multiplied by 100 and the reported coefficients are for dummy variables for the eleven months excluding July. In columns marked 'Squared', the dependent 
variable is the squared change in log monthly employment multiplied by 100 and the reported coefficients are for dummy variables for the eleven months excluding July. 
Standard errors in parentheses. * indicates significance at the 10% level; ** indicates significance at the 5% level; *** indicates significance at the 1% level.");
estimates drop _all;

