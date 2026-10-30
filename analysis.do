
*••••••••••••••••••••••••••••••••••••**••••••••••••••••••••••••••••*
*ANALYSIS OF Violence and HH Welfare in Afghanistan 					   
*Author: Habib Gul Ahmadzai (School of Economics, AUCA)                   
*Date: 15 April 2024
*•••••••••••••••••••••••••••••••••••••••••••••••••••••**••••••••••••••••••••••••••••••••••••••*
capture log close
local date: display %tdCCYYNNDD date(c(current_date),"DMY")
log using analysis_hh_welfare.log, replace	     					  

* Required user-written packages (install once):
*   ssc install asdoc
*   ssc install winsor2

*SET DIRECTORY FOR THE OUTPUT 
clear 
set more off
* Set this to the folder that holds the ALCS data file and where outputs are saved
cd "PATH/TO/YOUR/PROJECT/FOLDER"

use alcsucdp111316_cd22, clear 

*•••••••••••••••••••••••••••••••••••••*
*Section I: Defining variables and sumamry stats
******************••********************

egen region2=group(region_central region_eastern region_southern      ///
region_soutwestern region_western region_northern region_northeastern ///
region_westcentral)

label define reglab 1 "West Central"  2 "Northeastern"  3 "Northern"  ///
4 "Western"  5 "South Western" 6 "Southern" 7 "Eastern"  8 "Central"
label values region2 reglab 

label define violab 0 "Violence=0" 1 "Violence=1"
label values violence violab 

tab region2, gen(region2_)
tab residecode, gen(residcode_)
tab wave, gen(wave_)

*********Cheicking for outliers in the dependent variables
graph box total_income
graph box total_expenditures

winsor2 total_expenditures, cuts(0.25 99.75) trim  suffix(_tr) by(wave)
winsor2 total_income, cuts(0.25 99.75) trim  suffix(_tr) by(wave)
label var total_income_tr "Total Income (AFN)"
label var total_expenditures_tr "Total Expenditures (AFN)"

gen ltotal_income2=ln(total_income_tr+1)
gen ltotal_exp2= ln(total_expenditures_tr+1)

********drop missing values in X and Y vars 

global xyvars total_income_tr total_expenditures_tr violence headedu headage ///
hh_size hh_head_sex head_emp depratio opcltdist region2 residcode wave

misstable summarize $xyvars 
 
foreach var in $xyvars {
    drop if missing(`var')
}
*Note that after dropping the missing values, the estimation sample is 60,479 HHs

********Table 1: Summary statistics 

global xyvars total_income_tr total_expenditures_tr violence headedu headage ///
hh_size hh_head_sex head_emp depratio opcltdist region2_* residcode_* wave_*

su $yvars $xvars

*summary statas pooled sample 
asdoc su $xyvars, title(summary statitics -pooles sample) save(sumstats.doc) replace 

*summary stats by wave 
asdoc bys wave: tabstat $xyvars, statistics(mean sd min max) c(s) f(%6.3f) ///
save(sumstats.doc) append 
 
* Table 2: Tabulation of violence 
asdoc tab violence, save(sumstats.doc) append 
asdoc tab  wave violence, row save(sumstats.doc) append 

*Table 3: HH welfer by violence 
asdoc bys violence: tabstat total_income_tr total_expenditures, ///
statistics(mean N) c(s) f(%6.3f) save(sumstats.doc) append 
*••••••••••••••••••••••••••••••••••••*
*Section I: OLS regression analysis 
******************••********************

global xvars violence headedu headage i.head_emp hh_size i.hh_head_sex ///
depratio opcltdist i.residecode i.region2 i.wave

*Tables 4 and 5: regression results
*Basic regression (orgional variables, with no outliers removed)
reg ltotal_income $xvars 
reg ltotal_expenditures $xvars

* Alternative regressions, with outliers removed and robust standard errors  
asdoc reg ltotal_income2 $xvars, r save(reg_results.doc) replace ///
title(Linear Regression Using Total Household Income as Dependent Variable)
asdoc reg ltotal_exp2 $xvars, r save(reg_results.doc) append ///
title(Linear Regression Using Total Household Consumption Expenditures as Dependent Variable)

*••••••••••••••••••••••••••••••••••••••*
*Section I: Postestimation graphs 
******************••********************

*Figures 1 and 2:  Bar Graph of Average Total Income by Violence and Graph of Average Total Expenditure by Violence

graph bar (mean) total_income_tr, over(violence) ytitle(Total Income (mean)) ///
bar(1, fcolor()) name(incvio, replace) 
graph bar (mean) total_expenditures_tr, over(violence) ytitle(Total Expenditures (mean)) ///
bar(1, fcolor(maroon)) name(expvio, replace)
graph combine incvio expvio, xsize(5)
graph export welfbyvio.png, replace 

*Figure 3. Average Total Income and Expneidutures by Years of Education or or Schooling
graph bar (mean) total_income_tr, over(headedu) ytitle(Total Income (mean)) ///
bar(1, fcolor(gs8)) name(incbyedu, replace)
graph bar (mean) total_expenditures_tr, over(headedu) ytitle(Total Exppenditures (mean)) ///
bar(1, fcolor(maroon%75)) name(expbyedu, replace)
graph combine incbyedu expbyedu, xsize(8) title(HH Income and Expenditures by Head Education (years))
graph export welfbyedu.png, replace 

*Figure 4 and 5: Comparison of Total Household Income and expenditures by Head of Household's Sex
graph bar (mean) total_income_tr, over(hh_head_sex) ytitle(Total Income (mean)) ///
bar(1, fcolor(gs8)) name(incbysex, replace)
graph bar (mean) total_expenditures_tr, over(hh_head_sex) ytitle(Total Exppenditures (mean)) ///
bar(1, fcolor(maroon%75)) name(expbysex, replace)
graph combine incbysex expbysex , xsize(5)
graph export welfbysex.png, replace 

*Figure 6. Distribution of Average Total Income and Average Total Expenditures by Region
graph hbar total_income_tr, over(region2) name(increg, replace) title(Total Income (AFN))
graph hbar total_expenditures_tr, over(region2) name(expreg, replace) ///
title(Total Expenditures (AFN)) bar(1, fcolor(maroon))
gr combine increg expreg, xsize(7) 
graph export welfregion.png, replace 

*Figure 7. Average Level of Violence by Region
graph bar violence, over(region2) xsize(7) ytitle (violence and inserurity (mean))
graph export vioreg.png, replace 

*Figure 8 and 9: Violence Distribution by Resident Areas and Total Income and Total Expenditures by Resident Areas
graph bar violence, over(residcode) name(incresid, replace) ytitle(Violence (mean)) title(Violence by Residential Code)
graph bar total_income_tr total_expenditures_tr, over(residcode) name(incexpresid, replace ) legend(order(1 "Total Income (mean)" 2 "Total Expenditures (mean)")) legend(pos(6)) legend(rows(1)) title (Avg. Welfare by Residential Code)
graph combine incresid incexpresid, xsize(6)
graph export vio_welf_resid.png, replace 

*Figure 8: HH income and expenditures by wave 
graph bar total_income_tr, over(wave) name(incwave, replace) ///
title(Total Income (AFN)) ytitle(Total Income (mean))
graph bar total_expenditures_tr, over(wave) name(expwave, replace ) ///
title(Total Consumption (AFN)) bar(1, fcolor(maroon)) ytitle(Total Expenditures (mean))
gr combine incwave expwave, xsize(7) ysize(6)
graph export welfwave.png, replace 
