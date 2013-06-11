@call \cbwork\bin\perl516.bat run
rem ===============================================================================================
rem 以上先設定 perl 5.16 的執行環境
rem 程式說明：將指定目錄中的檔案合成一個大檔
rem 使用方法：
rem       perl connect.pl -s 來源目錄及檔案種類 -o 輸出結果的檔案 [-c -v -d]
rem 參數說明：
rem       -s 來源目錄，要包含檔案的種類模式，例如 -s c:\temp\*.txt
rem       -o 結果檔案，例如 -o c:\out.txt
rem       -c 切除行首，如果行首是 T01n0001_p0001a01║ 這種型格，皆一律移除
rem       -v 檔案前十行若有 V1.0 這種版本格式，一律換成 Vv.v，以方便比對
rem       -d 檔案前十行若有 2013/06/11 這種日期格式，一律換成 yyyy/mm/dd，以方便比對
rem 範例：
rem       perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d
rem ===============================================================================================
echo on

perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d