■ 部類處理法

C:\cbwork\work\cbreader\bulei\buLei1_orig.txt 惠敏法師所制 CBETA 經錄, 產生 bulei1.txt
C:\cbwork\work\cbreader\bulei\bulei2_orig.txt 大正藏各冊的列表, 產生 bulei2.txt
C:\cbwork\work\cbreader\bulei\bulei3_orig.txt 卍續藏各冊的列表, 產生 bulei3.txt
C:\cbwork\work\cbreader\bulei\bulei4_orig.txt 卍續藏各部的列表, 產生 bulei4.txt
C:\cbwork\work\cbreader\bulei\bulei5_orig.txt 嘉興藏各冊的列表, 產生 bulei5.txt
C:\cbwork\work\cbreader\bulei\bulei6_orig.txt 正　史各冊的列表, 產生 bulei6.txt
C:\cbwork\work\cbreader\bulei\bulei7_orig.txt 藏　外各冊的列表, 產生 bulei7.txt
C:\cbwork\work\cbreader\bulei\bulei8_orig.txt 佛拓百品各冊的列表, 產生 bulei8.txt

bulei1_check.pl 可以檢查 bulei1.txt 有沒有重覆的問題, 比對的來源是 TaishoMenu_b5.txt 及 XuzangjingMenu_b5.txt 等各藏 , 
這幾個是由 D:\Data\C\cbreader 目錄中的 TaishoMenu.txt 及 XuzangjingMenu.txt 等各藏的 big5 版本.
比對原理與細節請看 bulei1_check.pl

chk_bulei34_orig.pl 可檢查 bulei3_orig.txt 及 bulei4_orig.txt 是否有重覆的卍續藏經目

再用 bulei_orig_2_ok.pl 來產生 /cbwork/work/cbreader/bulei1,2,3,4.txt
要放在 /cbwork/work/cbreader/ 目錄中, 用 make_toc.pl 來產生各部類的 toc 檔

toc 做法請參考 /cbwork/work/cbreader/make_toc_readme.txt

再用 buleilist_make.pl 產生 buleilist.txt , 供 cbreader 使用