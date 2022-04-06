@echo off
IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
exit /B

:show_help
echo spine.bat -h     : help
echo spine.bat -a     : run all
echo spine.bat -see   : run seeland
exit /B

:run_all
copy spine.txt spine_bak.txt
copy spine_by_bm.txt spine_by_bm_bak.txt
perl create_spine.pl
perl create_spine_by_bm.pl
fc spine.txt spine_by_bm.txt
fc spine.txt spine_bak.txt
exit /B


:run_seeland
copy spine_see.txt spine_see_bak.txt
copy spine_see_by_bm.txt spine_see_by_bm_bak.txt
perl create_spine.pl see
perl create_spine_by_bm.pl see
fc spine_see.txt spine_see_by_bm.txt
fc spine_see.txt spine_see_bak.txt
exit /B