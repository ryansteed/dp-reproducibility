/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file installs all necessary packages needed to replicate the paper
*********************************/
clear
set more off
ssc install tabplot, replace
ssc install _gwtmean, replace
ssc install estout, replace
ssc install rdrobust, replace
ssc install coefplot, replace
ssc install grstyle, replace
ssc install palettes, replace
ssc install colrspace, replace