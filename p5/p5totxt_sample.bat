@echo off
:: ===============================================================
:: �{�������GXML P5 ����X�¤�r Normal ��
:: �Ѽƻ����Gp5totxt.rb �Ѽ�
:: �@-a�G���n���Y��T
:: �@-v�G���w�n�ഫ���@�U
:: �@-k�G��ܮհɲŸ�
:: �@-u�G�@���@��, �w�]�O�@�g�@��
:: �@-x�G�x��r�e�{��k: 0=��g(�w�]), 1=entity &SD-xxxx, 2=���i���j
:: �@-z�G���ϥγq�Φr
:: �]�w�ɡG�����]�w�� ../cbwork_bin.ini ���o
:: �d�ҡGruby p5totxt.rb -v N01 -k -x 1
::
:: �`�G�쥻�O python ���� p5totxt.py�A2022-05-04 �����令 ruby ��
::     python �������Ӥ��|���@�F
:: ===============================================================

:: p5dir �� p5 ���ؿ�
set p5dir=d:\cbwork\xml-p5
:: para ���w�e�{���榡
set para=-x 0 -u -a -z -k

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo p5totxt.bat -h     : help
echo p5totxt.bat -a     : run all
echo p5totxt.bat -see   : run seeland
echo p5totxt.bat -c T   : run T
echo p5totxt.bat -v T01 : run T01
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
FOR /D %%D IN (%p5dir%\%1\*) DO call :run_vol %%~nD
exit /B

:run_vol
ruby p5totxt.rb -v %1 %para%
rem p5totxt.py -v %1 %para%
exit /B

:END
rem shutdown /s /t 30
rem shutdown /h