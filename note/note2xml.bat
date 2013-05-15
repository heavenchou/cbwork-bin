@echo off
call c:\cbwork\bin\perl516.bat run
rem =============================
rem 以上先設定 perl 516 的環境
rem 以下才開始執行各冊
rem =============================

rem 程式說明：
rem 　　　　　以 N01 為例, 目錄下要先有 N01.txt , 這是 N01 的校勘原始格式純文字
rem 　　　　　執行後會產生 out_N01.txt , 這是 N01 的校勘 XML 格式 , 下一步 note_into_p5a.bat 會使用到
rem 　　　　　若有錯誤, 會產生 err_N01.txt , 可檢查裡面的內容

perl note2xml.pl N01