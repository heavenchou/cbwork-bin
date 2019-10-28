set vol=X45

if NOT VOL%1 == VOL set vol=%1

perl 2.cbrhtm2epub.pl %vol%
perl 3.mv_same_tag.pl %vol%
perl 4.zip_epub.pl %vol%
call 5.check_one.bat %vol%
