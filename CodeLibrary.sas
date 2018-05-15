*****************************************************************;
*    Protocol Number: xxxx                                       ;
*    SAS System Version: 9.4                                     ;
*    Author: Bob Li                                              ;
*    Creation Date: 15 May 2018                                  ;
*                                                                ;
*    Program Name: code/CodeLibrary.sas                          ;
*    Description:                                                ;
*    This is SAS code library                                    ;
*                                                                ;
*                                                                ;
*    Modification History:                                       ;
*    version 0.1                                                 ;
*                                                                ;
*****************************************************************;

* How to use a lookup dataset;
Data A;
	input id name $;
	datalines;
	1 Bob
	2 Sam
	3 Cod
	2 Tom
	1 Todd
run;

Data B(index=(id));
	input id city $;
	datalines;
	1 tianjin
	2 beijing
	2 bj
run;

Data C;
	length city $ 10;
	set A;
	city="";
	reset=1;
	set B key=id keyreset=reset;
	put city=;
run;

/* if there are unique observations on the master file
and multiple observations on the table file, a DO loop is needed
*/
data _null_;
	set csv_subj;
	************ SE_UNSCHEDULEDVISIT ******************;
	ssid="0010052";
	study_event_oid="SE_UNSCHEDULEDVISIT";
	flag=1;
	do until(_IORC_ NE 0);
		set dov_index key=ss;
		_ERROR_ = 0;
		if _IORC_ = 0 then do;
			put ssid= study_event_oid= date=;
		end;
	end;
run;
			reset=1;
			set se_index key=us keyreset=reset;
			if _IORC_ ^= 0 then do;
				_ERROR_ = 0;
			end;
			else do;
				
			end;

* How to use a lookup dataset end;

%macro myput(domain);
	put &domain;
%mend;


%macro getdomain;
data _null_;
	array domains[7] $2 ('ae' 'ce' 'cm' 'co' 'da' 'dm' 'ds');
	len = dim(domains);
	do i=1 to len;
		%myput(domains[i]);
	end;
run;
%mend;

%getdomain

/*
import and export xpt
*/

* import xpt;
libname demolib 'C:\sas\data\out\T89-02-US';
proc cimport infile='C:\sas\data\out\T89-02-US\dm.xpt' lib=demolib; 
run;

* export xpt;
proc cport data=sashelp.class file="D:\class.xpt";
run;

* use copy
libname xportout xport 'c:\sas\xpt\test.xpt';
proc copy in=work out=xportout memtype=data;
	select test;
run;

libname xportout xport 'c:\sas\xpt\test2.xpt';
proc copy in=work out=xportout memtype=data;
	select test2;
run;


libname xportin xport 'c:\sas\xpt\test.xpt';
proc copy in=xportin out=Mylib memtype=data; 
run;

libname xportin xport 'c:\sas\xpt\test2.xpt';
proc copy in=xportin out=Mylib memtype=data; 
run;


option nosource nonotes;


Data _null_;
	set S3REC;
	put PATIENT=;
	if notdigit(REDATE1) then put REDATE1=;
	if notdigit(REDOB) then put REDOB=;
	if notdigit(trim(SITE)) then put SITE=;
	put REDOB=;
	c = notdigit(trim(REDOB));
	put c=;

	if prxmatch('/^\d+$/', SITE) then put SITE=;
	if prxmatch('/^\d+\.?\d*$/', strip("  5.5  ")) then put "bbbb";
	
	* get variable type C and N;
	redatetype = vtype(REDATE1);
	put redatetype=;
	REDOBtype = vtype(REDOB);
	put REDOBtype=;
run;


Data _null_;
	date1="10//2017";
	date2 = input(date1, ?? ddmmyy10.);
	format date2 date9.;
	put date2=;
run;


data lab2b;
	set lab;
	flaglist = catx(',',
					ifc(highflag,'H',''),
					ifc(lowflag ,'L',''),
					ifc(blflag  ,'B',''),
					ifc(csflag  ,'CS',''),
					ifc(wpbflag ,'WPB','')
	);
run;

* generate random number method one;
* If you call the STREAMINIT subroutine with the value 0, 
then SAS will use the date, time of day, 
and possibly other information to manufacture a seed 
when you call the RAND function. 
SAS puts the seed value into the SYSRANDOM system macro variable. ;
data _null_;
call streaminit(0);   /* generate seed from system clock */
x = rand("uniform");
run;
%put &=SYSRANDOM;

* generate random number method two;
* A second method is to use the RAND function to 
generate a random integer between 1 and 231-1, 
which is the range of valid seed values for the Mersenne twister generator 
in SAS 9.4m4.;
data _null_;
call streaminit(0);
seed = ceil( (2**31 - 1)*rand("uniform") ); 
put seed=;
run;


********* Adding leading Zeros to Numeric Variable *****************;
data _null_;
 a=374747830939;
 b=put(a,z15.);
 format a z15.;
 put a= b=;
run;

*********** delete dulplicated data;
proc sort data=temp_dov2 out=temp_dov3 nodup ;
	by ssid VISDTMD date;
run;

*********** get all dulplicated data;
proc sort data = ett_eg 
    out = ett_eg_NODUPS  
    dupout = ett_eg_DUPIDS (keep = PATIENT24_ID HOSPITAL24_ID VISDTMD) 
    nodupkey ; 
    by PATIENT24_ID HOSPITAL24_ID VISDTMD; 
run ;
 
data dupobsETT ; 
    merge ett_eg (in=a) ett_eg_DUPIDS (in=b) ; 
    by PATIENT24_ID HOSPITAL24_ID VISDTMD; 
    if a & b ; 
run ;  

************** Integrity constraints ***************;
data Health;
   length Subj $ 3 Gender $ 1;
   input Subj Gender Heart_Rate;
datalines;
001 M 68
002 F 72
003 M 78
;

proc datasets;
   modify Health;
   ic create Subj_Chk = primary key(Subj);
   ic create Gender_Chk = check (where=(Gender in ('F','M')));
   ic create HR_Chk = check (where=(Heart_Rate ge 40 and Heart_Rate le 100));
quit;

data New;
   length Subj $ 3 Gender $ 1;
   input Subj Gender Heart_Rate;
   *Note: data errors are shown in red;
datalines;
004 x 55
001 M 80
005 F 110
006 M 66
;
 
proc append base=Health data=New;
run;

************** The end of Integrity constraints ***************;

proc template;
     list styles;
run;

options orientation=landscape;
ODS pdf FILE = "e:\sas\data\report1.pdf" style=journal;
*Age Groups;
PROC FREQ
	data = dmagesorted;
	by agegroup;
		tables race*sex_label;
run;
ODS pdf CLOSE;


Tips:Convert MISSING to 0
Jump to: navigation, search

I often need to store a 0 value in place of missing when reporting numeric values. I take advantage of the SUM function for this purpose. For each variable I sum itself with 0 as in:

COST = SUM(COST, 0);

The SUM function ignores missing values. So if COST is not missing, no change occurs. If COST is missing, it is now 0.

If only the display of missing values as 0 as needed, use the options statement (which does not change the internal value):

options missing = '0 ';


ods listing close;
options center orientation=portrait nodate nonumber
        topmargin=1in bottommargin=1in
        rightmargin=1in leftmargin=1in;

data test;
  set sashelp.class;
  subjid=catt(sex,age);
run;
title; footnote;
   
ods rtf file='c:\temp\bordertest.rtf' style=journal;
proc report data=test nowd;
  column subjid name height weight;
  define subjid / group ;
  define name / order;
  define height / sum;
  define weight / sum;
  compute subjid ;
       if subjid gt ' ' then
       call define(_row_,'style',
                  'style={bordertopcolor=cyan bordertopwidth=3}');
  endcomp;
run;
ods rtf close;


input @1 dt ymddttm24.;
Data Line               Result 
2012-03-16 11:23:07.4   1647516187.4
 

 
 
PROC EXPORT DATA=SubjectCompletedAllData label
            FILE="&path.Completed_AllData_&timestamp..xlsx"
            DBMS=xlsx REPLACE;
            SHEET="Sheet1";
RUN;

age = floor ((intck('month',birthday,today) - (day(today) < day(birthday))) / 12); 

age=INT(INTCK('MONTH',Date_of_birth,Informed_Consent_obtained_date)/12);
	IF MONTH(Date_of_birth)=MONTH(Informed_Consent_obtained_date) THEN 
		age=age-(DAY(Date_of_birth)>DAY(Informed_Consent_obtained_date));
 
CMSTDTC=put(input(SD,mmddyy10.),e8601da.);


data ecg;
	retain ssid site_name study_event_oid flag pr qt qrs stt_label sttelevated hr rr 
	qtcb QTcB_Baseline QTcB_Change qtcf QTcF_Baseline QTcF_Change;
	set ecg;
run;

d = put(19539, mmddyys10.);   06/30/2013

libname Orion "e:\sas\fiverr\ganderhill\Orion\" access=readonly;
proc contents data = Maps._all_ NODS;
run;
