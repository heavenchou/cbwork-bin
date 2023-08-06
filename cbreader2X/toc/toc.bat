@echo off
:: call \cbwork\bin\perl518.bat run
:: ==================================================
:: �H�W���]�w perl 5.16 ����������
:: �H�U�~�}�l����U�U
:: �{�������G���� toc
:: �Ѽƻ����G
::       toc.bat -h     : help
::       toc.bat -g     : gaiji (�̫�n�B�z�ʦr)
::       toc.bat -g -a  : run all and gaiji
::       toc.bat -a     : run all
::       toc.bat -see   : run seeland
::       toc.bat -c T   : run T
::       toc.bat -v T01 : run T01 (�p�߸�U�|��Ƥ���)
::
:: �@�@  perl create_toc.pl [T|T01]
:: �d�ҡGperl create_toc.pl     �B�z����
:: �d�ҡGperl create_toc.pl T   �B�z�j����
:: �d�ҡGperl create_toc.pl T01 �B�z�j���� T01
:: ==================================================

set gaiji=
IF "%1"=="-g" (
    set gaiji=1
    shift
)

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo toc.bat -h     : help
echo toc.bat -g     : gaiji (�̫�n�B�z�ʦr)
echo toc.bat -a     : run all
echo toc.bat -see   : run seeland
echo toc.bat -c T   : run T
echo toc.bat -v T01 : run T01 (�p�߸�U�|��Ƥ���)
exit /B

:run_all
call :run_coll A
call :run_coll B
call :run_coll C
call :run_coll CC
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
call :run_coll TX
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
perl create_toc.pl %1
exit /B

:run_vol
echo �p�߸�U�|��Ƥ���...
perl create_toc.pl %1
exit /B

:END
if "%gaiji%"=="1" (
    cd ../gaiji2word
    perl gaiji2word_toc.pl
    cd ../toc
)

rem shutdown /s /t 30