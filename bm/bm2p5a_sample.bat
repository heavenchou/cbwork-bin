@echo off
:: =========================================================
:: 程式說明：簡單標記版轉成 XML P5a 版
:: 參數說明：ruby bm2p5a.rb -v 要執行的冊數 -o 輸出結果的目錄位置
:: 設定檔：相關設定由 ../cbwork_bin.ini 取得
:: 範例：ruby bm2p5a.rb -o \temp\cbetap5a-ok\ -v N01
::
:: 注：原本是 python 版的 bm2p5a.py，2022-05-04 正式改成 ruby 版
::     python 未來應該不會維護了
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