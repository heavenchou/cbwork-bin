@echo off
:: ============================================================
:: �{�������GXML P5a ���ন XML P5 ��
:: �Ѽƻ����G
:: �@�����U: ruby p5a2p5.rb -v T01
:: �@��������j����: ruby p5a2p5.rb -c T
:: �@��������j����, �q�ĤG�U�}�l: ruby p5a2p5.rb -c T -s T02
:: �]�w�ɡG�����]�w�� ../cbwork_bin.ini ���o
::
:: �`�G�쥻�O python ���� p5a2p5.py�A2022-05-04 �����令 ruby ��
::     python �������Ӥ��|���@�F
:: ============================================================

set nv=
IF "%1"=="-n" (
    set nv=--nv
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
echo p5a2p5.bat -h     : help
echo p5a2p5.bat -n     : no valid
echo p5a2p5.bat -n -a  : run all no valid
echo p5a2p5.bat -a     : run all
echo p5a2p5.bat -see   : run seeland
echo p5a2p5.bat -c T   : run T
echo p5a2p5.bat -v T01 : run T01
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
ruby p5a2p5.rb %nv% -c %1
exit /B

:run_vol
ruby p5a2p5.rb %nv% -v %1
exit /B

:END
rem shutdown /s /t 30
rem shutdown /h