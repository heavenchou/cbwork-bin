@echo off
call \cbwork\bin\perl516.bat run
:: ==================================================================================
:: �H�W���]�w perl 5.16 ����������
:: �H�U�~�}�l����U�U
:: �{�������G²��аO����X���Ϊ��¤�r
:: �Ѽƻ����G
:: �@bm2nor.bat �����C�X����
::
:: �@bm2nor.pl ����U�� [NoHead] [No_Normal] [JK_Num] [ Normal | Normal1 | App | App1 ]
:: �@nohead ��ܨS��������T
:: �@no_normal �O���n���q�Φr
:: �@jk_num �O�n�e�{�հɼƦr�άP��
:: �@normal �@���@��(�w�]��) / normal1 �@�g�@�� / app �@���@�� App / app1 �@�g�@�� app
:: �]�w�ɡG�����]�w�� ../cbwork_bin.ini ���o
:: �d�ҡGperl bm2nor.pl N01
:: ==================================================================================

:: bmdir �� bm ���ؿ�
set bmdir=c:\cbwork\bm
:: para ���w�e�{���榡
set para=no_normal jk_num

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo bm2nor.bat -h     : help
echo bm2nor.bat -a     : run all
echo bm2nor.bat -see   : run seeland
echo bm2nor.bat -c T   : run T
echo bm2nor.bat -v T01 : run T01
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
FOR /D %%D IN (%bmdir%\%1\*) DO call :run_vol %%~nD
exit /B

:run_vol
perl bm2nor.pl %1 %para%
exit /B

:END