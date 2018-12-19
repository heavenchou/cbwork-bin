比對 CBReader 2X 版的說明:

1.使用 CBReader 2X (以下簡稱 CBR) 產生輸出檔, 但是要注意格式的設定如下:

  a.原書格式
  b.加上行首
  c.CBETA 校勘 (原書校勘 不易和 P5totxt 比對)
  d.使用 組字式 (不使用 unicode ext 和通用字, 免得無法比對)
  
  並輸出至 c:\temp\cbr_htm\ (old c:\Users\Heaven\AppData\Local\Temp\CBReader\Debug\)

2.cbr2txt.pl 將上面 CBR 的 HTML 轉成 TXT , 放在 c:\release\cbr_out_txt_xxxxxx\

3.標準的 P5 轉成 TXT

4.使用 comp_cbr_txt.pl 比對上面二組 TXT, 產生結果為 comp_result.txt