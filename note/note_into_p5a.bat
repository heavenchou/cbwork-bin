@echo off
call c:\cbwork\bin\perl516.bat run
rem =============================
rem 以上先設定 perl 516 的環境
rem 以下才開始執行各冊
rem =============================

rem 程式說明：
rem 　　　　　以 N01 為例, 目錄下要有 out_N01.txt , 這是 N01 的校勘 XML 格式 , 由 note2xml.bat 產生
rem 　　　　　原始的 N01 P5a xml 檔在 c:\cbwork\xml-p5a\N\N01 目錄中
rem 　　　　　執行後會產生 out_N01 目錄, 已插入校勘的 XML 檔就在此目錄中
rem 　　　　　若有錯誤, 會產生 err_out_N01.txt , 可檢查其內容

perl note_into_p5a.pl N01