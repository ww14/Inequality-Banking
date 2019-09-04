set type double
* cd to folder with data
cd "E:/inequality/hhmultiyear"

*import multiyear file
import delimited using hh_multiyear_analys.csv, clear
save multiyear, replace

*import single year repwgt file
import delimited using "single_yr_rep.csv", clear
save "E:/inequality/hhmultiyear/single_yr_rep.dta", replace

*merge single year replicate weights for each year of data in multiyear file
use multiyear, clear
merge 1:1 hryear4 qstnum  using "E:/inequality/hhmultiyear/single_yr_rep.dta"


* if you want 5 year weights to do weighted averages over time
*import 5 year replicate weights instead see example below
*import delimited using "hhrep13_17.csv", clear
*save "../hhrep13_17.dta", replace


**merge to 2013-2017 5 year estimates
*use multiyear, clear
*keep if hryear4 >= 2013 & hryear4 <= 2017
*merge 1:1 hryear4 qstnum  using "../hhrep13_17.dta"

