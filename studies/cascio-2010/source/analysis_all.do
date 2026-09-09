* analysis_all.do

* Insert directory path where you have unzipped the programs and data
cd "source/"

do defregs.do
do defgphs.do
do drmacros-nokids.do

global fes "_smhi1970*"

clear
cap clear matrix
set more off
set mem 500m
set matsize 10000

cap mkdir output
cap mkdir logs

global samp "landarea~=.&ccity~=.&ppexptot72~=.&nobaddata_area==1"

global controls1 "lnartot21976 hipub ccity pprevprop ppexptot drop_16t17 ptratio72 medfaminc" 

* global macros for variable names
do depvars.do
global controls2var3a "sch1ageshindnh_702"
global controls2var4a "lnodds1nh_702"
global controls2var5a "lnpop1nh_702"
global controls2var6a "shsch1nh1970"
global controls2var7a "privratenh1970"
global controls2var8a "ageshindnh1970"
global controls2var8b "lnoddsnh1970"
global controls2var8c "lnpopnh1970"

global controls3var7a ""

**********************************
* Main tables
**********************************

cap estimates clear
do table1.do
do table2.do
do table3.do
do table4fs.do
do table4regs.do
do table5.do
do table6.do

**********************************
* Main figures
**********************************
do figure1.do
do figures2_3_4.do

**********************************
* Appendix table
**********************************
do apptable1.do


