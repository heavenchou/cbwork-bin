■ 部類處理法

先做出這些基本資料 (那些各冊的資料, 應該可以試著由程式產生)

C:\cbwork\bin\cbreader\bulei\buLeiBL_orig.txt 惠敏法師所制 CBETA 經錄, 產生 buleiBL.txt
C:\cbwork\bin\cbreader\bulei\buleiT_orig.txt 大正藏各冊的列表, 產生 buleiT.txt
C:\cbwork\bin\cbreader\bulei\buleiX_orig.txt 卍續藏各冊的列表, 產生 buleiX.txt
C:\cbwork\bin\cbreader\bulei\buleiXB_orig.txt 卍續藏各部的列表, 產生 buleiXB.txt
C:\cbwork\bin\cbreader\bulei\buleiJ_orig.txt 嘉興藏各冊的列表, 產生 buleiJ.txt
C:\cbwork\bin\cbreader\bulei\buleiH_orig.txt 正　史各冊的列表, 產生 buleiH.txt
C:\cbwork\bin\cbreader\bulei\buleiW_orig.txt 藏　外各冊的列表, 產生 buleiW.txt
C:\cbwork\bin\cbreader\bulei\buleiI_orig.txt 佛拓百品各冊的列表, 產生 buleiI.txt
....
C:\cbwork\bin\cbreader\bulei\buleiSL_orig.txt 西蓮淨苑各冊的列表, 產生 buleiSL.txt

■ 檢查部份內容

buleiBL_check.pl 可以檢查 buleiBL.txt 有沒有重覆的問題, 比對的來源是 TaishoMenu_b5.txt 及 XuzangjingMenu_b5.txt 等各藏 , 
這幾個是由 D:\Data\C\cbreader 目錄中的 TaishoMenu.txt 及 XuzangjingMenu.txt 等各藏的 big5 版本.
比對原理與細節請看 buleiBL_check.pl

chk_buleiX_orig.pl 可檢查 buleiX_orig.txt 及 buleiXB_orig.txt 是否有重覆的卍續藏經目

■ 產生 TOC 需要的內容

再用 bulei_orig_2_ok.pl 來產生 /cbwork/bin/cbreader/bulei/buleiBL,T,X,XB,J....txt
這些做 toc 目錄會需要用到.

toc 做法請參考 /cbwork/bin/cbreader/toc/readme.txt

■ 產生 CBReader 需要的 buleilist.txt

再用 buleilist_make.pl 由 buleiBL_orig.txt 產生 buleilist.txt , 供 cbreader 使用.