********************************************************************************
* This file: create Table 2
********************************************************************************

// preambles
set more off
set matsize 4000
clear all
macro drop _all

// set working directory
****Modified by Eduardo Schnadower to use current path instead***
*local path "~/Dropbox/Research/Oil_Transfer/prep_for_pub/REStat_data_code/"
*cd `path'

// import project routines
do "code/project_routines.do"

cap log close
log using "results/table2.log", replace

********************************************************************************

cap program drop main
program main
    use_data_cnty_year
    regs_weighted
    create_table2
end

cap program drop export_results
program export_results
    esttab _all using "results/table2.csv", append ///
        drop(stateyrv* $controls _cons) stats(F_stat N, fmt(1 0)) ///
        b(3) se(3) nolz gaps depvars numbers
    eststo clear
    estimates clear
end

cap program drop run_2sls
program run_2sls
    // generic function to run 2SLS regressions
    args depv indepv iv period

    tab stateyr if og_state==1 & (`period') & ${`depv'_bal}, gen(stateyrv)
    eststo: ivreg2 D.log_real_`depv' (D.log_`indepv' = `iv') ///
        $controls stateyrv* $regWeight, cluster(fips) savefirst

        // save first stage and F-stat for excluded instruments
        tsunab ivs: `iv'
        local ivreg2result = e(firsteqs)
        foreach model of local ivreg2result {
            estimates restore `model'
            test `ivs'
            estadd scalar F_stat = r(F)
        }

    drop stateyrv*
    *** Line below commented by Eduardo Schnadower
    *export_results
end

cap program drop create_table2
program create_table2
    foreach pay in ssdi ssi {
        // Column 1 - 1967 Instrument: 1970–1993
        run_2sls `pay' "real_earn" "${og_oilprice_cont_67}" "tin(1970, 1993)"
        // Column 2 - 1967 Instrument: 1970–1993
        run_2sls `pay' "real_earn" "${og_oilprice_cont_67}" "tin(1994, 2011)"
        // Column 3 - 1974 Instrument: 1970–2011
        run_2sls `pay' "real_earn" "${og_oilprice_cont_74}" "tin(1970, 2011)"
        // Column 4 - 1967 Instrument no lags: 1970–2011
        run_2sls `pay' "real_earn" "${og_oilprice_cont_67_nolags}" "tin(1970, 2011)"
        // Column 5 - National employment Instrument: 1970–2011
        run_2sls `pay' "real_earn" "${og_emp_cont_67}" "tin(1970, 2011)"
    }
    ****Line below added by Eduardo Schnadower
    estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
end

********************************************************************************

main

log close
exit
