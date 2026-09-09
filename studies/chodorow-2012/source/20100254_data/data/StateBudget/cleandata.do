clear

insheet using StateBudgetInfo.csv, comma
rename state_id state_abrev
rename rainday2009 rainyday2009
destring cut2010spring cut2010fall, force replace
sort state_abrev

save statebudgetinfo, replace
