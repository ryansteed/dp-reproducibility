/******************************************************************************
Master file for:

Racial Differences in Police Use of Force:
Evidence from the 1960s Civil Disturbances
by Jamein P. Cunningham and Rob Gillezeau

Date: 1/12/2018
******************************************************************************/


*dofile directory (where this file is stored)
global dofile "."

*data directory (where posted datasets are stored)
global data "../data"

*output directory (where regression output, figures, and logs are saved)
global output "."

cd $dofile

*MAIN TABLES
do "$dofile/eventstudy_AEAPP_tables.do"



