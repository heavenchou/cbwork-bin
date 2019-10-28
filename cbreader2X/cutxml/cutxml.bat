@echo off
:: call \cbwork\bin\perl518.bat run
:: ==================================================
:: �H�W���]�w perl 5.16 ����������
:: �H�U�~�}�l����U�U
:: �{�������G�N XML-P5 ����
:: �Ѽƻ����G
:: �@�@cutxml.pl -b [-b] ����U��
:: �]�w�ɡG��X�ؿ��� ../cbwork_bin.ini ���o , 
::        �b [cutxml]�Ϥ��� output_dir = /temp/cutxml
:: �d�ҡGperl cutxml.pl -b T01
:: �d�ҡGperl cutxml.pl -b T01 (p5b ����)
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