@echo off
call \cbwork\bin\perl516.bat run
rem ===============================================================================================
rem 以上先設定 perl 5.16 的執行環境
rem 以下才開始執行各冊
rem 程式說明：簡單標記版轉出普及版純文字
rem 參數說明：
rem 　　bm2nor.pl 執行冊數 [NoHead] [No_Normal] [JK_Num] [ Normal | Normal1 | App | App1 ]
rem 　　nohead 表示沒有卷首資訊
rem 　　no_normal 是不要換通用字
rem 　　jk_num 是要呈現校勘數字及星號
rem 　　normal 一卷一檔(預設值) / normal1 一經一檔 / app 一卷一檔 App 格式 / app1 一經一檔 app 格式
rem 設定檔：相關設定由 ../cbwork_bin.ini 取得
rem 範例：perl bm2nor.pl N01
rem ===============================================================================================

perl bm2nor.pl N01