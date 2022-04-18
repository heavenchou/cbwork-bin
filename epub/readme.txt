【參考資料】

參考資料請見 D:\CBETA\epub電子書

【工作流程】

a.由 CBReader 取出全部的 HTML 檔, 格式請看 2.cbrhtm2epub.pl 最前面的註解內容, 放在 c:\release\cbr_out_epub
b.用 make_cover 目錄中的程式產生各經封面圖檔, 放在 c:\release\epub_cover

1.用 1.make_epub_all.bat 產生各經的 toc.ncx , TableOfContents.xhtml , content.opf , CoverPage.xhtml 至 c:\release\epub_unzip_toc
2.用 2.cbrhtm2epub.pl	將 cbr 的 html 轉換成 epub 所需要的格式, 放至 c:\release\epub_unzip . 此程式會同時複製圖檔, 因此圖檔請放置在指定位置.
3.將 c:\release\epub_unzip_toc 的資料 copoy 到 c:\release\epub_unzip , 再用 3.mv_same_tag 將 c:\release\epub_unzip 重覆的連結做一些處理.
  (因為第 1 步驟產生 c:\release\epub_unzip_toc 比較慢, 若第 3 步失敗了, 直接再次 copy 第 1 步驟, 然後重做第 2 步驟, 比較省時間)
4.用 4.zip_epub_all.bat 將所有資料壓縮成 epub 檔 c:\release\epub_zip
5.用 5.check_all.bat 檢查有沒有錯誤

-------------------------------------------------------------------------------
【ePub 規格】

這邊有 ePub 支援的 Tag 清單
http://www.idpf.org/2007/ops/OPS_2.0_0.984_draft.html#Section2.2
http://idpf.org/epub/20/spec/OPS_2.0.1_draft.htm#Section2.2
-------------------------------------------------------------------------------

【目錄格式】

[CBR 目錄]

<name>JB267 牧雲和尚嬾齋別集 (14卷)</name><book>J</book><vol>31</vol><sutra>B267</sutra>
<UL>
  <name>目錄</name>
  <UL>
    <name>敘</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0529a01</pageline>
    <name>序</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0529a21</pageline>
    <UL><!-- Level 1 -->
      <name>論</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0538a05</pageline>
      <UL><!-- Level 2 -->
        <name>觀苦入道論</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0538a06</pageline>
      </UL><!-- 1267 end of Level 2 -->
    </UL><!-- 1284 end of Level 1 -->
  </UL><!-- end of Mulu -->
  <name>卷</name><value>1</value>
  <UL>
    <name>第一</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0538a01</pageline>
    <name>第二</name><book>J</book><vol>31</vol><juan>2</juan><pageline>0545c01</pageline>
  </UL><!-- end of Juan -->
</UL><!-- end of Jing -->

[epub 目錄]

	 <navMap>
			<navPoint id="navPoint-1" playOrder="1">
				<navLabel>
					 <text>目錄</text>
				</navLabel>
				<content src="TableOfContents.xhtml" />
			</navPoint>
			
			<navPoint id="navPoint-2" playOrder="2">                 ============>   <UL>
				<navLabel>                                           ============>        <name>
					 <text>章節</text>
				</navLabel>                                          ============>        </name>
				<content src="TableOfContents.xhtml#chapter" />      ============>           <pageline>......</pageline>
				
					 <navPoint id="navPoint-3" playOrder="3">        ============>        <UL>
					 <navLabel>                                      ============>          <name>
								<text>佛國品第一</text>
					 </navLabel>                                     ============>          </name>
					 <content src="T14n0475-001.xhtml#p0537a06" />   ============>          <pageline>......</pageline>
					 </navPoint>                                     ============>        </UL>
					 
					 <navPoint id="navPoint-4" playOrder="4">
					 <navLabel>
								<text>方便品第二</text>
					 </navLabel>
					 <content src="T14n0475-001.xhtml#p0539a07" />
					 </navPoint>
					 
			</navPoint>
			<navPoint id="navPoint-17" playOrder="17">
				<navLabel>
					 <text>卷次</text>
				</navLabel>
				<content src="TableOfContents.xhtml#juan" />
					 <navPoint id="navPoint-18" playOrder="18">
					 <navLabel>
								<text>卷上</text>
					 </navLabel>
					 <content src="T14n0475-001.xhtml" />
					 </navPoint>
					 <navPoint id="navPoint-19" playOrder="19">
					 <navLabel>
								<text>卷中</text>
					 </navLabel>
					 <content src="T14n0475-002.xhtml" />
					 </navPoint>
					 <navPoint id="navPoint-20" playOrder="20">
					 <navLabel>
								<text>卷下</text>
					 </navLabel>
					 <content src="T14n0475-003.xhtml" />
					 </navPoint>
			</navPoint>
			<navPoint id="navPoint-21" playOrder="21">
				<navLabel>
					 <text>贊助</text>
				</navLabel>
				<content src="donate.xhtml" />
			</navPoint>
	 </navMap>

-------------------------------------------------------------------------------

【ePub 檢查】

這裡有兩個程式可以檢查ePub檔案內容:

1. http://code.google.com/p/epubcheck/ (一個python程式)
2. http://www.threepress.org/document/epub-validate/ (線上版的ePub 檢查)

-------------------------------------------------------------------------------

【封面圖檔有這些字要用自己處理的字】

T,16,0710,1,慈氏菩薩所說大乘緣生稻[卄/幹]喻經,【唐 不空譯】
T,18,0913,1,火[合*牛]供養儀軌,【】
T,20,1115,1,觀自在菩薩阿麼[齒*來]法,【】
T,20,1159A,1,[峚-大+(企-止)]窖大道心驅策法,【】
T,21,1238,1,阿吒婆[牛*句]鬼神大將上佛陀羅尼經,【失譯】
T,21,1240,1,阿吒薄[牛*句]付囑咒,【】
-------------------------------------------------------------------------------

【目錄取代用字】

[王*寶] => 珍
[諔-又] => 寂
[金/(土*土)] => ? （依內文用字）
[基-土+蟲] => ? （依內文用字）
[王*延] => 珽 （依內文用字）
[目*韋] = 暐 （依內文用字）
[厄*殳] => ? （參考其他各本用字）
[虎-兒+丘] （組字錯誤） => [虎-儿+丘] => ?
[甬-用+(囗@(幸-土))] （組字修訂）=>	[甬-用+(圉-土)] => ?
== 以下有 unicode ext-b 字元 ==
[卄/幹] =>【Unicode: 26F2E ??】
[合*牛] =>【Unicode: 24656 ??】
[齒*來] =>【Unicode: 2A628 ??】
[牛*句] =>【Unicode: 2463D ??】
== 以下沒有任何對應字元 ==
[峚-大+(企-止)]
-------------------------------------------------------------------------------

【待辦事項】

V 1. html 許多 </a> 待補上, 主要是品名一開始.
V 2. 卷名的 <p> 沒有 </p> 結尾
V 2. ePub 第一個檔案不能壓縮, 而且指定是要這個檔案 mimetype
V 3. html 多餘 javascript 碼要移除.
V 4. <a name 要改成 <a id="pxxxx">
5. 組字式先換成 unicode (目錄部份)
6. <span class="w"><div>....會有問題, 大概 div 不能在 span 裡面 (p 好像也不能在 span 裡面)

-------------------------------------------------------------------------------

ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(143): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(145): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context

Check finished with warnings or errors!

ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(143): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(145): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context

Check finished with warnings or errors!

