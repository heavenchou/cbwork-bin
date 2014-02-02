@echo off
call \cbwork\bin\perl516.bat run
rem ===============================================================================================
rem 以上先設定 perl 5.16 的執行環境
rem 以下才開始執行各冊
rem 程式說明：將 XML-P5 切卷
rem 參數說明：
rem 　　cutxml.pl 執行冊數
rem 設定檔：輸出目錄由 ../cbwork_bin.ini 取得 , 在 [cutxml]區中的 output_dir = /release/cutxml
rem 範例：perl cutxml.pl T01
rem ===============================================================================================

perl cutxml.pl T01