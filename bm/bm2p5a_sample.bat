@echo off
:: =========================================================
:: �{�������G²��аO���ন XML P5a ��
:: �Ѽƻ����Gruby bm2p5a.rb -v �n���檺�U�� -o ��X���G���ؿ���m
:: �]�w�ɡG�����]�w�� ../cbwork_bin.ini ���o
:: �d�ҡGruby bm2p5a.rb -o \temp\cbetap5a-ok\ -v N01
::
:: �`�G�쥻�O python ���� bm2p5a.py�A2022-05-04 �����令 ruby ��
::     python �������Ӥ��|���@�F
:: =========================================================

set bmdir=d:\cbwork\bm

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo bm2p5a.bat -h     : help
echo bm2p5a.bat -c T   : run T
echo bm2p5a.bat -v T01 : run T01
exit /B

:run_coll
FOR /D %%D IN (%bmdir%\%1\*) DO call :run_vol %%~nD
exit /B

:run_vol
ruby bm2p5a.rb -o \temp\cbetap5a-ok\ -v %1
rem python bm2p5a.py -o \temp\cbetap5a-ok\ -v %1
exit /B

:end