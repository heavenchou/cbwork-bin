@echo off
IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
exit /B

:show_help
echo nav.bat -h     : help
echo nav.bat -a     : run all
echo nav.bat -see   : run seeland
exit /B

:run_all
perl create_bulei_nav.pl 
perl create_book_nav.pl simple_nav.txt
perl create_book_nav.pl advance_nav.txt
cd ../gaiji2word
perl gaiji2word.pl nav
cd ../nav
exit /B

:run_seeland
perl create_book_nav.pl seeland_nav.txt
cd ../gaiji2word
perl gaiji2word.pl nav_see
cd ../nav
exit /B