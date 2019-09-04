
clear all 
set more off

cd "E:\inequality\hhmultiyear\"
ssc install lorenz
set matsize 10000

/*
**************************************Create the Data*************************** 
import delim "cps_00001"

*drop years not of interest
drop if year==2008| year==2010| year==2012| year==2014| year==2016| year==2016| year==2018| year==2019

*Clean the data 
sort year
*looks like 2009 is missing a lot of data, cannot use. 
by year: count if missing(hhincome)
drop if year==2009


**Generate New Variables 
forvalues fee=1(1)10{
	gen fee`fee'=`fee'
}

**CHECK CASHING STORY 
*Can do CC contrast for 2011, 2013, 2015 and 2017 
foreach var of varlist fee1 fee2 fee3 fee4 fee5 fee6 fee7 fee8 fee9 fee10 {
gen hhincome_without_`var'=.
replace hhincome_without_`var'= (.1087)*hhincome/(1-(`var'/100))+(1-.1087)*hhincome if hhincome<15000 & year==2017
replace hhincome_without_`var'= (.1061)*hhincome/(1-(`var'/100))+(1-.1061)*hhincome if hhincome>15000 & hhincome<30000 & year==2017
replace hhincome_without_`var'= (.0697)*hhincome/(1-(`var'/100))+(1-.0697)*hhincome if hhincome>30000 & hhincome<50000	& year==2017
replace hhincome_without_`var'= (.0483)*hhincome/(1-(`var'/100))+(1-.0483)*hhincome if hhincome>50000 & hhincome<75000	& year==2017
replace hhincome_without_`var'= (.0304)*hhincome/(1-(`var'/100))+(1-.0304)*hhincome if hhincome>75000 & year==2017

replace hhincome_without_`var'= (.1317)*hhincome/(1-(`var'/100))+(1-.1317)*hhincome if hhincome<15000 & year==2015
replace hhincome_without_`var'= (.0993)*hhincome/(1-(`var'/100))+(1-.0993)*hhincome if hhincome>15000 & hhincome<30000 & year==2015
replace hhincome_without_`var'= (.0708)*hhincome/(1-(`var'/100))+(1-.0708)*hhincome if hhincome>30000 & hhincome<50000	& year==2015
replace hhincome_without_`var'= (.0505)*hhincome/(1-(`var'/100))+(1-.0505)*hhincome if hhincome>50000 & hhincome<75000	& year==2015
replace hhincome_without_`var'= (.0314)*hhincome/(1-(`var'/100))+(1-.0314)*hhincome if hhincome>75000 & year==2015

replace hhincome_without_`var'= (.1479)*hhincome/(1-(`var'/100))+(1-.1479)*hhincome if hhincome<15000 & year==2013
replace hhincome_without_`var'= (.1056)*hhincome/(1-(`var'/100))+(1-.1056)*hhincome if hhincome>15000 & hhincome<30000 & year==2013
replace hhincome_without_`var'= (.0688)*hhincome/(1-(`var'/100))+(1-.0688)*hhincome if hhincome>30000 & hhincome<50000	& year==2013
replace hhincome_without_`var'= (.0404)*hhincome/(1-(`var'/100))+(1-.0404)*hhincome if hhincome>50000 & hhincome<75000	& year==2013
replace hhincome_without_`var'= (.0222)*hhincome/(1-(`var'/100))+(1-.0222)*hhincome if hhincome>75000 & year==2013

replace hhincome_without_`var'= (.1559)*hhincome/(1-(`var'/100))+(1-.1559)*hhincome if hhincome<15000 & year==2011
replace hhincome_without_`var'= (.1161)*hhincome/(1-(`var'/100))+(1-.1161)*hhincome if hhincome>15000 & hhincome<30000 & year==2011
replace hhincome_without_`var'= (.0781)*hhincome/(1-(`var'/100))+(1-.0781)*hhincome if hhincome>30000 & hhincome<50000	& year==2011
replace hhincome_without_`var'= (.048)*hhincome/(1-(`var'/100))+(1-.048)*hhincome   if hhincome>50000 & hhincome<75000	& year==2011
replace hhincome_without_`var'= (.028)*hhincome/(1-(`var'/100))+(1-.028)*hhincome   if hhincome>75000 & year==2011
}

**ALL AFS STORY
*Can look at 2013, 2015 and 2017, assume generously that those 3+ are all at 12 AFS a year. Also generous assumption that pay is given monthly
foreach var of varlist fee1 fee2 fee3 fee4 fee5 fee6 fee7 fee8 fee9 fee10 {
gen hhincome_without_afs`var'=.

replace hhincome_without_afs`var'= ((.2483/12)+(.1107/6)+.0536)*hhincome/(1-(`var'/100))+(1-((.2483/12)+(.1107/6)+.0536))*hhincome if hhincome<15000 & year==2013
replace hhincome_without_afs`var'= ((.2113/12)+(.086/6)+.0502)*hhincome/(1-(`var'/100)) +(1-((.2113/12)+(.086/6)+.0502)) *hhincome if hhincome>15000 & hhincome<30000 & year==2013
replace hhincome_without_afs`var'= ((.1853/12)+(.065/6)+.0286)*hhincome/(1-(`var'/100)) +(1-((.1853/12)+(.065/6)+.0286)) *hhincome if hhincome>30000 & hhincome<50000 & year==2013
replace hhincome_without_afs`var'= ((.1632/12)+(.0391/6)+.0145)*hhincome/(1-(`var'/100))+(1-((.1632/12)+(.0391/6)+.0145))*hhincome if hhincome>50000 & hhincome<75000 & year==2013
replace hhincome_without_afs`var'= ((.1155/12)+(.0216/6)+.0056)*hhincome/(1-(`var'/100))+(1-((.1155/12)+(.0216/6)+.0056))*hhincome if hhincome>75000 & year==2013

replace hhincome_without_afs`var'= ((.2607/12)+(.1043/6)+.0474)*hhincome/(1-(`var'/100))+(1-((.2607/12)+(.1043/6)+.0474))*hhincome if hhincome<15000 & year==2015
replace hhincome_without_afs`var'= ((.2501/12)+(.0814/6)+.0423)*hhincome/(1-(`var'/100))+(1-((.2501/12)+(.0814/6)+.0423))*hhincome if hhincome>15000 & hhincome<30000 & year==2015
replace hhincome_without_afs`var'= ((.1829/12)+(.066/6)+.0296)*hhincome/(1-(`var'/100)) +(1-((.1829/12)+(.066/6)+.0296)) *hhincome if hhincome>30000 & hhincome<50000 & year==2015
replace hhincome_without_afs`var'= ((.1592/12)+(.0464/6)+.0145)*hhincome/(1-(`var'/100))+(1-((.1592/12)+(.0464/6)+.0145))*hhincome if hhincome>50000 & hhincome<75000 & year==2015
replace hhincome_without_afs`var'= ((.1144/12)+(.0202/6)+.0058)*hhincome/(1-(`var'/100))+(1-((.1144/12)+(.0202/6)+.0058))*hhincome if hhincome>75000 & year==2015

replace hhincome_without_afs`var'= ((.2262/12)+(.0919/6)+.0328)*hhincome/(1-(`var'/100))+(1-((.2262/12)+(.0919/6)+.0328))*hhincome if hhincome<15000 & year==2017
replace hhincome_without_afs`var'= ((.1968/12)+(.0825/6)+.0388)*hhincome/(1-(`var'/100))+(1-((.1968/12)+(.0825/6)+.0388))*hhincome if hhincome>15000 & hhincome<30000 & year==2017
replace hhincome_without_afs`var'= ((.1795/12)+(.0657/6)+.0293)*hhincome/(1-(`var'/100))+(1-((.1795/12)+(.0657/6)+.0293))*hhincome if hhincome>30000 & hhincome<50000 & year==2017
replace hhincome_without_afs`var'= ((.1666/12)+(.0384/6)+.012)*hhincome/(1-(`var'/100)) +(1-((.1666/12)+(.0384/6)+.012)) *hhincome if hhincome>50000 & hhincome<75000 & year==2017
replace hhincome_without_afs`var'= ((.1168/12)+(.0218/6)+.004)*hhincome/(1-(`var'/100)) +(1-((.1168/12)+(.0218/6)+.004)) *hhincome if hhincome>75000 & year==2017
}

*Extreme Case-- 100% AF for those below $30K and 0 for those over 
foreach var of varlist fee1 fee2 fee3 fee4 fee5 fee6 fee7 fee8 fee9 fee10 {
gen hhincome_extreme`var'=.
replace hhincome_extreme`var'= hhincome/(1-(`var'/100)) if hhincome<30000 & year==2011
replace hhincome_extreme`var'= hhincome if hhincome>30000 & year==2011

replace hhincome_extreme`var'= hhincome/(1-(`var'/100)) if hhincome<30000 & year==2013
replace hhincome_extreme`var'= hhincome if hhincome>30000 & year==2013

replace hhincome_extreme`var'= hhincome/(1-(`var'/100)) if hhincome<30000 & year==2015
replace hhincome_extreme`var'= hhincome if hhincome>30000 & year==2015

replace hhincome_extreme`var'= hhincome/(1-(`var'/100)) if hhincome<30000 & year==2017
replace hhincome_extreme`var'= hhincome if hhincome>30000 & year==2017
}

*Opportunity cost of time for depositing a check 
gen hhincome_nolosttime=.
replace hhincome_nolosttime= (.8094*.2405)*hhincome/(1-(.025))+(1-.8094*.2405)*hhincome if hhincome<15000 & year==2017
replace hhincome_nolosttime= (.8463*.2837)*hhincome/(1-(.025))+(1-.8463*.2837)*hhincome if hhincome>15000 & hhincome<30000 & year==2017
replace hhincome_nolosttime= (.7824*.2825)*hhincome/(1-(.025))+(1-.7824*.2825)*hhincome if hhincome>30000 & hhincome<50000	& year==2017
replace hhincome_nolosttime= (.7583*.2719)*hhincome/(1-(.025))+(1-.7583*.2719)*hhincome if hhincome>50000 & hhincome<75000	& year==2017
replace hhincome_nolosttime= (.6662*.2775)*hhincome/(1-(.025))+(1-.6662*.2775)*hhincome if hhincome>75000 & year==2017


save "E:\inequality\hhmultiyear\cps_lorenz.dta", replace
*/

use "E:\inequality\hhmultiyear\cps_lorenz.dta"


***************************INSPECT DATA*****************************************
*not too many negative income homes (less than a hundred each year unweighted), many zero income homes 
by year: count if hhincome<0
by year: count if hhincome==0
by year: count if hhincome>0 & hhincome<1 

sum hhincome [aw=asecwth] if year==2011, detail
sum hhincome if year==2011, detail

*Lorenz Curve
lorenz estimate hhincome [pw=asecwth], over(year) nquantiles(100) gini
lorenz graph, aspectratio(1) ytitle("HH Income Share") xtitle("Population Share") ///
	title("Lorenz Curve") legend(order(1 "Perfect Equality" 2 "Lorenz Curve")) ///
	xlabel(, grid) lcolor("22 150 210") noci 

	
*************************TEST DATA**********************************************	
*LET'S SEE WHAT KIND OF EFFECT CC FEES COULD HAVE
lorenz estimate hhincome hhincome_without_fee* if year==2017 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_without_fee* if year==2015 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_without_fee* if year==2013 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_without_fee* if year==2011 [pw=asecwth], gini nquantiles(100)

*Now look at the Gini after eliminiating all AFS fees
lorenz estimate hhincome hhincome_without_afs* if year==2013 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_without_afs* if year==2015 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_without_afs* if year==2017 [pw=asecwth], gini nquantiles(100)

*Extreme Case 
lorenz estimate hhincome hhincome_extreme* if year==2011 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_extreme* if year==2013 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_extreme* if year==2015 [pw=asecwth], gini nquantiles(100)
lorenz estimate hhincome hhincome_extreme* if year==2017 [pw=asecwth], gini nquantiles(100)


*Opportunity Cost of Time for Depositing a Check
lorenz estimate hhincome hhincome_nolosttime if year==2017 [pw=asecwth], gini nquantiles(100)
