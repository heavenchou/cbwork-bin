
■ readme.txt 本說明檔

■ 產生部類資料的程式 , 詳見 bulei/readme.txt

bulei1.txt
bulei2.txt
bulei3.txt
bulei4.txt
buleinewsign.txt
.....

以上這些檔案是產生 TOC 需要的.

再用 buleilist_make.pl 由 bulei1_orig.txt 產生 buleilist.txt , 供 cbreader 使用.

■ 產生 TOC 的程式 , 詳見 toc/readme.txt

make_toc.cfg
make_toc.pl             (若經文有增加, 要改 c:/cbwork/work/bin/cbetasub.pl)
make_toc_all.bat
readme.txt		主要說明檔

■ cbreader 產生 normal 的程式

cbr2t.pl		主程式
cbr2t_all.bat	執行全部的批次檔
cbr2t_one.bat	執行單冊的批次檔
cbr/readme.txt	說明檔

■ 將 xml 切成一卷一檔的程式

cutxml-all.bat	切全部的批次檔
cutxml.pl		切卷程式
cutxml_cfg.pl	設定檔

■ 產生 cbreader 全文檢索的 perl 程式

build.pl			主程式
build/readme.txt	說明文件

build.pl 裡面處理通用詞是要獨立處理, 
有一段程式可以由 "產生通用字build.pl" 來產生 "通用字_build.pl" , 未來應該可以整合進來.

■ 產生全文檢索可單經選擇的列表 bulei_sutra_sch.lst 及 sutra_sch.lst

詳見 search_list/readme.txt

■ 將每一卷第一行資料放在 c:/release/juanline 目錄中

getjuan1line.pl
getjuan1line_all.bat

■■■■■■■■■■■■■■■■■■■■■■■■
■ 特殊資料
■■■■■■■■■■■■■■■■■■■■■■■■

■ 產生 epub 需要的目錄 

bulei1.txt
bulei2.txt
bulei3.txt
bulei4.txt
buleinewsign.txt
.....
make_epub.cfg
make_epub.pl             (若經文有增加, 要改 c:/cbwork/work/bin/cbetasub.pl)
make_epub_all.bat

c:\cbwork\work\epub\readme.txt		主要說明檔

裡面有用 buleilist_make.pl 產生 buleilist.txt , 供 cbreader 使用