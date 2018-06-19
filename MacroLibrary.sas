*****************************************************************;
*    Protocol Number: xxxx                                       ;
*    SAS System Version: 9.4                                     ;
*    Author: Bob Li                                              ;
*    Creation Date: 15 May 2018                                  ;
*                                                                ;
*    Program Name: code/CodeLibrary.sas                          ;
*    Description:                                                ;
*    This is SAS Macro Library                                   ;
*                                                                ;
*                                                                ;
*    Modification History:                                       ;
*    version 0.1                                                 ;
*                                                                ;
*****************************************************************;
/*
	Get .docx file list from the specific path.
    Args:
        path: folder where .docx files located
        filetype: default is docx
	Returns:
		create a dataset named filelist.
*/
%macro getFilelist(path=,filetype=docx);
	data filelist;
		infile "dir &path\*.&filetype /s /b " pipe truncover end=eof;
		input file $256.;
	run;
	proc sort data=filelist;
		by file;
	run;
%Mend  getFilelist;

/*
	Loop a dataset by macro
	Args:
		ds: The name of the dataset which be iterated
*/
%macro loopds(ds);
data _null_;
	if 0 then set &ds nobs=X;
	call symputx('total_records', X, 'G');
	stop;
run;

%do i=1 %to &total_records;
	...
%end;
%mend loopds;

/*
  if a macro variable is blank, if equal to 1, it's blank
  Args:
  	param: the variable name
  return:
  	1: the variable is blank
*/
%macro isBlank(param);
%sysevalf(%superq(param)=,boolean)
%mend isBlank;

%if %isBlank(&type1)=1 %then %do;
	...
%end;

%MACRO printlast;
	proc print data=&syslast;
	title "Listing of &syslast data set";
	run;
%MEND

*********************************************************;
*create sites folder;
*********************************************************;
%macro createfolder(sites, path);
	%let len = %sysfunc(countw(&sites,","));
	Data _null_;
		%do i=1 %to &len;
			%let siteid = %scan(&sites,&i,",");
			d = dcreate("&siteid","&path");
		%end;
	run;
%mend;

*********************************************************;
*copy files to sites folder;
*********************************************************;
%macro copyfile(domain,sites, sourcepath, despath);
	%let len = %sysfunc(countw(&sites,","));
	Data _null_;
		%do i=1 %to &len;
			%let siteid = %scan(&sites,&i,",");
			command = "copy &sourcepath.&domain..xlsx &despath\&siteid";
			call system(command);
		%end;
	run;
%mend;

* import excel file, *;
%macro ImportExcel(rawdatapath, filename, sheet, outds);
	PROC IMPORT OUT=&outds DATAFILE="&rawdatapath.&filename..xls" DBMS=EXCEL REPLACE;
		SHEET="&sheet";
		GETNAMES=YES;
	Run;
%mend;
