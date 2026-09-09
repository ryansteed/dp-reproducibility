*******************************
*Title: paper_shell.do

*Purpose: runs all code for replication package for Jacob (2024): School Board Elections Before, During, and After the COVID-19 Pandemic
*This replication package uses data from the following replication package from the author: Baum & Jacob (2023): Racial Differences in Parent Response to COVID-19 Schooling Policies 

*Output: see folder "Output"

*Created by: Alvin Christian, 27 Aug 2024
*******************************

clear all
*insert own file paths below 
global filepath "C:\Users\alvinchr\University of Michigan Dropbox\Alvin Christian\School_Boards_and_COVID\School Board Elections\Replication"
global data "${filepath}\Data"
cd "${filepath}"
program drop _all
*******************************
/* This script runs the entire paper replication package, from the data build to the output. 

Input your directory filepath above and ensure that you have the following folders inside of your directory: 1) Code, 2) Data, 3) Output 

You will need the following non-standard Stata packages: estout, reghdfe. The program "install_packages" installs these packages. 
*/
*******************************
program paper_shell
install_packages 
build_code 
//output_code
end 

program install_packages
ssc install estout, replace 

* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/") replace

end

capture drop program build_code
program build_code 


do Do/1_ballotpedia18-21.do
cd "${filepath}"

do Do/2_ballotpedia22.do
cd "${filepath}"

do Do/3_ballotpedia_combine.do
cd "${filepath}"

do Do/4_sbe_base_v3.do
cd "${filepath}"
 
do Do/5_analysis.do

 
end 


paper_shell



