********************************************************************************
*** TABLES AND FIGURES
********************************************************************************

clear*
set matsize 11000

* Path: original data
global pathdataorig "../../Data/Originais"
* Path: workfiles
global pathdata "../../Data/Workfiles"
* Path: where output is going to be saved
global pathresults "."

* Path: do-files for tables
global path_tables "tables"
* Path: do-files for figures
global path_figures "figures"


********************************************************************************
*** MAIN TABLES

*** TABLE 1 - Descriptive statistics
do "$path_tables/table1_descriptive_stats.do"


* Load data and make final adjustments for regressions and figures
do "$path_tables/_preamble.do"


*** TABLE 2 - Results using main specification (RF, OLS, IV)
do "$path_tables/table2_main_results.do"

*** EDITED by Ryan Steed
exit
***

*** TABLE 3 - First stage (main specification)
do "$path_tables/table3_first_stage.do"


*** TABLE 4 - Mortality by cause & other outcomes (RF & IV)
do "$path_tables/table4_other_outcomes.do"


*** TABLE 5 - Trends with birth rate
do "$path_tables/table5_trends_birth_rate.do"


*** TABLE 6 - Placebo using glyphosate & potential downstream
do "$path_tables/table6_placebo_downstream.do"


*** TABLE 7 - Heterogeneity
do "$path_tables/table7_heterogeneity.do"


*** TABLE 8 - Effects on mortality by exposure
do "$path_tables/table8_exposure.do"


*** TABLE 9 - Land Use
do "$path_tables/table9_land_use.do"


********************************************************************************
*** TABLES, APPENDIX C - SPECIFICATION CONTROLLING FOR SUM UPSTREAM & DOWNSTREAM

*** TABLE C1 - Results on infant mortality
do "$path_tables/tableC1_sum_up_down.do"


*** TABLE C2 - Mortality by cause & other birth outcomes
do "$path_tables/tableC2_sum_up_down_other.do"


********************************************************************************
*** TABLES, APPENDIX E - ADDITIONAL TABLES

*** TABLE E1 - Effects on mortality (IV) using other measures of glyphosate
do "$path_tables/tableE1_glyph_alt_measures.do"


*** TABLE E2 - Effects on mortality excluding municipalities without area upstream
do "$path_tables/tableE2_IMR_wo_area_upstream.do"


*** TABLE E3 - Mortality & other outcomes using placebo (downstream) specification
do "$path_tables/tableE3_placebo_downstream.do"


*** TABLE E4 - Effects on mortality including interaction with area upstream
do "$path_tables/tableE4_interaction_area.do"


*** TABLE E5 - Effects on mortality by distance
do "$path_tables/tableE5_distance.do"


*** TABLE E6 - Spillovers based on Bustos et al. (Obs: different dataset)
preserve
do "$path_tables/tableE6_spillovers.do"
restore


*** TABLE E7 - First Stage for Corn
do "$path_tables/tableE7_corn.do"


*** TABLE E9 - Results for water quality
do "$path_tables/tableE9_water_quality.do"



********************************************************************************
*** FIGURES

*** Figure 1 - Soy and glyphosate in Brazil
do "$path_figures/fig1_soy_glyph_br.do"

*** Figure 3 - Event-study for IMR
do "$path_figures/fig3_event_study_IMR.do"


********************************************************************************
*** ADDITIONAL FIGURES

*** Figure D2 - Event-study for mortality by cause & other outcomes
do "$path_figures/figD2_event_study_other_outcomes.do"


*** Figure D3 - Event-study for mortality by exposure
do "$path_figures/figD3_event_study_exposure.do"
