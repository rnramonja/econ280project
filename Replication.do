/* Assignment 4
Riana (Rin)
*/ 
clear all
cd "C:\Users\riana\OneDrive - UC San Diego\2024 Fall\ECON 280 Computation\Assignemennt\4"
local dataclean "C:\Users\riana\OneDrive - UC San Diego\2024 Fall\ECON 280 Computation\Assignemennt\4\Data"
local output "C:\Users\riana\OneDrive - UC San Diego\2024 Fall\ECON 280 Computation\Assignemennt\4\Output"


use "`dataclean'/Visit123_clean_replication_noPII.dta", clear
	
drop b_educ* 
	
merge 1:1 respondent_id  using "`dataclean'/Visit123_analysis_replication_noPII.dta"
	
	
g educ_primcomplete = (b_educ >= 39) if !missing(b_educ) & b_educ!=96 & b_educ!=97
g educ_somesec = (b_educ > 39) if !missing(b_educ) & b_educ!=96 & b_educ!=97
g educ_seccomplete = (b_educ >= 44) if !missing(b_educ) & b_educ!=96 & b_educ!=97
	

encode pracTIOLIitem, g(item)

keep if Visit2==1

keep b_incomeself_* d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years v1_beliefs_annual_mean v1_beliefs_annual_sd prac_finwtp item finwtp_USD treatc_pooled treata_pooled t_benefits t_benefits_C t_costs t_costs_C PB CreditXPB  CreditXPBXcosts a1 educ* b_educ

//save "`dataclean'\replication", replace

local c = "USD"

* Replace missings (to maintain sample size when including controls in regression):
foreach var of varlist b_incomeself_* {
su `var', detail
replace `var' = `r(mean)' if missing(`var')
}


local CONTROLS = "d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years v1_beliefs_annual_mean v1_beliefs_annual_sd prac_finwtp item" 



// Mean test
ttest finwtp_USD, by(educ_primcomplete)
ttest finwtp_USD, by(educ_somesec)
ttest finwtp_USD, by(educ_seccomplete)

gen interaction=treatc_pooled*educ_primcomplete
gen interaction2=treatc_pooled*educ_somesec
gen interaction3=treatc_pooled*educ_seccomplete


label var treatc_pooled "Credit"
label var educ_primcomplete "Completed primary"
label var educ_somesec "Some secondary"
label var educ_seccomplete "Completed secondary"
label var interaction "Completed primary x credit"
label var interaction2 "Some secondary x credit"
label var interaction3 "Completed secondary x credit"

eststo clear

* FULL SAMPLE (1)
eststo caFI: reg finwtp_`c' treatc_pooled t_benefits t_costs  `CONTROLS' 
sum  finwtp_`c' treatc_pooled t_benefits t_costs `CONTROLS'

estadd local sample "Full"
su finwtp_`c' if treatc_pooled==0 & treata_pooled==0
estadd scalar cmean = r(mean)
di e(cmean)


* Regression (2)
eststo caFIprim: reg finwtp_`c' treatc_pooled t_benefits t_costs educ_primcomplete interaction `CONTROLS' 
sum  finwtp_`c' treatc_pooled t_benefits t_costs `CONTROLS'

estadd local sample "Full"
su finwtp_`c' if treatc_pooled==0 & treata_pooled==0
estadd scalar cmean = r(mean)
di e(cmean)


* Regression (3)
eststo caFIsec: reg finwtp_`c' treatc_pooled t_benefits t_costs educ_somesec interaction2 `CONTROLS' 
sum  finwtp_`c' treatc_pooled t_benefits t_costs `CONTROLS'

estadd local sample "Full"
su finwtp_`c' if treatc_pooled==0 & treata_pooled==0
estadd scalar cmean = r(mean)
di e(cmean)


* Regression (4)
eststo caFIsecc: reg finwtp_`c' treatc_pooled t_benefits t_costs educ_seccomplete interaction3 `CONTROLS' 

sum  finwtp_`c' treatc_pooled t_benefits t_costs `CONTROLS'

estadd local sample "Full"
su finwtp_`c' if treatc_pooled==0 & treata_pooled==0
estadd scalar cmean = r(mean)
di e(cmean)



esttab caFI caFIprim caFIsec caFIsecc using "`output'/Stata_replication_table5.rtf", replace label keep(treatc_pooled t_benefits t_costs educ_primcomplete educ_somesec educ_seccomplete interaction*) se(2) b(2) scalars("cmean Control Mean" "sample Sample") nomtitles obs num 

esttab caFI caFIprim caFIsec caFIsecc  using "`output'/Stata_replication_table5.tex", replace label keep(treatc_pooled t_benefits t_costs educ_primcomplete educ_somesec educ_seccomplete interaction*) se(2) b(2) scalars("cmean Control Mean" "sample Sample") nomtitles obs num



