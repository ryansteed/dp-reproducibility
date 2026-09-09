/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates Table 2, which generates summary statistics for the paper.

DATA INPUTS: (1) Master Admin Data (2) hasany
OUTPUT: TABLE 2

*********************************/
**Set Globals
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*Call Main Admin Data
use "${path}\Data\Intermediate\Master_Admin_Data_Final", clear
sort district_code school_year

*Merge to data indicators if the district has ever had a ref (either op. or ref.)
merge m:1 district_code using "${path}\Data\Intermediate\hasany" //17 school districts never held one or the other
drop _merge
replace hasany=0 if hasany==.


*All districts
sum rev_lim_mem tot_exp_mem tot_exp_inst_mem tot_exp_ss_mem tot_exp_oth_mem [aw=membership]
sum dropout_rate advprof_math10 wkce_math10 perc_instate [aw=membership]
sum ratio_stdnts_to_staff_total AverageLocalExp compensation turnover_LA prop_val_mem urban_centric_locale [aw=membership]
sum fall_enr 
 
*Never proposed districts
sum rev_lim_mem tot_exp_mem tot_exp_inst_mem tot_exp_ss_mem tot_exp_oth_mem [aw=membership] if hasany==0
sum dropout_rate advprof_math10 wkce_math10 perc_instate [aw=membership] if hasany==0
sum ratio_stdnts_to_staff_total AverageLocalExp compensation turnover_LA prop_val_mem urban_centric_locale [aw=membership] if hasany==0
sum fall_enr if hasany==0 
 
*Proposed at least one
sum rev_lim_mem tot_exp_mem tot_exp_inst_mem tot_exp_ss_mem tot_exp_oth_mem [aw=membership] if hasany==1
sum dropout_rate advprof_math10 wkce_math10 perc_instate [aw=membership] if hasany==1
sum ratio_stdnts_to_staff_total AverageLocalExp compensation turnover_LA prop_val_mem urban_centric_locale [aw=membership] if hasany==1
sum fall_enr if hasany==1
  

*Differences in means
reg rev_lim_mem hasany [aw=membership], cluster(district_code)
reg tot_exp_mem hasany [aw=membership], cluster(district_code)
reg tot_exp_inst_mem hasany [aw=membership], cluster(district_code)
reg tot_exp_ss_mem hasany [aw=membership], cluster(district_code) 
reg tot_exp_oth_mem hasany [aw=membership], cluster(district_code)
 
reg dropout_rate hasany [aw=membership], cluster(district_code)
reg advprof_math10 hasany [aw=membership], cluster(district_code)
reg wkce_math10 hasany [aw=membership], cluster(district_code)
reg perc_instate hasany [aw=membership], cluster(district_code)
 
reg ratio_stdnts_to_staff_total hasany [aw=membership], cluster(district_code)
reg AverageLocalExp hasany [aw=membership], cluster(district_code)
reg compensation hasany [aw=membership], cluster(district_code)
reg turnover_LA hasany [aw=membership], cluster(district_code)
reg prop_val_mem hasany [aw=membership], cluster(district_code) 
reg urban_centric_locale hasany [aw=membership], cluster(district_code) 
reg fall_enr hasany, cluster(district_code)  
 