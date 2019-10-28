比對 CBReader 版的說明:

1.使用 CBReader (以下簡稱 CBR) 產生輸出檔, 但是要注意格式的設定如下:

  a.依大正藏格式切行
  b.加上行首
  c.使用組字式 (第二順位是通用字, 這樣產生的巴利文才能正確比對)
  d.勘誤二者皆要 (或只用正確的, 看怎麼比對方便就怎麼做)
  e.使用悉曇字型
  
  並假設輸出至 c:\release\cbr_out

  使用 cbr2html_all.bat 可以用逐冊產生 html

2.手動建立目錄 c:\cbcheck\cbr_comp, 此目錄下有

  cbr2t.pl , 這是主要的程式
  cbr2t_one.bat 是處理一冊的批次檔, 例如 cbr2t_one.bat T01
  cbr2t_all.bat 是處理全部的批次檔
  
  如果 cbr 的預設目錄不是 c:\release\cbr_out\
  則 cbr2t.pl 要改這一行:
  
  $source_path = "c:/release/cbr_out/";
  
  執行後會產生 T01_cbr.txt , T02_cbr.txt ..... 

3.使用 diff_one.bat  Txx (或 diff_all 處理全部) 將 Txx_crt.txt 與
  xml->normal 產生出來的 normal 版的合併大檔比對

4.使用 fcsplit_one.bat Txx (或 fcsplit_all 處理全部) 來將差異檔分離.
  這時會產生 Txx 的目錄, 裡面是 fcsplit1.txt 及 fcsplit2.txt
  我們還要再 copy wfgfc.exe 進去, 就可以比對 fcsplit1.txt 及 fcsplit2.txt 了.