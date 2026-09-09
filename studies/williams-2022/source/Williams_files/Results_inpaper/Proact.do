clear

#delimit;


*** CLEANING FILE and RESULTS FILE ***;
** Input file: proact_reg_temp;

global infile = "Input_data";
global infile2 = "Analysis_data";
global outfile = "Latex_files";


use "$infile/proact_reg_temp";

generate Black_regpreact = pre_act_nonwhite/vote_age_nonwhite*100;
generate White_regpreact = pre_act_white/vote_age_white*100;
generate White_regpostact = post_act_white/vote_age_white*100;
generate Black_regpostact = post_act_nonwhite/vote_age_nonwhite*100;

generate total_vote = vote_age_nonwhite + vote_age_white;
generate sharenonwhite = vote_age_nonwhite/total_vote;

merge 1:1 fips using "$infile2/lynchallstates";
drop _merge;

** Figure 4;
** Pre Act results;
binscatter Black_regpreact lynchcapitamob, controls(sharenonwhite) absorb(State_FIPS) graphregion(color(white)) bgcolor(white)
ytitle("Percentage of black registered voters") xtitle("Black lynching rate") title("Pre-Act");
graph save "$outfile/regpreact.gph", replace;

** Post Act results;
binscatter Black_regpostact lynchcapitamob, controls(sharenonwhite) absorb(State_FIPS) graphregion(color(white)) bgcolor(white)
ytitle("Percentage of black registered voters") xtitle("Black lynching rate") title("Post-Act");
graph save "$outfile/regpostact.gph", replace;

graph combine "$outfile/regpreact.gph" "$outfile/regpostact.gph", xcommon ycommon graphregion(color(white));
graph export "$outfile/proact.eps", as(eps) preview(off) replace;

