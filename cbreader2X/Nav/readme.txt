
本說明是要產生 CBReader 2X 的 bulei_nav.xhtml , book_nav.xhtml 二個書目檔的簡單版, 詳請參考底下說明

1. 如果 ../sutralist/sutralist.txt 太舊或不足, 請找 heaven 重新產生.
2. 開啟 ../bulei/BuLei.xls , 將內容全選後貼在 ../bulei/bulei.txt (要是 UTF8 格式)
3. 開啟 book_nav.xlsx , 將內容全選後貼在 book_nav.txt (要是 UTF8 格式)
4. 執行 create_nav.bat 會產生 bulei_nav.xhtml , book_nav.xhtml


========================================================================

本說明是要產生 CBReader 2X 的 bulei_nav.xhtml , book_nav.xhtml 二個書目檔的詳細說明

1. 前提要先準備好 ../sutralist/sutralist.txt 經目資料, 這是由 XML 經文產生的, 
   若需要重新產生, 由 heaven 來做比較好. 免得大家各做自己的, 造成 git 同步出問題. 除非你知道如何處理.

2. 開啟 ../bulei/BuLei.xls , 將內容全選後貼在 ../bulei/bulei.txt (要是 UTF8 格式)

3. 開啟 book_nav.xlsx , 將內容全選後貼在 book_nav.txt (要是 UTF8 格式)

4. 執行 create_nav.bat 會產生 bulei_nav.xhtml , book_nav.xhtml

	這其實是底下幾個動作 :

	a. 產生部類目錄 bulei_nav_gaiji.xhtml

		是由 ../sutralist/sutralist.txt 的經目資料, 以及 ../bulei/bulei.txt 部類目錄二者產生

		../bulei/bulei.txt 則是由 ../bulei/BuLei.xls 的內容直接全選然後貼在 ../bulei/bulei.txt (要是 UTF8 格式)

		主要程式為 create_bulei_nav.pl ,  ../bulei/Bulei.pm , ../sutralist/SutraList.pm ,

		此時只要執行底下即可產生 bulei_nav_gaiji.xhtml

		perl create_bulei_nav.pl 


	b. 產生原書目錄 book_nav_gaiji.xhtml

		是由 ../sutralist/sutralist.txt 的經目資料, 以及 book_nav.txt 原書架構目錄二者產生

		book_nav.txt 則是由 book_nav.xlsx 的內容直接全選然後貼在 book_nav.txt (要是 UTF8 格式)

		主要程式為 create_book_nav.pl , BookNav.pm , ../sutralist/SutraList.pm

		此時只要執行底下即可產生 book_nav_gaiji.xhtml

		perl create_book_nav.pl


	c. 最後要去 ../gaiji2word 目錄執行

		perl gaiji2word.pl

		就會在 Nav 目錄產生最後的 bulei_nav.xhtml , book_nav.xhtml