@echo off
IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
exit /B

:show_help
echo sutralist.bat -h     : help
echo sutralist.bat -a     : run all
echo sutralist.bat -see   : run seeland
exit /B

:run_all
copy sutralist.txt sutralist_bak.txt
copy sutralist_by_bm.txt sutralist_by_bm_bak.txt
perl create_sutralist.pl
perl create_sutralist_by_bm.pl
fc sutralist.txt sutralist_bak.txt
fc sutralist_by_bm.txt sutralist_by_bm_bak.txt
exit /B

:run_seeland
copy sutralist_see.txt sutralist_see_bak.txt
copy sutralist_see_by_bm.txt sutralist_see_by_bm_bak.txt
perl create_sutralist.pl see
perl create_sutralist_by_bm.pl see
fc sutralist_see.txt sutralist_see_bak.txt
fc sutralist_see_by_bm.txt sutralist_see_by_bm_bak.txt
exit /B