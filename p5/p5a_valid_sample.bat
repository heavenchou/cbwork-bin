@echo off
:: ===============================================================
:: 程式說明：驗證 P5a XML
:: 參數說明：
:: 　p5a_valid.bat 直接列出說明
::
:: 範例：
::   p5a_valid.bat -a  (全部驗證, 除了西蓮專案)
::   p5a_valid.bat -see  (驗證西蓮專案)
::   p5a_valid.bat -c T  (驗證 T)
::   p5a_valid.bat -v T01  (驗證 T01)
::
:: 其他：錯誤報告會在 p5a_valid.log
:: ===============================================================

:: p5adir 為 p5a 的目錄
set p5adir=c:\cbwork\xml-p5a
:: 設定主要驗證程式 jing.jar 的位置
set jing=c:\bin\jing\bin\jing.jar 
:: 設定 rnc 驗證檔的位置
set rnc=c:\cbwork\xml-p5a\schema\cbeta-p5a.rnc

IF "%1"=="" goto show_help
IF "%1"=="-h" goto show_help

if EXIST p5a_valid.log del p5a_valid.log
set finderr=OK

IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo p5a_valid.bat -h     : help
echo p5a_valid.bat -a     : run all
echo p5a_valid.bat -see   : run seeland
echo p5a_valid.bat -c T   : run T
echo p5a_valid.bat -v T01 : run T01
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
FOR /R %p5adir%\%1 %%f IN (*.xml) DO call :valid_one %%f
exit /B

:run_vol
set vol=
call :get_vol %1
FOR /R %p5adir%\%vol%\%1 %%f IN (*.xml) DO call :valid_one %%f
exit /B

:valid_one
echo %1
java -Xms64000k -Xmx512000k -jar %jing% -c %rnc% %1 >> p5a_valid.log
if errorlevel 1 set finderr=Find Error! See p5a_valid.log
exit /B

:: 取得目錄, 由 T01 取得 T , 由 GA001 取得 GA
:: 先處理二位代碼的
:get_vol
set p1=%1
set vol=%p1:~0,2%
if "%vol%"=="GA" exit /B
if "%vol%"=="GB" exit /B
if "%vol%"=="ZS" exit /B
if "%vol%"=="ZW" exit /B
if "%vol%"=="HM" exit /B
if "%vol%"=="ZY" exit /B
if "%vol%"=="DA" exit /B
set vol=%p1:~0,1%
exit /B

:END
echo %finderr%