
* total of 17k firm-years that we scraped ended in data (CEO + Dir + ISS)  

/* Import Dir data*/

* total of 23 k firm-years available for dir comp

clear all
cd "R:\ps664\Dr_Becher - DirComp\10_post_collection_analysis"
import sas dirs0618_comp

format boardreportdate %dCY-N-D
format datadate %dCY-N-D


* all these companies are checked on presence of insiders
gen iss_yes=1
gen sp_1500_data=0

rename GVKEY gvkey 
rename YEAR fyear 
rename DIRNAME dirname 
rename OTHCOMP othercomp
rename CONAME coname
destring gvkey, replace 

* From firm-year-dir to firm-year
sort gvkey fyear dirname

by gvkey fyear: egen cash_dir=sum(cash)
by gvkey fyear: egen stock_dir=sum(stock)
by gvkey fyear: egen options_dir=sum(options)
by gvkey fyear: egen nonequity_dir=sum(nonequity)
by gvkey fyear: egen pension_dir=sum(pension)
by gvkey fyear: egen othercomp_dir=sum(othercomp)
by gvkey fyear: egen total_dir=sum(total)

* firm_total - total dir comp reported by a firm in a table
* total_dir - calculated comp dir total 


drop dirname cash stock options nonequity pension othercomp total
drop PERSONID dirid classification outsider DIRECTOR_DETAIL_ID NED

duplicates drop gvkey fyear, force

*drop cases with no director comp 
drop if cash_dir==0 & total_dir==0

* replace cases where numbers don't add up with a sum of all comp components
replace total_dir=cash_dir+stock_dir+options_dir+nonequity_dir+pension_dir+othercomp_dir if total_dir==0



/* Merge Dir data and CEO data*/
cd "R:\ps664\Dr_Becher - DirComp\10_post_collection_analysis"
merge m:1 gvkey fyear using ceos0618_comp
keep if _merge==3
drop _merge

rename options option
rename pension pension_report




/* Add CEO and Dir data for S&P 1500*/
/* Stack Director-CEO data for S&P 1500 */
* e.g. gvkey 1274 for 2007 John J. Burns, Jr. looks like an outsider (not counted in Jared's data, but counted in S&P 1500 data)

cd "R:\ps664\Dr_Becher - DirComp\3_add_sp1500"
append using  sp_1500_dir_ceo
replace sp_1500_data=1 if missing(sp_1500_data)
*rename directorname ceo_name
rename nonequity_dir nonequit_dir
replace coname=firmname if missing(coname)

drop firmname directorname CONAME

keep if iss_yes==1
replace execucomp=1 if missing(execucomp)




* adjust $ comp from nominal value to 1000s
replace cash_dir=cash_dir/1000 if sp_1500_data==1
replace stock_dir=stock_dir/1000  if sp_1500_data==1
replace options_dir=options_dir/000  if sp_1500_data==1
replace nonequit_dir=nonequit_dir/1000 if sp_1500_data==1
replace pension_dir=pension_dir/1000  if sp_1500_data==1
replace othercomp_dir=othercomp_dir/1000  if sp_1500_data==1
replace total_dir=total_dir/1000  if sp_1500_data==1
replace salary=salary/1000  if sp_1500_data==1
replace stock=stock/1000 if sp_1500_data==1
replace option=option/1000 if sp_1500_data==1
replace total=total/1000  if sp_1500_data==1
replace bonus=bonus/1000  if sp_1500_data==1
replace nonequity=nonequity/1000 if sp_1500_data==1
replace othercomp=othercomp/1000  if sp_1500_data==1
replace pension_report=pension_report/1000  if sp_1500_data==1
 
gsort gvkey fyear sp_1500_data
duplicates drop gvkey fyear cash_dir stock_dir total_dir, force

* if we have firm data from both scraped files and CRSP-Comp, keep scraped
gsort gvkey fyear sp_1500_data
duplicates drop gvkey fyear, force



/* Mark firms as S&P 1500 and not S&P 1500*/

cd "C:\Users\ps664\OneDrive - Drexel University\2nd Year Paper - Work\Data\SP_500"
* Merge with S&P500
merge m:1 gvkey fyear using data_sp500
drop if _merge==2
drop _merge
replace sp_500=0 if missing(sp_500)

* Merge with S&P1500
merge m:1 gvkey fyear using data_sp1500
drop if _merge==2
drop _merge 
replace sp_1500=0 if missing(sp_1500)


sort gvkey fyear 
duplicates drop  gvkey fyear, force


/////* Continue with old code here 4_dir_comp_innov*/////


* Merge with CRP-Compustat Financial Data
cd "R:\ps664\Dr_Becher - DirComp\6_correct_errors"
merge 1:1 gvkey fyear using  crsp_comp_data
keep if _merge==3
drop _merge


* non-S&P (scraped) firms are from 2007 only
drop if fyear<2007

* Ratios
gen mb_=(prcc_c*csho) / ceq
gen roa_= oibdp/at
* adjust weird observations with negative net sales
*drop if sale<0
*drop if mb<0
*replace sale=. if sale<0
* Profit Margin	
gen net_sales_=sale/at
* Return on Equity
gen roe_= oibdp / teq
* Gross Profit Margin
gen gpm_=gp/revt



* Adjust missing comp data
replace cash_dir=0 if missing(cash_dir)
replace stock_dir=0 if missing(stock_dir)
replace options_dir=0 if missing(options_dir)
replace nonequit_dir=0 if missing(nonequit_dir)
replace pension_dir=0 if missing(pension_dir)
replace othercomp_dir=0 if missing(othercomp_dir)
replace total_dir=0 if missing(total_dir)
	
replace salary=0 if missing(salary)
replace stock=0 if missing(stock)
replace option=0 if missing(option)
replace total=0 if missing(total)
replace bonus=0 if missing(bonus)
replace nonequity=0 if missing(nonequity)
replace othercomp=0 if missing(othercomp)
replace pension_report=0 if missing(pension_report)


replace total= salary+ bonus+ stock+ option+ nonequity+ othercomp+ pension_report if total==0
drop if total==0 
		
replace total_dir= cash_dir+ stock_dir+ options_dir+ nonequit_dir+ pension_dir+ othercomp_dir  if total_dir==0		
drop if total_dir==0



cd "R:\ps664\Patent Applications - Michelle Michela\More Data"
merge 1:1 fyear gvkey using app_pat_yearly_updated_
keep if _merge==3 | _merge==1
drop _merge
drop  av_approval* all_approval*

* drop extra columns from innovation data 
drop crsp_comp_name application_number granted_pat patent_number uspc_class age this_datatdate l_datatdate examiner_number examiner_art_unit filing_date patent_issue_date small_entity_indicator rf_id ee_name application_invention_type uspc_subclass appl_status_desc match permco xi_real xi_nominal cites issue_date cites_scaled green_cpc green_ipc mb roa net_sales roe gpm log_at ln_mkt_value ln_at l_ebitda_at sic app_year grant_year cites_scaled_gr total_cites_scaled_gr average_art_year average_tclass_year average_art average_tclass appr_rate_art_tclass_year average_art_year_gr average_tclass_year_gr average_art_gr average_tclass_gr appr_rate_art_tclass_year_gr year av_appr_art_year av_appr_art av_appr_tclass_year av_appr_tclass av_appr_art_tclass_year av_appr_art_year_gr av_appr_art_gr av_appr_tclass_year_gr av_appr_tclass_gr av_appr_art_tclass_year_gr     total_grant_gr total_appl_gr total_grant_gr_this_y


cd "C:\Users\ps664\OneDrive - Drexel University\2nd Year Paper - Work\Working Folder 1"
merge m:1 permno fyear using obsolescence_123		
drop if _merge==2
drop _merge

* Merge with H&B fluidity measure
cd "R:\ps664\Data\Fluidity"
gen year=fyear
merge m:1 gvkey year using fluidity		
drop if _merge==2
drop _merge
label variable prodmktfluid "Fluidity"
drop year


					* Merge Innovation Data (Stoffman's citation, originality etc)
					*cd "C:\Users\ps664\OneDrive - Drexel University\2nd Year Paper - Work\Working Folder 1"
					*rename at at_
					*rename capx capx_
					*rename sale sale_
					*merge m:1 permno fyear using patents_final		
					*drop if _merge==2	
					*drop _merge
					*cd "R:\ps664\Dr_Becher - DirComp\2_pull_exec_comp"

* Merge with HHI data
cd "C:\Users\ps664\OneDrive - Drexel University\2nd Year Paper - Work\Data\hhi data"
merge 1:1 gvkey fyear using hhi_data
keep if _merge==3
drop _merge
rename HHI hhi
sort gvkey fyear
by gvkey: gen l_hhi=hhi[_n-1]
label variable l_hhi "HHI"
cd "R:\ps664\Dr_Becher - DirComp\2_pull_exec_comp"

					*drop mb roa 
					*rename mb_ mb
					*rename roa_ roa
					*rename at_ atge
					*rename capx_ capx
					*rename sale_ sale 

replace xrd=0 if missing(xrd)

rename mb_ mb 
rename roa_ roa
rename net_sales_ net_sales
rename roe_ roe 
rename gpm_ gpm 

drop if missing(mb) | missing(roa) | missing(at) | missing(capx) | missing(sale)

drop if sale<0

* Sales growth
sort gvkey fyear
*drop lag_sale sales_growth
by gvkey fyear: gen lag_sale=sale[_n-1]
gen sales_growth=(sale-lag_sale)/lag_sale


sort gvkey fyear
by gvkey: gen next_innov= total_grant[_n+1]
by gvkey: gen lag_sales_growth = sales_growth[_n-1]
by gvkey: gen l_mb = mb[_n-1]
by gvkey: gen l_capx = capx[_n-1]
by gvkey: gen l_xrd = xrd[_n-1]
gen ln_at=ln(at)
by gvkey: gen l_ln_at = ln_at[_n-1]
by gvkey: gen l_ch = ch[_n-1]
by gvkey: gen l_roa = roa[_n-1]

gen sic= floor(sich/10)		
ffind sic, newvar(ffi) type(48)
egen iyfe=group(ffi fyear)

* Drop financials
drop if sich>6000 & sich<6999
* Drop Utilities
drop if sich>=4900 & sich<=4949



gen high_tech=1 if sic==283 | sic==284 | sic==351 | sic==353 | sic==355 | sic==356 | sic==357 | sic==360 | sic==361 | sic==362 | sic==363 | sic==364 | sic==365 | sic==366 |  sic==367 |  sic==369 |  sic==371 | sic==372 | sic==373 | sic==375 | sic==379 | sic==381 | sic==382 | sic==384 | sic==387 | sic==481 | sic==484 | sic==489 | sic==737 |  sic==873
replace high_tech=0 if missing(high_tech)	

sort gvkey fyear
replace total_grant=0 if missing(total_grant)
gen ln_total_grant=ln(1+total_grant)

by gvkey: gen l_ln_total_grant= ln_total_grant[_n-1]
by gvkey: gen l_total_grant= total_grant[_n-1]
by gvkey: gen l_total_appl= total_appl[_n-1]
*by gvkey: gen l_mean_scaled_citation= mean_scaled_citation[_n-1]
by gvkey: gen l_xi_total =  xi_total[_n-1]

xtile quant_1 = total_grant, nq(10)
xtile quant_2 = total_appl, nq(10)
xtile quant_3 = xi_total, nq(10)


					///* Director Compensation*///


winsor2 cash_dir, cuts(1 99)
winsor2 stock_dir, cuts(1 99)
winsor2 options_dir, cuts(1 99)
winsor2 nonequit_dir, cuts(1 99)
winsor2 pension_dir, cuts(1 99)
winsor2 othercomp_dir, cuts(1 99)
winsor2 total_dir, cuts(1 99)

gen total_made_dir=cash_dir+ stock_dir+ options_dir+ nonequit_dir+ pension_dir+ othercomp_dir

gen stock_prop_dir=stock_dir/total_dir
gen option_prop_dir=options_dir/total_dir
gen cash_prop_dir=cash_dir/total_dir
gen nonequit_prop_dir=nonequit_dir/total_dir
gen pension_prop_dir=pension_dir/total_dir
gen othercomp_prop_dir=othercomp_dir/total_dir


* Director's comp
by gvkey: gen l_stock_prop_dir = stock_prop_dir[_n-1]
by gvkey: gen l_option_prop_dir = option_prop_dir[_n-1]
by gvkey: gen l_cash_prop_dir = cash_prop_dir[_n-1]
by gvkey: gen l_nonequit_prop_dir = nonequit_prop_dir[_n-1]
by gvkey: gen l_pension_prop_dir = pension_prop_dir[_n-1]
by gvkey: gen l_othercomp_prop_dir = othercomp_prop_dir[_n-1]

sort gvkey fyear
by gvkey: gen l_stock_dir_w= stock_dir_w[_n-1]
by gvkey: gen l_options_dir_w= options_dir_w[_n-1]
by gvkey: gen l_cash_dir_w= cash_dir_w[_n-1]
by gvkey: gen l_nonequit_dir_w= nonequit_dir_w[_n-1]
by gvkey: gen l_pension_dir_w= pension_dir_w[_n-1]
by gvkey: gen l_othercomp_dir_w= othercomp_dir_w[_n-1]
by gvkey: gen l_total_dir_w= total_dir_w[_n-1]


					///* CEO Compensation*///

winsor2 total, cuts(1 99)
winsor2 salary, cuts(1 99)
winsor2 stock, cuts(1 99)
winsor2 option, cuts(1 99)
winsor2 bonus, cuts(1 99)
winsor2 nonequity, cuts(1 99)
winsor2 othercomp, cuts(1 99)
winsor2 pension_report, cuts(1 99)

* adjust putliers
gen total_made=salary+ stock+ option+ nonequity+ pension_report+ othercomp

gen stock_prop=stock/total
gen salary_prop=salary/total
gen bonus_prop=bonus/total
gen option_prop=option/total
gen nonequity_prop=nonequity/total
gen othercomp_prop=othercomp/total
gen pension_prop=pension_report/total


by gvkey: gen l_stock_prop= stock_prop[_n-1]
by gvkey: gen l_salary_prop = salary_prop[_n-1]
by gvkey: gen l_bonus_prop = bonus_prop[_n-1]
by gvkey: gen l_option_prop = option_prop[_n-1]
by gvkey: gen l_nonequity_prop = nonequity_prop[_n-1]
by gvkey: gen l_othercomp_prop = othercomp_prop[_n-1]
by gvkey: gen l_pension_prop = pension_prop[_n-1]


by gvkey: gen l_salary_w= salary_w[_n-1]
by gvkey: gen l_stock_w= stock_w[_n-1]
by gvkey: gen l_option_w = option_w[_n-1]
by gvkey: gen l_total_w = total_w[_n-1]
by gvkey: gen l_bonus_w = bonus_w[_n-1]


global l_controls "lag_at lag_mb lag_capx lag_xrd lag_roa"


///* Adjust outliers *///
* those that go outside of 0-1 as a proportion first replace with sum(components)
* if that doesnt help, just replace with the boundary 0 or 1 

* Stocks
replace l_stock_prop_dir=stock_dir/total_made_dir if l_stock_prop_dir>1 & !missing(l_stock_prop_dir)
replace l_stock_prop_dir=stock_dir/total_made_dir if l_stock_prop_dir<0
replace l_stock_prop=stock/total_made  if l_stock_prop>1 & !missing(l_stock_prop)
replace l_stock_prop=stock/total_made if l_stock_prop<0
replace l_stock_prop_dir=1 if l_stock_prop_dir>1 & !missing(l_stock_prop_dir)
replace l_stock_prop_dir=1 if l_stock_prop_dir<0
replace l_stock_prop=1 if l_stock_prop>1 & !missing(l_stock_prop)
replace l_stock_prop=0 if l_stock_prop<0

* Options
replace l_option_prop_dir=options_dir/total_made_dir if l_option_prop_dir>1 & !missing(l_option_prop_dir)
replace l_option_prop_dir=options_dir/total_made_dir if l_option_prop_dir<0
replace l_option_prop=option/total_made  if l_option_prop>1 & !missing(l_option_prop)
replace l_option_prop=option/total_made if l_option_prop<0
replace l_option_prop_dir=1 if l_option_prop_dir>1 & !missing(l_option_prop_dir)
replace l_option_prop=1 if l_option_prop>1 & !missing(l_option_prop)
replace l_option_prop_dir=0 if l_option_prop_dir<0
replace l_option_prop =0 if l_option_prop<0

* Cash
replace l_cash_prop_dir=cash_dir/total_made_dir if l_cash_prop_dir>1 & !missing(l_cash_prop_dir)
replace l_cash_prop_dir=cash_dir/total_made_dir if l_cash_prop_dir<0
replace l_salary_prop=salary/total_made  if l_salary_prop>1 & !missing(l_salary_prop)
replace l_salary_prop=salary/total_made if l_salary_prop<0
replace l_cash_prop_dir=1 if l_cash_prop_dir>1 & !missing(l_cash_prop_dir)
replace l_salary_prop=1 if l_salary_prop>1 & !missing(l_salary_prop)
replace l_cash_prop_dir=0 if l_cash_prop_dir<0
replace l_salary_prop=0 if l_salary_prop<0

* Nonequity
replace l_nonequit_prop_dir=nonequit_dir/total_made_dir if l_nonequit_prop_dir>1 & !missing(l_nonequit_prop_dir)
replace l_nonequit_prop_dir=nonequit_dir/total_made_dir if l_nonequit_prop_dir<0
replace l_nonequity_prop=nonequity/total_made  if l_nonequity_prop>1 & !missing(l_nonequity_prop)
replace l_nonequity_prop=nonequity/total_made if l_nonequity_prop<0
replace l_nonequit_prop_dir=1 if l_nonequit_prop_dir>1 & !missing(l_nonequit_prop_dir)
replace l_nonequit_prop_dir=0 if l_nonequit_prop_dir<0
replace l_nonequity_prop=1 if l_nonequity_prop>1 & !missing(l_nonequity_prop)
replace l_nonequity_prop=0 if l_nonequity_prop<0

* Pension
replace l_pension_prop_dir=pension_dir/total_made_dir if l_pension_prop_dir>1 & !missing(l_pension_prop_dir)
replace l_pension_prop_dir=pension_dir/total_made_dir if l_pension_prop_dir<0
replace l_pension_prop=pension_report/total_made  if l_pension_prop>1 & !missing(l_pension_prop)
replace l_pension_prop=pension_report/total_made if l_pension_prop<0
replace l_pension_prop_dir=1 if l_pension_prop_dir>1 & !missing(l_pension_prop_dir)
replace l_pension_prop_dir=0 if l_pension_prop_dir<0
replace l_pension_prop=1 if l_pension_prop>1 & !missing(l_pension_prop)
replace l_pension_prop=0 if l_pension_prop<0

* Other Comp
replace l_othercomp_prop_dir=othercomp_dir/total_made_dir if l_othercomp_prop_dir>1 & !missing(l_othercomp_prop_dir)
replace l_othercomp_prop_dir=othercomp_dir/total_made_dir if l_othercomp_prop_dir<0
replace l_othercomp_prop=othercomp/total_made  if l_othercomp_prop>1 & !missing(l_othercomp_prop_dir)
replace l_othercomp_prop=othercomp/total_made if l_othercomp_prop<0
replace l_othercomp_prop_dir=1 if l_othercomp_prop_dir>1 & !missing(l_othercomp_prop_dir)
replace l_othercomp_prop_dir=0 if l_othercomp_prop_dir<0
replace l_othercomp_prop=1 if l_othercomp_prop>1 & !missing(l_othercomp_prop)
replace l_othercomp_prop=0 if l_othercomp_prop<0

* Bonus
replace l_bonus_prop=bonus/total_made if l_bonus_prop>1 & !missing(l_bonus_prop)
replace l_bonus_prop=bonus/total_made if l_bonus_prop<0
replace l_bonus_prop=1 if l_bonus_prop>1 & !missing(l_bonus_prop)
replace l_bonus_prop=0 if l_bonus_prop<0


* Mao & Zhang 
replace stock_dir=0 if stock_dir<=0
replace options_dir=0 if options_dir<=0
replace stock=0 if stock<=0
replace option=0 if option<=0
by gvkey: gen l_ln_stock=ln(1+stock[_n-1])
by gvkey: gen l_ln_stock_dir=ln(1+stock_dir[_n-1])
by gvkey: gen l_ln_option=ln(1+option[_n-1])
by gvkey: gen l_ln_options_dir=ln(1+options_dir[_n-1])
by gvkey: gen l_ln_total=ln(1+total_made[_n-1])
by gvkey: gen l_ln_total_dir=ln(1+total_made_dir[_n-1])

gen ln_total_appl = ln(1+total_appl)
gen ppe_emp = ln(ppent/emp)
by gvkey: gen l_ppe_emp=ppe_emp[_n-1]
*by gvkey: gen l_log_at=log_at[_n-1]
by gvkey: gen l_ln_sales=ln(1+sale[_n-1])
gen tobin_q = mkt_value/at
by gvkey: gen l_tobin_q=tobin_q[_n-1]
gen l_hhi2 = l_hhi*l_hhi
label variable l_ln_stock "ln(1+Stocks)"
label variable l_ln_stock_dir "ln(1+Stocks Dir)"
label variable l_ln_option "ln(1+Options)"
label variable l_ln_options_dir "ln(1+Options Dir)"
label variable l_ppe_emp "PPE/N of Empl"
label variable l_tobin_q "Tobin Q"
label variable l_hhi2 "HHI^2"
label variable l_ln_sales "ln(Sales)"
*label variable l_log_sales "log(Sales)"
*label variable age "Age"
by gvkey: gen l_log_sales =log(1+sale[_n-1])
label variable l_log_sales "log(Sales)"

*keep if !missing(l_log_sale)

xtset fyear
xtset ffi
xtset iyfe
xtset gvkey

* Only keep cases avaialble in ISS or Boardex (to exclude executive director comp from dir comp)
by gvkey: gen l_iss_yes = iss_yes[_n-1]
drop if l_iss_yes==0

* Import Delta/Vega
cd "C:\Users\ps664\OneDrive - Drexel University\2nd Year Paper - Work\Data\CEO comp - delta vega"
merge 1:1 gvkey fyear using deltavega2015_ready
drop if _merge==2

*keep if !missing(delta)

sort gvkey fyear
by gvkey: gen l_age=age[_n-1]
label variable l_age "CEO Age"

cd "R:\ps664\Data\Firm Age Public"
drop _merge
merge 1:1 gvkey fyear using firm_age
drop if _merge==2
drop _merge


																				* Merge with M&A data 
																				* get cusip first 
																				*cd "R:\ps664\Patent Applications - Michelle Michela\More Data"
																				*drop _merge
																				*merge 1:1 gvkey fyear using ticker_formatted
																				*drop if _merge==2
																				*duplicates drop gvkey fyear, force
																				*gen cusip_8= substr(cusip, 1, 8)
																				*replace cusip = substr(cusip, 1, 6)
																				*drop _merge

																				*duplicates drop cusip fyear if !missing(cusip), force


/* ADD CONTROL VARIABLE FROM PRIOR LIT*/

drop cusip
replace permno=PERMNO
gen year=fyear 

* get cusip for all firms
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data"
merge m:1 permno year using WRDS_cusip_permno
drop if _merge==2
drop _merge
gen cusip=substr(cusip_8, 1,6)
			
			
			
* get m&a data
cd "C:\Users\ps664\OneDrive - Drexel University\2nd Year Paper - Work\Data\Mergers 1990_2019"
merge m:m cusip fyear using mergers1990_2019
drop if _merge==2
drop _merge
sort gvkey fyear DateAnnounced
gen ma=1 if !missing(DateAnnounced)
by gvkey fyear: egen did_ma= max(ma)
duplicates drop gvkey fyear, force
drop ma





* institutional ownership
*gen year = fyear
*drop year_

cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data"
merge m:1 year cusip using instit_data
drop if _merge==2
drop _merge
merge 1:1 fyear gvkey using no_instit_own_added
drop if _merge==2
drop _merge
replace INSTOWN=INSTOWN_ if missing(INSTOWN)
replace INSTOWN_PERC=INSTOWN_PERC_ if missing(INSTOWN_PERC)
replace NUMINSTBLOCKOWNERS=NUMINSTBLOCKOWNERS_ if missing(NUMINSTBLOCKOWNERS)
drop  gvkey_char tfn_date INSTOWN_ INSTOWN_PERC_ NUMINSTBLOCKOWNERS_ INSTOWN_HHI INSTBLOCKOWN TOP5INSTOWN INSTBLOCKOWN_perc TOP5INSTOWN_perc nonmissing


duplicates drop gvkey fyear permno year, force

* Get NCUSIPs 
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data"
merge 1:m permno year using WRDS_yearly
drop if _merge==2
duplicates drop gvkey fyear, force
drop _merge 

rename NCUSIP ncusip
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data"
duplicates drop gvkey fyear year ncusip, force
merge m:1 year ncusip using IBES_Forecasts_yearly
drop if _merge==2
drop _merge 


* analyst overage
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data"
rename ncusip NCUSIP
merge m:1 year NCUSIP using analyst_data
drop if _merge==2
drop _merge
replace ln_coverage=ln(1) if missing(ln_coverage)




duplicates drop gvkey fyear, force

* board data from Jared (Boardex & Risk Matrix)
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\Board Controls from Jared"
merge 1:1 year gvkey using bxrmboardcontrols_9618
drop if _merge==2
drop _merge

* keep lagged non-normalized observations
sort gvkey fyear
by gvkey: gen l_hhifinexpert_out=hhifinexpert_out[_n-1]
by gvkey: gen l_hhibachelor_out=hhibachelor_out[_n-1]
by gvkey: gen l_stddevage_out=stddevage_out[_n-1]
by gvkey: gen l_avgotherboardseats_out=avgotherboardseats_out[_n-1]
by gvkey: gen l_pctfemale_out=pctfemale_out[_n-1]


*1. fraction of female directors (PCT_FEMALE) -> pctfemale_out
*2. the mean number of other boards in the Standard and Poor's (S&P) 1500 on which current members serve (NUM_BOARDS) -> avgotherboardseats_out
*3. the standard deviation of directors’ age (STDEV_AGE) -> stddevage_out
*4. Herfindahl concentration indexes for director ethnicity (HHI_ETHNICITY) -> NONE
*5. institution where the directors received their Bachelor's degree (HHI_BACHELOR) -> hhibachelor_out
*6. director financial expertise (HHI_FINEXPERT) -> hhifinexpert_out

* normalize each iversity component by mean and SD  following the paper
*"We normalize each diversity component by its mean and standard deviation, so that their scale is comparable, and then equally weight each factor to construct the board diversity index"
egen mean1 =mean(pctfemale_out)
egen sd_1 = sd(pctfemale_out)
gen pctfemale_out_norm= (pctfemale_out - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(avgotherboardseats_out)
egen sd_1 = sd(avgotherboardseats_out)
gen avgotherboardseats_out_norm= (avgotherboardseats_out - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(stddevage_out)
egen sd_1 = sd(stddevage_out)
gen stddevage_out_norm= (stddevage_out - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(hhifinexpert_out)
egen sd_1 = sd(hhifinexpert_out)
gen hhifinexpert_out_norm= (hhifinexpert_out - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(hhibachelor_out)
egen sd_1 = sd(hhibachelor_out)
gen hhibachelor_out_norm= (hhibachelor_out - mean1)/sd_1

* then diversity is the weighted average of all components
gen diversity= 0.2* pctfemale_out_norm + 0.2* stddevage_out_norm + 0.2* avgotherboardseats_out_norm  - 0.2* hhibachelor_out_norm - 0.2* hhifinexpert_out_norm

drop mean1 sd_1
egen mean1 =mean(pctfemale )
egen sd_1 = sd(pctfemale)
gen pctfemale_norm= (pctfemale - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(avgotherboardseats)
egen sd_1 = sd(avgotherboardseats)
gen avgotherboardseats_norm= (avgotherboardseats - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(stddevage )
egen sd_1 = sd(stddevage)
gen stddevage_norm= (stddevage - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(hhifinexpert )
egen sd_1 = sd(hhifinexpert)
gen hhifinexpert_norm= (hhifinexpert - mean1)/sd_1

drop mean1 sd_1
egen mean1 =mean(hhibachelor )
egen sd_1 = sd(hhibachelor)
gen hhibachelor_norm= (hhibachelor - mean1)/sd_1

gen diversity_no_out= 0.2* pctfemale_norm + 0.2* stddevage_norm + 0.2* avgotherboardseats_norm - 0.2* hhibachelor_norm - 0.2* hhifinexpert_norm


* boards data - VC directors (using cusip_8 and year)
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors"
merge m:1 year cusip_8 using firm_dir_vc
drop if _merge==2
drop _merge
replace vc=0 if missing(vc)

* liquidity data based on Amihud(2002) (using cusip_8 and year)
cd "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data"
merge m:1 year PERMNO using liquidity
drop if _merge==2
drop _merge


* check outliers for institutional ownership 
* create all lags for control variables
sort gvkey fyear
by gvkey: gen l_diversity=diversity[_n-1]
by gvkey: gen l_vc=vc[_n-1]
by gvkey: gen l_boardintensemonitor=boardintensemonitor[_n-1]
by gvkey: gen l_cboard=cboard[_n-1]
by gvkey: gen l_pctconnectedtoceo=pctconnectedtoceo[_n-1]
by gvkey: gen l_boardsize=boardsize[_n-1]
by gvkey: gen l_pctindep=pctindep[_n-1]
by gvkey: gen l_ln_coverage=ln_coverage[_n-1]
by gvkey: gen l_numinstblockowner=NUMINSTBLOCKOWNERS[_n-1]
by gvkey: gen l_instsharestotal=INSTOWN[_n-1]
by gvkey: gen l_instown_perc=INSTOWN_PERC[_n-1]
by gvkey: gen l_liquidity=liquidity[_n-1]
by gvkey: gen l_liquidity_sc=liquidity_sc[_n-1]
by gvkey: gen l_liquidity_absret=liquidity_absret[_n-1]
by gvkey: gen l_liquidity_sc_absret=liquidity_sc_absret[_n-1]

gen indboard=1 if pctindep>0.5
replace indboard=0 if pctindep<=0.5
by gvkey: gen l_indboard=indboard[_n-1]


			/// * REPORT - Summary stats * ///


* negative MB due to negative Common/Ordinary Equity - Total (denominator)
* negative ROA due to negative Operating Income Before Depreciation

duplicates drop gvkey fyear, force 

sort gvkey fyear
by gvkey: gen ln_l_delta = ln(1+delta[_n-1])
by gvkey: gen ln_l_vega = ln(1+vega[_n-1])
label variable ln_l_delta "ln(1+ Delta CEO)"
label variable ln_l_vega "ln(1+ Vega CEO)"
 

label variable cash_dir_w "Cash Dir in 1000s"
label variable stock_dir_w "Stock Dir in 1000s"
label variable options_dir_w "Options Dir in 1000s"
label variable nonequit_dir_w "Non-equity Dir in 1000s"
label variable pension_dir_w "Pension Change Dir in 1000s"
label variable othercomp_dir_w "Other Comp Dir in 1000s"
label variable total_dir_w "Total Dir in 1000s"

label variable l_cash_dir_w "Cash Dir in 1000s"
label variable l_stock_dir_w "Stock Dir in 1000s"
label variable l_options_dir_w "Options Dir in 1000s"
label variable l_nonequit_dir_w "Non-equity Dir in 1000s"
label variable l_pension_dir_w "Pension Change Dir in 1000s"
label variable l_othercomp_dir_w "Other Comp Dir in 1000s"
label variable l_total_dir_w "Total Dir in 1000s"

label variable l_cash_prop_dir "Proportion of Cash Dir"
label variable l_stock_prop_dir "Proportion of Stock Dir"
label variable l_option_prop_dir "Proportion of Options Dir"
label variable l_nonequit_prop_dir "Proportion of Non-equity Dir"
label variable l_pension_prop_dir "Proportion of Pension Change Dir"
label variable l_othercomp_prop_dir "Proportion of Other Comp Dir"

by gvkey: gen l_nonequity_w=nonequity_w[_n-1]
by gvkey: gen l_othercomp_w=othercomp_w[_n-1]
by gvkey: gen l_pension_report_w=pension_report_w[_n-1]
label variable l_salary_w "Cash in 1000s"
label variable l_stock_w "Stock in 1000s"
label variable l_option_w "Options in 1000s"
label variable l_bonus_w "Bonus in 1000s"
label variable l_othercomp_w "Other Comp in 1000s"
label variable l_pension_report_w "Pension Change in 1000s"
label variable l_total_w "Total in 1000s"
label variable l_nonequity_w "Non-equity in 1000s"

label variable l_salary_prop "Proportion of Cash"
label variable l_stock_prop "Proportion of Stock"
label variable l_option_prop "Proportion of Options"
label variable l_bonus_prop "Proportion of Bonus"
label variable l_othercomp_prop "Proportion of Other Comp"
label variable l_pension_prop "Proportion of Pension Change"
label variable l_nonequity_prop "Proportion of Non-equity"
label variable age "Age"
label variable xi_total "Patent Quality (KPSS)"
label variable total_grant "N of Patents per year"
label variable l_xi_total "Patent Quality (KPSS)"
label variable l_total_grant "N of Patents per year"


sort gvkey fyear
by gvkey: gen l_ni=ni[_n-1]
by gvkey: gen l_age_firm=age[_n-1]
by gvkey: gen l_mkt_value=mkt_value[_n-1]
label variable l_mkt_value "Market Cap in mill"
label variable l_hhi "HHI"
label variable l_mb "Market to Book"
label variable l_roa "ROA"
label variable l_ln_at "ln(Total Assets)"

*label variable l_log_sales "log(Sales)"
*gen log_sale = log(1+sale)
*label variable log_sale "log(Sales)"

* some financial variables are still missing
* +> put a restriction on non-missing variable with lowest n of obs (xi_total)

* Sum Stats - Financials

gen l_t_equity_dir=l_stock_prop_dir + l_option_prop_dir
gen l_t_equity = l_stock_prop + l_option_prop
gen t_equity_dir_w = stock_dir_w + options_dir_w
label variable t_equity_dir_w  "Equity Dir in 1000s"
label variable l_t_equity_dir "Proportion of Equity Dir"
label variable l_t_equity "Proportion of Equity CEO"

replace l_t_equity_dir=1 if l_t_equity_dir>1 & !missing(l_t_equity_dir)
replace l_t_equity_dir=0 if l_t_equity_dir<0
replace l_t_equity=1 if l_t_equity>1 & !missing(l_t_equity)
replace l_t_equity=0 if l_t_equity<0

by gvkey: replace l_t_equity_dir=. if _n==1
by gvkey: replace l_t_equity=. if _n==1
by gvkey: replace l_stock_prop_dir=. if _n==1
by gvkey: replace l_option_prop_dir=. if _n==1
by gvkey: replace l_cash_prop_dir=. if _n==1
by gvkey: replace l_nonequit_prop_dir=. if _n==1
by gvkey: replace l_pension_prop_dir=. if _n==1
by gvkey: replace l_othercomp_prop_dir=. if _n==1
by gvkey: replace l_salary_prop=. if _n==1
by gvkey: replace l_stock_prop=. if _n==1
by gvkey: replace l_option_prop=. if _n==1
by gvkey: replace l_bonus_prop=. if _n==1
by gvkey: replace l_nonequity_prop=. if _n==1
by gvkey: replace l_othercomp_prop=. if _n==1
by gvkey: replace l_pension_prop=. if _n==1

keep if !missing(xi_total)
global l_controls "l_ln_at l_ch l_mb l_capx l_xrd l_roa"


* Scale all variables by assets
drop l_xrd l_capx l_ch l_ch
sort gvkey fyear
by gvkey: gen l_xrd = xrd[_n-1]/at[_n-1]
by gvkey: gen l_capx = capx[_n-1] /at[_n-1]
by gvkey: gen l_ch = ch[_n-1]/at[_n-1]
by gvkey: gen l_total_cites = total_cites[_n-1]
replace l_total_cites=0 if missing(l_total_cites)
drop l_total_appl
by gvkey: gen l_total_appl = total_appl[_n-1]
replace l_total_appl=0 if missing(l_total_appl)


winsor2 l_xrd, cuts(1 99) by(fyear) replace
winsor2 l_capx, cuts(1 99) by(fyear) replace
winsor2 l_ch, cuts(1 99) by(fyear) replace
winsor2 l_mb, cuts(1 99) by(fyear) replace
winsor2 l_roa, cuts(1 99) by(fyear) replace
winsor2 l_ni, cuts(1 99) by(fyear) replace
winsor2 l_mkt_value, cuts(1 99) by(fyear) replace

label variable l_ln_at "ln(Total Assets)"
label variable l_xrd "R&D/Assets"
label variable l_mb "Market to Book"
label variable l_ch "Cash/Assets"
label variable l_roa "ROA"
label variable l_capx "CAPX/Assets"
label variable l_ni "Net Income (Loss)"
label variable l_age_firm "Years Public (since 2000)"
label variable l_total_cites "N of Citations"
label variable l_total_appl "N of Patent Applications per year"

gen l_ceo_connection=1 if l_pctconnectedtoceo>0
replace l_ceo_connection=0 if missing(l_ceo_connection)
replace l_ceo_connection=. if missing(l_pctconnectedtoceo)

replace l_instown_perc=0 if missing(l_instown_perc)

label variable 	l_vc "VC Director"
label variable 	l_boardintensemonitor "Intense Board Monitoring"
label variable 	l_cboard "Classified Board"
label variable 	l_pctconnectedtoceo "CEO Connection %"
label variable 	l_indboard "Board Independence"

label variable 	l_ln_coverage "Analyst Coverage"
label variable 	l_numinstblockowner "N of Instit Owners"
label variable 	l_instsharestotal "Instit Inv Shares"
label variable 	l_instown_perc "Instit Inv Ownership %"
label variable 	l_liquidity "Illiquidity"
label variable 	l_liquidity_sc  "Illiquidity"
label variable 	l_diversity "Board Diversity"

label variable 	l_pctfemale_out "Female Directors %"
label variable 	l_avgotherboardseats_out "Av. Outside Board Seats"
label variable 	l_stddevage "SD of Director Age"
label variable 	l_hhibachelor_out "HHI Bachelor Degree"
label variable 	l_hhifinexpert_out "HHI Fin Expert"
label variable 	l_ceo_connection "Friendly Board"
label variable 	l_pctindep "Independent Dir %"

gen my_sample=1 if !missing(l_capx) & !missing(l_t_equity_dir) & !missing(ln_total_grant) & !missing(l_t_equity_dir) & !missing(l_diversity) & !missing(l_vc) & !missing(l_boardintensemonitor) & !missing(l_ceo_connection) & !missing(l_indboard) & !missing(l_ln_coverage) & !missing(l_instown_perc) & !missing(l_liquidity_sc) 

*& !missing(l_xi_total) 

drop ffi
ffind sich, newvar(ffi) type(48)


global l_controls "l_ln_sales l_ch l_mb l_capx l_xrd l_roa"
global l_div_measure "l_pctfemale_out l_avgotherboardseats_out l_stddevage_out  l_hhibachelor_out l_hhifinexpert_out"
*global l_controls "l_ln_at l_ch l_mb l_capx l_xrd l_roa"
global l_controls_priorlit "l_diversity l_vc l_boardintensemonitor l_ceo_connection l_pctconnectedtoceo l_pctindep l_indboard  l_instown_perc l_liquidity_sc"
*l_ln_coverage
global l_div_measure_no_out "l_pctfemale l_avgotherboardseats l_stddevage  l_hhibachelor l_hhifinexpert"

* USE l_pctindep instead of l_indboard !!!

winsor2 l_ln_coverage, replace cuts(1 99) by(fyear)
winsor2 l_instown_perc, replace cuts(1 99) by(fyear)


cd "R:\ps664\Dr_Becher - DirComp\Reports\02-26-21\No liquidity"

* Table 1 
outreg2 using sum_table_1.doc if my_sample==1 &  !missing(l_t_equity_dir), replace sum(detail) eqkeep(N mean p50 sd ) keep(l_ln_sales $l_controls l_ni l_mkt_value l_total_grant l_total_cites   l_hhi $l_controls_priorlit $l_div_measure ln_l_delta ln_l_vega $l_controls) sortvar(l_ln_sales l_ln_at l_mkt_value l_ch l_capx l_roa l_ni l_mb l_xrd l_total_grant   l_hhi l_age_firm l_total_cites  $l_controls_priorlit $l_div_measure ln_l_delta ln_l_vega $l_controls) label title("Table 1 - Summary Stats - Financials")
*l_xi_total


* Sum Stats - Director Comp

			*replace l_cash_dir_w=l_cash_dir_w/1000
			*replace l_stock_dir_w=l_stock_dir_w/1000
			*replace l_options_dir_w=l_options_dir_w/1000
			*replace l_nonequit_dir_w=l_nonequit_dir_w/1000
			*replace l_pension_dir_w=l_pension_dir_w/1000
			*replace l_othercomp_dir_w=l_othercomp_dir_w/1000
			*replace l_total_dir_w=l_total_dir_w/1000
* Table 2
* Report summary stats on variables used in regressions (lagged ones)
global l_dir_sum "l_total_dir_w l_stock_dir_w l_options_dir_w l_cash_dir_w l_nonequit_dir_w l_pension_dir_w l_othercomp_dir_w l_t_equity_dir l_stock_prop_dir l_option_prop_dir  l_cash_prop_dir l_nonequit_prop_dir l_pension_prop_dir l_othercomp_prop_dir l_ln_stock_dir l_ln_options_dir"
global l_ceo_sum "l_total_w l_stock_w l_option_w l_salary_w l_bonus_w  l_nonequity_w l_pension_report_w l_othercomp_w l_t_equity l_salary_prop l_stock_prop l_option_prop l_bonus_prop  l_nonequity_prop l_othercomp_prop  l_pension_prop l_ln_stock l_ln_option ln_l_delta ln_l_vega"
label variable l_ln_stock_dir "ln(1+Stock Dir)"
label variable l_ln_options_dir "ln(1+Options Dir)"
label variable l_ln_stock "ln(1+Stock CEO)"
label variable l_ln_option "ln(1+Options CEO)"

outreg2 using sum_table_2.doc if my_sample==1, replace sum(detail) eqkeep(N mean p50 sd) keep($l_dir_sum $l_ceo_sum) sortvar($l_dir_sum $l_ceo_sum) label title("Table 2 - Summary Stats - Director and CEO Compensation")



* Table 3 
outreg2 using sum_table_3a.doc if sp_500==1 & my_sample==1, replace sum(detail) eqkeep(N mean p50 sd min max) keep($l_dir_sum) label title("Table 3A - S&P 500")

outreg2 using sum_table_3b.doc if sp_1500==1 & sp_500==0 & my_sample==1, replace sum(detail) eqkeep(N mean p50 sd min max) keep($l_dir_sum) label title("Table 3B - from S&P 500 to S&P 1500") 

outreg2 using sum_table_3c.doc if sp_1500==0 & my_sample==1, replace sum(detail) eqkeep(N mean p50 sd min max) keep($l_dir_sum) label title("Table 3C - beyond S&P 1500") 




* Figure 1
* Firm size and equity comp 
xtile size_q = at, nq(10)
xtile age_q = age, nq(10)
xtile mb_q = mb, nq(10)
xtile ch_q = ch, nq(10)
xtile roa_q = roa, nq(10)

gen pay_ratio = l_total_w/l_total_dir_w
xtile xrd_q = xrd, nq(10)


graph bar pay_ratio  , over(xrd_q)  ytitle("Proportion of Total Compensation")  title("Equity Compensation over Firm Size Quantiles") legend( label(1 "Director Equity") label(2 "CEO Equity")) 


* Figures 1
graph bar l_t_equity_dir l_t_equity , over(size_q)  ytitle("Proportion of Total Compensation")  title("Equity Compensation over Firm Size Quantiles") legend( label(1 "Director Equity") label(2 "CEO Equity")) 

graph bar l_t_equity_dir l_t_equity , over(year)  ytitle("Proportion of Total Compensation")  title("Equity Compensation over Time") legend( label(1 "Director Equity") label(2 "CEO Equity")) 

* Figures 2
* why stocks and options for directors are negatively correlated
*this trend is only for directors, and not for CEOs
graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir, over(size_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation over Firm Size Quantiles") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

graph bar  l_t_equity l_stock_prop l_option_prop l_salary_prop, over(size_q)  ytitle("Proportion of Total Compensation")  title("CEO Equity Compensation over Firm Size Quantiles") legend( label(1 "CEO Equity") label(2 "CEO Stock") label(3 "CEO Options") label(4 "CEO Cash")) 


* Figures 3
graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir if fyear<2013, over(size_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation" "over Firm Size Quantiles before 2013") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir if fyear>=2013, over(size_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation" " over Firm Size Quantiles after 2013") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir, over(fyear)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation over time") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 


* Figures 4
graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir if sp_1500==1, over(size_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation" " over S&P 1500 Firm Size Quantiles") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir if sp_1500==0, over(size_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation " "over non-S&P 1500 Firm Size Quantiles") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

* Figures 5
graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir l_cash_prop_dir, over(age_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation over Firm Age Quantiles") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir if sp_1500==1, over(age_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation" " over S&P 1500 Firm Age Quantiles") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 

graph bar  l_t_equity_dir l_stock_prop_dir l_option_prop_dir l_cash_prop_dir if sp_1500==0, over(age_q)  ytitle("Proportion of Total Compensation")  title("Director Equity Compensation" " over non-S&P 1500 Firm Age Quantiles") legend( label(1 "Director Equity") label(2 "Director Stock") label(3 "Director Options") label(4 "Director Cash")) 


* Figure 6
* Non-S&P 1500 or scraped firms
tab fyear if sp_1500==0




				///////////////////// * Regressions * ////////////////////////////////////

cd "R:\ps664\Dr_Becher - DirComp\Reports\02-26-21\No liquidity"	

*by gvkey: gen l_log_sales=log(1+sale[_n-1])


* mark firms that have ever been in S&O 500 or S&P 1500
by gvkey: egen sp_500_ever=max(sp_500)
by gvkey: egen sp_1500_ever=max(sp_1500)

by gvkey: gen l_diversity_no_out = diversity_no_out[_n-1]

winsor2 xi_total, replace cuts(1 99) by(fyear)

drop iyfe 
egen iyfe=group(ffi fyear)


					* Specification #2	
					
global l_controls "l_ln_sales l_ch l_mb l_capx l_xrd l_roa"
*global l_controls "l_ln_at l_ch l_mb l_capx l_xrd l_roa"
global l_controls_priorlit "l_diversity l_vc l_boardintensemonitor l_ceo_connection l_indboard  l_instown_perc l_liquidity_sc"
*l_ln_coverage
global l_controls_priorlit_1 "l_vc l_boardintensemonitor l_ceo_connection l_indboard  l_instown_perc l_liquidity"

*replace l_cboard=0 if missing(l_cboard)

global div_measure "l_pctfemale_out l_avgotherboardseats_out l_stddevage_out l_hhibachelor_out l_hhifinexpert_out" 

* change variable of interes to equity compensation

label variable 	l_t_equity_dir "Proportion of Equity Dir"
label variable 	l_t_equity "Proportion of Equity CEO"
label variable 	l_stock_prop "Proportion of Stocks CEO"
label variable 	l_stock_prop_dir "Proportion of Stocks Dir"
label variable 	l_option_prop "Proportion of Options CEO"
label variable 	l_option_prop_dir "Proportion of Options Dir"
label variable 	l_stock_w "$ Stocks"
label variable 	l_stock_dir_w "$ Stocks Dir"
label variable 	l_option_w "$ Options"
label variable 	l_options_dir_w "$ Options"
label variable 	l_salary_prop "Proportion of Salary CEO"
label variable 	l_cash_prop_dir "Proportion of Cash Dir"
label variable 	l_salary_w "$ Salary CEO"
label variable 	l_cash_dir_w "$ Cash Dir"
label variable 	l_total_w "$ Total Comp CEO"
label variable 	l_total_dir_w "$ Total Comp Dir"

* Table 7A - Proportions - Innov Quantity
* before - ln_total_grant & my_sample==1
* after - ln_appl ln_cites xi_total_w
replace total_appl=0 if missing(total_appl)
replace total_cites_scaled=0 if missing(total_cites_scaled)
gen ln_appl = ln(1+total_appl)
gen ln_cites = ln(1+total_cites_scaled)
replace total_grant_scaled=0 if missing(total_grant_scaled)
gen ln_total_grant_scaled=ln(1+total_grant_scaled)
gen ln_total_appl_scaled=ln(1+total_appl_scaled)

winsor2 ln_cites, cuts(1 99) by(fyear)

replace did_ma=0 if missing(did_ma)

* Table 3 - Quantity & Quality

* Quantity:
*ln_total_grant
*ln_total_grant_scaled
*ln_total_appl_scaled

* Quality:
*ln_cites_w
*xi_total

by gvkey: gen n2_ln_total_grant_scaled=ln_total_grant_scaled[_n+2]


by gvkey: gen l_ln_av_coverage=ln(av_coverage[_n-1])
winsor2 l_ln_av_coverage, cuts(1 99) by(fyear)

cd "R:\ps664\Dr_Becher - DirComp\Reports\02-26-21"
cd "R:\ps664\Dr_Becher - DirComp\Reports\02-26-21\No liquidity"
xtset fyear
xtreg ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_1a.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear ,  ll(0)   iterate(5)
outreg2 using table_1a.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_1a.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear ,  ll(0)   iterate(5)
outreg2 using table_1a.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)





* Table 4 - Comparison between small and big firms 

*l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop

	
	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_2a_500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_2a_500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_2a_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_2a_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel B 

* up to S&P 1500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==1 & sp_500==0, fe vce(robust)
outreg2 using table_2a_not500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==1  & sp_500==0,  ll(0)   iterate(5)
outreg2 using table_2a_not500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* up to S&P 1500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==1 & sp_500==0, fe vce(robust)
outreg2 using table_2a_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==1  & sp_500==0,  ll(0)   iterate(5)
outreg2 using table_2a_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel C 

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==0 , fe vce(robust)
outreg2 using table_2a_not1500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==0,  ll(0)   iterate(5)
outreg2 using table_2a_not1500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==0 , fe vce(robust)
outreg2 using table_2a_not1500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if sp_1500==0,  ll(0)   iterate(5)
outreg2 using table_2a_not1500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)









* Table 5 - stock vs options 

* l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop

	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_3a_500.doc, replace ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_3a_500.doc, append ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_3a_500.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_3a_500.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel B 

* up to S&P 1500
xtset fyear
xtreg ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==1 & sp_500==0, fe vce(robust)
outreg2 using table_3a_not500.doc, replace ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==1  & sp_500==0,  ll(0)   iterate(5)
outreg2 using table_3a_not500.doc, append ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* up to S&P 1500
xtset fyear
xtreg ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==1 & sp_500==0, fe vce(robust)
outreg2 using table_3a_not500.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==1  & sp_500==0,  ll(0)   iterate(5)
outreg2 using table_3a_not500.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel C 

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==0 , fe vce(robust)
outreg2 using table_3a_not1500.doc, replace ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==0,  ll(0)   iterate(5)
outreg2 using table_3a_not1500.doc, append ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==0 , fe vce(robust)
outreg2 using table_3a_not1500.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if sp_1500==0,  ll(0)   iterate(5)
outreg2 using table_3a_not1500.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)






* Table 6 - Comparison between mature and young firms

* drop age_q
* age_q=3 is old
sort gvkey fyear 
by gvkey: gen l_f_age=f_age[_n-1]
xtile age_q = l_f_age, nq(3)

xtile eq_q = l_t_equity, nq(3)
xtile mon_q = pctintensemonitor, nq(3)

xtile div_q = l_diversity, nq(3)




	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==3 , fe vce(robust)
outreg2 using table_4a_old.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==3 ,  ll(0)   iterate(5)
outreg2 using table_4a_old.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==3 , fe vce(robust)
outreg2 using table_4a_old.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==3 ,  ll(0)   iterate(5)
outreg2 using table_4a_old.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel B 

* up to S&P 1500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==2, fe vce(robust)
outreg2 using table_4a_med.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if  age_q==2,  ll(0)   iterate(5)
outreg2 using table_4a_med.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* up to S&P 1500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==2, fe vce(robust)
outreg2 using table_4a_med.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==2,  ll(0)   iterate(5)
outreg2 using table_4a_med.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel C 

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==1 , fe vce(robust)
outreg2 using table_4a_young.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==1,  ll(0)   iterate(5)
outreg2 using table_4a_young.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==1 , fe vce(robust)
outreg2 using table_4a_young.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if age_q==1,  ll(0)   iterate(5)
outreg2 using table_4a_young.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)




* Table 7 -  mature and young, stock vs options

* l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop

	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==3 , fe vce(robust)
outreg2 using table_5_old.doc, replace ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==3 ,  ll(0)   iterate(5)
outreg2 using table_5_old.doc, append ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==3, fe vce(robust)
outreg2 using table_5_old.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==3 ,  ll(0)   iterate(5)
outreg2 using table_5_old.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel B 

* up to S&P 1500
xtset fyear
xtreg ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==2 , fe vce(robust)
outreg2 using table_5_med.doc, replace ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if  age_q==2,  ll(0)   iterate(5)
outreg2 using table_5_med.doc, append ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* up to S&P 1500
xtset fyear
xtreg ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==2, fe vce(robust)
outreg2 using table_5_med.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if  age_q==2,  ll(0)   iterate(5)
outreg2 using table_5_med.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel C 

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if  age_q==1, fe vce(robust)
outreg2 using table_5_young.doc, replace ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==1,  ll(0)   iterate(5)
outreg2 using table_5_young.doc, append ctitle("ln(1+n of patents)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==1 , fe vce(robust)
outreg2 using table_5_young.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop $l_controls_priorlit $l_controls  i.fyear if age_q==1,  ll(0)   iterate(5)
outreg2 using table_5_young.doc, append ctitle("ln(1+n of cites)") keep( l_stock_prop_dir l_option_prop_dir l_stock_prop l_option_prop ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)





///* Appendix *///

* Table A1 

	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear   , fe vce(robust)
outreg2 using table_a1a.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls_priorlit $l_controls) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear   ,  ll(0)   iterate(5)
outreg2 using table_a1a.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls_priorlit $l_controls) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear   , fe vce(robust)
outreg2 using table_a1a.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls_priorlit $l_controls) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear   ,  ll(0)   iterate(5)
outreg2 using table_a1a.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls_priorlit $l_controls) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)




* Table A2 - delta and vega and size

	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_a1a_500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_a1a_500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_a1a_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_a1a_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel B 

* up to S&P 1500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==1 & sp_500==0, fe vce(robust)
outreg2 using table_a1b_not500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==1  & sp_500==0,  ll(0)   iterate(5)
outreg2 using table_a1b_not500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* up to S&P 1500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==1 & sp_500==0, fe vce(robust)
outreg2 using table_a1b_not500.doc, append ctitle("ln(1+n of cites)") keep(  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==1  & sp_500==0,  ll(0)   iterate(5)
outreg2 using table_a1b_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel C 

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==0 , fe vce(robust)
outreg2 using table_a1c_not1500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==0,  ll(0)   iterate(5)
outreg2 using table_a1c_not1500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==0 , fe vce(robust)
outreg2 using table_a1c_not1500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_1500==0,  ll(0)   iterate(5)
outreg2 using table_a1c_not1500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



* Table A3 - delta and vega and size


	* Panel A 
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==3 , fe vce(robust)
outreg2 using table_a3_old.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==3 ,  ll(0)   iterate(5)
outreg2 using table_a3_old.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==3 , fe vce(robust)
outreg2 using table_a3_old.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==3 ,  ll(0)   iterate(5)
outreg2 using table_a3_old.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel B 

* up to S&P 1500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==2, fe vce(robust)
outreg2 using table_a3_med.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if  age_q==2,  ll(0)   iterate(5)
outreg2 using table_a3_med.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* up to S&P 1500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==2, fe vce(robust)
outreg2 using table_a3_med.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==2,  ll(0)   iterate(5)
outreg2 using table_a3_med.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



	* Panel C 

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==1 , fe vce(robust)
outreg2 using table_a3_young.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==1,  ll(0)   iterate(5)
outreg2 using table_a3_young.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==1 , fe vce(robust)
outreg2 using table_a3_young.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if age_q==1,  ll(0)   iterate(5)
outreg2 using table_a3_young.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity  ln_l_vega ln_l_delta) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)












* Other Breakdowns :




* Competition or market concentration acts as a governance mechanism/monitoring effect for CEO => 
* => firms in high competition (high HHI) will have a positive effect of dir equity 
* => firms in low competition (low HHI) will have a negative effect of dir equity 

* comp 3 is low competition
* comp 1 is high competition
gen competition=(-1)*hhi
xtile comp_q = competition, nq(3)

xtile fluid_q = prodmktfluid, nq(3)

gen competition2=(-1)*l_hhi
xtile comp_q2 = competition2, nq(3)

xtile size_q = at, nq(10)
xtile age_q = age, nq(10)
xtile mb_q = mb, nq(10)
xtile roa_q = roa, nq(10)


* debt/assets 
by gvkey: gen debt=dltt[_n-1]/at[_n-1]
xtile debt_q = debt, nq(3)
xtile ch_q = l_ch, nq(3)
xtile mb_q = l_mb, nq(3)

xtile monitor_q = l_boardintensemonitor, nq(2)

xtile indep_q = l_pctindep, nq(3)
xtile diver_q = l_diversity, nq(3)
xtile roa_q = l_roa, nq(3)

by gvkey: gen l_pctintensemonitor=pctintensemonitor[_n-1]
xtile mon_q = l_pctintensemonitor, nq(3)


xtset fyear
xtset gvkey
sum hhi if comp_q==1
xtreg did_ma l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_4b_young.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q==3, fe vce(robust)


* benefit of advising > cost of monitoring (in high competition firms because additional board monitoring is not so costly for them as they're already monitored by competitors)
* benefits of advisisng < cost of monitoring (in low competition firms because low competition implies no external monitoring)


* Panel A - low competition
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity l_hhi $l_controls_priorlit $l_controls  i.fyear if comp_q2==3, fe vce(robust)
outreg2 using table_5a_no_comp.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity l_hhi $l_controls_priorlit $l_controls  i.fyear if comp_q2==3,  ll(0)   iterate(5)
outreg2 using table_5a_no_comp.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, YES) label noni  pdec(3) dec(3)

xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==3 , fe vce(robust)
outreg2 using table_5a_no_comp.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==3,  ll(0)   iterate(5)
outreg2 using table_5a_no_comp.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, YES) label noni  pdec(3) dec(3)



* Panel B -  medium competition
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==2, fe vce(robust)
outreg2 using table_5a_med_comp.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==2,  ll(0)   iterate(5)
outreg2 using table_5a_med_comp.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, YES) label noni  pdec(3) dec(3)

xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==2 , fe vce(robust)
outreg2 using table_5a_med_comp.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==2,  ll(0)   iterate(5)
outreg2 using table_5a_med_comp.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, YES) label noni  pdec(3) dec(3)




* Panel C -  high competition
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==1, fe vce(robust)
outreg2 using table_5a_high_comp.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==1,  ll(0)   iterate(5)
outreg2 using table_5a_high_comp.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, YES) label noni  pdec(3) dec(3)

xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==1 , fe vce(robust)
outreg2 using table_5a_high_comp.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, NO) label noni   pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites  l_t_equity_dir l_t_equity $l_controls_priorlit $l_controls  i.fyear if comp_q2==1,  ll(0)   iterate(5)
outreg2 using table_5a_high_comp.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ) addtext(Controls, YES, Year FE, YES, Firm FE, YES) label noni  pdec(3) dec(3)









///******* Appendix with Delta/Vega *******///


* Table 1 - Quantity 

	* Panel B - with Delta/Vega
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_1b.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset ffi
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_1b.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, YES, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset iyfe		
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit  $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_1b.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, NO, Industry FE, NO, Industry x Year, YES, Firm FE, NO) label noni pdec(3) dec(3)

xtset gvkey
xtreg ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_1b.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear ,  ll(0)   iterate(5)
outreg2 using table_1b.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



* Table 2 - Quality 

	* Panel B - with Delta/Vega
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_2b.doc, replace ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset ffi
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_2b.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, YES, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset iyfe		
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit  $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_2b.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, NO, Industry FE, NO, Industry x Year, YES, Firm FE, NO) label noni pdec(3) dec(3)

xtset gvkey
xtreg ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear  , fe vce(robust)
outreg2 using table_2b.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear ,  ll(0)   iterate(5)
outreg2 using table_2b.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls) addtext(Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)



* Table 3 - Quantity S&P 500 versus other 

	* Panel B - with Delta/Vega
* S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_3b_500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset ffi
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_3b_500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES,Industry FE, YES, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset iyfe		
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit  $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_3b_500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, NO, Industry FE, NO, Industry x Year, YES, Firm FE, NO) label noni pdec(3) dec(3)

xtset gvkey
xtreg ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_3b_500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_3b_500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0 , fe vce(robust)
outreg2 using table_3b_not500.doc, replace ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset ffi
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0 , fe vce(robust)
outreg2 using table_3b_not500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, YES, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset iyfe		
xtreg ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit  $l_controls  i.fyear if sp_500==0  , fe vce(robust)
outreg2 using table_3b_not500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, NO, Industry FE, NO, Industry x Year, YES, Firm FE, NO) label noni pdec(3) dec(3)

xtset gvkey
xtreg ln_total_grant_scaled  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0  , fe vce(robust)
outreg2 using table_3b_not500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_total_grant_scaled l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0,  ll(0)   iterate(5)
outreg2 using table_3b_not500.doc, append ctitle("ln(1+n of patents)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)




* Table 4 - Quality S&P 500 versus other 

	* Panel B - with Delta/Vega
* S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_4b_500.doc, replace ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset ffi
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_4b_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES,Industry FE, YES, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset iyfe		
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit  $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_4b_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, NO, Industry FE, NO, Industry x Year, YES, Firm FE, NO) label noni pdec(3) dec(3)

xtset gvkey
xtreg ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 , fe vce(robust)
outreg2 using table_4b_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==1 ,  ll(0)   iterate(5)
outreg2 using table_4b_500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* not S&P 500
xtset fyear
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0 , fe vce(robust)
outreg2 using table_4b_not500.doc, replace ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset ffi
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0 , fe vce(robust)
outreg2 using table_4b_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, YES, Industry x Year, NO, Firm FE, NO) label noni   pdec(3) dec(3)

xtset iyfe		
xtreg ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit  $l_controls  i.fyear if sp_500==0  , fe vce(robust)
outreg2 using table_4b_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, NO, Industry FE, NO, Industry x Year, YES, Firm FE, NO) label noni pdec(3) dec(3)

xtset gvkey
xtreg ln_cites  l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0  , fe vce(robust)
outreg2 using table_4b_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)

* limit number of iterations of Max likelihood
xtset gvkey
xttobit ln_cites l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit $l_controls  i.fyear if sp_500==0,  ll(0)   iterate(5)
outreg2 using table_4b_not500.doc, append ctitle("ln(1+n of cites)") keep( l_t_equity_dir l_t_equity ln_l_vega ln_l_delta ) addtext(Controls, YES, Year FE, YES, Industry FE, NO, Industry x Year, NO, Firm FE, YES) label noni  pdec(3) dec(3)










* To Do: 
* check the signs of control variables, check data correctly pulled (analys coverage wrong, insts own, liquidity)

* Total Grants (ln_total_grant)
* Total Grants with prior lit 
* Total Grants for S&P1500 vs not 
* Total Grants with Firm FE with Jared's tobit transformation
* Split equity = options + stock (l_stock_prop_dir l_option_prop_dir)
 
* Total Citations (ln_cites_w)
* Total Citations with prior lit 
	
* Total Value of a Patent (xi_total_w)
* Total Value of a Patent  with prior lit 

* M&A (did_ma) (only for S&P 1500 sample)
* M&A  with prior lit 


* With Delta/Vega
* Total Grants with prior lit & delta/vega
* Total Citations with prior lit & delta/vega
	* break S&P 1500 vs not (looks like - effect in S&P1500)
* Total Value of a Patent with prior lit & delta/vega



xtreg ln_cites_w  l_t_equity_dir l_t_equity $l_controls  i.fyear  , fe vce(robust)
xtreg ln_cites_w  l_t_equity_dir l_t_equity c.l_t_equity_dir#c.sp_500 sp_500 $l_controls  i.fyear  , fe vce(robust)


global l_controls "l_ln_at l_ch l_mb l_capx l_xrd l_roa"

		replace cites_scaled=0 if missing(cites_scaled)
		winsor2 cites_scaled, cuts(1 99) by(fyear)
		gen ln_cites_scaled=ln(1+cites_scaled_w)

winsor2 total_appl, cuts(1 99) by(fyear)

* Quantity
ln_total_grant
ln_total_grant_scaled
ln_total_appl_scaled

* Quality
ln_cites_w
xi_total


cites_scaled

xi_total_w 
xi_total



l_stock_prop_dir l_option_prop_dir


* With Delta / Vega

* Strongest Specification 
xtreg ln_total_grant l_t_equity_dir l_t_equity ln_l_vega ln_l_delta $l_controls_priorlit_1  $l_controls  i.fyear  , fe vce(robust)

xtreg ln_total_grant l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls  i.fyear  , fe vce(robust)

* strongest that works 
xtset fyear
xtset iyfe		
xtset gvkey
xtreg ln_total_grant l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls $l_controls_priorlit_1 i.fyear if sp_500==0 & sp_1500==1, fe vce(robust)
xtreg ln_total_grant l_t_equity_dir l_t_equity ln_l_vega ln_l_delta  $l_controls $l_controls_priorlit_1 i.fyear if sp_500==0 & sp_1500==1, fe vce(robust)


xtset fyear
xtset ffi
xtset iyfe		
xtset gvkey
xtreg xi_total_w l_t_equity_dir l_t_equity $l_controls  i.fyear if sp_1500==0 , fe vce(robust)

xtreg ln_cites_scaled  l_t_equity_dir l_t_equity $l_controls  i.fyear  , fe vce(robust)

xtreg xi_total_w l_t_equity_dir l_t_equity $l_controls  i.fyear , fe vce(robust)





* total obs with Jared's CEO data - 24,286 (12.6 for S&P and 11.6 for non)




  