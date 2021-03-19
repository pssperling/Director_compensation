/* Get CRSP-Compustat Financial Data*/

LIBNAME comp 'R:\ps664\Patent Applications - Michelle Michela';

%LET wrds=wrds.wharton.upenn.edu 4016;
OPTIONS COMAMID=TCP REMOTE=WRDS;
SIGNON USERNAME=_prompt_;



/* Import Firm-Board data*/
PROC IMPORT
	DATAFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\Boardex 2020\NA - Board Summary - 1.xlsx'
	DBMS=xlsx
	OUT=board_data1
	REPLACE;
RUN;


/* Import Firm-Board data*/
PROC IMPORT
	DATAFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\Boardex 2020\NA - Board Summary - 2.xlsx'
	DBMS=xlsx
	OUT=board_data2
	REPLACE;
RUN;


/* Import Firm-Board data*/
PROC IMPORT
	DATAFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\Boardex 2020\NA - Board Summary - 3.xlsx'
	DBMS=xlsx
	OUT=board_data3
	REPLACE;
RUN;


/* To convert from ISIN to CUSIP, remove ifrst two letters from ISIN (e.g. US) and remove the last digit (encoded security check)*/
data board_data;
set   board_data1 board_data2 board_data3;
 cusip= SUBSTR(ISIN,3,8);
 year_=year(Annual_Report_Year);
run;




/* Import Dir Employment data*/
PROC IMPORT
	DATAFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\Boardex 2020\NA - Director Profile - Employment Historical Board - 1.xlsx'
	DBMS=xlsx
	OUT=board_employ1
	REPLACE;
RUN;


/* Import Dir Employment data*/
PROC IMPORT
	DATAFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\Boardex 2020\NA - Director Profile - Employment Historical Board - 2.xlsx'
	DBMS=xlsx
	OUT=board_employ2
	REPLACE;
RUN;

data board_employ;
set   board_employ1 board_employ2 ;
run;
		

/* Import VC data*/
PROC IMPORT
	DATAFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\vc_data.xlsx'
	DBMS=xlsx
	OUT=vc_data
	REPLACE;
RUN;

/* Make a list of VC firms*/
proc sort nodupkey data = vc_data out=vc_list_1 ; by Fund_Name; run;
data vc_list_2;
set   vc_list_1 (keep = Fund_Name); 
run;


/* Make a list of Director's employment*/
data board_e_list_1;
set   board_employ (keep = Sector_Name DirectorID_ director_name CompanyID_ Company_Name Start_date end_date);
rename CompanyID_ = CompanyID;
rename DirectorID_ = DirectorID;
if find(Company_Name,"Venture") then vc=1;
run;


	
data board_e_list_2;
  set board_e_list_1;
  comp_name = prxchange('s/\(([^\)]+)\)//i', -1, Company_Name);
  drop Company_Name;
  if start_date="UnKnown" then start_date="";
  if end_date="UnKnown" then end_date="";
run;
proc sort nodupkey data = board_e_list_2 out=board_e_list_3 ; by DirectorID comp_name; run;


/* Standardize company names*/
DATA board_e_list_3;
	SET board_e_list_2;
	formatted_conm  = COMPRESS(UPCASE(comp_name),".");
	letter_dir=substr(formatted_conm,1,1);	
	formatted_conm  = TRANWRD(formatted_conm,"EMC CORP/MA",'EMC');										
	formatted_conm  = TRANWRD(formatted_conm,"&",' AND ');
	formatted_conm  = TRANWRD(formatted_conm,"+",' AND ');
	formatted_conm  = TRANSLATE(formatted_conm,' ',"!(),/:?-");
	formatted_conm  = TRANWRD(formatted_conm,' LLC',"");
	formatted_conm  = TRANWRD(formatted_conm,' LP','');
	formatted_conm  = TRANWRD(formatted_conm,'THE ','');
	formatted_conm  = TRANWRD(formatted_conm,'FINANCIAL','FINL');
	formatted_conm  = TRANWRD(formatted_conm,' INTERNATIONAL',' INTL');
	formatted_conm  = TRANWRD(formatted_conm,' COMPANY',' CO');
	formatted_conm  = TRANWRD(formatted_conm,' CORPORATION',' CORP');
	formatted_conm  = TRANWRD(formatted_conm,' INCORP','');
	formatted_conm  = TRANWRD(formatted_conm,' INC','');
	formatted_conm  = TRANWRD(formatted_conm,' LIMITED','');
	/*formatted_conm  = TRANWRD(formatted_conm,' INDUSTRIES','');*/
	formatted_conm  = TRANWRD(formatted_conm,' CC','');
	formatted_conm  = TRANWRD(formatted_conm,' LTD','');
	formatted_conm  = TRANWRD(formatted_conm,'L L C','');
	formatted_conm  = TRANWRD(formatted_conm,' AG ','');
	formatted_conm  = TRANWRD(formatted_conm,' PLC ','');
	formatted_conm  = TRANWRD(formatted_conm,' SYSTEMS','S');
	formatted_conm  = TRANWRD(formatted_conm,' LIMITED PARTNERSHIP','');
	formatted_conm  = TRANWRD(formatted_conm,')','');
	formatted_conm  = TRANWRD(formatted_conm," INT'L",'INTL');
	formatted_conm  = TRANWRD(formatted_conm," ET AL",'');
	formatted_conm  = TRANWRD(formatted_conm," COMPANIES",'COS');
	formatted_conm  = TRANWRD(formatted_conm," US ",'');
	formatted_conm  = TRANWRD(formatted_conm," ORPORATED",'CORP');
	formatted_conm  = TRANWRD(formatted_conm," SOLTNS",' SOLUTIONS');
	formatted_conm  = TRANWRD(formatted_conm," SYS ",' S ');
	formatted_conm  = TRANWRD(formatted_conm," PRODUCTS",' PROD');
	formatted_conm  = TRANWRD(formatted_conm,"'S",'S');
	formatted_conm  = TRANWRD(formatted_conm," LABORATORY",' LAB');
	formatted_conm  = TRANWRD(formatted_conm," LABORATORIES",' LAB');
	formatted_conm  = TRANWRD(formatted_conm," LABORATO",' LAB');
	formatted_conm  = TRANWRD(formatted_conm," PHARMACEUTICALS",' PHARMA');
	formatted_conm  = TRANWRD(formatted_conm," PHARMACEUTICAL",' PHARMA');
	formatted_conm  = TRANWRD(formatted_conm," PHARMACEUTIC",' PHARMA');
	formatted_conm  = TRANWRD(formatted_conm," PHARMACEUT",' PHARMA');
	formatted_conm  = TRANWRD(formatted_conm,' TECHNOLOGIES',' TECH');
	formatted_conm  = TRANWRD(formatted_conm," TECHNOLOGY",' TECH');
	formatted_conm  = TRANWRD(formatted_conm," TECHNOL",' TECH');
	formatted_conm  = TRANWRD(formatted_conm," TECHN",' TECH');
	formatted_conm  = TRANWRD(formatted_conm,"'",'');
	formatted_conm  = TRANWRD(formatted_conm," CL A",'');
	formatted_conm  = TRANWRD(formatted_conm," CL B",'');
	formatted_conm  = TRANWRD(formatted_conm," REDH ",'');
	formatted_conm  = TRANWRD(formatted_conm," CORPP",'');
	formatted_conm  = TRANWRD(formatted_conm," CORP",'');
	formatted_conm  = TRANWRD(formatted_conm," COR",'');
	formatted_conm  = TRANWRD(formatted_conm," COMPANIES",'');
	formatted_conm  = TRANWRD(formatted_conm," COMPANY",'');
	formatted_conm  = TRANWRD(formatted_conm," COS ",'');
	formatted_conm  = TRANWRD(formatted_conm," CO ",'');
	formatted_conm  = TRANWRD(formatted_conm," OLD ",'');
	formatted_conm  = TRANWRD(formatted_conm," HLDGS",'');
	formatted_conm  = TRANWRD(formatted_conm," INTL",'');
	formatted_conm  = TRANWRD(formatted_conm," GROUP",'');
	formatted_conm  = TRANWRD(formatted_conm," GBR",'');
	if find(formatted_conm, 'INTL BUSINESS MACHINES') then formatted_conm="INTL BUSINESS MACHINES";
	if find(formatted_conm, 'NORTEL NETWORKS') then formatted_conm="NORTEL NETWORKS";
	if find(formatted_conm, 'UNITED TECH') then formatted_conm="UNITED TECH";
	if find(formatted_conm, "DISNEY  WALT") then formatted_conm="WALT DISNEY";
RUN;



/* Standardize company names*/
DATA vc_list_3;
	SET vc_list_2;
	Fund_Name_formatted  = COMPRESS(UPCASE(Fund_Name),".");
	letter_fund=substr(Fund_Name_formatted,1,1);	
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"EMC CORP/MA",'EMC');										
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"&",' AND ');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"+",' AND ');
	Fund_Name_formatted  = TRANSLATE(Fund_Name_formatted,' ',"!(),/:?-");
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' LLC',"");
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' LP','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,'THE ','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,'FINANCIAL','FINL');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' INTERNATIONAL',' INTL');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' COMPANY',' CO');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' CORPORATION',' CORP');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' INCORP','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' INC','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' LIMITED','');
	/*Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' INDUSTRIES','');*/
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' CC','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' LTD','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,'L L C','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' AG ','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' PLC ','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' SYSTEMS','S');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' LIMITED PARTNERSHIP','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,')','');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," INT'L",'INTL');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," ET AL",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," COMPANIES",'COS');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," US ",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," ORPORATED",'CORP');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," SOLTNS",' SOLUTIONS');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," SYS ",' S ');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," PRODUCTS",' PROD');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"'S",'S');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," LABORATORY",' LAB');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," LABORATORIES",' LAB');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," LABORATO",' LAB');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," PHARMACEUTICALS",' PHARMA');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," PHARMACEUTICAL",' PHARMA');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," PHARMACEUTIC",' PHARMA');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," PHARMACEUT",' PHARMA');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,' TECHNOLOGIES',' TECH');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," TECHNOLOGY",' TECH');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," TECHNOL",' TECH');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," TECHN",' TECH');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"'",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," CL A",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," CL B",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," REDH ",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," CORPP",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," CORP",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," COR",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," COMPANIES",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," COMPANY",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," COS ",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," CO ",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," OLD ",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," HLDGS",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," INTL",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," GROUP",'');
	Fund_Name_formatted  = TRANWRD(Fund_Name_formatted," GBR",'');
	if find(Fund_Name_formatted, 'INTL BUSINESS MACHINES') then Fund_Name_formatted="INTL BUSINESS MACHINES";
	if find(Fund_Name_formatted, 'NORTEL NETWORKS') then Fund_Name_formatted="NORTEL NETWORKS";
	if find(Fund_Name_formatted, 'UNITED TECH') then Fund_Name_formatted="UNITED TECH";
	if find(Fund_Name_formatted, "DISNEY  WALT") then Fund_Name_formatted="WALT DISNEY";
RUN;

/* keep only names of companies where directors worked*/

data board_list;
	set board_e_list_3 (keep = formatted_conm comp_name);
run;
proc sort nodupkey data = board_list; by  formatted_conm; run;

proc sort nodupkey data = vc_list_3; by  Fund_Name_formatted; run;


/* take the first letter of a company*/
data board_list;
	set board_list ;
	letter_dir = substr(formatted_conm, 1, 1);
	if letter_dir=" " then letter_dir= substr(formatted_conm, 2, 1);
run;
data vc_list_4;
	set vc_list_3 ;
	letter_fund = substr(Fund_Name_formatted, 1, 1);
	if letter_fund=" " then letter_fund= substr(Fund_Name_formatted, 2, 1);
run;

				/* Director match*/
				PROC SQL ;
					CREATE TABLE match_1 AS
					SELECT *
					FROM board_list AS l LEFT JOIN vc_list_4 AS r
					ON	l.formatted_conm = r.Fund_Name_formatted ;
				QUIT;
				data match_final1;
					set match_1 ;
					if not missing(Fund_Name_formatted);
				run;

				data board_list_vc (drop = Fund_Name letter_fund);
					set match_1 ;
					if missing(Fund_Name_formatted);
					if find(formatted_conm, "VENTURE") then vc=1;
					if find(formatted_conm, "EQUITY") then vc=1;
					if find(formatted_conm, "INVEST") then vc=1;
					if find(formatted_conm, "FUND") then vc=1;
					if find(formatted_conm, "CAPITAL") then vc=1;
					if find(formatted_conm, "SECURIT") then vc=1;
					drop Fund_Name_formatted;
					if vc=1;
				run;


				/* Submit the request to WRDS computer*/
				/* checks 22 mill potential matches*/
				RSUBMIT;
				proc upload data=board_list_vc ;
				run;
				proc upload data=vc_list_4 ;
				run;
				proc sort data = vc_list_4; by letter_fund; run;
				proc sort data = board_list_vc; by  letter_dir ; run;

				/* Create the potential matches*/
				PROC SQL ;
					CREATE TABLE potential_matches AS
					SELECT *
					FROM board_list_vc AS l LEFT JOIN  vc_list_4 AS r
					ON	l.letter_dir = r.letter_fund;
				QUIT;
				data potential_matches_1;
					set potential_matches;
					gedscore = spedis(formatted_conm, Fund_Name_formatted);
				run;
				proc sort data = potential_matches_1 ; by formatted_conm gedscore; run;
				data potential_matches_2;
				  set potential_matches_1;
				  top_5 + 1;
				  by  formatted_conm  ;
				  if first.formatted_conm  then top_5 = 1;
				run;
				data potential_matches_3;
				  set potential_matches_2;
				  if top_5 < 4 ;
				run;

				PROC DOWNLOAD DATA=potential_matches_3 OUT=match_2;
				RUN;

				ENDRSUBMIT;


				proc sort data = match_2 ; by gedscore; run;

				/* Recalculate distance score*/
				data match_3;
					set match_2;
					Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"VENTURE",'');
					Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"EQUITY",'');
					Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"INVEST",'');
					Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"FUND",'');
					Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"CAPITAL",'');
					Fund_Name_formatted  = TRANWRD(Fund_Name_formatted,"SECURIT",'');

					formatted_conm  = TRANWRD(formatted_conm,"VENTURE",'');
					formatted_conm  = TRANWRD(formatted_conm,"EQUITY",'');
					formatted_conm  = TRANWRD(formatted_conm,"INVEST",'');
					formatted_conm  = TRANWRD(formatted_conm,"FUND",'');
					formatted_conm  = TRANWRD(formatted_conm,"CAPITAL",'');
					formatted_conm  = TRANWRD(formatted_conm,"SECURIT",'');
					gedscore_2 = spedis(formatted_conm, Fund_Name_formatted);
					if gedscore_2<18;
				run;
				proc sort data = match_3 ; by gedscore_2; run;		
	
				data match_final2 (keep = comp_name formatted_conm Fund_Name Fund_Name_formatted letter_dir letter_fund);
				  set match_3;
				  if gedscore_2<18;
				run;

				data all_matches;
				  set match_final1 match_final2;	 
				drop Fund_Name_formatted letter_dir letter_fund; 
				rename comp_name = comp_name_;
				run;
				proc sort data = all_matches ; by comp_name_ ; run;		
					
				/* Merge back to Director ID data using company name*/
				PROC SQL ;
					CREATE TABLE board_e_list_vc AS
					SELECT *
					FROM board_e_list_3 AS l LEFT JOIN all_matches AS r
					ON	l.comp_name = r.comp_name_ ;
				QUIT;

				data board_e_list_vc1;
				  set board_e_list_vc;	 
				if not missing(Fund_Name);
				drop formatted_conm vc letter_dir comp_name_ CompanyID Sector_Name comp_name ;	
				vc =1;
				run;

				proc sort nodupkey data = board_e_list_vc1 ; by DirectorID Start_Date End_Date ; run;	


				/* Merge to company list dataset using director_id*/
				data board_data_short ( keep = cusip year_ CompanyID_ Annual_Report_Year ISIN DirectorID_ Individual_Name);
					set board_data ;
					year_ = SUBSTR(Annual_Report_Year,4,5);
				run;

				/* Restrict to only directors that will be in the final dataset (work for companies in the final dataset*/
				PROC SQL ;
					CREATE TABLE firm_dir_vc AS
					SELECT *
					FROM board_data_short AS l LEFT JOIN board_e_list_vc1 AS r
					ON l.DirectorID_ = r.DirectorID;
				QUIT;

				proc sort data = firm_dir_vc ; by CompanyID_ Annual_Report_Year DirectorID_ Start_Date End_Date ; run;	

				/* Ignore start end date of the VC job*/
				data firm_dir_vc1 (keep = vc cusip_8 Fund_name  year ISIN Individual_Name );
					set firm_dir_vc ;
					if not missing(Fund_Name);
					vc=1;
					rename year_ = year;
					rename cusip = cusip_8;
				run;


				proc sort nodupkey data = firm_dir_vc1 ; by cusip_8 year ; run;	



PROC EXPORT
	DATA=firm_dir_vc1
	DBMS=dta
	OUTFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\VC directors\firm_dir_vc.dta'
	REPLACE;
RUN;




/*********** Get Liquidity data based on Amihud (2002) from daily CRSP data *************/

%LET wrds=wrds.wharton.upenn.edu 4016;
OPTIONS COMAMID=TCP REMOTE=WRDS;
SIGNON USERNAME=_prompt_;

/*Liquidity - is the average of the daily ratio of absolute return (mode(return)) to the dollar volumne for a stock in a given year*/

/* The illiquidity measure here is the average across stocks of the daily ratio 
of absolute stock return to dollar volume, which is easily obtained from daily stock data for long time series in most stock markets.*/
/* Amihud: https://www.sciencedirect.com/science/article/abs/pii/S1386418101000246 */

/* Replication: https://cfr.ivo-welch.info/forthcoming/harris-amato-2018.pdf */
/* Replication: ILLIQ: The annual mean of the stock’s daily illiquidity measure. Because the illiquidity measure
varies substantially over the years, and in particular, decreases substantially during the sample period,
in the cross-sectional analysis we normalize all values by dividing them by their cross-sectional mean
in each month. This monthly rescaling has no effect on the monthly cross-sectional regressions, but
stabilizes the estimated regression coefficient. Amihud calls the mean-adjusted version of the
illiquidity variable “ILLIQMA.”*/


/****  Assemble CRSP Daily Data ****/
RSUBMIT;
/*Pull data from CRSP 'Monthly Stock - Securities' file*/
DATA msf1 (DROP=shrout);
	SET crsp.dsf (KEEP =  permno date ret vol prc );
	WHERE 2000 <= year(date) <= 2019;
	IF NOT MISSING(ret) AND vol>=0;  *require non-missing stock data;
RUN;
PROC DOWNLOAD DATA=msf1 OUT=msf1;
RUN;
ENDRSUBMIT;


data msf2 ;
set msf1;
year=year(DATE);
month=month(DATE);
day=day(DATE);
*abs_ret=abs(ret);
average_daily = abs(ret/(vol*prc));
average_daily_absret = abs(ret)/(vol*prc);
run;

/* Scale by the average of a month following https://cfr.ivo-welch.info/forthcoming/harris-amato-2018.pdf */
/* not sure if I have to scale by a firm's month avergae or by all firms' month average*/
proc sql;
create table msf2_scaled as
select *, avg(average_daily) as scale_by, avg(average_daily_absret) as scale_by_absret
from msf2
group by year, month
order by  year, month;
quit;


proc sql;
create table msf3 as
select *, avg(average_daily/scale_by) as liquidity_sc , avg(average_daily) as liquidity, avg(average_daily_absret) as liquidity_absret, avg(average_daily_absret/scale_by_absret) as liquidity_sc_absret
from msf2_scaled
group by permno, year 
order by permno, year;
quit;

proc sort nodupkey data = msf3 out = msf4 ; by permno year  ; run;	



PROC EXPORT 
	DATA=msf4
	DBMS=dta
	OUTFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data\liquidity.dta'
	REPLACE;
RUN;




/*********** Get gvkey to instit own data ****************/


LIBNAME comp "R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data";



data inst_own ;
set comp.IBES_Forecasts_0019;
run;


PROC EXPORT 
	DATA=inst_own
	DBMS=dta
	OUTFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data\IBES_Forecasts_0019.dta'
	REPLACE;
RUN;




RSUBMIT;

/****************************************************************************
BEGIN INITIALIZE MACRO FOR CUSIP TO PERMNO/GVKEY MATCH: 
****************************************************************************/;
%macro cusiptopermnogvkey(
dsetin      = , 
dsetout     = , 
inputcusip  = ,
inputticker = ,
inputname   = ,
inputdate   = );
/** Suppress log file while macro runs;*/
/*filename junk dummy;proc printto log=junk; run;*/
%if &dsetout = %then %let dsetout = &dsetin;
data dsetin; set &dsetin;
MACROPRIMARYKEY = _N_;
run;
data dsetworking; set dsetin;
KEEP MACROPRIMARYKEY &inputticker &inputcusip &inputname &inputdate;
run;
/* END INITIALIZE MACRO */;



/*************************************************************************
BEGIN CREATE CUSIP / PERMNO / PERMCO <-> GVKEY LOOKUP TABLE: 
*************************************************************************/;
* Generate unique PERMNO -> GVKEY relation;
proc sort data= a_ccm.CCMXPF_LINKTABLE out=lnk;
  where LINKTYPE in ("LU", "LC", "LD", "LF", "LN", "LO", "LS", "LX") 
  and   USEDFLAG = 1;
  by GVKEY LINKDT;
run;
* Link each PERMNO / CUSIP /  Company Name combination to GVKEY;
* Note: This step inflates the number of obs due to overlapping link windows;
proc sql;
create table LinkageTablePERMNOCUSIPGVKEY
as select stk.PERMNO, stk.PERMCO, lnk.GVKEY, stk.CUSIP, stk.NCUSIP, 
substr(stk.NCUSIP,1,6) as CN6, stk.TICKER, stk.COMNAM, 
stk.NAMEDT, stk.NAMEENDDT, lnk.LINKDT, lnk.LINKENDDT
from a_ccm.stocknames as stk LEFT JOIN lnk as lnk
on   stk.PERMNO     = lnk.LPERMNO                          and
    (stk.NAMEENDDT >= lnk.LINKDT    or lnk.LINKDT    = .B) and 
	(stk.NAMEDT    <= lnk.LINKENDDT or lnk.LINKENDDT = .E);
quit;
* Adjust for overlaps in the link windows;
data LinkageTablePERMNOCUSIPGVKEY; set LinkageTablePERMNOCUSIPGVKEY;
if MISSING(NCUSIP) then do;
	CN6 = substr(CUSIP,1,6);
end;
FORMAT NAMEDT NAMEENDDT LINKDT LINKENDDT DATE9.;
if NAMEDT    < LINKDT    AND NOT(MISSING(LINKDT))    then NAMEDT    = LINKDT;
if NAMEENDDT > LINKENDDT AND NOT(MISSING(LINKENDDT)) then NAMEENDDT = LINKENDDT;
LABEL CN6 = 'Six-Digit Historical CUSIP';
run;
proc sort data = LinkageTablePERMNOCUSIPGVKEY nodupkey;
by CN6 PERMNO NCUSIP NAMEDT;
run;
/* END CREATE CUSIP / PERMNO / PERMCO <-> GVKEY LOOKUP TABLE */;



/*************************************************************************
BEGIN STEP 1 - LINK BY CUSIP: 
*************************************************************************/;
/* INPUT DATA: Get the list of CUSIPS / TICKERS for firms in input data */
proc sort data = dsetworking 
          out  = dsetcusips 
         (keep = MACROPRIMARYKEY &inputticker &inputcusip &inputname &inputdate);
where not(missing(&inputcusip));
by &inputticker &inputcusip &inputdate;
run;
/* CRSP: Get all PERMNO-NCUSIP combinations */
proc sort data = LinkageTablePERMNOCUSIPGVKEY 
          out  = CRSP1 
         (keep = GVKEY PERMNO PERMCO CN6 TICKER comnam namedt nameenddt);
where not missing(CN6);
by PERMNO CN6 namedt;
run;
/* Arrange effective dates for CUSIP link */
proc sql;
create table CRSP2
as select GVKEY,PERMNO,PERMCO,comnam,
          TICKER             as CRSPTICKER,
          CN6                as CRSPCUSIP,
          min(namedt)        as crspcusipdt,
          max(nameenddt)     as crspcusipenddt,
          namedt,nameenddt
from CRSP1
group by PERMNO, CRSPCUSIP
order by PERMNO, CRSPCUSIP, NAMEDT;
quit;
/* Label date range variables */
data CRSP2; set CRSP2;
label crspcusipdt    = "Start date of CUSIP record";
label crspcusipenddt = "End date of CUSIP record";
format crspcusipdt crspcusipenddt date9.;
run;
/* Create CUSIP Link Table */ 
/* CUSIP date ranges are only used in scoring as CUSIPs are not reused for 
    different companies overtime */
proc sql;
create table LINK1_1
as select *
from dsetworking as a, CRSP2 as b
where a.&inputcusip = b.CRSPCUSIP
order by &inputcusip, &inputdate, PERMNO;
quit;
/* Score links using CUSIP date range and company name spelling distance */
data LINK1_2; set LINK1_1;
INPUTNAMESPEDIS  = COMPRESS(UPCASE(&inputname),".");
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,"&",' AND ');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,"+",' AND ');
INPUTNAMESPEDIS  = TRANSLATE(INPUTNAMESPEDIS,' ',"!(),/:?-");
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'LLC',"");
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'INC','');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'LP','');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'THE ','');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'FINANCIAL','FINL');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'INTERNATIONAL','INTL');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'COMPANY','CO');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'CORPORATION','CORP');
CRSPNAMESPEDIS   = COMPRESS(UPCASE(COMNAM),".");
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,"&",' AND ');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,"+",' AND ');
CRSPNAMESPEDIS   = TRANSLATE(CRSPNAMESPEDIS,' ',"!(),/:?-");
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'LLC',"");
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'INC','');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'LP','');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'THE ','');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'FINANCIAL','FINL');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'INTERNATIONAL','INTL');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'COMPANY','CO');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'CORPORATION','CORP');
name_dist = min(spedis(INPUTNAMESPEDIS,CRSPNAMESPEDIS),
                spedis(CRSPNAMESPEDIS,INPUTNAMESPEDIS));
ticker_dist = min(spedis(&inputticker,CRSPTICKER),
                spedis(CRSPTICKER,&inputticker));
if missing(&inputticker) then ticker_dist = 999;
if NAMEDT    <= &inputdate <= NAMEENDDT then date_diff = 0;
if NAMEDT    >= &inputdate              then date_diff = NAMEDT - &inputdate;
if NAMEENDDT <= &inputdate              then date_diff = &inputdate  - NAMEENDDT;
if (not ((&inputdate<crspcusipdt) or (&inputdate>crspcusipenddt))) and name_dist < 30 then SCORE = 0;
	else if (not ((&inputdate<crspcusipdt) or (&inputdate>crspcusipenddt)))           then SCORE = 1;
	else if name_dist < 30                                                            then SCORE = 2; 
	else                                                                                   SCORE = 3;
run;
/* In the case of a duplicate match, take the lowest score match, then the closest company
name match, then the closet ticker match, then the closest date range match, and finally the
match with the largest market cap */
proc sql;
create table LINK1_2
as select a.*,abs( b.prc * b.shrout) as mktcap
from LINK1_2 as a LEFT JOIN crsp.msf as b
on a.permno            = b.permno      and 
   month(a.&inputdate) = month(b.date) and 
   year(a.&inputdate)  = year(b.date);
quit;
proc sort data = LINK1_2;
by &inputcusip &inputdate SCORE name_dist ticker_dist date_diff descending mktcap;
run;
data LINK1_2; set LINK1_2;
by &inputcusip &inputdate SCORE name_dist ticker_dist date_diff descending mktcap;
if first.&inputdate;
keep MACROPRIMARYKEY &inputcusip &inputticker &inputname &inputdate 
GVKEY PERMNO PERMCO comnam score;
run;
/* END STEP 1 - LINK BY CUSIP */;



/*************************************************************************
BEGIN STEP 2 - FIND REMAINING LINKS USING EXCHANGE TICKER: 
*************************************************************************/;
/* Identify remaining unmatched cases */
proc sql;
create table NOMATCH1
as select distinct a.*
from dsetworking as a 
where a.&inputticker NOT in (select &inputticker from LINK1_2)
order by a.&inputticker;
quit; 
/* CRSP: Get entire list of CRSP stocks with Exchange Ticker information */
proc sort data = LinkageTablePERMNOCUSIPGVKEY 
          out  = CRSP1 
         (keep = GVKEY PERMNO PERMCO CN6 TICKER comnam namedt nameenddt);
where not missing(TICKER);
by PERMNO TICKER namedt;
run;
/* Arrange effective dates for CUSIP link */
proc sql;
create table CRSP2
as select GVKEY,PERMNO,PERMCO,comnam,
          TICKER             as CRSPTICKER,
          CN6                as CRSPCUSIP,
          min(namedt)        as crsptickerdt,
          max(nameenddt)     as crsptickerenddt,
          namedt, nameenddt
from CRSP1
group by PERMNO, CRSPTICKER
order by PERMNO, CRSPTICKER, NAMEDT;
quit;
/* Label date range variables */
data CRSP2; set CRSP2;
label crsptickerdt    = "Start date of exch. ticker record";
label crsptickerenddt = "End date of exch. ticker record";
format crsptickerdt crsptickerenddt date9.;
run;
/* Merge remaining unmatched cases using Exchange Ticker */
/* Note: Use ticker date ranges as exchange tickers are reused overtime */
proc sql;
create table LINK2_1
as select a.*, b.GVKEY, b.permno, b.permco, b.comnam, b.CRSPCUSIP, b.crspticker, b.crsptickerdt, 
b.crsptickerenddt, b.NAMEDT, b.NAMEENDDT
from NOMATCH1 as a, CRSP2 as b
where a.&inputticker  = b.CRSPTICKER     and 
     (a.&inputdate   >= crsptickerdt)    and 
     (a.&inputdate   <= crsptickerenddt)
order by CRSPTICKER, &inputticker, &inputdate;
quit; 
/* Score using company name using 6-digit CUSIP and company name spelling distance */
data LINK2_2; set LINK2_1;
INPUTNAMESPEDIS  = COMPRESS(UPCASE(&inputname),".");
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,"&",' AND ');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,"+",' AND ');
INPUTNAMESPEDIS  = TRANSLATE(INPUTNAMESPEDIS,' ',"!(),/:?-");
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'LLC',"");
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'INC','');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'LP','');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'THE ','');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'FINANCIAL','FINL');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'INTERNATIONAL','INTL');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'COMPANY','CO');
INPUTNAMESPEDIS  = TRANWRD(INPUTNAMESPEDIS,'CORPORATION','CORP');
CRSPNAMESPEDIS   = COMPRESS(UPCASE(COMNAM),".");
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,"&",' AND ');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,"+",' AND ');
CRSPNAMESPEDIS   = TRANSLATE(CRSPNAMESPEDIS,' ',"!(),/:?-");
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'LLC',"");
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'INC','');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'LP','');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'THE ','');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'FINANCIAL','FINL');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'INTERNATIONAL','INTL');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'COMPANY','CO');
CRSPNAMESPEDIS   = TRANWRD(CRSPNAMESPEDIS,'CORPORATION','CORP');
name_dist = min(spedis(INPUTNAMESPEDIS,CRSPNAMESPEDIS),
                spedis(CRSPNAMESPEDIS,INPUTNAMESPEDIS));
if NAMEDT    <= &inputdate <= NAMEENDDT then date_diff = 0;
if NAMEDT    >= &inputdate              then date_diff = NAMEDT - &inputdate;
if NAMEENDDT <= &inputdate              then date_diff = &inputdate  - NAMEENDDT;
if &inputcusip = CRSPCUSIP and name_dist < 30 then SCORE = 0;
	else if &inputcusip = CRSPCUSIP           then SCORE = 4;
	else if name_dist < 30                    then SCORE = 5; 
	else                                           SCORE = 6;
run;
/* In the case of a duplicate match, take the lowest score match, then the closest company
name match, then the closest date range match, and finally the
match with the largest market cap */
proc sql;
create table LINK2_2
as select a.*,abs( b.prc * b.shrout) as mktcap
from LINK2_2 as a LEFT JOIN crsp.msf as b
on a.permno            = b.permno      and 
   month(a.&inputdate) = month(b.date) and 
   year(a.&inputdate)  = year(b.date);
quit;
proc sort data = LINK2_2;
by &inputcusip &inputdate SCORE name_dist date_diff descending mktcap;
run;
data LINK2_2; set LINK2_2;
by &inputcusip &inputdate SCORE name_dist date_diff descending mktcap;
if first.&inputdate;
keep MACROPRIMARYKEY &inputcusip &inputticker &inputname &inputdate 
GVKEY PERMNO PERMCO comnam score;
run;
/* END STEP 2 - FIND REMAINING LINKS USING EXCHANGE TICKER */;



/*************************************************************************
COMBINE LINKAGE TABLES AND IMPORT TO OUTPUT DATASET: 
*************************************************************************/;
/* Create final link table */
data LINK; set LINK1_2 LINK2_2;
run;
/* Merge to input dataset */
proc sql;
create table dsetout as
select a.*, b.GVKEY, b.PERMNO, b.PERMCO
		, b.COMNAM, b.SCORE
from dsetin as a LEFT JOIN LINK as b
on a.MACROPRIMARYKEY  = b.MACROPRIMARYKEY;
quit;
data &dsetout; set dsetout;
label CRSPNAME = "Company Name in CRSP";
label SCORE    = "Link Score: 0(best) - 6"; 
DROP MACROPRIMARYKEY;
run;

/* END LINKAGE TABLES AND IMPORT TO OUTPUT DATASET */;



/*************************************************************************
BEGIN CLEAN UP:
*************************************************************************/;
/* Clean up */
proc datasets library = work nolist;
delete dsetin dsetworking dsetout dsetcusips LinkageTablePERMNOCUSIPGVKEY
LINK1_1 LINK1_2 LINK2_1 LINK2_2 LINK LNK NOMATCH1 CRSP1 CRSP2;
run;quit;
* Turn log file back on;
/*proc printto; run;*/
/* END CLEAN UP */;
quit;
%mend cusiptopermnogvkey;
/*************************************************************************
								END OF MACRO:
*************************************************************************/;

%cusiptopermnogvkey(dsetin = inst_own ,dsetout = inst_own,inputcusip=CUSIP,inputticker = OFTIC,inputname=CNAME,inputdate=FPEDATS);

/*Extract dataset from WRDS*/
PROC DOWNLOAD DATA=inst_own_2 OUT=inst_own_2;
RUN;
ENDRSUBMIT;
/* ********************************************************************************* */



data inst_own_1 ;
set inst_own;
date2 = put ( FPEDATS, date9.);
run;

/****  Assemble CRSP Daily Data ****/
RSUBMIT;
/*Pull data from CRSP 'Monthly Stock - Securities' file*/
DATA msf1 (DROP=shrout);
	SET crsp.msf (KEEP =  permno date ret vol prc cusip Ncusip );
	WHERE 2000 <= year(date) <= 2019;
	IF NOT MISSING(ret) AND vol>=0;  *require non-missing stock data;
RUN;
PROC DOWNLOAD DATA=msf1 OUT=msf1;
RUN;
ENDRSUBMIT;

data msf2 (keep= permno cusip date year );
set msf1;
year=year(date);
run;

proc sort nodupkey data = msf2 out = msf3 ; by permno cusip year  ; run;	

PROC EXPORT
	DATA=msf3
	DBMS=dta
	OUTFILE='R:\ps664\Dr_Becher - DirComp\7_add_controls\WRDS data\WRDS_cusip_permno.dta'
	REPLACE;
RUN;
