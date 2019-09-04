********WWS582b Banking Paper *********
* Spring 2019			      *
* Author: William Willoughby          *
* Email: william.willoughby@gmail.com *
***************************************

clear all

set type double
set more off
ssc install outreg2


cd "E:/inequality/hhmultiyear"
*cd "D:/inequality/hhmultiyear"

/*create dataset
do "E:/inequality/hhmultiyear/sample_read_programs/read_stata_multiyear"
svyset qstnum [pw=hhsupwgt]
save weighted_multiyear
*/

use  weighted_multiyear.dta


*To see labels and code #
*label list `var'
/*
*Add numberic labels for ease
foreach var of varlist gereg-qstnum{
tab `var'
numlabel, add
}
foreach var of varlist huseccrsnv2 huseccrsn {
 label list `var'
}
for some reason you cannot just list unbanking status, idk why*/

*****************************Create Dummy Variables****************************
/*Outcome variable, banking status
gen banked=.
replace banked=0 if hbankstatv2==1 | hbankstat==1
replace banked=1 if hbankstatv2==2 | hbankstat==2
replace banked=2 if hbankstatv2==3 | hbankstat==3
label define banked 0 "Unbanked" 1 "Underbanked" 2 "Banked"
label values banked banked
label variable banked "What is your banking status?"


*Race Dummy
gen poc=.
replace poc=1 if praceeth!=6
replace poc=0 if praceeth==6

*Education Dummy, HS degree or less=0, More than HS degree=1
gen college=.
replace college=0 if peducgrp<=2
replace college=1 if peduc>=3

*Age dummy, =1 if <34 and, =0 if 35+ --> this one is not helpful
gen young=.
replace young=0 if pagegrp>=3
replace young=1 if pagegrp<=2
*continous age is prtage

*Home owner dummy
gen home=.
replace home=0 if hhtenure==2
replace home=1 if hhtenure==1

*Internet Dummy 
gen internet=.
replace internet=0 if hintacc==2
replace internet=0 if hintaccv2==2
replace internet=0 if hintacc==1
replace internet=0 if hintaccv2==1

*Income Volatility Dummy; only for 2015 and 2017
gen incomevolatility=.
replace incomevolatility=0 if hincvol==1
replace incomevolatility=1 if hincvol==2
replace incomevolatility=1 if hincvol==3

*Citizenship dummy
gen citizen=.
replace citizen=1 if pnativ==1
replace citizen=0 if pnativ==2
replace citizen=0 if pnativ==3

*Single parent family household dummy
gen singleparent=.
replace singleparent=0 if hhtype<2 
replace singleparent=0 if hhtype>3
replace singleparent=1 if hhtype==2 |hhtype==3

*Disability dummy
gen disabled=.
replace disabled=1 if pdisabl_age25to64==1
replace disabled=0 if pdisabl_age25to64==2

*Typical Income Type
foreach var of varlist htypincchkmo htypincddbnk htypincddpp htypinccash htypincoth htypinccc htypincnone htypincbnka htypincbnko {
 gen income_`var'=.
 replace income_`var'=1 if `var'==1
 replace income_`var'=0 if `var'==2
}
label variable income_htypincchkmo "Paper check or money order" 
label variable  income_htypincddbnk "Direct deposit or electronic transfer into bank account" 
label variable income_htypincddpp "Direct deposit or electronic transfer onto prepaid card" 
label variable income_htypinccash "Cash" 
label variable  income_htypincoth "Other" 
label variable income_htypinccc "Used nonbank check casher" 
label variable  income_htypincnone "None selected" 
label variable income_htypincbnka "Any bank method" 
label variable  income_htypincbnko "Only bank methods"

local controls poc college young home citizen singleparent disabled

*Note, to to twoway group comparison of outcome measure use, 
*svy: tab x y, tab(outcomevar)
*/
*------------------------------------------------------------------------------*
*Unbanked
svy: tab hhincome hunbnk if hryear==2017
svy: tab hhincome hunbnk if hryear==2017, row
*svy: tab hhincome hunbnk, count
*Both
svy: tab hhincome hbankstatv2 if hryear==2017
svy: tab hhincome hbankstatv2 if hryear==2017, row

*generally the trend on banking status is improving if not flat
svy: tab hbankstatv2 hryear, col


*Use of AFS in past 12 months by Banking Status; noteworthy that 38 percent of unbanked do not use AFS
svy: tab huse12afs hbankstatv2 if hryear==2011, column
svy: tab huse12afs hbankstatv2 if hryear==2017 
*78.5% of those w/ bank accounts did not use afs in past 12 months
*could use huse2AFSv2 if we care if R ever used AFS 
*underbanked definitionally use afs
svy: tab huse12afs banked, column 

*Reasons unbanked, not enough money
hist hunbnkrmv3  if hunbnkrmv3>0 & hunbnkrmv3<11
svy: tab hunbnkrmv3  if hunbnkrmv3>0 & hunbnkrmv3<11 & hryear==2015

*------------------------------------------------------------------------------*
*Logits
/**** DSS help 2, remove internet b/c collinearity/nonsolution. 
However year FE with multinomial logit models are tricky and viewed skeptically 
The result relies on CLT. With mlogits, each covariate relies on relative 
probability with others. Therefore one bad covariate that does not converge 
with small observation numbers under FE means that it could infect other variables. 
*/
mlogit banked poc college pempstat hhincome prtage home ///
 hsmphone citizen huspnish singleparent ///
 disabled i.hryear [pw=hhsupwgt], r 
outreg2 using mlogit.xls, ctitle(Banking Status Pr) addtext(Year FE, YES)replace

margins, at(hhincome=(1(1)5))
margins poc college pempstat hhincome prtage home hsmphone citizen huspnish ///
 singleparent disabled
 margins poc college pempstat hhincome prtage home hsmphone citizen huspnish ///
 singleparent disabled, predict(outcome(1))
marginsplot

*simplified
mlogit banked hhincome `controls' i.hryear [pw=hhsupwgt], r 
outreg2 using mlogitsimple.xls, ctitle(Banking Status Pr) addtext(Controls, YES) addtext(Year FE, YES) append


*OLS ALternative 
reg banked poc college pempstat hhincome prtage home ///
  hsmphone  citizen huspnish singleparent ///
  disabled i.hryear [pw=hhsupwgt], r 
outreg2 using mlogit.xls, ctitle(Banking Status OLS) addtext(Year FE, YES) append

*-----------------------------------------------------------------------------*
*******Typical income analysis*************
*should we care more about payday loans or about check cashing? 
*first we would want to know which do people use more? 
*do people use credit afs or transaction afs? underbanked rely by far mostly on transaction afs, not credit afs 
svy: tab huse12afstypev2 banked if huse12afstypev2>-1 & hryear==2017, column

*Second we would want to know if underbanked mostly receive income through check or money order, which is central to Klein and Sociologist's story
svy: tab htypincchkmov2 banked if htypincchkmov2>-1, column

svy: mean income_* if hryear==2017 & banked==0
svy: mean income_* if hryear==2017 & banked==1
svy: mean income_* if hryear==2017 & banked==2


*let's see if the underbanked used only banks for managing typical monthly income; it appears preferable to use only over any, ie use htypincbnkov2 instead of htypincbnkav2
svy: tab htypincbnkov2 banked if htypincbnkov2>-1, column
*most underbanked tend to use the bank for their typical monthly income, but that doesn't shed light on check cashing usage. 

*are unbanked likely to have had an account ever in the past?
svy: tab hbnkprevv2 banked if banked==0 & hbnkprevv2>-1, column
*did unbanked have an account in the past year? if had bank acct in past it was typically more than a year ago
*note: how do you do this by year?
svy: tab hbnkprevlyv2 banked if banked==0 & hbnkprevlyv2>-1, column

*why do people use check cashing? the underbanked find it (1) more convenient or (2) to get money faster 
svy: tab huseccrsn hbankstat if huseccrsn>-1 , col
svy: tab huseccrsnv2 hbankstatv2 if huseccrsnv2>-1 & hryear==2017, col
*2009 and 2011 version of the same question are roughly similar, create unified var called chkcashrsn

*do people who get typical income through checks use mobile check deposit? 
svy: tab hbnkmobv2g banked if income_htypincddbnk==1 & hryear==2017

*********Credit***********
*do underbanked use credit AFS?
svy: tab htypbnkoafsc if banked==1 & htypbnkoafsc>-1

*do underbanked use credit cards or other lines of credit in past 12 months?
svy: tab hcred12ccorbnk if banked==1 & hcred12ccorbnk>-1 	

*have underbanked HH applied for credit cards or other lines of credit in past 12 months?
svy: tab hcred12newapp if banked==1 & hcred12newapp>-1

*were they denied if applied?
svy: tab hcred12deniedc if banked==1 & hcred12deniedc>-1
*there arent intersting year trends on this tab cluster

*do underbanked deposit mobile checks? first time asked in 2017; most people don't use mobile banking is biggest takeaway
svy: tab hbnkmobv2g banked if banked>0, column


****IMPLIED HARM 

*how much of a harm could check cashing impose on inequality? 
*first find checkcashing use by income group. Check cashing is descreasing in income, question available in 2011-17
svy: tab huse12cc hhincome if huse12cc<99 & hryear==2017, col
svy: tab huse12cc hhincome if huse12cc<99 & hryear==2015, col
svy: tab huse12cc hhincome if huse12cc<99 & hryear==2013, col
svy: tab huse12cc hhincome if huse12cc<99 & hryear==2011, col

*svy: tab husecc hhincome if husecc<99 & hryear==2011, col

/*Let's make an extreme assumption, 
everyone that used CC in the past 30 days uses if every paycheck
someone that used it in the past year used it once, assuming monthly paycheck 
(which would also overstate since most paychecks are biweekly
average check cashing fee is 4.11% (Find better source than this: https://personalfinance.costhelper.com/check-cashing.html)
apply the average % check cashing use by income bracket and apply to inequality statistic. go to other do file
*/

*If they use any type of AFS, most HH only use one/year. 
svy: tab huse12afsnbr hhincome if hryear==2013 & huse12afsnbr<99, col
svy: tab huse12afsnbr hhincome if hryear==2015 & huse12afsnbr<99, col
svy: tab huse12afsnbr hhincome if hryear==2017 & huse12afsnbr<99, col

*Let's go even further, take an even more extreme case 
svy: tab huse12afs hhincome if hryear==2013 & huse12afs<99, col
svy: tab huse12afs hhincome if hryear==2015 & huse12afs<99, col
svy: tab huse12afs hhincome if hryear==2017 & huse12afs<99, col

*Now consider the opportunity cost of check depositing
svy: tab hbnkmobv2g hhincome if hbnkmobv2g>-1 & htypincchkmov2==1 & hryear==2017, column
svy: tab htypincchkmov2 hhincome if htypincchkmov2>-1 & hryear==2017, column

***************************Section 2*********************
/*this is the ideal regression 
	reg overdraft use_afs if lowincome 
	the indep var would be htypinccc, but we have no y var. 
xtreg gini use_afs cluster(hhincome)
	
no one seems to survey overdrafts, neither CFPB report or SHED survey
	https://www.consumerfinance.gov/data-research/financial-well-being-survey-data/
	https://www.federalreserve.gov/consumerscommunities/shed.htm
*/
