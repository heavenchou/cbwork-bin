rem =========================================================================================
rem 程式說明：驗證 XML
rem 參數說明：-r 驗證用的 rnc 檔的位置 -d 要驗證的目錄
rem 設定檔：相關設定由 ../cbwork_bin.ini 取得
rem 範例：valid_vol.py -r \cbwork\xml-p5a\schema\cbeta-p5a.rnc -d c:\temp\cbetap5a-ok\N\N01\
rem 其他：結果會在 valid_vol.log
rem =========================================================================================

rem 先刪除 valid_vol.log 檔
del valid_vol.log

rem 再執行各冊數
valid_vol.py -r \cbwork\xml-p5a\schema\cbeta-p5a.rnc -d c:\temp\cbetap5a-ok\N\N01\