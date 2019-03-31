@echo off
:: ==========================================================
:: 程式說明：XML P5a 版轉成 XML P5 版
:: 參數說明：
:: 　執行單冊: p5a2p5.py -v T01
:: 　執行全部大正藏: p5a2p5.py -c T
:: 　執行全部大正藏, 從第二冊開始: p5a2p5.py -c T -s T02
:: 設定檔：相關設定由 ../cbwork_bin.ini 取得
:: ==========================================================

IF "%1"=="" call :show_help
IF "%1"=="-h" call :show_help
IF "%1"=="-a" call :run_all
IF "%1"=="-see" call :run_seeland
IF "%1"=="-c" call :run_coll %2
IF "%1"=="-v" call :run_vol %2
goto END

:show_help
echo p5a2p5.bat -h     : help
echo p5a2p5.bat -a     : run all
echo p5a2p5.bat -see   : run seeland
echo p5a2p5.bat -c T   : run T
echo p5a2p5.bat -v T01 : run T01
exit /B

:run_all
p5a2p5.py -c A
p5a2p5.py -c B
p5a2p5.py -c C
p5a2p5.py -c D
p5a2p5.py -c F
p5a2p5.py -c G
p5a2p5.py -c GA
p5a2p5.py -c GB
p5a2p5.py -c I
p5a2p5.py -c J
p5a2p5.py -c K
p5a2p5.py -c L
p5a2p5.py -c M
p5a2p5.py -c N
p5a2p5.py -c P
p5a2p5.py -c S
p5a2p5.py -c T
p5a2p5.py -c U
p5a2p5.py -c X
p5a2p5.py -c Y
p5a2p5.py -c ZS
p5a2p5.py -c ZW
exit /B

:run_seeland
p5a2p5.py -c DA
p5a2p5.py -c HM
p5a2p5.py -c ZY
exit /B

:run_coll
p5a2p5.py -c %1
exit /B

:run_vol
p5a2p5.py -v %1
exit /B

:END