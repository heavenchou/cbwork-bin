@echo off
:: call \cbwork\bin\perl518.bat run
:: ==================================================
:: 以上先設定 perl 5.16 的執行環境
:: 以下才開始執行各冊
:: 程式說明：將 XML-P5 切卷
:: 參數說明：
:: 　　cutxml.pl -b [-b] 執行冊數
:: 設定檔：輸出目錄由 ../cbwork_bin.ini 取得 , 
::        在 [cutxml]區中的 output_dir = /temp/cutxml
:: 範例：perl cutxml.pl -b T01
:: 範例：perl cutxml.pl -b T01 (p5b 切卷)
:: ==================================================

set p5bdir=c:\cbwork\xml-p5b

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo cutxml.bat -h     : help
echo cutxml.bat -a     : run all
echo cutxml.bat -see   : run seeland
echo cutxml.bat -c T   : run T
echo cutxml.bat -v T01 : run T01
exit /B

:run_all
call :run_coll A
call :run_coll B
call :run_coll C
call :run_coll D
call :run_coll F
call :run_coll G
call :run_coll GA
call :run_coll GB
call :run_coll I
call :run_coll J
call :run_coll K
call :run_coll L
call :run_coll LC
call :run_coll M
call :run_coll N
call :run_coll P
call :run_coll S
call :run_coll T
call :run_coll U
call :run_coll X
call :run_coll Y
call :run_coll ZS
call :run_coll ZW
exit /B

:run_seeland
call :run_coll DA
call :run_coll HM
call :run_coll ZY
exit /B

:run_coll
FOR /D %%D IN (%p5bdir%\%1\*) DO call :run_vol %%~nD
exit /B

:run_vol
perl cutxml.pl -b %1
exit /B

:END
rem shutdown /s /t 30