* drmacros.do
* April 14, 2011
*
* Creates several global macro variables and macro program "caldr" for translating coefficient
* estimates into a "displacement rate": the number of non-Hispanics households with school-aged
* kids who leave for each household arriving with a low-English Hispanic arrival in the public.
* school.  This version skips the calculation at the "child" level.
*
* Also adds: explicitly shows marginal effect for log odds specification


* Macro variables for displacement calculations that are independent of sample:
* Approximate SD or mean increase in Low-English Hispanic share (arhisesl_sdf)
global dx 0.1

* Stats needed for household displacement rate calculations. 
* phi = the fraction of adults (20-49) in hhlds with kids
global phi = .5467349  /* calc in HHmixCA2k.do, 2000 PUMS */

* Number of low-English Hispanic kids in public schools in families that have them
global kids_hh_lehp = 1.628895 /* calc in HHmixCA2k.do, 2000 PUMS */

* moment at which the evaluation is done (mean)
global moment "mean"



cap program drop caldr
program define caldr
/* calculates displacement rate, given coefficient estimate
   ARGUMENTS
   1: where regression coefficient is stored (estimates restore `1')
   2: path and dataset
   3: subsetting if statement (optional)
   4: weighting command, including brackets (optional)

   outputs: $hhdr1 = household disp rate; $mgeff - marginal effect (log odds only)

*/
   local est "`1'"
   local data "`2'"
   local if "`3'"
   local wt "`4'"


   * need a few other stats from the data to do the calculations
   * data
   use "`data'", clear

   * Initial average share of district's non-Hispanic kids in the metro area
   qui summ sch1ageshindnh1970 `if' `wt', d
   global y0 = r($moment) 
   di "Init Shr of MSA's Non-Hisps: $y0"

   * Initial mean total enrollment...
   qui summ arDm_tot2_good1976 `if' `wt', d
   global enr0=r($moment)
   di "Init Tot Enr: $enr0"

   * Initial number of low-English Hispanic
   qui summ arDm_his_esl1976 `if' `wt', d
   global hisesl0=r($moment)
   di "Init LEH Enr: $hisesl0"

   * The initial mean #of non-Hispanics households
   qui summ hhkidsnh `if' `wt', d 
   global nhhh0 = r($moment)
   di "Init #nh hhlds w/kids: $nhhh0"



   * We need the coefficient on arhisesl_sdf from the regression
   estimates restore `est'
   global coef = _b[arhisesl_sdf]
   global mgeff = 0 /* default value if mg eff not calculated */
   local depvar = e(depvar)


   * DISPLACEMENT RATE CALCULATION:
   /* Step 1: Translate the estimated effect into (intial) share of district's
      non-Hispanics "lost," which is the same as the share of non-Hispanic HOUSEHOLDS
      with kids lost.  Also, divide coefficient by 1-share of non-Hispanic households
      who have kids ("phi"), to adjust for the fact that the comparison group is
      partially treated. */
   if "`depvar'" == "sch1ageshindnh_df2" {
     local shreff = $coef * $dx / (1-$phi) / $y0
   }
   else if "`depvar'"=="lnodds1nh_df2" {
     * first get marginal effect:
     global mgeff = $coef * $y0 * (1-$y0) 
     di "Marginal Effect: $mgeff"

     local shreff = $mgeff * $dx / (1-$phi) / $y0
   }
   else if "`depvar'"=="lngrth1nh_df2" {
     local shreff = $coef * $dx / (1-$phi) 
   }
   else if "`depvar'"=="shsch1nh_df" {
     * Given that that $phi fractio of adults have kids, and that the average hhld has ///
       2 adults and 2 kids, this implies that there are the following #of 0-19 and 0-49 ///
       year olds (which may be different than the actual mean):
     global nhpop0 = 2*$nhhh0 
     global totnhpop0 = 4*$nhhh0 + (1-$phi)/$phi * 2*$nhhh0

     * which translates the to the following share kids before and after the arrival of LEH kids ///
       according to the regression coefficient:
     global shr0 = $nhpop0 / $totnhpop0
     global shr1 = $shr0 + $coef * $dx

     * for the share kids to change by this amount (through the loss of households with
     * kids, that is) requires the # of kids to change by:
     * ($shr1 * $totnhpop0 - $nhpop0) / (1 - 2*$shr1),
     * or the number of households with kids by half that (again, assuming 2 kids/adults
     * lost per hhld). As a fraction of the initial number of households, that's:
     local shreff = ($shr1 * $totnhpop0 - $nhpop0) / (1 - 2*$shr1) / 2 / $nhhh0 
   }

   /* Step 2: get #of low-English Hispanic kids need to add to raise share by $dx
      This is very close to enrollment * dx, but you have to adjust for the fact 
      that adding low-English hispanics raises both the numerator AND denominator. */
   local adj = 1 - $dx - $hisesl0/$enr0  /* this is the adjustment factor */
   local leh_added = $dx * $enr0 / `adj' 

   /* Step 3: Household displacement rates:
      1. Multiply the share of households lost by the number of households in the typical district
      2. Divide the number of LEH kids added by LEH kids per household
      3. Divide the first number by the second to get the displacement rate
   */
   global hhdr1 = -(`shreff'*$nhhh0 ) /(`leh_added' / $kids_hh_lehp )
   di "Disp of $hhdr1 Non-Hisp HHlds for each LEH-containing hhld"

end
