*Macro Library;

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
