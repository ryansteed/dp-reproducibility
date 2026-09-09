/**

do ipeds_long_diff2.do "enrollment"
do ipeds_long_diff2.do "men"
do ipeds_long_diff2.do "women"

do ipeds_long_diff2.do "enrollment" "placebo"
do ipeds_long_diff2.do "men" "placebo"
do ipeds_long_diff2.do "women" "placebo"

**/



**
** Full set of colleges/universities
**local types = "high most all"
local types = "high"

foreach type of local types  {
do ipeds_annual_event_study_graphs.do "enrollment" "`type'"
do ipeds_annual_event_study_graphs.do "women"  "`type'"
do ipeds_annual_event_study_graphs.do "men"  "`type'"

do ipeds_annual_event_study_graphs2.do "enrollment" "`type'"
do ipeds_annual_event_study_graphs2.do "women"  "`type'"
do ipeds_annual_event_study_graphs2.do "men"  "`type'"
}
exit



do ipeds_long_diff2.do "enrollment" "00_12"
do ipeds_long_diff2.do "men" "00_12"
do ipeds_long_diff2.do "women" "00_12"

do ipeds_long_diff2.do "enrollment" "06_12"
do ipeds_long_diff2.do "men" "06_12"
do ipeds_long_diff2.do "women" "06_12"

**/


do ipeds_long_diff2.do "enrollment" "completions"
do ipeds_long_diff2.do "men" "completions"
do ipeds_long_diff2.do "women" "completions"

do ipeds_net_costs.do

**
** Robustness to sample of IPEDS colleges/universities (OA.15)
**
*do ipeds_long_diff2.do "enrollment" "most"
*do ipeds_long_diff2.do "men" "most"
*do ipeds_long_diff2.do "women" "most"
*do ipeds_long_diff2.do "enrollment" "all"
*do ipeds_long_diff2.do "men" "all"
*do ipeds_long_diff2.do "women" "all"

exit



