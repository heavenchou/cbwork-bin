@echo off
:: ============================================================
:: 程式說明：XML P5a 版轉成 EPUB 電子書
:: 參數說明：
:: 　執行全部: ruby xml2epub.rb ALL 2022.Q1
:: 　執行全部大正藏: ruby xml2epub.rb T 2022.Q1
:: 　執行某範圍藏經: ruby xml2epub.rb A..D 2022.Q1
:: ============================================================

IF "%1"=="" goto :show_help
IF "%1"=="-h" goto :show_help
IF "%2"=="" goto :show_help
IF "%1"=="-a" call :run_all %2
IF "%1"=="-see" call :run_seeland %2
IF "%3"=="" goto :show_help
IF "%1"=="-c" call :run_coll %2 %3
goto END

:show_help
echo xml2epub.bat -h           : help
echo xml2epub.bat -a   2022.Q1 : run all
echo xml2epub.bat -see 2022.Q1 : run seeland
echo xml2epub.bat -c T 2022.Q1 : run T
goto END

:run_all
call :run_coll A %1
call :run_coll B %1
call :run_coll C %1
call :run_coll D %1
call :run_coll F %1
call :run_coll G %1
call :run_coll GA %1
call :run_coll GB %1
call :run_coll I %1
call :run_coll J %1
call :run_coll K %1
call :run_coll L %1
call :run_coll LC %1
call :run_coll M %1
call :run_coll N %1
call :run_coll P %1
call :run_coll S %1
call :run_coll T %1
call :run_coll TX %1
call :run_coll U %1
call :run_coll X %1
call :run_coll Y %1
call :run_coll ZS %1
call :run_coll ZW %1
exit /B

:run_seeland
call :run_coll DA %1
call :run_coll HM %1
call :run_coll ZY %1
exit /B

:run_coll
ruby xml2epub.rb %1 %2
exit /B

:END
rem shutdown /s /t 30
rem shutdown /h