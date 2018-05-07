1. 產生部類目錄 bulei_nav_gaiji.xhtml

是由 ../sutralist/sutralist.txt 的經目資料, 以及 ../bulei/bulei.txt 部類目錄二者產生

程式為 create_bulei_nav.pl , ../sutralist/SutraList.pm , ../bulei/Bulei.pm

執行

perl create_bulei_nav.pl


2. 原書目錄 book_nav_gaiji.xhtml

是由 ../sutralist/sutralist.txt 的經目資料, 以及 book_nav.txt (來自 book_nav.xlsx) 二者產生

程式為 create_book_nav.pl , BookNav.pm , ../sutralist/SutraList.pm

執行

perl create_book_nav.pl


3. 最後要去 gaiji2word 目錄執行

perl gaiji2word.pl

就會在 Nav 目錄產生最後的 bulei_nav.xhtml , book_nav.xhtml