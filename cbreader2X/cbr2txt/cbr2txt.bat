@echo off
rem call \cbwork\bin\perl518.bat run
rem =============================================
rem 以上先設定 perl 5.16 的執行環境
rem 以下才開始執行各冊
rem 程式說明：將 CBReader 2X 產生的 HTML 轉成 TXT 
rem 參數說明：
rem 　　cbr2txt.pl (全部)
rem 　　cbr2txt.pl T (大正藏)
rem 　　cbr2txt.pl T01 (大正藏第一冊)
rem =============================================

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo cbr2txt.bat -h     : help
echo cbr2txt.bat -a     : run all
echo cbr2txt.bat -see   : run seeland
echo cbr2txt.bat -c T   : run T
echo cbr2txt.bat -v T01 : run T01
exit /B

:run_all
perl cbr2txt.pl A
perl cbr2txt.pl B
perl cbr2txt.pl C
perl cbr2txt.pl D
perl cbr2txt.pl F
perl cbr2txt.pl G
perl cbr2txt.pl GA
perl cbr2txt.pl GB
perl cbr2txt.pl I
perl cbr2txt.pl J
perl cbr2txt.pl K
perl cbr2txt.pl L
perl cbr2txt.pl LC
perl cbr2txt.pl M
perl cbr2txt.pl N
perl cbr2txt.pl P
perl cbr2txt.pl S
perl cbr2txt.pl T
perl cbr2txt.pl U
perl cbr2txt.pl X
perl cbr2txt.pl Y
perl cbr2txt.pl ZS
perl cbr2txt.pl ZW
exit /B

:run_seeland
perl cbr2txt.pl DA
perl cbr2txt.pl HM
perl cbr2txt.pl ZY
exit /B

:run_coll
perl cbr2txt.pl %1
exit /B

:run_vol
perl cbr2txt.pl %1
exit /B

:END
rem shutdown /s /t 30