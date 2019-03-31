@echo off
call \cbwork\bin\perl516.bat run
:: ==================================================================================
:: 以上先設定 perl 5.16 的執行環境
:: 以下才開始執行各冊
:: 程式說明：簡單標記版轉出普及版純文字
:: 參數說明：
:: 　bm2nor.bat 直接列出說明
::
:: 　bm2nor.pl 執行冊數 [NoHead] [No_Normal] [JK_Num] [ Normal | Normal1 | App | App1 ]
:: 　nohead 表示沒有卷首資訊
:: 　no_normal 是不要換通用字
:: 　jk_num 是要呈現校勘數字及星號
:: 　normal 一卷一檔(預設值) / normal1 一經一檔 / app 一卷一檔 App / app1 一經一檔 app
:: 設定檔：相關設定由 ../cbwork_bin.ini 取得
:: 範例：perl bm2nor.pl N01
:: ==================================================================================

:: bmdir 為 bm 的目錄
set bmdir=c:\cbwork\bm
:: para 指定呈現的格式
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