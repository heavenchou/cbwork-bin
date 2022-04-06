@echo off
IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
exit /B

:show_help
echo catalog.bat -h     : help
echo catalog.bat -a     : run all
echo catalog.bat -see   : run seeland
exit /B

:run_all
copy catalog.txt catalog_bak.txt
perl create_catalog.pl
cd ../gaiji2word
perl gaiji2word.pl catalog
cd ../catalog
fc catalog.txt catalog_bak.txt
exit /B

:run_seeland
copy catalog_see.txt catalog_see_bak.txt
perl create_catalog.pl see
cd ../gaiji2word
perl gaiji2word.pl catalog_see
cd ../catalog
fc catalog_see.txt catalog_see_bak.txt
exit /B