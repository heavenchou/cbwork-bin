比對 P5 轉 TXT 和 BM 轉 TXT

1.使用 BM 轉成 TXT

  perl bm2nor.pl T01 no_normal jk_num

2.標準的 P5 轉成 TXT

  p5totxt.py -v T01 -x 0 -u -a -z -k

3.使用 comp_normal.pl 比對上面二組 TXT, 產生結果為 comp_result.txt