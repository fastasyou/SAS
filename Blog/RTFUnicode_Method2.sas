ods rtf file="unicode_symbols.rtf" style=sasdocprinter;

data test;
infile datalines truncover;
input Name $ 1-24 Character $ 26-37 link $120.;
datalines;
GREEK SMALL LETTER IOTA {\uc0\u953}
GREEK SMALL LETTER ALPHA {\uc0\u945} {\field {\*\fldinst HYPERLINK \\l "link1"}{\fldrslt {\cf2 \b \ul this is a link with {\uc0\u945}}}}
GREEK SMALL LETTER MU {\uc0\u956}
GREEK SMALL LETTER ZETA {\uc0\u950}
GREATER-THAN OR EQUAL TO {\uc0\u8805}
;
run;

proc print data=test noobs;
title "Special characters in RTF";
run;

ods _all_ close;
