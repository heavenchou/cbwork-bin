@echo off
call \cbwork\bin\perl516.bat run
rem ==========================================================
rem 以上先設定 perl 516 的環境
rem 以下才開始執行各冊
rem 程式說明：檢查 XML 檔中的卷首資訊
rem 參數說明：perl juan.pl 要執行的冊數
rem 設定檔：相關設定由 ../cbwork_bin.ini 取得
rem 範例：perl juan.pl T01
rem 其他：結果會在 DOS 視窗上呈現
rem ==========================================================

perl juan.pl T01


rem 底下的 pause 是要暫停視窗, 才能看到結果
pause