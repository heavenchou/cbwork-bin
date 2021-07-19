
■ readme.txt 本說明檔

這個目錄是處理 CBReader 2X 版本相關資料的程式

資料準備流程

	1. P5a 轉 P5b，此動作要先做，因為底下有些資料是由 P5b 產生的。
    2. 準備基本資料 sutralist , bulei (sutralist 採用 p5b 的版本, 經名才不會有 unicode ext-b)
    3. P5b 切卷
    4. 產生二份主要導覽文件 bulei_nav.xhtml , book_nav.xhtml -----> 要處理 <g> 缺字 , 手動改 古今圖書集成 ..（上）移除
    5. 產生各經文的目錄 toc -----> 要處理 <g> 缺字
    6. 產生經文目錄 catalog  ----> 手動處理大般若經, 部別, <g> 缺字
    7. 產生經文流水順序 spine
    8. 別忘了要做新增經文的 epub 封面圖檔

其中 sutralist , catalog 的資料都要同時包含跨冊的記錄, 例如

A,120,1565,18,1,0175b01,瑜伽師地論義演(第1卷-第32卷),唐 清素．澄淨述
A,121,1565,5,33,0001b01,瑜伽師地論義演(第33卷-第40卷),唐 清素．澄淨述

但在產生 bulei_nav , book_nav 只要處理第一筆

toc 則要將跨冊資料合併在同一個目錄中

catalog 雖然有多份, 但都連結到同一卷嗎? 例 點 A121n1565 經, 要到 33 卷嗎?

■ P5a 轉 P5b

	這個要先做

■ sutralist

	【執行 sutralist.bat】
	
	這裡是執行二個動作
	
	1. 執行 perl create_sutralist.pl

	產生 sutralist.txt，這是所有經文的冊、經號、經名、卷數、第一卷、起始頁行欄

	是重要的基礎目錄
	
	2. 執行 perl create_sutralist_by_bm.pl
	
	由 BM 產生 sutralist_by_bm.txt，理論上要和 sutralist.txt 一樣，可列為檢查項目。
	
	同時會比對舊的與新的，看看有沒有不同。

■ 切卷程式 cutxml

	【執行 cutxml.bat 可看參數】
	執行 cutxml.bat -a 處理 CBETA 全部資料
	執行 cutxml.bat -see 處理西蓮全部資料
	
■ bulie

	部類資料
	
	若有新的典籍加入，要修改 bulei.xlsx , 並貼成純文字檔 bulei.txt

■ 產生導覽目錄 nav

	若有新的典籍加入，要處理 simple_nav.xlsx, advance_nav.xlsx , 並貼成對應的純文字檔

	【執行 nav.bat , 西蓮版執行 nav_slreader.bat】
	
	產生如下三個檔案
	
	1. bulei_nav.xhtml

	以部類為主的經目樹狀列表

	由 bulei_nav.pl 產生, 需要讀取 sutralist.txt 和部類資料 bulei.txt

	2. advance_nav.xhtml
	3. simple_nav.xhtml

	以原書結構為主的經目樹狀列表
	
	這是有經過缺字處理的版本

■ 產生各經的目錄 toc

	重要 : 因為 mac 在 parser XML 時, 標記中的第一個字不能是 unicode ext-b 的字, 
	因此最好全部空一格. 目前這是在 gaiji2word 步驟遇缺字才處理, 未來應該在產生時全部統一處理.

	【執行 toc.bat 可看參數】
	toc.bat -a 全部執行
	toc.bat -g -a 全部執行, 而且自動處理缺字的部份
	
	它實際有二個部份：

	1. 執行 perl create_toc.pl 在 toc_gaiji 目錄產生目次檔

	2. 加上 -g 參數則至 ../gaiji2word 執行

	perl gaiji2word_toc.pl 
	
	會在 toc 的目錄下產生 toc , 這是有處理過缺字的結果

■ 產生經目列表 catalog

	【執行 catalog.bat (還沒細分 CBETA 和西蓮版)】
	
	＊ 這一版結果不盡理想, 還要考慮單經多部類問題, 以及 T0220x , 要記得和上一個正式版比對。

■ 產生循序各卷卷名列表檔案 Spine

	【執行 spine.bat】

	spine.txt 是提供全文檢索用的檔案列表

	它實際有二個部份：
	
	1. 執行 perl create_spine.pl
	
	由 XML P5b 產生 spine.txt

	2. 執行 perl create_spine_by_bm.pl
	
	由 BM 產生 spine_by_bm.txt，理論上要和 spine.txt 一樣，可列為檢查項目。
	
	最後會自動比對上面二者，以及舊版的內容。
	
	西蓮淨苑版要自行改一下程式
	
	my @book_order = ("T","X","A","K","S","F","C"...
	
	換成這行
	
	my @book_order = ("DA","ZY","HM");

■ 別忘了要做新增經文的 epub 封面圖檔

■ 把缺字 g 標記換成 unicode 或組字式


================================================================================================
以下是第一代 CBReader 產生資料的說明，留著參考用
================================================================================================

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