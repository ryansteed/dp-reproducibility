* Created  October 12, 2017                                
*
* Modify the path below to point to your data file.
* The specified subdirectory was not created on
* your computer. You will need to do this.
*
* The stat program must be run against the specified
* data file. This file is specified in the program
* and must be saved separately.
*
* This program does not provide tab or summarize for all
* variables.
*
* There may be missing data for some institutions due
* to the merge used to create this file.
*
* This program does not include reserved values in its
* calculations for missing values.
*
* You may need to adjust your memory settings depending
* upon the number of variables and records.
*
* The save command may need to be modified per user
* requirements.
*
* For long lists of value labels, the titles may be
* shortened per program requirements.
clear
cd "$PATH/Academic Calendar/Data/"
insheet using f1516_f1a_data_stata.csv, comma clear
label data "dct_f1516_f1a"
label variable unitid   "Unique identification number of the institution"
label variable xf1a01 "Imputation field for f1a01 - Total current assets"
label variable f1a01    "Total current assets"
label variable xf1a31 "Imputation field for f1a31 - Depreciable capital assets, net of depreciation"
label variable f1a31    "Depreciable capital assets, net of depreciation"
label variable xf1a04 "Imputation field for f1a04 - Other noncurrent assets"
label variable f1a04    "Other noncurrent assets"
label variable xf1a05 "Imputation field for f1a05 - Total noncurrent assets"
label variable f1a05    "Total noncurrent assets"
label variable xf1a06 "Imputation field for f1a06 - Total assets"
label variable f1a06    "Total assets"
label variable xf1a19 "Imputation field for f1a19 - Deferred outflows of resources"
label variable f1a19    "Deferred outflows of resources"
label variable xf1a07 "Imputation field for f1a07 - Long-term debt, current portion"
label variable f1a07    "Long-term debt, current portion"
label variable xf1a08 "Imputation field for f1a08 - Other current liabilities"
label variable f1a08    "Other current liabilities"
label variable xf1a09 "Imputation field for f1a09 - Total current liabilities"
label variable f1a09    "Total current liabilities"
label variable xf1a10 "Imputation field for f1a10 - Long-term debt"
label variable f1a10    "Long-term debt"
label variable xf1a11 "Imputation field for f1a11 - Other noncurrent liabilities"
label variable f1a11    "Other noncurrent liabilities"
label variable xf1a12 "Imputation field for f1a12 - Total noncurrent liabilities"
label variable f1a12    "Total noncurrent liabilities"
label variable xf1a13 "Imputation field for f1a13 - Total liabilities"
label variable f1a13    "Total liabilities"
label variable xf1a20 "Imputation field for f1a20 - Deferred inflows of resources"
label variable f1a20    "Deferred inflows of resources"
label variable xf1a14 "Imputation field for f1a14 - Invested in capital assets, net of related debt"
label variable f1a14    "Invested in capital assets, net of related debt"
label variable xf1a15 "Imputation field for f1a15 - Restricted-expendable"
label variable f1a15    "Restricted-expendable"
label variable xf1a16 "Imputation field for f1a16 - Restricted-nonexpendable"
label variable f1a16    "Restricted-nonexpendable"
label variable xf1a17 "Imputation field for f1a17 - Unrestricted"
label variable f1a17    "Unrestricted"
label variable xf1a18 "Imputation field for f1a18 - Net position"
label variable f1a18    "Net position"
label variable xf1a214 "Imputation field for f1a214 - Land  improvements - Ending balance"
label variable f1a214   "Land  improvements - Ending balance"
label variable xf1a224 "Imputation field for f1a224 - Infrastructure - Ending balance"
label variable f1a224   "Infrastructure - Ending balance"
label variable xf1a234 "Imputation field for f1a234 - Buildings - Ending balance"
label variable f1a234   "Buildings - Ending balance"
label variable xf1a324 "Imputation field for f1a324 - Equipment, including art and library collections - Ending balance"
label variable f1a324   "Equipment, including art and library collections - Ending balance"
label variable xf1a274 "Imputation field for f1a274 - Construction in progress - Ending balance"
label variable f1a274   "Construction in progress - Ending balance"
label variable xf1a27t4 "Imputation field for f1a27t4 - Total for plant, property and equipment - Ending balance"
label variable f1a27t4  "Total for plant, property and equipment - Ending balance"
label variable xf1a284 "Imputation field for f1a284 - Accumulated depreciation - Ending balance"
label variable f1a284   "Accumulated depreciation - Ending balance"
label variable xf1a334 "Imputation field for f1a334 - Intangible assets , net of accumulated amortization - Ending balance"
label variable f1a334   "Intangible assets , net of accumulated amortization - Ending balance"
label variable xf1a344 "Imputation field for f1a344 - Other capital assets - Ending balance (New Aligned)"
label variable f1a344   "Other capital assets - Ending balance (New Aligned)"
label variable xf1d01 "Imputation field for f1d01 - Total revenues and other additions"
label variable f1d01    "Total revenues and other additions"
label variable xf1d02 "Imputation field for f1d02 - Total expenses and other deductions"
label variable f1d02    "Total expenses and other deductions"
label variable xf1d03 "Imputation field for f1d03 - Change in net position during the year"
label variable f1d03    "Change in net position during the year"
label variable xf1d04 "Imputation field for f1d04 - Net position beginning of year"
label variable f1d04    "Net position beginning of year"
label variable xf1d05 "Imputation field for f1d05 - Adjustments to beginning net position"
label variable f1d05    "Adjustments to beginning net position"
label variable xf1d06 "Imputation field for f1d06 - Net position end of year"
label variable f1d06    "Net position end of year"
label variable xf1b01 "Imputation field for f1b01 - Tuition and fees, after deducting discounts and allowances"
label variable f1b01    "Tuition and fees, after deducting discounts and allowances"
label variable xf1b02 "Imputation field for f1b02 - Federal operating grants and contracts"
label variable f1b02    "Federal operating grants and contracts"
label variable xf1b03 "Imputation field for f1b03 - State operating grants and contracts"
label variable f1b03    "State operating grants and contracts"
label variable xf1b04 "Imputation field for f1b04 - Local/private operating grants and contracts"
label variable f1b04    "Local/private operating grants and contracts"
label variable xf1b04a "Imputation field for f1b04a - Local operating grants and contracts"
label variable f1b04a   "Local operating grants and contracts"
label variable xf1b04b "Imputation field for f1b04b - Private operating grants and contracts"
label variable f1b04b   "Private operating grants and contracts"
label variable xf1b05 "Imputation field for f1b05 - Sales and services of auxiliary enterprises"
label variable f1b05    "Sales and services of auxiliary enterprises"
label variable xf1b06 "Imputation field for f1b06 - Sales and services of hospitals"
label variable f1b06    "Sales and services of hospitals"
label variable xf1b26 "Imputation field for f1b26 - Sales and services of educational activities"
label variable f1b26    "Sales and services of educational activities"
label variable xf1b07 "Imputation field for f1b07 - Independent operations"
label variable f1b07    "Independent operations"
label variable xf1b08 "Imputation field for f1b08 - Other sources - operating"
label variable f1b08    "Other sources - operating"
label variable xf1b09 "Imputation field for f1b09 - Total operating revenues"
label variable f1b09    "Total operating revenues"
label variable xf1b10 "Imputation field for f1b10 - Federal appropriations"
label variable f1b10    "Federal appropriations"
label variable xf1b11 "Imputation field for f1b11 - State appropriations"
label variable f1b11    "State appropriations"
label variable xf1b12 "Imputation field for f1b12 - Local appropriations, education district taxes, and similar support"
label variable f1b12    "Local appropriations, education district taxes, and similar support"
label variable xf1b13 "Imputation field for f1b13 - Federal nonoperating grants"
label variable f1b13    "Federal nonoperating grants"
label variable xf1b14 "Imputation field for f1b14 - State nonoperating grants"
label variable f1b14    "State nonoperating grants"
label variable xf1b15 "Imputation field for f1b15 - Local nonoperating grants"
label variable f1b15    "Local nonoperating grants"
label variable xf1b16 "Imputation field for f1b16 - Gifts, including contributions from affiliated organizations"
label variable f1b16    "Gifts, including contributions from affiliated organizations"
label variable xf1b17 "Imputation field for f1b17 - Investment income"
label variable f1b17    "Investment income"
label variable xf1b18 "Imputation field for f1b18 - Other nonoperating revenues"
label variable f1b18    "Other nonoperating revenues"
label variable xf1b19 "Imputation field for f1b19 - Total nonoperating revenues"
label variable f1b19    "Total nonoperating revenues"
label variable xf1b27 "Imputation field for f1b27 - Total operating and nonoperating revenues"
label variable f1b27    "Total operating and nonoperating revenues"
label variable xf1b20 "Imputation field for f1b20 - Capital appropriations"
label variable f1b20    "Capital appropriations"
label variable xf1b21 "Imputation field for f1b21 - Capital grants and gifts"
label variable f1b21    "Capital grants and gifts"
label variable xf1b22 "Imputation field for f1b22 - Additions to permanent endowments"
label variable f1b22    "Additions to permanent endowments"
label variable xf1b23 "Imputation field for f1b23 - Other revenues and additions"
label variable f1b23    "Other revenues and additions"
label variable xf1b24 "Imputation field for f1b24 - Total other revenues and additions"
label variable f1b24    "Total other revenues and additions"
label variable xf1b25 "Imputation field for f1b25 - Total all revenues and other additions"
label variable f1b25    "Total all revenues and other additions"
label variable xf1c011 "Imputation field for f1c011 - Instruction - Current year total"
label variable f1c011   "Instruction - Current year total"
label variable xf1c012 "Imputation field for f1c012 - Instruction - Salaries and wages"
label variable f1c012   "Instruction - Salaries and wages"
label variable xf1c021 "Imputation field for f1c021 - Research - Current year total"
label variable f1c021   "Research - Current year total"
label variable xf1c022 "Imputation field for f1c022 - Research - Salaries and wages"
label variable f1c022   "Research - Salaries and wages"
label variable xf1c031 "Imputation field for f1c031 - Public service - Current year total"
label variable f1c031   "Public service - Current year total"
label variable xf1c032 "Imputation field for f1c032 - Public service - Salaries and wages"
label variable f1c032   "Public service - Salaries and wages"
label variable xf1c051 "Imputation field for f1c051 - Academic support - Current year total"
label variable f1c051   "Academic support - Current year total"
label variable xf1c052 "Imputation field for f1c052 - Academic support - Salaries and wages"
label variable f1c052   "Academic support - Salaries and wages"
label variable xf1c061 "Imputation field for f1c061 - Student services - Current year total"
label variable f1c061   "Student services - Current year total"
label variable xf1c062 "Imputation field for f1c062 - Student services - Salaries and wages"
label variable f1c062   "Student services - Salaries and wages"
label variable xf1c071 "Imputation field for f1c071 - Institutional support - Current year total"
label variable f1c071   "Institutional support - Current year total"
label variable xf1c072 "Imputation field for f1c072 - Institutional support - Salaries and wages"
label variable f1c072   "Institutional support - Salaries and wages"
label variable xf1c101 "Imputation field for f1c101 - Scholarships and fellowships expenses -- Current year total"
label variable f1c101   "Scholarships and fellowships expenses -- Current year total"
label variable xf1c111 "Imputation field for f1c111 - Auxiliary enterprises -- Current year total"
label variable f1c111   "Auxiliary enterprises -- Current year total"
label variable xf1c112 "Imputation field for f1c112 - Auxiliary enterprises -- Salaries and wages"
label variable f1c112   "Auxiliary enterprises -- Salaries and wages"
label variable xf1c121 "Imputation field for f1c121 - Hospital services - Current year total"
label variable f1c121   "Hospital services - Current year total"
label variable xf1c122 "Imputation field for f1c122 - Hospital services - Salaries and wages"
label variable f1c122   "Hospital services - Salaries and wages"
label variable xf1c131 "Imputation field for f1c131 - Independent operations - Current year total"
label variable f1c131   "Independent operations - Current year total"
label variable xf1c132 "Imputation field for f1c132 - Independent operations - Salaries and wages"
label variable f1c132   "Independent operations - Salaries and wages"
label variable xf1c141 "Imputation field for f1c141 - Other expenses  deductions - Current year total"
label variable f1c141   "Other expenses  deductions - Current year total"
label variable xf1c142 "Imputation field for f1c142 - Other expenses  deductions - Salaries and wages"
label variable f1c142   "Other expenses  deductions - Salaries and wages"
label variable xf1c191 "Imputation field for f1c191 - Total expenses and deductions - Current year total"
label variable f1c191   "Total expenses and deductions - Current year total"
label variable xf1c192 "Imputation field for f1c192 - Total expenses  expenses and deductions - Salaries and wages"
label variable f1c192   "Total expenses  expenses and deductions - Salaries and wages"
label variable xf1c193 "Imputation field for f1c193 - Total expenses and deductions - Employee fringe benefits"
label variable f1c193   "Total expenses and deductions - Employee fringe benefits"
label variable xf1c19om "Imputation field for f1c19om - Total expenses and deductions - Operations and maintenance of plant"
label variable f1c19om  "Total expenses and deductions - Operations and maintenance of plant"
label variable xf1c19dp "Imputation field for f1c19dp - Total expenses  and deductions - Depreciation"
label variable f1c19dp  "Total expenses  and deductions - Depreciation"
label variable xf1c19in "Imputation field for f1c19in - Total expenses deductions - Interest"
label variable f1c19in  "Total expenses deductions - Interest"
label variable xf1c19ot "Imputation field for f1c19ot - Total expenses and deductions - Other Natural Expenses and Deductions"
label variable f1c19ot  "Total expenses and deductions - Other Natural Expenses and Deductions"
label variable f1mhp    "Pension information reported"
label variable xf1m01 "Imputation field for f1m01 - Pension expense"
label variable f1m01    "Pension expense"
label variable xf1m02 "Imputation field for f1m02 - Net pension liability"
label variable f1m02    "Net pension liability"
label variable xf1m03 "Imputation field for f1m03 - Deferred inflows of resources for pension"
label variable f1m03    "Deferred inflows of resources for pension"
label variable xf1m04 "Imputation field for f1m04 - Deferred outflows of resources for pension"
label variable f1m04    "Deferred outflows of resources for pension"
label variable xf1e01 "Imputation field for f1e01 - Pell grants (federal)"
label variable f1e01    "Pell grants (federal)"
label variable xf1e02 "Imputation field for f1e02 - Other federal grants"
label variable f1e02    "Other federal grants"
label variable xf1e03 "Imputation field for f1e03 - Grants by state government"
label variable f1e03    "Grants by state government"
label variable xf1e04 "Imputation field for f1e04 - Grants by local government"
label variable f1e04    "Grants by local government"
label variable xf1e05 "Imputation field for f1e05 - Institutional grants from restricted resources"
label variable f1e05    "Institutional grants from restricted resources"
label variable xf1e06 "Imputation field for f1e06 - Institutional grants from unrestricted resources"
label variable f1e06    "Institutional grants from unrestricted resources"
label variable xf1e07 "Imputation field for f1e07 - Total gross scholarships and fellowships"
label variable f1e07    "Total gross scholarships and fellowships"
label variable xf1e08 "Imputation field for f1e08 - Discounts and allowances applied to tuition and fees"
label variable f1e08    "Discounts and allowances applied to tuition and fees"
label variable xf1e09 "Imputation field for f1e09 - Discounts and allowances applied to sales & services of auxiliary enterprises"
label variable f1e09    "Discounts and allowances applied to sales & services of auxiliary enterprises"
label variable xf1e10 "Imputation field for f1e10 - Total discounts and allowances"
label variable f1e10    "Total discounts and allowances"
label variable xf1e11 "Imputation field for f1e11 - Net scholarships and fellowship expenses"
label variable f1e11    "Net scholarships and fellowship expenses"
label variable f1fha    "Does this institution or any of its foundations or other affiliated organizations own endowment assets ?"
label variable xf1h01 "Imputation field for f1h01 - Value of endowment assets at the beginning of the fiscal year"
label variable f1h01    "Value of endowment assets at the beginning of the fiscal year"
label variable xf1h02 "Imputation field for f1h02 - Value of endowment assets at the end of the fiscal year"
label variable f1h02    "Value of endowment assets at the end of the fiscal year"
label define label_f1mhp 1 "Yes -  additional (unfunded) pension information reported"
label define label_f1mhp 2 "No",add
label values f1mhp label_f1mhp
label define label_f1fha 1 "Yes - (report endowment assets)"
label define label_f1fha 2 "No",add
label define label_f1fha -2 "Not applicable",add
label values f1fha label_f1fha
*The following are the possible values for the item imputation field variables
*A Not applicable
*B Institution left item blank
*C Analyst corrected reported value
*D Do not know
*G Data generated from other data values
*H Value not derived - data not usable
*J Logical imputation
*K Ratio adjustment
*L Imputed using the Group Median procedure
*N Imputed using Nearest Neighbor procedure
*P Imputed using Carry Forward procedure
*R Reported
*Z Implied zero
tab xf1a01
tab xf1a31
tab xf1a04
tab xf1a05
tab xf1a06
tab xf1a19
tab xf1a07
tab xf1a08
tab xf1a09
tab xf1a10
tab xf1a11
tab xf1a12
tab xf1a13
tab xf1a20
tab xf1a14
tab xf1a15
tab xf1a16
tab xf1a17
tab xf1a18
tab xf1a214
tab xf1a224
tab xf1a234
tab xf1a324
tab xf1a274
tab xf1a27t4
tab xf1a284
tab xf1a334
tab xf1a344
tab xf1d01
tab xf1d02
tab xf1d03
tab xf1d04
tab xf1d05
tab xf1d06
tab xf1b01
tab xf1b02
tab xf1b03
tab xf1b04
tab xf1b04a
tab xf1b04b
tab xf1b05
tab xf1b06
tab xf1b26
tab xf1b07
tab xf1b08
tab xf1b09
tab xf1b10
tab xf1b11
tab xf1b12
tab xf1b13
tab xf1b14
tab xf1b15
tab xf1b16
tab xf1b17
tab xf1b18
tab xf1b19
tab xf1b27
tab xf1b20
tab xf1b21
tab xf1b22
tab xf1b23
tab xf1b24
tab xf1b25
tab xf1c011
tab xf1c012
tab xf1c021
tab xf1c022
tab xf1c031
tab xf1c032
tab xf1c051
tab xf1c052
tab xf1c061
tab xf1c062
tab xf1c071
tab xf1c072
tab xf1c101
tab xf1c111
tab xf1c112
tab xf1c121
tab xf1c122
tab xf1c131
tab xf1c132
tab xf1c141
tab xf1c142
tab xf1c191
tab xf1c192
tab xf1c193
tab xf1c19om
tab xf1c19dp
tab xf1c19in
tab xf1c19ot
tab f1mhp
tab xf1m01
tab xf1m02
tab xf1m03
tab xf1m04
tab xf1e01
tab xf1e02
tab xf1e03
tab xf1e04
tab xf1e05
tab xf1e06
tab xf1e07
tab xf1e08
tab xf1e09
tab xf1e10
tab xf1e11
tab f1fha
tab xf1h01
tab xf1h02
summarize f1a01
summarize f1a31
summarize f1a04
summarize f1a05
summarize f1a06
summarize f1a19
summarize f1a07
summarize f1a08
summarize f1a09
summarize f1a10
summarize f1a11
summarize f1a12
summarize f1a13
summarize f1a20
summarize f1a14
summarize f1a15
summarize f1a16
summarize f1a17
summarize f1a18
summarize f1a214
summarize f1a224
summarize f1a234
summarize f1a324
summarize f1a274
summarize f1a27t4
summarize f1a284
summarize f1a334
summarize f1a344
summarize f1d01
summarize f1d02
summarize f1d03
summarize f1d04
summarize f1d05
summarize f1d06
summarize f1b01
summarize f1b02
summarize f1b03
summarize f1b04
summarize f1b04a
summarize f1b04b
summarize f1b05
summarize f1b06
summarize f1b26
summarize f1b07
summarize f1b08
summarize f1b09
summarize f1b10
summarize f1b11
summarize f1b12
summarize f1b13
summarize f1b14
summarize f1b15
summarize f1b16
summarize f1b17
summarize f1b18
summarize f1b19
summarize f1b27
summarize f1b20
summarize f1b21
summarize f1b22
summarize f1b23
summarize f1b24
summarize f1b25
summarize f1c011
summarize f1c012
summarize f1c021
summarize f1c022
summarize f1c031
summarize f1c032
summarize f1c051
summarize f1c052
summarize f1c061
summarize f1c062
summarize f1c071
summarize f1c072
summarize f1c101
summarize f1c111
summarize f1c112
summarize f1c121
summarize f1c122
summarize f1c131
summarize f1c132
summarize f1c141
summarize f1c142
summarize f1c191
summarize f1c192
summarize f1c193
summarize f1c19om
summarize f1c19dp
summarize f1c19in
summarize f1c19ot
summarize f1m01
summarize f1m02
summarize f1m03
summarize f1m04
summarize f1e01
summarize f1e02
summarize f1e03
summarize f1e04
summarize f1e05
summarize f1e06
summarize f1e07
summarize f1e08
summarize f1e09
summarize f1e10
summarize f1e11
summarize f1h01
summarize f1h02


keep unitid f1d0* f1c191
rename f1d01 revenue
rename f1d02 costs
gen year=2016

 save publicrevenues2016.dta, replace
