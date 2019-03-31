@echo off
:: ===============================================================
:: �{�������G���� P5a XML
:: �Ѽƻ����G
:: �@p5a_valid.bat �����C�X����
::
:: �d�ҡG
::   p5a_valid.bat -a  (��������, ���F�转�M��)
::   p5a_valid.bat -see  (���Ҧ转�M��)
::   p5a_valid.bat -c T  (���� T)
::   p5a_valid.bat -v T01  (���� T01)
::
:: ��L�G���~���i�|�b p5a_valid.log
:: ===============================================================

:: p5adir �� p5a ���ؿ�
set p5adir=c:\cbwork\xml-p5a
:: �]�w�D�n���ҵ{�� jing.jar ����m
set jing=c:\bin\jing\bin\jing.jar 
:: �]�w rnc �����ɪ���m
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

:: ���o�ؿ�, �� T01 ���o T , �� GA001 ���o GA
:: ���B�z�G��N�X��
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