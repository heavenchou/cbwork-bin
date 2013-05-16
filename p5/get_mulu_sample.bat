@echo off
call \cbwork\bin\perl516.bat run
rem ==========================================================
rem 以上先設定 perl 516 的環境
rem 以下才開始執行各冊
rem 程式說明：由 XML 經文的 <mulu> 標記產生目錄樹
rem 參數說明：perl get_mulu.pl 要執行的冊數
rem 範例：perl get_mulu.pl X55
rem 其他：結果會在 tree 目錄下產生 X55_tree.txt
rem ==========================================================

perl get_mulu.pl X55