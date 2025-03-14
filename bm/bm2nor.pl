########################################################################
# bm2nor.pl  		                                    ~by heaven 
#
# 將簡單標記版經文處理成普及版 (normal, normal1, app, app1) 的程式
#
# 執行參數 bm2nor.pl Vol [NoHead] [No_Normal] [JK_Num] [ Normal | Normal1 | App | App1 ]
# 例 : bm2nor.pl T01
# 不下參數預設值是 normal 版, 至於輸出目錄則與版本同名
# nohead 表示沒有卷首資訊
# no_normal 是不要換通用字
# jk_num 是要呈現校勘數字及星號
#
# 設定檔：相關設定由 ../cbwork_bin.ini 取得
#
# Copyright (C) 1998-2024 CBETA
# Copyright (C) 1999-2024 Heaven Chou
########################################################################

# 2024-03-17 支援 <p,1,bold,kai> 這類標記
# 2024-13-10 1.支援 <sanot> 北印體標記，或 <hi,sanot>
# 2024-03-10 處理 ⏑⏓ 這二個特殊字, 雖然大於 unicode 2.0 , 但要直接呈現
# 2024-03-07 支援 <p,bold,kai> 這類標記
# 2023-11-07 支援 <circle> 標記
# 2023-06-12 支援 CC、CBETA選集、CBETA Selected Collection
# 2023-05-18 支援 <tag,1,2,bold,it> 等格式
# 2023-04-05 支援 <[ABCEY],[crl]> 等格式 (c 置中，r 靠右，l 靠左)
# 2023-04-04 支援 <p,c>, <p,r>, <Q1,c>, <Q1,r> 等格式 (c 置中，r 靠右)
# 2023-04-01 忽略 <del>,<under>,<over> 標記
# 2023-01-18 支援處理 <㊣X> 標記
##########################################################
# 2022/10/13 修改標記的判斷
# 2022/03/31 數字不能用 \d 判斷了，要用 [0-9]，因為全型數字也會被視為 \d，但組字式有這種 [１２．] = ⒓
##########################################################
# 2021/01/15 太虛大師全集 TX 的修訂採用修訂前的文字
# 2021/09/09 1. <Q> 和 <p=h> 支援到 25 層.
# 2021/01/07 1. 支援 <c,2>, <c2 r3,2> 這種格式, ",2" 表示內文空二格, 但轉 normal 不處理
# 2020/12/25 1. 忽略 <it> <bold> <kai> <ming> <hei> <song>
#            2. <p_r> 段落靠右, 空格比照 <p,8>, <p_c> 段落置中, 空格比照 <p,4>
# 2020/06/30 偈頌修改處理方式, 增加 <TL>, <TL,x,y,z> 等標記
##########################################################
# 2018/11/04 V12.3 輸出的目錄加一層藏經名
# 2018/04/01 V12.2 修改藏經中英文名稱 (by maha)
# 2018/03/29 V12.1 修改藏經中英文名稱
# 2018/02/09 V12.0 1. <mj> 標記改成 <mj xxx> , xxx 是卷數
#                  2. 檔名在卷數前一律加上下底線 
##########################################################
# 2018/02/07 V11.3 處理大藏經補編不連續卷
# 2017/11/07 V11.2 處理 ȧ 這個特殊字, 雖然大於 unicode 2.0 , 但要直接呈現
# 2017/06/19 V11.1 移除全型英文字母行中標記，新增 <M><R><W> 三個標記
##########################################################
# 2017/05/17 V10.7 處理 <J-> 標記, 等同行首的 J-# , 也就是不理它
# 2017/05/15 V10.6 再次支援 <Qn=> 的標記, 比照 <Qn> 處理, 前版有問題
# 2017/05/05 V10.5 支援 <Qn=> 的標記, 比照 <Qn> 處理
# 2017/04/20 V10.4 支援佛寺志 <reg> 標記，表示是通用字，不理它即可。
# 2017/04/04 V10.3 支援印順法師佛學著作集新增的 <F> , <r> 等表格標記。(等同行首標記的 F 與 f)
# 2017/02/24 V10.2 支援無參數的 <quote> 標記
# 2016/12/03 V10.1 支援印順法師佛學著作集新增的 : 規範字詞 [A=B], 行首頁碼有英文字母 _pa001
##########################################################
# 2016/11/01 V9.17 將藏外佛教文獻的藏經代碼 W 改成 ZW , 正史佛教資料類編的 H 改成 ZS
# 2016/05/20 V9.16 呈現的 unicode 由 1.1 改成 2.0 , 因為要呈現某些韓文
# 2016/05/15 V9.15 處理 BM 檔有 UTF8 的 BOM 時, 會造成第一行被忽略的情況
# 2016/05/13 V9.14 修改一經一檔的檔名, 要支援藏經代碼超過1個英文字母的經文
# 2016/05/07 V9.13 加入 GA , GB 佛寺志中英文名稱
# 2016/05/04 V9.12 再次處理修訂作者的名稱 [A>B]<resp="CBETA.maha">
# 2016/04/19 V9.11 處理修訂作者的名稱 [A>B]<resp="CBETA.maha">
# 2015/06/24 V9.10 處理 <p,1.5,-2.5> 這類有小數的情況, 空格一律採用四捨五入處理
# 2015/06/24 V9.9  處理 <L_sp> 標記, 忽略不處理
# 2015/04/12 V9.8  <c> 標記處理超過 10 的數字, 例如 <c11>
# 2014/12/27 V9.7  處理 formula 標記, 它和 sub, sup 是一組的.
# 2014/12/25 V9.6  處理 <sub></sub><sup></sup> 標記
# 2014/06/17 V9.5  原西蓮代碼 "SL" 改成 智諭 "ZY", 取消西蓮專用目錄
# 2014/05/27 V9.4  處理 <A>, <B>, <C>, <E>, <Y> 及 </p>, </P> , 前者空四格, 後者不理它.
# 2014/03/10 V9.3  不論是否用通用字, 一律不使用通用詞
# 2014/03/09 V9.2  處理部份經文在 "一經一檔" 的模式下不用改檔名的問題
# 2014/03/06 V9.1  修改在 normal1 模式(一經一檔)時嘉興藏經名錯誤的問題
# 2013/11/25 V9.0  使用 cbeta.pm 模組中的缺字物件
# 2013/11/06 V8.9  處理 2013/08/26 修改後造成 source.txt 中空白的來源代碼產生的錯誤
# 2013/10/10 V8.8  處理百品的 [A||B] 標記, 只呈現 B.
# 2013/10/07 V8.7  處理百品的 <k><k1><f><f1> 標記, 也就是忽略它.
# 2013/08/29 V8.6  處理藏西蓮淨苑的 "引文" 標記 <quote ...>...</quote>
# 2013/08/26 V8.5  處理藏經代碼為二位數的情況, 例如西蓮淨苑的 'SL'
# 2013/07/16 V8.4  若檔尾沒有換行符號, 則自動加上去
# 2013/06/27 V8.3  <T,y> 改成 <T,x,y>, 比照 <p,x,y> 的規則處理
# 2013/06/19 V8.2  <trans-mark,...> 前後的空格移除.
# 2013/06/09 V8.1  設定由 ../cbwork_bin.ini 來獲得
# 2013/03/26 V8.0  正式改為 utf8 版, 由 perl 5.16 開始執行
##########################################################
# 2011/06/25 V7.5  取消版本與日期的呈現, 非正式版不使用日期與版本
# 2011/06/20 V7.4  修正將行中<n>誤判為行首<n>.
# 2011/05/14 V7.3  支援國圖的資料
# 2011/05/11 V7.2  不刪除經名後面的括號了, 因為目前的括號都是跨冊的卷數資料.
# 2011/02/23 V7.1  修改一些不連續卷的檔名
# 2011/01/24 V7.0  整合 preformat.pl 及 format.pl 二支程式
# 2010/12/08 V6.9  處理 <tt> 標記, 不空格
# 2010/11/10 V6.8  Ｗ改成空一格。
# 2010/09/15 V6.7  修訂前一版的錯誤, 簡單標記有 = 符號的空格問題
# 2010/07/19 V6.6  支援冊數大於二位數的經文
# 2010/06/09 V6.5  增加第三期藏經 TXJHWIABCDFGKLMNPQSU
# 2009/12/04 V6.4  處理 <N> 標記, 比照 N 空二格
# 2009/10/10 V6.3  處理嘉興 J32, J33 跨冊經文
# 2009/03/06 V6.2  若簡單標記 Q= 前一行行首沒數字, 前前一行也沒有, 則檢查前一行最後一個 <Qn> 標記
# 2009/02/28 V6.1  用另一個方式支援H及W，取消開始支援第三期 C 代碼為行首開頭的經文
# 2009/02/23 V6.0  開始支援第三期 C 代碼為行首開頭的經文
# 2009/02/18 V5.7  處理模糊字 <□> -> ▆
# 2008/05/05 V5.6  支援嘉興藏及 <annals><date><event> 三組標記
# 2007/11/29 V5.5  T56~T84 要比照卍續的標記, 因為卍續比較精準.
# 2007/11/16 V5.4  處理 T56 SAT 三組新標記 : <sd> , <ruby><rb><rt> , <note type="okuri" place="inline"></note>
# 2007/09/27 V5.3  忽略 <s> 標記
# 2006/11/07 V5.2  <p=hn> 由 <Qn> 改成 <p,m> , n 與 m 有某種比例
# 2006/11/02 V5.1  處理 cutptag , 當初忘了處理 <I\d> 這種格式, 忘了加 \d
# 2006/10/03 V5.0  修改切卷的判斷法, 嚴格規定每一卷的開頭一定有 <mj> 的標記.
# 2006/09/26 V4.41 暫時讓 <mj> 通過
# 2006/06/20 V4.40 忽略側註標記 <i> </i>
# 2006/05/27 V4.39 把雙句點變成單句點的置換移除, 因為真的有可能要雙句點.
# 2006/04/14 V4.38 不管 <K1 初序分(二)> 這種科判
# 2006/02/06 V4.37 處理 <p> 在行中時, 若前面有空格, 就不要空了 (這應該以前就要處理好了啊?)
# 2006/01/29 V4.36 處理 <c2 r2> 的格式
# 2005/11/05 V4.35 處理 X03 的不連續卷問題
# 2005/10/17 V4.34 修訂上版失誤,若有連續 <Qn m=xxx><Qn m=xxx><Qn m=xxx>....<xx> 則忽略 <Qn>... , 只處理 <xx>
# 2005/09/23 V4.33 處理新標記, <Qn m=xxx> 及 <p=hn> 都比照 <Qn> 空格, 但若有 <Qn m=xxx><xx> 則忽略 <Qn> , 只處理 <xxx>
# 2005/08/10 V4.32 昨天 V4.31 取消, 因為 sm 要取消 n## 及 e## , <e> 比對 <n> 處理
# 2005/08/09 V4.31 1. 處理 <n,a,b>...<d><p,x,y> 時, <p,x,y> 要繼承 <n,a,b> 的空格, 包括 <d><p> 在行首的情況.
# 2005/08/05 V4.30 1. 處理Ｉ, 比照前一個 <In> 的處理法.
# 2005/07/30 V4.29 1. 處理 <n,a,b>...<d><p,x,y> 時, <p,x,y> 要繼承 <n,a,b> 的空格
#				   2. 處理Ｉ, 比照 <I> 的處理法.
# 2005/07/21 V4.28 1. 因為 <z> 和 <p> 處理方法相同, 所以將 <z> 換成 <p> 來處理
# 				   2. 行首 <p> 不空格, 若是 <I2><p> 造成 <p> 之前已有空格, 依然算是行首
# 2005/06/27 V4.27 1. <T 標記會切斷 <p> 的範圍
# 2005/06/24 V4.26 1. 行首的 <n> 不空格
# 2005/06/13 V4.25 1. 因為 <z,x,y> 和 <p,x,y> 處理方法相同, 所以將 <z, 換成 <p, 來處理
# 2005/06/10 V4.24 1. <T,n> 依 n 空格 
# 2005/03/21 V4.23 1. Ｃ 空四格, 
#                  2. <c> 的範圍會跨行, 所以第一個 <c> 要以 f 簡單標記來判斷.
# 2005/03/18 V4.22 1. <c2> 空三格
# 2005/02/18 V4.21 1. 版本及日期支援 xml 的檔案
# 2005/01/27 V4.20 1. </F>
# 2004/12/17 V4.19 1. <x> 及 <x, 及 <x  都能切斷 p 的影響, x 是特定標記, 以前只處理第一種.
# 2004/12/13 V4.18 1.<[en],\d> 空三格
# 2004/11/15 V4.17 1.Ｐ及Ｚ不換成圈點, 因為已經自動換了
# 2004/11/12 V4.16 1.處理 <c> 標記, 第一個空一格, 其它空三格.
# 2004/09/24 V4.15 1.Ｐ不繼承行首有 Q 簡單數字的空格。<?><p...> 的 <p> 也算行首的 <p>
# 2004/09/20 V4.14 1.行中的Ｐ或<p,x,x>至少都要有一個空格
# 2004/09/09 V4.13 1.Ｚ比照Ｐ空格
# 2004/09/09 V4.12 1.I 標記不繼承 P , 但 Ｉ 行中標記要繼承.
# 2004/09/09 V4.11 1.Z 標記不繼承 P , 但 Ｚ 行中標記要繼承.
# 2004/09/08 V4.10 1.Q 之後非第一個 Ｐ 則空一格
# 2004/09/03 V4.9  1.去除行尾空格
# 2004/08/18 V4.8  1.APP 能處理卍續藏新增的標記
# 2004/08/17 V4.7  1.G 標記依然會繼承 P 的縮排
# 2004/07/31 V4.6  1.取消 a-i 的空格 (若配合 P 則不取消, 如 P#a), 並處理一些瑣碎的事
# 2004/07/29 V4.5  1.處理 <o>,<u>
# 2004/07/21 V4.4  1.處理 <S> , <X,n>
# 2004/07/14 V4.3  1.nohead 版讀取 source.txt , normal 版讀 source4.txt
# 2004/07/14 V4.2  1.處理 <J> 標記
# 2004/07/13 V4.1  1.處理 <In> 在行首的空格
#                  2.處理 = 符號達到 3 行範圍
# 2004/07/09 V4.0  1.重新修改標記處理法.
#                  2.合併 fgformat_nohead.pl
#                  3.修改 <In> 標記, 行中同一層的 <In> 只空一格
#                  4.處理 = 符號的簡單標記
#                  5.處理 <w><a><e><n><d>....等標記
# 2004/06/14 V3.32 1.修改 <In> 標記, 因為它也會與簡單標記 I 同時出現
# 2004/05/31 V3.31 1.讓 Q 所在行的行中段落Ｐ或 <p> 在 sm→normal 呈現空一格
# 2004/05/12 V3.30 1.Ｐ在無特別情況下, 改成一個空格.
# 2004/05/07 V3.29 1.若 Ｐ 的前面是 s，則Ｐ轉出兩個空格.
#                  2.X若有數字,則比照 Q 的數字.
# 2004/03/30 V3.28 1.序的標題改成空二格
# 2003/12/05 V3.27 1.若簡單標記有 - , 例如 J-# , 則該卷不切
# 2003/11/26 V3.26 1.若第二卷之後還有 N 標記, 記得也放入該卷, 別被切到上一卷了
# 2003/11/12 V3.25 1.Ｐ若在標題Q, 且在 （ｘｘ）之後，則不加句點
# 2003/11/12 V3.24 1.Ｐ若在小經q, 則不加句點
# 2003/11/11 V3.22 1.Ｐ分成大正藏 VS 卍續藏
# 2003/11/11 V3.21 1.Ｐ又要加空格了?
# 2003/11/07 V3.20 1.處理 I 及 <In> 標記
# 2003/10/29 V3.19 1.處理這行特例, 不讓它跑到上一卷去 X84n1579_p0020b11
# 2003/10/23 V3.18 1.處理 <Q數字> 的標記
# 2003/10/07 V3.17 1.I 除了遇到 </L> , 遇到 L 開頭也要停止該段的空格
# 2003/10/01 V3.16 1.處理 "LQ+數字" 的問題, 這一類一律空 0 格
#                  2.遇到 I , 則 I 的段落都要空格, 直到遇到 </L> 為止
# 2003/09/17 V3.15 1.處理連續二個句點的問題
# 2003/09/15 V3.14 1.處理 <j>
#                  2.Ｐ要繼承之前的<p,x,y>或是P#d, 但要小心Q
# 2003/09/10 V3.13 1.Ｐ應該是不處理, 而不是空格.
# 2003/09/10 V3.12 1.再處理 <p,x,x> 的問題
# 2003/09/08 V3.11 1.段尾加上圈點，所以Ｐ及<p,x,x>不加圖點
# 2003/09/03 V3.10 1.處理 Q 的 bug
# 2003/09/03 V3.9 1.處理一行多個 <p,x,y>
# 2003/08/29 V3.8 1.若是行中的 <p,x,y> , 則第一個空格改成句點。
# 2003/08/29 V3.7 1.處理</Qn></L>
# 2003/08/29 V3.6 1.處理小寫 p 參數
# 2003/08/26 V3.5 1.修改 Q +數字的空格數
# 2003/08/22 V3.4 1.處理 Q +數字及IL 標記
# 2003/08/20 V3.3 1.修改成適用卍續藏經文 part III
# 2003/08/20 V3.2 1.修改成適用卍續藏經文 part II
# 2003/08/13 V3.1 1.修改成適用卍續藏經文
# 2001/07/01 V3.0 1.徹底修改 app 折行規則
# 				  2.取消日期與版本 (因為要以 xml 為主嘛!)
# 06/30/2001 V2.3 1.55 冊有新標記"M"、"R"、"Ｍ"、"Ｒ"，於處理 normal 版時，
#                   建議將"Ｍ"、"Ｒ"皆以一個全形空白來替代。
#		  		2.加入一些標記, 如 Tt(不規則偈頌) 2001/06/30
# 01/09/2001 V2.2 1.加入簡單標記小寫英文字 a-i, 用來表示 10~18 個全型空格
#                   而原來的小d 是因為含卷名的品名,故不空格, 如今改成若同時有DJ,就不空格.
# 12/11/2000 V2.1 1.加入將全型小寫ｊ變成全型空格的判斷
#		  		2.處理第一卷是 JX# 的判斷, 以前會和下一卷接起來, 如今不會了.
#		  		3.加入將Ｔ變成全型空格的判斷(此為非標準格式偈頌，故空一格當開頭)
# 05/09/2000 V2.0 1.加入 K(會), V(分) 簡單標記的判斷.
#		  		2.序不再使用 xxxx_000.txt
# 03/06/2000 V1.9 1.簡單標記加入數字, 用以表示此行要加多少個全型空格.
#                 2. app 版切字加入【】這二個判斷的符號.
#                 3. app 切字本來是一個全型空格, 現在改成所有空格都要移至下一行, 讓行尾無空格. (2000/03/10)
# 02/28/2000 V1.8 V1.5沒寫好, 修改因為第 19 冊 946 經沒有第 3 卷, 所以檔名要跳過 T19/0946_003.txt
# 02/28/2000 V1.7 序名忘了 app 化, 本版補上
# 02/25/2000 V1.6 1.將經卷名, 作譯者, 其它標題都 app 化!
#                 2.處理空白行不應該只有空白.
# 02/25/2000 V1.5 1.加上 ＡＹＢ 內文標記, 要空四格, 是 byline 系列, 同作者譯者其它署名...
#                 2.為第 19 冊寫的, 因為第 19 冊 946 經沒有第 3 卷, 所以檔名要跳過 T19/0946_003.txt
#                 3.全型右括號'）'無法直接比對, 所以使用 $righthook 變數處理
#                 4.make_app 加上 GH? 三個標記, 這是屬於不要管它的標記, 容許它們斷行處理.
#                 5.將品名, 也列入 app 折行. (經名, 譯者, 作者...等再考慮吧)
# 02/17/2000 V1.4 1.加上 B 簡單標記, 要空四格, 是 byline 系列, 同作者譯者...
#                 2.加上 d 簡單標記, 不空格的品, 通常是和其它格式共用的品, 例如和經名重覆.
# 01/13/2000 V1.3 1.加上 q 這個簡單標記, 這是不空二格的 "其它標題"
#		  2.加上 ＤＱ 二個內文的特殊標記.
#		  3.修改結果的目錄.
# 01/06/2000 V1.2 修改版本來源格式, 讓各經的版本數字與日期都獨立出來.
# 11/27/1999 V1.1 處理 ＰＺＳｓ四個全型內文的標記, 讓 ? 的標記減少
# 11/20/1999 V1.0 正確處理 第六冊 及 第七冊 Normal 版的檔名 (201~400 , 401~600卷)
# 11/15/1999 V0.9 正確處理卷與序的切點, 除了第一個序之後卷會獨立成檔, 其它序後的卷都會接著序.
#                 而附文 (簡單標記 W) 的一切標記都不做切檔參考.
#		  並修行卷首資料各版本的中英文名稱.
# 11/07/1999 V0.8 改名成 bm2nor.pl , 並修改支援三行的簡單標記 x║ or x## or xy#
# 10/30/1999 V0.7 附文標記由一個 W 改成每行一個, 且若該行沒資料, 不要加全形空格
#                 之前版本附文標記只有一個 W , 只有本卷結束才結束
# 10/10/1999 V0.6 支援 App(一卷一檔), App1 版本 (一經一檔, 皆依逗點斷句).
# 10/08/1999 V0.5 支援 normal1 版本(一經一檔), 之前只支援一卷一檔模式
# 8/23/1999 V0.4 修正第 xx 冊, xx 中文表示的方法
# 8/1/1999 V0.3  來源記錄中英文的分別由空白改成逗點, 這樣中文就可以有空白了
#		 舊: S:蕭鎮國大德, Text as provided by Mr. Hsiao Chen-Kuo
#		 新: S:蕭鎮國大德  Text as provided by Mr. Hsiao Chen-Kuo
# 7/21/1999 V0.2 簡易內文標記Ｐ要換成句點"。", 上一版是換成全型空白
#                一經的版本來源不一定是三個, 所以要修改程式
# 7/20/1999 V0.1 第一個測試版
#
#######################################################################
#流程 :
#
#捉一行
#檢查屬性, 情況計有 :
#  1. 原來沒有, 並發現序, 所以可以訂 xxxx_000.txt
#  2. 原來沒有, 並發現卷, 所以可以訂 xxxx_yyy.txt
#  4. 原來有序(卷), 並發現卷(序or卷),  換檔了.

use lib "../";
use cbeta;
use utf8;
use autodie;
use Encode;
use Config::IniFiles;

my $show_uni_ver = '2.0';

#######################################
# 讀取來自 ../cbwork_bin.ini 的設定
#######################################

my $cfg = Config::IniFiles->new( -file => "../cbwork_bin.ini" );

my $release_dir = $cfg->val('default', 'release', '/release');	# 讀取 release 目錄
my $cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');	# 讀取 cbwork 目錄
my $Xfile = $cfg->val('bm2nor', 'Xfile', 0);		# 1 : 表示序要單獨一個檔, 0: 表示不用了 -- V2.0

my $outdir = $release_dir . "/bm/";				# 輸出的目錄
my $xml_root_path = $cbwork_dir . "/xml/";		# xml 經文的位置

#######################################
#不要改的參數
#######################################

#local $ver;	#版本, 由 get_ver_date 讀出 (V1.2 之後取消)
#local $date;	#版本日期, 由 get_ver_date 讀出 (V1.2 之後取消)

my @all_sutra;						# 讀入的經文檔
my @all_source;						# 讀入的來源檔

my $filename = "";
my $now_sutra="";			#這一行的經號
local $line="";				#這一行的內容
my $jun_num = 0;
my $prefile_sutra = "";		#上一個檔案的經號, 用來判斷這是本經的第幾個檔

# 和傳入的參數有關, 這是處理經文格式用的
my $vol_head;			#判斷是 "T"(大正), "X" 或是其它.
my $T_vol = "";			#處理的冊數, 由參數傳入, 例如 "T05";
my $format = "NORMAL";	# 輸出版本, 預設值是 normal (一卷一檔) , 目前尚支援 normal1, app1, app
my $nohead = 0;			# 判斷要不要有卷首資料, 可由參數 NOHEAD 保留校勘數字
my $jk_num = 0;			# 判斷要不要移除校勘數字, 可由參數 JK_NUM 保留校勘數字
my $no_normal = 0;		# 判斷要不要通用字, 可由參數 NO_NORMAL 保留校勘數字

my %xmlver;				# 由 xml 取回的各經版本, 參數有五位數, 例如 $xmlver{"0001_"}
my %xmldate;			# 由 xml 取回的各經版本日期, 參數有五位數, 例如 $xmlver{"0001_"}
my $ctag_num;   		# <c> 的次數, 由遇到 f 標記開始計數, 第一個要空一格, 其它空三格.

# 有段落概念的標記參數.######################

my $I_space = "";		# 如果遇到 I , 則要空 I_space 個空格, 直到遇到 </L>
my $smallp1 = 0;		# 小 p 的第一個參數.
my $smallp2 = 0;		# 小 p 的第二個參數.
my $is_p = 0;			# 用來判斷現在是不是在 P 參數中, 這是為了 Ｐ的繼承判斷用的.
my $I_level = 0;		# I 的層次

# <n> 的處理法, 記錄 <n,x,y> 的 x,y , 若遇到 <d> 則設定 $has_d , 
# 若再遇到 <p> , 則 <p> 繼承 <n> 的 x,y, 直到遇到下一個 <n> 或 </n> 才解除 $has_d

my $smalln1 = 0;		# 小 n 的第一個參數 x.
my $smalln2 = 0;		# 小 n 的第二個參數 y.
my $has_d = 0;			# 若有 <d> 標記, 則 <p> 標記不要切斷前面 <n,1,2> 的範圍, 並將 <n> 的範圍加入 <p>, 也就是處理 $smallp1 及 $smallp2	

#######################################
#由參數判斷要輸出何種版本經文
#######################################

sub check_format()
{
	print_help() if ($ARGV[0] !~ /^(\D+)\d+/i);	# 沒有第一個參數就錯了!
	$vol_head = uc($1);								#判斷是 "T"(大正), "X" 或是其它.
	$T_vol = uc($ARGV[0]);
	
	print "Run $T_vol";
	
	return if ($ARGV[1] eq "");		#無參數則用 default 值 (Normal)
	
	for($i = 1; $i <= $#ARGV; $i++)
	{
		my $tmp = uc($ARGV[$i]);
		
		print " $tmp";
		
		if(($tmp eq "NOHEAD") || ($tmp eq "NO_HEAD"))
		{
			$nohead = 1;
			$sourcefile = "source.txt";
		}
		elsif($tmp eq "JK_NUM")
		{
			$jk_num = 1;		# 不要移除校勘數字
		}
		elsif($tmp eq "NO_NORMAL")
		{
			$no_normal = 1;		# 不要換通用字
		}
		elsif($tmp eq "NORMAL" or$tmp eq "NORMAL1" or $tmp eq "APP" or $tmp eq "APP1")
		{
			$format = $tmp;
		}
		else
		{
			print_help();
		}
	}
}

sub print_help()
{
	print STDERR tobig5("\n參數錯誤！\n");
	print STDERR "使用方法 : Perl bm2nor.pl Vol [NoHead] [No_Normal] [JK_Num] [ Normal | Normal1 | App | App1 ]\n";
	print STDERR "例 : Perl bm2nor.pl T01\n";
	exit;	
}

#######################################
# 每一個檔案產生後, 都要重新設定的參數
#######################################

sub reinitial()
{
	@content="";
	pop(@content);
	$sutra_num = "";        #上一行的經號
	$state = "";			#本卷第一個發現的 J or X 簡易標記
}

#######################################
# 清除舊檔案
#######################################
sub mv_old_file
{
	# 待清除舊的檔案
	if(-d "$outdir$format/$vol_head/$T_vol")
	{
		my $del_files = "$outdir$format/$vol_head/$T_vol/*.*";
		unlink <${del_files}>;
	}
}

#######################################
#
#  主程式
#
#######################################

my $gaiji = new Gaiji();
$gaiji->load_access_db();

open ERR, ">>:utf8", "bm2nor_err.txt";	# 錯誤檔的輸出

check_format();	# 由參數判斷要輸出何種版本經文
mv_old_file();	# 清除舊檔案

prenormal();	# 原來的 prenormal.pl 程式, 主要是把缺字變成通用字, 並去除標記
get_source();   # 處理經文來源檔
get_ver_date_from_xml();	# 由 xml 經文取得各經的版本與日期
#get_ver_date();	#取得日期與版本號碼 (V1.2 之後取消)

# open IN, "../$T_vol/$infile" || die "open ../$T_vol/$infile error : $!";
reinitial();                    #初值設定

#############

while($line=shift(@all_sutra))	# 取得每一行資料
{
	next if($line !~ /^[A-Z]/);
	$line =~ /^\D+\d+n(.{5}).{8}(...)/;
	$now_sutra = $1;

	if(($now_sutra ne $sutra_num) and ($sutra_num ne ""))   #換新的經文了
	{
		unshift(@all_sutra, $line);
		makefile();
		next;
	}

	$sutra_num = $now_sutra;

	if ($format eq "NORMAL" or $format eq "APP")		# 一卷一檔才需要底下的作法
	{
		if ($state eq "" and $line =~ /<mj (\d\d\d)>/)	#新的一卷
		{
			$jun_num = $1;
			$state = "<mj>";
		}
		elsif ($state eq "<mj>" and $line =~ /<mj (\d\d\d)>/) #新的一卷
		{
			unshift(@all_sutra, $line);
			makefile();
			next;
		}
	}
	push(@content, $line);
}
makefile();

close ERR;
print " ... ok\n";
exit;

##########################################################
# 取得一行 (先由 buffer 取, 若沒有, 再由檔案取)
# V7.0 改成由 all_sutra 來取資料, 沒有檔案了
##########################################################

sub getline()
{
	my $tmp;

	#unless ($tmp = shift(@buffer))
	#{
	#	$tmp = <IN>;
	#}
	
	$tmp = shift(@all_sutra);
	return $tmp;
}

##########################################################
# 將 @content 的內容變成檔案
##########################################################

sub makefile()
{
	local $_;
	$filename = getfilename();
	if($filename !~ /^\D+\d\d\d+[a-zA-Z]?_\d\d\d/) { 
		print ERR "檔名格式錯誤: $filename\n";
		exit_show_err_msg("檔名格式錯誤: $filename");
	}
	
	mkdir ("$outdir", "0777") if (not -d $outdir);
	mkdir ("$outdir$format", "0777") if (not -d "$outdir$format");
	mkdir ("$outdir$format/$vol_head", "0777") if (not -d "$outdir$format/$vol_head");
	mkdir ("$outdir$format/$vol_head/$T_vol", "0777") if (not -d "$outdir$format/$vol_head/$T_vol");
	
	open OUT, ">:utf8", "$outdir$format/$vol_head/$T_vol/$filename";
	if($sutra_num ne $prefile_sutra)
	{
		print_jun_head(1);	#本經第一檔, 印資料多的卷首資訊
	}
	else
	{
		print_jun_head(2);	#非本經第一檔, 印資料少的卷首資訊
	}

	if ($format =~ /APP/)
	{
		make_app();		# 做出 app 格式
	}	

	#local $checkW = 0;		# 用來處理卷末附文用的, 在 rm_simple_sign 會用到. (不用了)
	for(my $i=0; $i<=$#content; $i++)
	{
		$_ = rm_simple_sign($i);	#將此行的基本標記移除, 並做一些處理, 此時會將 ║ 這個符號加入
		
		# 取消印出怪怪的內容
		#if (not /^[TXJHWIABCDFGKLMNPQSU]\d+n\d{4}.p\d{4}[abc]\d{2}\(*\d*\)*║/)	#若格式不對, 則印出來參考
		#{
		#	print "$filename : $_";
		#}
		#if (/^[TXJHWIABCDFGKLMNPQSU]\d+n\d{4}.p\d{4}[abc]\d{2}\d+\)║/)	#app 移位超過 99 , 則印出來參考
		#{
		#	print "$filename : $_";
		#}		
		print OUT "$_";
    }
	close OUT;
	$prefile_sutra = $sutra_num;    #記錄這一個檔的經號
	reinitial();
}

##########################################################
# 本經第一檔, 印資料多的卷首資訊
# 傳入參數 1 表示印長的卷首資訊, 2 表示印短的卷首資訊
##########################################################

sub print_jun_head()
{

##########################################################
#
# 取得經文來源檔資料
#
##########################################################
# 格式如下
#
#【經文資訊】大正新脩大藏經 第八冊 No. 221《放光般若經》
#【版本記錄】CBETA 電子佛典 V1.0 (UTF-8) 普及版，完成日期：6/1/1999
#【編輯說明】本資料庫由中華電子佛典協會（CBETA）依大正新脩大藏經所編輯
#【原始資料】CBETA 自行掃瞄辨識，EBS 人工一校之高麗藏CD經文，其他
#【其它事項】本資料庫可自由免費流通，詳細內容請參閱【中華電子佛典協會版權宣告】(http://www.cbeta.org/copyright.htm)
#========================================================================
## Taisho Tripitaka Vol. 8, No. 221 放光般若經
## CBETA Chinese Electronic Tripitaka Version 1.0 (UTF-8) normalized version, Release Date: 6/1/1999
## Distributor: Chinese Buddhist Electronic Text Association (CBETA)
## Source material obtained from: OCR by CBETA﹐Tripitaka Koreana as proofread by Electronic Buddhadharma Society (EBS)﹐Others
## Distributed free of charge. For details please read at http://www.cbeta.org/copyright_e.htm
#========================================================================
#
# 短的卷首資訊
#
#【經文資訊】大正新脩大藏經 第八冊 No. 221《放光般若經》CBETA 電子佛典 V1.0 普及版
## Taisho Tripitaka Vol. 8, No. 221 放光般若經, CBETA Chinese Electronic Tripitaka V1.0, Normal-Format
#=======================================================================

	my $lors = $_[0];  # 1 表示印長的卷首資訊, 2 表示印短的卷首資訊 # lors : long or small

	my $longver_e;
	my $shortver_e;
	my $longver_c;
	my $shortver_c;
	
	my $sutraver_c;
	my $sutraver_e;

	if ($format =~ /APP/)
	{
		$longver_e = "App-Format";
		$shortver_e = "App-Format";
		$longver_c = "App普及版";
		$shortver_c = "App普及版";	
	}
	else
	{
		$longver_e = "Normalized Version";
		$shortver_e = "Normalized Version";
		$longver_c = "普及版";
		$shortver_c = "普及版";		
	}
		#普及版
		#長卷首中文版本 : V1.0 (Big5) 普及版
		#短卷首中文版本 : V1.0 普及版
		#長卷首英文版本 : V1.0 (Big5) Normalized Version
		#短卷首英文版本 : V1.0, Normalized Version
		#App版
		#長卷首中文版本 : V1.0 (Big5) App普及版
		#短卷首中文版本 : V1.0 App普及版
		#長卷首英文版本 : V1.0 (Big5) App-Format
		#短卷首英文版本 : V1.0, App-Format
		#HTML 版
		#長卷首中文版本 : V1.0 (Big5) HTML普及版
		#短卷首中文版本 : V1.0 HTML普及版
		#長卷首英文版本 : V1.0 (Big5) HTML-Format
		#短卷首英文版本 : V1.0, HTML-Format

# T 大正新脩大藏經 (Taisho Tripitaka) （大正藏） 【大】
# X 卍新纂大日本續藏經 (Manji Shinsan Dainihon Zokuzokyo) （新纂卍續藏） 【卍續】
# J 嘉興大藏經(新文豐版) (Jiaxing Canon(Xinwenfeng Edition)) （嘉興藏） 【嘉興】
# H 正史佛教資料類編 (Passages concerning Buddhism from the Official Histories) （正史） 【正史】
# W 藏外佛教文獻 (Buddhist Texts not contained in the Tripitaka) （藏外） 【藏外】 
# I 北朝佛教石刻拓片百品 (Selections of Buddhist Stone Rubbings from the Northern Dynasties) 【佛拓】

# A 金藏 (Jin Edition of the Canon) （趙城藏） 【金藏】
# B 大藏經補編 (Supplement to the Dazangjing) 　 【補編】
# C 中華大藏經 (Zhonghua Canon) （中華藏） 【中華】
# D 國家圖書館善本佛典 (Selections from the Taipei National Central Library Buddhist Rare Book Collection) 【國圖】
# DA 道安長老全集 (the Complete Works of Ven Daoan)  【道安】
# F 房山石經 (Fangshan shijing) 　 【房山】
# G 佛教大藏經 (Fojiao Canon) 　 【教藏】
# GA 中國佛寺史志彙刊 (Zhongguo Fosi Shizhi Huikan) 【志彙】
# GB 中國佛寺志叢刊 (Zhongguo Fosizhi Congkan) 【志叢】
# HM 惠敏法師蓮風集 (the Seeland Works of Ven Huimin) 【惠敏】
# K 高麗大藏經 (Tripitaka Koreana) （高麗藏） 【麗】
# L 乾隆大藏經(新文豐版) (Qianlong Edition of the Canon(Xinwenfeng Edition)) （清藏、龍藏、乾隆藏） 【龍】
# M 卍正藏經(新文豐版) (Manji Daizokyo(Xinwenfeng Edition)) （卍正藏） 【卍正】
# N 永樂南藏 (Southern Yongle Edition of the Canon) （再刻南藏） 【南藏】
# P 永樂北藏 (Northern Yongle Edition of the Canon) （北藏） 【北藏】
# Q 磧砂大藏經(新文豐版) (Qisha Edition of the Canon(Xinwenfeng Edition)) （磧砂藏） 【磧砂】
# R 卍續藏經(新文豐版) (Manji Zokuzokyo(Xinwenfeng Edition)) （卍續藏）
# S 宋藏遺珍(新文豐版) (Songzang yizhen(Xinwenfeng Edition)) 　 【宋遺】
# U 洪武南藏 (Southern Hongwu Edition of the Canon) （初刻南藏） 【洪武】
# Y 印順法師佛學著作集 (Corpus of Venerable Yin Shun's Buddhist Studies) 【印順】
# Z 卍大日本續藏經 (Manji Dainihon Zokuzokyo)
# ZY 智諭老和尚全集 (the Complete Works of Ven Zhiyu) 【智諭】
		
		
	# TXJHWIABCDFGKLMNPQSU 的名稱
	if($vol_head eq "T")
	{
		$sutraver_c = "大正新脩大藏經";
		$sutraver_e = "Taishō Tripiṭaka";
	}
	elsif($vol_head eq "X")
	{
		$sutraver_c = "卍新纂大日本續藏經";
		$sutraver_e = "Manji Shinsan Dainihon Zokuzōkyō";
	}
	elsif($vol_head eq "J")
	{
		$sutraver_c = "嘉興大藏經（新文豐版）";
		$sutraver_e = "Jiaxing Canon (Shinwenfeng Edition)";
	}
	elsif($vol_head eq "ZS")
	{
		$sutraver_c = "正史佛教資料類編";
		$sutraver_e = "Passages concerning Buddhism from the Official Histories";
	}
	elsif($vol_head eq "ZW")
	{
		$sutraver_c = "藏外佛教文獻";
		$sutraver_e = "Buddhist Texts not contained in the Tripiṭaka";
	}
	elsif($vol_head eq "I")
	{
		$sutraver_c = "北朝佛教石刻拓片百品";
		$sutraver_e = "Selections of Buddhist Stone Rubbings from the Northern Dynasties";
	}
	elsif($vol_head eq "A")
	{
		$sutraver_c = "趙城金藏";
		$sutraver_e = "Jin Edition of the Canon";
	}
	elsif($vol_head eq "B")
	{
		$sutraver_c = "大藏經補編";
		$sutraver_e = "Supplement to the Dazangjing";
	}
	elsif($vol_head eq "C")
	{
		$sutraver_c = "中華大藏經（中華書局版）";
		$sutraver_e = "Zhonghua Canon (Chunghwa Book Edition)";
	}
	elsif($vol_head eq "CC")
	{
		$sutraver_c = "CBETA選集";
		$sutraver_e = "CBETA Selected Collection";
	}
	elsif($vol_head eq "D")
	{
		$sutraver_c = "國家圖書館善本佛典";
		$sutraver_e = "Selections from the Taipei National Central Library Buddhist Rare Book Collection";
	}
	elsif($vol_head eq "F")
	{
		$sutraver_c = "房山石經";
		$sutraver_e = "Fangshan shijing";
	}
	elsif($vol_head eq "G")
	{
		$sutraver_c = "佛教大藏經";
		$sutraver_e = "Fojiao Canon";
	}
	elsif($vol_head eq "GA")
	{
		$sutraver_c = "中國佛寺史志彙刊";
		$sutraver_e = "Zhongguo Fosi Shizhi Huikan";
	}
	elsif($vol_head eq "GB")
	{
		$sutraver_c = "中國佛寺志叢刊";
		$sutraver_e = "Zhongguo fosizhi congkan";
	}
	elsif($vol_head eq "K")
	{
		$sutraver_c = "高麗大藏經（新文豐版）";
		$sutraver_e = "Tripiṭaka Koreana (Shinwenfeng Edition)";
	}
	elsif($vol_head eq "L")
	{
		$sutraver_c = "乾隆大藏經（新文豐版）";
		$sutraver_e = "Qianlong Edition of the Canon (Shinwenfeng Edition)";
	}
	elsif($vol_head eq "M")
	{
		$sutraver_c = "卍正藏經（新文豐版）";
		$sutraver_e = "Manji Daizōkyō (Shinwenfeng Edition)";
	}
	elsif($vol_head eq "N")
	{
		#$sutraver_c = "永樂南藏";
		#$sutraver_e = "Southern Yongle Edition of the Canon";
		$sutraver_c = "漢譯南傳大藏經（元亨寺版）";
		$sutraver_e = "Chinese Translation of the Pāḷi Tipiṭaka (Yuan Heng Temple Edition)";
	}
	elsif($vol_head eq "P")
	{
		$sutraver_c = "永樂北藏";
		$sutraver_e = "Northern Yongle Edition of the Canon";
	}
	elsif($vol_head eq "Q")
	{
		$sutraver_c = "磧砂大藏經（新文豐版）";
		$sutraver_e = "Qisha Edition of the Canon (Shinwenfeng Edition)";
	}
	elsif($vol_head eq "S")
	{
		$sutraver_c = "宋藏遺珍（新文豐版）";
		$sutraver_e = "Songzang yizhen (Shinwenfeng Edition)";
	}
	elsif($vol_head eq "ZY")
	{
		$sutraver_c = "智諭老和尚全集";
		$sutraver_e = "the Complete Works of Ven Zhiyu";
	}
	elsif($vol_head eq "DA")
	{
		$sutraver_c = "道安長老全集";
		$sutraver_e = "the Complete Works of Ven Daoan";
	}
	elsif($vol_head eq "HM")
	{
		$sutraver_c = "惠敏法師蓮風集";
		$sutraver_e = "the Seeland Works of Ven Huimin";
	}
	elsif($vol_head eq "U")
	{
		$sutraver_c = "洪武南藏";
		$sutraver_e = "Southern Hongwu Edition of the Canon";
	}
	elsif($vol_head eq "Y")
	{
		$sutraver_c = "印順法師佛學著作集";
		$sutraver_e = "Corpus of Venerable Yin Shun's Buddhist Studies";
	}
	
	$content[0] =~ /^\D+(\d+)n(.{5})/;
	my $vol = $1;
	my $full_sutra = $2;
	my $sutra_num = $full_sutra;
	my $vol_c;

	if ($vol =~ /^0+(\d+)/)		#取冊數
	{
		$vol = $1;
	}
	if ($full_sutra =~ /^0*(\d*[^_])/)	#取經號
	{
		$sutra_num = $1;
	}
	if ($full_sutra =~ /([AB]\d+[^_])/)	#取經號
	{
		$sutra_num = $1;
	}

	$vol_c = get_cnum($vol);	#取得冊數中文數字

	my ($from, $ver, $date, $sutra_name) = split(/,/, $source{$full_sutra});
	my $fromkey="";
	my $from_c="";
	my $from_e="";

	# 如果有 xml 的版本與日期, 就用 xml 的版本與日期
	
	if($xmlver{"${T_vol}n${full_sutra}"}) { $ver = $xmlver{"${T_vol}n${full_sutra}"};}
	if($xmldate{"${T_vol}n${full_sutra}"}) { $date = $xmldate{"${T_vol}n${full_sutra}"};}
	
	# 第五六七冊有例外
	
	if($T_vol eq "T05")
	{
		if($xmlver{"T05n0220a"}) { $ver = $xmlver{"T05n0220a"};}
		if($xmldate{"T05n0220a"}) { $date = $xmldate{"T05n0220a"};}
	}
	if($T_vol eq "T06")
	{
		if($xmlver{"T06n0220b"}) { $ver = $xmlver{"T06n0220b"};}
		if($xmldate{"T06n0220b"}) { $date = $xmldate{"T06n0220b"};}
	}
	if($T_vol eq "T07")
	{
		if($jun_num <= 537)
		{
			if($xmlver{"T07n0220c"}) { $ver = $xmlver{"T07n0220c"};}
			if($xmldate{"T07n0220c"}) { $date = $xmldate{"T07n0220c"};}
		}
		elsif($jun_num <= 565)
		{
			if($xmlver{"T07n0220d"}) { $ver = $xmlver{"T07n0220d"};}
			if($xmldate{"T07n0220d"}) { $date = $xmldate{"T07n0220d"};}
		}
		elsif($jun_num <= 573)
		{
			if($xmlver{"T07n0220e"}) { $ver = $xmlver{"T07n0220e"};}
			if($xmldate{"T07n0220e"}) { $date = $xmldate{"T07n0220e"};}
		}
		elsif($jun_num <= 575)
		{
			if($xmlver{"T07n0220f"}) { $ver = $xmlver{"T07n0220f"};}
			if($xmldate{"T07n0220f"}) { $date = $xmldate{"T07n0220f"};}
		}
		elsif($jun_num <= 576)
		{
			if($xmlver{"T07n0220g"}) { $ver = $xmlver{"T07n0220g"};}
			if($xmldate{"T07n0220g"}) { $date = $xmldate{"T07n0220g"};}
		}
		elsif($jun_num <= 577)
		{
			if($xmlver{"T07n0220h"}) { $ver = $xmlver{"T07n0220h"};}
			if($xmldate{"T07n0220h"}) { $date = $xmldate{"T07n0220h"};}
		}
		elsif($jun_num <= 578)
		{
			if($xmlver{"T07n0220i"}) { $ver = $xmlver{"T07n0220i"};}
			if($xmldate{"T07n0220i"}) { $date = $xmldate{"T07n0220i"};}
		}
		elsif($jun_num <= 583)
		{
			if($xmlver{"T07n0220j"}) { $ver = $xmlver{"T07n0220j"};}
			if($xmldate{"T07n0220j"}) { $date = $xmldate{"T07n0220j"};}
		}
		elsif($jun_num <= 588)
		{
			if($xmlver{"T07n0220k"}) { $ver = $xmlver{"T07n0220k"};}
			if($xmldate{"T07n0220k"}) { $date = $xmldate{"T07n0220k"};}
		}
		elsif($jun_num <= 589)
		{
			if($xmlver{"T07n0220l"}) { $ver = $xmlver{"T07n0220l"};}
			if($xmldate{"T07n0220l"}) { $date = $xmldate{"T07n0220l"};}
		}
		elsif($jun_num <= 590)
		{
			if($xmlver{"T07n0220m"}) { $ver = $xmlver{"T07n0220m"};}
			if($xmldate{"T07n0220m"}) { $date = $xmldate{"T07n0220m"};}
		}
		elsif($jun_num <= 592)
		{
			if($xmlver{"T07n0220n"}) { $ver = $xmlver{"T07n0220n"};}
			if($xmldate{"T07n0220n"}) { $date = $xmldate{"T07n0220n"};}
		}
		elsif($jun_num <= 600)
		{
			if($xmlver{"T07n0220o"}) { $ver = $xmlver{"T07n0220o"};}
			if($xmldate{"T07n0220o"}) { $date = $xmldate{"T07n0220o"};}
		}
	}

	while(length ($from) >0)		# 取得中英文的經文來源資料
	{
		$fromkey = substr $from, 0, 1;
		$from = substr $from, 1;
		$from_c .= "$source_sign_c{$fromkey}，";
		$from_e .= "$source_sign_e{$fromkey}, ";
	}

	substr ($from_c, -1 , 1) = "";
	substr ($from_e, -2 , 2) = "";

# 日期與版本都不用了 -- V3.0 , 因為換了 git 再次不用日期與版本了 -- V7.5 2013/06/25

$ver = "Vv.v";
$date = "yyyy/mm/dd";

 if($nohead == 0)
 {
  if ($lors == 1)	# 第一卷為全部卷首資料
  {
   print OUT "【經文資訊】$sutraver_c 第${vol_c}冊 No. $sutra_num《$sutra_name》\n";
   print OUT "【版本記錄】CBETA 電子佛典 $ver (UTF-8) $longver_c，完成日期：$date\n";
   print OUT '【編輯說明】本資料庫由中華電子佛典協會（CBETA）依'.${sutraver_c}.'所編輯'."\n";
   print OUT "【原始資料】$from_c\n";
   print OUT '【其它事項】本資料庫可自由免費流通，詳細內容請參閱【中華電子佛典協會版權宣告】(http://www.cbeta.org/copyright.htm)'."\n";
   print OUT "=========================================================================\n";
   print OUT "# $sutraver_e Vol. $vol, No. $sutra_num $sutra_name\n";
   print OUT "# CBETA Chinese Electronic Tripitaka $ver (UTF-8) $longver_e, Release Date: $date\n";
   print OUT "# Distributor: Chinese Buddhist Electronic Text Association (CBETA)\n";
   print OUT "# Source material obtained from: $from_e\n";
   print OUT "# Distributed free of charge. For details please read at http://www.cbeta.org/copyright_e.htm\n";
   print OUT "=========================================================================\n";
  }else{
   print OUT "【經文資訊】$sutraver_c 第${vol_c}冊 No. $sutra_num《$sutra_name》CBETA 電子佛典 $ver $shortver_c\n";
   print OUT "# $sutraver_e Vol. $vol, No. $sutra_num $sutra_name, CBETA Chinese Electronic Tripitaka $ver, $shortver_e\n";
   print OUT "=========================================================================\n";
  }
 }
}

##########################################################
#
# 取得經文來源檔資料
#
##########################################################

sub get_source()
{
	local $_;
	my $record = 0;	#記錄用, 若二次取得經文, 表示中間有漏掉, 表示有問題.
	
	# %source_sign_e 放英文名詞, 例 $source_sing_e{"S"} = "Text as provided by Mister Hsiao Chen-kuo"
    # %source_sign_c 放中文名詞, 例 $source_sing_c{"S"} = "蕭鎮國大德"
    # %source        放各經名及來源, 例 $source{"0310_"} = "大寶積經,SKB";

    #open SOURCE , "../$T_vol/$sourcefile" || die "open ../$T_vol/$sourcefile error : $!";
    for($i = 0; $i<=$#all_source; $i++)
    {
    	$_ = $all_source[$i];
    	
		#找到來源記錄, 格式如下
		#S:蕭鎮國大德, Text as provided by Mr. Hsiao Chen-Kuo

		if (/(.)\s*:\s*(.*?)\s*,\s*(.*?)\s*$/)
		{
			$source_sign_c{"$1"} = "$2";
			$source_sign_e{"$1"} = "$3";
			$record++ if $record == 1;
		}
		#找到經名及來源, 格式如下
		#SK4    T0310-11-p0001 K0022-06 120 大寶積經(120卷)【唐 菩提流志譯并合】
		#elsif (/^(.*?)\s+T(.{5}).*?\s+.*?\s+.*?\s+(.*?)(?:(?:\()|(?:【))/)
		#APJ    T0220-05-p0001  V1.0   1999/12/10  200  大般若波羅蜜多經                【唐 玄奘譯】    K0001-01
		# OcJ   T0241-08-p0778  V1.0   1999/12/10    1  金剛頂瑜伽理趣般若經            【唐 金剛智譯】       -
		#S O    T1057b20-p0090  V1.0   2000/03/01    2  千眼千臂觀世音菩薩陀羅尼神呪經  【唐 智通譯】    K0292-11
		#CR     JA042_01_p0793  V1.0   2008/03/18    1  大慧普覺禪師年譜                    【宋 祖詠編　張掄序　宗演跋】
		#S      ZY0001_01_p0017 V1.0   2013/08/19    1  修大方廣佛華嚴法界觀門直解              【智諭老和尚撰述】
		
		#elsif (/^(.*?)\s\D+(.{5})\d*[\-_].*?\s+(.*?)\s+(.*?)\s+.*?\s+(.*?)\s+/)
		#elsif (/^(.+?)\s[^\d\s]+(.{5})\d*[\-_].*?\s+(.*?)\s+(.*?)\s+.*?\s+(.*?)\s+/)
		elsif (/^(.+?)\s[^\d\s]+(.{4}[\-_a-zA-Z])\d*[\-_].*?\s+(.*?)\s+(.*?)\s+.*?\s+(.*?) +/)
		{
			my $from = $1;
			my $sut_num = $2;
			my $sut_ver = $3;
			my $sut_date = $4;
			my $name = $5;

			$from =~ s/ //g;
			if ($name =~ /\)$/)
			{
				# $name = cut_note($name);	#去除尾部的括號
			}
			if ($sut_num =~ /(.{4})\-/)
			{
			        $sut_num = "$1_";
			}
			$source{"$sut_num"} = "$from,$sut_ver,$sut_date,$name";
			
			$record =1 if $record == 0;	#判斷取經名有否連續
			$record ++ if $record > 1;
		}
		else
		{
			$record++ if $record == 1;
		}
    }
   # close SOURCE;

#       check again

	# 不 check 了啦!
	return;
	
	###############################
	# 底下不管了

    open TMP, ">../$T_vol/$sourlog" || die "open ../$T_vol/$sourlog error : $!";
    
    print TMP "\nrecord : $record  ";
    if ($record <= 2)
    {
    	print TMP "Good!\n\n";
    }
    else
    {
    	print TMP "*****   Oh! It's not good :(   *****\n\n";
    }        
    
    while (($tmp1, $tmp2) = each(%source_sign_e))
    {
            print TMP "$tmp1 : $source_sign_c{$tmp1}, $tmp2\n";
    }
    
    print TMP "\n-------------------------------------------------------\n\n";

    foreach $key (sort keys(%source))
    {
		my ($t1, $t2, $t3, $t4) = split(/,/, $source{"$key"});
		$t1 .= "          ";
		$t1 =~ s/^(.{10})\s+$/$1/;
		print TMP "$t1  $key  $t2  $t3  $t4\n";
    }

    close TMP;
}

#############################################################
# 取得中文數字
#############################################################

sub get_cnum()
{
	local $_ = $_[0];
	my $head = "";

	s/^10$/十/;		# 10 換成 十
	s/^1(.)$/十$1/g;		# 1x 換成 十x
	
	if(/^(\d)(\d\d)$/)
	{
		$head = "$1百";
		$_ = $2;
		
		if(/^0([1-9])/)		# ex. 208
		{
			$head .= "零";
			$_ = $1;
		}
		
		$_ = $head . $_;
	}
	
	s/([1-9])(\d)/$1十$2/;	# xx 換成 x十x	
	
	s/1/一/g;
	s/2/二/g;
	s/3/三/g;
	s/4/四/g;
	s/5/五/g;
	s/6/六/g;
	s/7/七/g;
	s/8/八/g;
	s/9/九/g;
	s/0//g;
	return ($_);
}

#############################################################
# 由經號與卷數合成檔案
#############################################################

sub getfilename()
{
	local $_;
	
	if ($format eq "NORMAL" or $format eq "APP")
	{
		$content[0] =~ /^(\D+)/;
		$_ = $1;
		$_ .= $sutra_num;
		$_ .= "_" if($_ !~ /_$/);
		$_ .= sprintf ("%03d.txt", "$jun_num");
		#tr/A-Z/a-z/;
		return $_;
	}
	elsif  ($format eq "NORMAL1" or $format eq "APP1")
	{
		#my $tmp = substr($content[0],1,7);
		#my $other = substr($content[0],8,1);
		#if ($other ne "_")
		#{
			#substr($tmp,2,1) = $other;
		#	$tmp .= $other;
		#}
		$content[0] =~ /^(\D+\d+n[AB]?\d{3,4})([a-zA-Z]?)/;
		my $tmp = $1;
		my $tmp2 = $2;
		
		$tmp = $tmp . lc($tmp2) . ".txt";
		return $tmp;
	}
}

#############################################################
# 製作 APP 格式
#
#	V3.0 版, 徹底改變 app 處理規則
#
#		T01n0001_p0001b10_##Ａ這是一個標題
#		T01n0001_p0001b10A##這是一個標題
#		T01n0001_p0001b10P##這是一個段落
#
#		以上都表示前一行都不可接到本行
#
#		T01n0001_p0001b10A##這是一個標題
#		T01n0001_p0001b11A#=這是一個前一行可接過來的標題
#
#		若想接到本行, 就一定要使用 = 符號, 
#		並且只能使用小寫簡單標記, 不可用全型內文標記
#
#############################################################

sub make_app()
{

	# T..n...._p....a..s║ 或
	# T..n...._p....a..s## 或
	# T..n...._p....a..ss# 或

	my $this_sign;		#本行簡單標記
	my $next_sign;		#下一行簡單標記
	my $line_head;		#本行行首
	local $line;		#本行內容

	my $line_num=0;			#輸出的行數
	local $shift_str="";	#上一行移下來的字串
	my $shift_num=0;		#上一行移位的字數

	for($line_num = 0 ; $line_num <= $#content; $line_num++)
	{
		$_ = $content[$line_num];
		chomp;

		#/([TXJHWIABCDFGKLMNPQSU].{16})(...)(.*)/;
		/(\D+\d+n.*?p.\d+.\d\d)(...)(.*)/;
		$line_head = $1;
		$this_sign = $2;		# 取出簡單標記
		$line = $3;
		$this_sign =~ s/║/##/;		# 為了相容舊版用 ║ 符號.

		# 特例處理, 若有本行是空行或一開始是特殊符號, 則上一行的東西不用移過來

		if($shift_num > 0)
		{
			if (($line eq "") or ($line =~ /^((<\/?[wadenIJjpQSouXLP]>)|(。)|( )|(,)|(　)|(◇)|(□)|(．)|(、)|(【)|(】)|(（)|(）)|(\()|(\)))/))
			{
				chomp($content[$line_num-1]);
				$content[$line_num-1] = $content[$line_num-1] . "$shift_str\n";	#上一行還原
				$shift_str = "";
				$shift_num = 0;
			}
		}

		$line = $shift_str . $line;

		if($shift_num < 10) 
		{
			$line_head = $line_head . "(0$shift_num)". $this_sign ;
		}
		elsif($shift_num < 100) 
		{
			$line_head = $line_head . "($shift_num)" . $this_sign;
		}
		else	# 移位超過 100 個字
		{
			$line_head = $line_head . "$shift_num)" . $this_sign;
		}

		$shift_str = "";
		$shift_num = 0;

		if ($line_num != $#content)	#如果不是最後一筆才處理
		{
			$next_sign = substr($content[$line_num+1],17,3);

			if (($next_sign =~ /=/) or ($next_sign =~ /[\d_#a-iFGHTtW\?]{3}/))
			# 要處理的情況, 指定 {3} 是為了不能摻雜其它特殊標記
			{
				# 將 $line 切成 $line + $shift_str (這二個字串都可能被改變)
				cut_line();
				$shift_num = get_shift_num($shift_str);		#計算字數吧!
			}		
		}
		$content[$line_num] = $line_head . $line . "\n";
	}
}

#############################################################
# 將 $line 切成 $line + $shift_str
# 切點有'　'(全型空格)'Ｐ''。'及雙行小註的左右括號
#############################################################

sub cut_line()
{
	# 技巧, 先將缺字換成 !1!, !2!, 放至陣列, 最後再換回來
	
	my $loseword_num=0;
	my @loseword;
	my $loseutf8 = '(?:[^\[\]])';
	
	@loseword = "";
	pop(@loseword);
	
	while($line =~ /\[$loseutf8*?\]/)
	{
		$loseword_num++;
		$line =~ s/(\[$loseutf8*?\])/!$loseword_num!/;
		$loseword[$loseword_num] = $1;
	}
	
	#以'<[wadJSou].*?><\/[wneouQLP].*?>ＰＷＳｓ。．、◇□, 】）)'十二者為切點....] 暫時不用, 缺字啊....，空白則要在下一行行首
	if ($line =~ /^(.)*((<[wadJSou].*?>)|(<\/[wneouQLP].*?>)|(。)|(．)|(、)|(◇)|(□)|(,)|( )|(】)|(）)|(\)))/)
	{
		$line =~ /(.*(?:(?:<[wadJSou].*?>)|(?:<\/[wneouQLP].*?>)|(?:。)|(?:．)|(?:、)|(?:◇)|(?:□)|(?:,)|(?: )|(?:】)|(?:）)|(?:\))))(.*)/;	
		$line = $1;
		$shift_str = $2;
	}
	else
	{
		$shift_str = $line;
		$line = "";
	}

	#if($shift_str =~ /^$big5*\[/)		#若有右中括號, 也可變成切點
	#{
	#	$shift_str =~ /(.*)(\[.*)/;
	#	$line .= $1;
	#	$shift_str = $2;
	#}	
	
	# #若有雙行小註的右括號, 全型右括號,全型空白,ＴＺ(因為會換成全型空白),Ｄ,Ｑ，也可變成切點
	if($shift_str =~ /^.*((\()|(（)|(【)|(　)|(<[enIjpQX].*?>))/)		
	{
		$shift_str =~ /^(.*)((?:(?:\()|(?:（)|(?:【)|(?:　)|(?:<[enIjpQX].*?>)).*)/;
		$line .= $1;
		$shift_str = $2;
	}
	
	#若 $line 字尾是全型空白, 則移至 $shift_str
	if ($line =~ /(　)$/)
	{
		$line =~ /(.*?)((?:　)*)$/;
		$line = $1;
		$shift_str = $2 . $shift_str;
	}
	
	# 若 $shift_str 開頭是 (Ｍ)|(Ｒ)|(ｊ)|(Ｄ)|(Ｑ)|(Ａ)|(Ｙ)|(Ｂ)|(Ｅ) 則移除, 與下一行結合出更多空格
	# $shift_str =~ s/^((Ｍ)|(Ｒ)|(ｊ)|(Ｄ)|(Ｑ)|(Ａ)|(Ｙ)|(Ｂ)|(Ｅ))//;

	# 再將缺字換回來
	while($line =~ /!\d*?!/)
	{
		$line =~ s/!(\d*?)!/$loseword[$1]/g;
	}
	while($shift_str =~ /!\d*?!/)
	{
		$shift_str =~ s/!(\d*?)!/$loseword[$1]/g;
	}
}

#############################################################
# 計算目前這個字串的字數
#############################################################

sub get_shift_num()
{
	local $_ = $_[0];
	my $loseutf8 = '(?:[^\[\]])';
	my $num = 0;

	s/\[$loseutf8*?\]/，/g;		#缺字換成全型，

	# 標記移除不算

	s/<.*?>//g;

	# 英文字母不算

	#s/^((Ｚ)|(Ｉ)|(Ｔ)|(　))//;		# 可能有漏掉的英文字母要處理
	s/^(　)//;		# 可能有漏掉的英文字母要處理

	$num = length($_);
	return $num;
}

#############################################################
# 去除字串尾部的括號
# 例 xxxx(yy) -> xxxx
# 小心 xxxx(yy[(zz)]) -> xxxx
#############################################################

sub cut_note()
{
	local $_ = $_[0];
	
	while (/\)$/)
	{
		while(not /\([^\)]*?\)$/)
		{
			s/\(([^\(]*?)\)/#1#$1#2#/g;
		}
	
		if (/\([^\)]*\)$/)
		{
			s/\([^\(]*\)$//;
		
		}
	
		s/#1#/\(/g;
		s/#2#/\)/g;
	}
	return $_;
}


#############################################################
#將此行的基本標記移除, 並做一些處理
#############################################################

sub rm_simple_sign()
{
	# 數字表 1-9 個空格
	# 小寫英文字 a-i, 用來表示 10~18 個全型空格
	# A 著者
	# B 空四格的 byline (功能同 AYEC)
	# C 收集者(Collector)
	# D 品名
	# E 編輯者(Editor)
	# e 辭書條目（後面若加「數字」，表示整段縮排多少）
	# F 表格
	# G 圖形
	# H 悉曇字
	# I Item
	# J 經卷（啟始）
	# j 經卷（結束）
	# K 會
	# L List
	# M （Ｍ）經文中提到的經名，普及版只空一格，應該是 T55 冊才有的
	# N 經號
	# n 註解條目（後面若加「數字」，表示整段縮排多少）
	# P 段落
	# p 縮排 (<p,x,y> , x : 整段縮排, x+y : 行首縮排)
	# Q 其它標題
	# q 其它標題, 但普及版不空二格, 為了要與 Q 功能有所分野之故, 而且 q 像段落, 
	#   不一定是單獨一行, 有時會是 q （一）如是我聞．．．這類的開頭.
	# R （Ｒ）經文中提到的經名作者，普及版只空一格，應該是 T55 冊才有的
	# r 照原狀排列，通常在經前目錄 (xml 就是 <p type="pre">)
	# S 偈頌（啟始）
	# s 偈頌（結束）
	# T 不規則偈頌（啟始）
	# t 不規則偈頌（結束）
	# V 分
	# W 卷末附文
	# X 前序, 可視為一卷的開始
	# x 後序, 不是卷的開始
	# Y 譯者
	# Z 咒語
	# ? 難以處理者
	#(不用了) d 不空二格的 "品名". (尤其經名中含有 xxx 品的這種品, 如 T19n0947)

	#APP 會切斷者 :      ABCDEeFIJjKLMNnPpQqRSsTtVXxYZ 
	#APP 不會切斷 :      GHW

	#會結束 P 的縮排者 : ABCDEeFIJjKMNnPpQqRSsTtVXxYZ
	#不會結束 P 的縮排 : GHLW

	# 一堆空格 abcdefghi (先假設不結束 P 也不會切斷 APP)

=begin

	特例: 如果是 "LQ數字" , 則不管 "Q數字" 只管 L , 也就是空 0 格

	Q 且沒數字 ==> 空2格
	Q1 ==> 空2格
	Q2 ==> 空3格
	Q3 ==> 空4格
	Q4 ==> 空2格
	Q5 ==> 空3格
	Q6 ==> 空4格
	Q7 ==> 空2格
	Q8 ==> 空3格

	X 比照 Q 來處理

	L  ==> 空0格
	L1 ==> 空0格
	L2 ==> 空1格
	L3 ==> 空2格
	L4 ==> 空3格

	I  ==> 空1格
	Ｉ ==> 空1格
	I1 ==> 空1格
	I2 ==> 空2格
	I3 ==> 空3格
	I4 ==> 空4格

=== [有規則的問答] ==========================
　<w><p,數字1,數字2> "問"的段落
　<a><p,數字1,數字2> "答"的段落
　</w> 連續問答的結束
　------------------------------------------------
　X68n1319_p0577c08Q#4║淨土問答
　X68n1319_p0577c09_##║<w><p,1>問。念佛之心。無雜無間。即精進度。何故乃云不退
　X68n1319_p0577c10_##║墮耶。
　X68n1319_p0577c11_##║<a><p>答。將謂精進乃能不退墮。非精進即是不退墮耶。辯
  ...
　X68n1319_p0577c18_##║<w><p,1>問。世人聞念佛念心。心淨土淨之語。因膠執內心。
　...
　X68n1319_p0581a21_##║麤而細。若易而難。普願深思。慎勿忽也。</w>
 === [辭書] =================================
　e 辭書條目（後面若加「數字」，表示整段縮排多少）
　<e> 行中辭書條目（依原書格式呈現時內定空三格）
　<d><p,數字1,數字2> 辭典條目之解釋內容及段落縮排狀況
　</e> 連續辭書條目的結束
　------------------------------------------------
　X64n1261_p0314c06e##烈派<d><p,1>烈當依列言行列也。
　....
　X64n1261_p0314b02e##師資<d><p,1>老氏曰。善人。不善人之師。不善人。善人之資。
　X64n1261_p0314b03_##<p,1>說者曰。善人有不善人。然後善救之功著。故曰資。
　....
　X64n1262_p0437c15e##弊<d><p,1>病也。<e>夫<d><p,1>承上啟下之辭。
 === [段落後註解] =============================
　n 註解條目（後面若加「數字」，表示整段縮排多少）
　<n> 行中註解條目（依原書格式呈現時內定空三格）
　<d><p,數字1,數字2> 註解條目之解釋內容及段落縮排狀況
　</n> 連續註解條目的結束
　------------------------------------------------
　X64n1263_p0469b12n#1竹菴<d><p,0,1>溫州龍翔竹菴士珪禪師。成都府史氏子。
　X64n1263_p0469b13_#1嗣佛眼清遠禪師。南嶽下十五世也。
　....
　X64n1263_p0469b14n#1誅茅<d><p,0,1>誅茅者。斬草也。謂誅斬茅草結菴隱居也
　X64n1263_p0469b15_#1淳[烈-列+((厂-一)*臣*巳)]<p,0,1>淳[烈-列+((厂-一)*臣*巳)]宋孝宗年號。
　....
　X64n1263_p0471a16n#1弊<d><p,0,1>病也。<n>張<d><p,0,1>施也。
　=======
　※出現於行中的 <e>、<n>，輸出成 normal 時統一空三格。
==========================

P 空格的規則:

<p> 比照 <p,0,0>
行首 <p,x,y> 比照 x+y 去空格.
行中 <p,x,y> 比照 x+y 去空格, 但若 x+y = 0 , 則自動加一個空格 (依原書呈現時)
 
Q或q之後第一個Ｐ：比照一般的Ｐ（表示可能不只一個空格），但在大正藏不再加句讀。在全型右括號”）”之後的Ｐ就不空格。例如（一）Ｐ
Q之後非第一個Ｐ：比照一般的Ｐ。（也就是沒有額外的規則）

s之後的第一個Ｐ：變成二個空格。（是否是不管之前的繼承？例如之前是空三格，但這裡依然空二格，而下一個Ｐ恢復空三格？）

其它的Ｐ：依繼承的空格數去空格。
　　例外情況：若行首有I+數字，則空格數再加上該數字的空格。
　　　　　　　若至此空格數為0，則自動變成空格１。
　　　　　　　若是大正藏，再空格前再加上句讀。（但不會同時有二個句讀）

==========================
※ sm->normal 時，<Qn....>、<p=h1> 依 Qn 的層次空格，<Qn....><xx> 先變成 <xx>，依 <xx> 格式空格。 
※ sm 要用到 m= 的，統一用 <Qn....> 不用 Q#1，而原來標記欄位的標記改標在 <Qn....> 後面。

=cut

	my $line_index = shift;
	local $_ = $content[$line_index];

	my $linehead;
	my $sign;
	my $shift_str;
	my $line;
	my $preline = "";		# 以後要加在 line 之前的, 例如增加的空格

	# /([TXJHWIABCDFGKLMNPQSU].{16})(\(*\d+\))?(...)(.*\n)/;
	/(\D+\d+n.*?p.\d+.\d\d)(\(*\d+\))?(...)(.*\n)/;
	$linehead = $1;
	$shift_str = $2;
	$sign = $3;		# 取出簡單標記
	$line = $4;	

	if($linehead eq "P178n1611_p0619a02")
	{
		my $debug = 1;
	}

	if($format =~ /APP/)
	{
		$linehead = $linehead . $shift_str . "║";
	}
	else
	{
		$linehead .= "║";
	}

	# 處理 = 的符號

	if($sign =~ /=/ and $sign !~ /\d/)
	{
		my $lastline = $content[$line_index-1];
		#$lastline =~ /[TXJHWIABCDFGKLMNPQSU].{16}(\(*\d+\))?(...)/;
		$lastline =~ /\D+\d+n.*?p.\d+.\d\d(\(*\d+\))?(...)/;
		my $lastsign = $2;		# 取出簡單標記
		$lastsign =~ /(\d)/;
		my $lastnum = $1;
		if($lastnum ne "")
		{
			$sign =~ s/=/$lastnum/;
		}
		elsif($lastsign =~ /=/)
		{
			$lastline = $content[$line_index-2];
			#$lastline =~ /[TXJHWIABCDFGKLMNPQSU].{16}(\(*\d+\))?(...)/;
			$lastline =~ /\D+\d+n.*?p.\d+.\d\d(\(*\d+\))?(...)/;
			$lastsign = $2;		# 取出簡單標記
			$lastsign =~ /(\d)/;
			$lastnum = $1;			
			if($lastnum ne "")
			{
				$sign =~ s/=/$lastnum/;
			}
		}
		#else
		elsif($sign =~ /Q=/i)
		# 若簡單標記 Q= 前一行行首沒數字, 前前一行也沒有, 則檢查前一行最後一個 <Qn> 標記
		{
			$lastline = $content[$line_index-1];
			$lastline =~ /.*<Q(\d+)/;
			$lastnum = $1;			
			if($lastnum ne "")
			{
				$sign =~ s/=/$lastnum/;
			}
		}
	}
	
	###################################################################
	# 先依序處理簡單標記, 再處理行中的標記 V4.0
	###################################################################

	if($sign =~ /[ABCDEeFfIJjKMNnPQqRSsTtVXxYZ]/)
	{
		# 遇到上面的標記, 就要修改小p標記的參數, 表示段落結束了 --------------------------
		$smallp1 = 0;
		$smallp2 = 0;
		$is_p = 0 if ($sign !~ /P/);		# 現在不在段落中
	}

	if ($line ne "\n")
	{
		if($sign =~ /W/)	#若是卷末附文, 全部加一個全型空格
		{
			$preline = "　" . $preline;
		}
		
		if ($sign =~ /[AYCEB]/)		# 作譯者
		{
			$preline = "　　　　" . $preline;
		}

		if ($sign =~ /[ND]/)		# 品名或經號要加二個空格
		{
			if($sign !~ /[Jq]/)		# 但不能是卷名, 否則不能加空白
			{
				$preline = "　　" . $preline;
			}
		}
		
		# Q 在大正藏空二格.
		# 在卍續藏有不同的處理法 :
		# 若後接數字, 則 1 空二格, 2 空三格, 3 空四格 , 4 空二格, 5 空三格, ......
		# 若沒數字, 則空二格.
		
		if ($sign =~ /Q/)	# Q 其它標題
		{
			if((($T_vol ge "T01") && ($T_vol le "T55")) || ($T_vol eq "T85"))	# 大正藏 1-55,85, 空二格
			{
				if($sign !~ /J/)	# 不能是卷名, 否則不能加空白
				{
					$preline = "　　" . $preline;
				}
			}
			else		# 其它, 目前只有卍續藏 , Q1 Q4 空二格, 依此類推
			{
				# 如果是 "LQ數字" , 則不管 "Q數字" 只管 L , 也就是空 0 格
				if($sign !~ /L/ or $sign !~ /\d/)
				{
					if   ($sign =~ /[147]/) {$preline = "　　" . $preline;}
					elsif($sign =~ /[258]/) {$preline = "　　　" . $preline;}
					elsif($sign =~ /[369]/) {$preline = "　　　　" . $preline;}
					else {$preline = "　　" . $preline;}
				}
			}
		}

		# Xx 序
		# 若後接數字, 則 1 空二格, 2 空三格, 3 空四格 , 4 空二格, 5 空三格, ......
		# 若沒數字, 則空二格.

		if ($sign =~ /[Xx]/)
		{
			if   ($sign =~ /[147]/) {$preline = "　　" . $preline;}
			elsif($sign =~ /[258]/) {$preline = "　　　" . $preline;}
			elsif($sign =~ /[369]/) {$preline = "　　　　" . $preline;}
			else {$preline = "　　" . $preline;}
		}
		
		if ($sign =~ /[ne]/)		# n,e 不理它, 但要切斷 d
		{
			$smalln1 = 0;
			$smalln2 = 0;
			$has_d = 0;
		}

		# 處理 I, I 有段落的概念, 每行都要空格, 直到遇到 </L> 才結束

		if ($sign =~ /I/)
		{
			if ($sign !~ /\d/)
			{
				$I_level = 1;
				$I_space = "　";					# 若沒數字, 則要空一格
				$preline = $I_space . $preline;
			}
			elsif($sign !~ /Q/)						# 有數字就依數字去空
			{
				$sign =~ /(\d)/;
				$I_level = $1;
				$I_space = "　" x $I_level;
				$preline = $I_space . $preline;
			}
			else			# 有I有數字就不能有 Q , 否則應該不空格
			{
				$I_level = 1;
				$I_space = "";
			}
		}
		else				# 至此, 就表示沒有 I
		{
			if($sign =~ /L/)	# 沒有 L 才行加空格
			{
				$I_level = 0;
				$I_space = "";
			}
			else
			{
				if($line !~ /^(<.*?>)*?<I\d*>/)	#行首也不可以是 <I>, 才能加空格
				{
					$preline = $I_space . $preline;
				}
			}
		}

		# 處理 L 及獨立數字產生的空格
		
		$sign =~ /(.)(.)(.)/;
		local @signs = ($1, $2, $3);
		
		#if(($vol_head eq "T") or ($sign !~ /[QIXx]/))	# 若數字遇到 Q or I則另外處理
		if(((($T_vol ge "T01") && ($T_vol le "T55")) || ($T_vol eq "T85")) or ($sign !~ /[QIXx]/))	# 若數字遇到 Q or I則另外處理
		{
			my $sp10 = '　　　　　　　　　　';	# 10 個空格
			
			for($i=0;$i<3;$i++)		# 數字加空格
			{
				if ($signs[$i] =~ /\d/)
				{
					# 如果是 "LQ數字" , 則不管 "Q數字" 只管 L , 也就是空 0 格
					if($sign !~ /Q/ or $sign !~ /L/ or $sign !~ /\d/)
					{
						for($j=0; $j<$signs[$i]; $j++)
						{
							next if($sign =~ /L/ and $j==0);		# 如果有 L , 則空格少一個
							$preline = "　" . $preline;
						}
					}
				}
				# a-i 加足數的空格
				elsif ($signs[$i] eq 'a' and $sign=~ /P/){$preline = $sp10 . $preline;}
				elsif ($signs[$i] eq 'b' and $sign=~ /P/){$preline = $sp10 . "　" . $preline;}
				elsif ($signs[$i] eq 'c' and $sign=~ /P/){$preline = $sp10 . "　　" . $preline;}
				elsif ($signs[$i] eq 'd' and $sign=~ /P/){$preline = $sp10 . "　　　" . $preline;}
				elsif ($signs[$i] eq 'e' and $sign=~ /P/){$preline = $sp10 . "　　　　" . $preline;}
				elsif ($signs[$i] eq 'f' and $sign=~ /P/){$preline = $sp10 . "　　　　　" . $preline;}
				elsif ($signs[$i] eq 'g' and $sign=~ /P/){$preline = $sp10 . "　　　　　　" . $preline;}
				elsif ($signs[$i] eq 'h' and $sign=~ /P/){$preline = $sp10 . "　　　　　　　" . $preline;}
				elsif ($signs[$i] eq 'i' and $sign=~ /P/){$preline = $sp10 . "　　　　　　　　" . $preline;}
			}
		}		
	}

	###################################################################
	# 處理行中的標記及大寫的英文字(行中簡單標記) V4.0
	###################################################################
	
	# <?> 標記有 : cwadenIJjpQSouX  (X 不會切斷 p 的範圍)
	# </?> 結尾標記有 : wneouQLP
	# ？ 單一全型英文字母標記有 : ＰＳｓＷＺＩＭＲｊＴＤＱＡＹＢＥＣ
	
	# 處理標記及簡單標記
	
	
	#my $tagword = '(?:(?:<.*?>)|(?:Ｐ)|(?:Ｓ)|(?:ｓ)|(?:Ｗ)|(?:Ｚ)|(?:Ｉ)|(?:Ｍ)|(?:Ｒ)|(?:ｊ)|(?:Ｔ)|(?:Ｄ)|(?:Ｑ)|(?:Ａ)|(?:Ｙ)|(?:Ｂ)|(?:Ｅ)|(?:Ｃ))';
	my $tagword = '(?:<.*?>)';
		
	$fullspace = '　';
	$fullspace1 = '　';
	$fullspace2 = '　　';
	$fullspace3 = '　　　';
	$fullspace4 = '　　　　';
	$fullspace5 = '　　　　　';
	$fullspace6 = '　　　　　　';
	$fullspace7 = '　　　　　　　';
	$fullspace8 = '　　　　　　　　';
	
	my $cutptag = 'aceIJjnopQSTuw';	# 會切斷 p 範圍的標記 -----------------------------------
	
	$_ = $line;
	
	# 處理模糊字, ▆(內碼 A267)
	s/<□>/▆/g;

	# 因為 <z,x,y> 和 <p,x,y> 處理方法相同, 所以先置換
	s/<z,/<p,/g;
	s/<z>/<p>/g;
	#<e..> 和 <n..>  處理方法相同, 所以先置換
	s/<e>/<n>/g;
	s/<e(,.*?>)/<n$1/;
	#<p_r> 段落靠右, 空格比照 <p,8>
	#<p_c> 段落置中, 空格比照 <p,4>
	s/<p_r/<p,8/g;
	s/<p_c/<p,4/g;
	s/<p,r/<p,8/g;
	s/<p,c/<p,4/g;
	
	# <Qn m=...><xx> 要先換成 <xx> 即可, 忽略 <Qn m=...>
	# <Qn m=...> 及 <p=hn> 比照 <Qn> 空格
	
	s/(<Q\d+[^>]*>)+(<.*?>)/$2/g;
	#s/(<Q\d+ m=[^>]*>)+(Ａ)/$2/g;
	s/(<Q\d+)[^>]*>/$1>/g;
	#s/<p=h(\d)>/<Q$1>/g;
	
	#<p=h1> 對應到 <p,2>
	#<p=h2> 對應到 <p,3>
	#<p=h3> 對應到 <p,4>
	#<p=h4> 對應到 <p,2>
	#<p=h5> 對應到 <p,3>
	#<p=h6> 對應到 <p,4>
	#<p=h7> 對應到 <p,2>
	#<p=h8> 對應到 <p,3>
	#<p=h9> 對應到 <p,4>
	#<p=h10>對應到 <p,2>
	
	# 目前 Q 到 25 層

	s/<p=h[147]/<p,2/g;
	s/<p=h[258]/<p,3/g;
	s/<p=h[369]/<p,4/g;
	
	s/<p=h1[0369]/<p,2/g;
	s/<p=h1[147]/<p,3/g;
	s/<p=h1[258]/<p,4/g;

	s/<p=h2[0369]/<p,3/g;
	s/<p=h2[147]/<p,4/g;
	s/<p=h2[258]/<p,2/g;

	if($sign =~ /f/) {$ctag_num = 0;}	# <r> 也是比照處理
	
	# 先處理行首的一些問題

	# <p,c> <p,r> <p,x,y,c> <p,c,x,y> c: 置中, r: 靠右

	if(/^<p(?:,[^>]*?)?,?(-?[\d\.]*),?(-?[\d\.]*).*?>/)		# 行首發現小p標記
	{
		$smallp1 = $1;
		$smallp2 = $2;
		
		$smallp1 = 0 if($smallp1 eq "");
		$smallp2 = 0 if($smallp2 eq "");
		
		$smallp1 = ($smallp1>=0)?int($smallp1+0.5):int($smallp1-0.5);
		$smallp2 = ($smallp2>=0)?int($smallp2+0.5):int($smallp2-0.5);

		$is_p = 1;		# 現在是新的段落開始
		
		# <p> 在行首, 所以要先繼承再空格
		
		if($has_d)	# 在 <d> 標記後面, 所以要繼承 <n> 的範圍
		{
			$smallp1 = $smalln1 + $smallp1;
			$smallp2 = $smallp2;
		}
		
		my $space = "　" x ($smallp1+$smallp2);

		s/^<p(?:,[^>]*?)?,?(-?[\d\.]*),?(-?[\d\.]*).*?>/$space/;
	}
	else
	{
		if(/^(<.*?>)*?<[$cutptag]/)	#  除非行首有 <p,<o,<..... 等, 否則就先加空格
		{
			if(/^<d[^>]*?><p/)		# 如果是 <d> 之後有 <p> 則依然要空格.
			{
				$preline = "　" x $smallp1 . $preline if($line ne "\n");
			}
		}
		else
		{
			$preline = "　" x $smallp1 . $preline if($line ne "\n");
		}
	}

	# 行首的 <n> 不空格
	# 行首的 <n,1> 空一格
	# 行首的 <n,x> 等於 <n,x,0> , 行中的 <n,x> 等於 <n,x,3-x>
	
	if(/^(<[^>]*?>)*?<n>/)
	{
		s/^((<[^>]*?>)*?)<n>/$1<n,0,0>/;
	}
	if(/^(?:<[^>]*?>)*?<n,(\d+)>/)
	{
		my $tmp = $1;
		s/^((<[^>]*?>)*?)<n,\d+>/$1<n,$tmp,0>/;
	}

	# 處理行中的標記及大寫的英文字(行中簡單標記)

	while (/^(.*?)(${tagword})/)
	{
		my $pretag = $1;
		my $thistag = $2;
		
		# 斷落結束的標記
		if($thistag =~ /<[$cutptag][>,\s\dL]/)	# L 是用在 TL
		{
			unless($thistag =~ /<p[>,\s]/ and $has_d)
			# <d> 後面的 <p> 會繼承 <n,x,y> 的空格, 不能算是另起段落
			{
				$smallp1 = 0;
				$smallp2 = 0;
				$is_p = 0;		# 現在是新的段落開始
			}
		}
		
		# 處理小寫的 p 標記 (<p,x,y> , x : 整段縮排, y : 行首縮排)
		# <p,c> <p,r> <p,x,y,c> <p,c,x,y> c: 置中, r: 靠右

		if($thistag =~ /<p(?:,[a-z]*)*?,?(-?[\d\.]*),?(-?[\d\.]*)(?:,[a-z]*)*?>/)	
		{
			$smallp1 = $1;
			$smallp2 = $2;
			
			$smallp1 = 0 if($smallp1 eq "");
			$smallp2 = 0 if($smallp2 eq "");
		
			$smallp1 = ($smallp1>=0)?int($smallp1+0.5):int($smallp1-0.5);
			$smallp2 = ($smallp2>=0)?int($smallp2+0.5):int($smallp2-0.5);
			
			$is_p = 1;		# 現在是新的段落開始
			
			my $myspace = $smallp1 + $smallp2;
			my $pretagtmp = $pretag;
			$pretagtmp =~ s/^($fullspace)*//;	# 判斷是否為行中 <p> , 例如 <I2><p> 會在 <p> 前有空格, 但算行首
			#$pretagtmp =~ s/$fullspace//g;	# 判斷是否為行中 <p> , 例如 <I2><p> 會在 <p> 前有空格, 但算行首
			
			$myspace = 1 if($myspace == 0 and $pretagtmp ne "" and $pretagtmp !~ /$fullspace$/);
			
			my $space = "　" x $myspace;
			s/<p(?:,[a-z]*)*?,?(-?[\d\.]*),?(-?[\d\.]*)(?:,[a-z]*)*?>/$space/;
			
			# <p> 在行中, 所以先處理空格, 再處理繼承
			
			if($has_d)	# 在 <d> 標記後面, 所以要繼承 <n> 的範圍
			{
				$smallp1 = $smalln1 + $smallp1;
				$smallp2 = $smallp2;
			}
			
			next;
		}
		
		# 將行中Ｉ換成標記型的Ｉ
		#if($thistag eq "Ｉ")
		#{
		#	if($I_level)
		#	{
		#		s/^(.*?)Ｉ/$1<I${I_level}>/;
		#		$thistag = "<I${I_level}>";
		#	}
		#	else
		#	{
		#		s/^(.*?)Ｉ/$1<I>/;
		#		$thistag = "<I>";
		#	}
		#}
		
		if($thistag =~ /(<I(\d*)(,[^>]*)?>)/)		# 標記型的 I
		{
			my $itag = $1;
			my $I_level_tmp = $2;
			$I_level_tmp = 1 if($I_level_tmp eq "");
			
			if($I_level_tmp == $I_level and $pretag ne "")	# 同一級, 只要空一格
			{
				s/$itag/　/;
			}
			else
			{
				$I_level = $I_level_tmp;
				$I_space = "　" x $I_level;
				s/$itag/$I_space/;		
			}
			next;
		}

		if($thistag =~ /<\/L\d?>/)		# 遇到 </L> 則結束
		{
			$I_space = "";
			$I_level = 0;
			s/<\/L\d?>//;
			next;
		}

		# Xx 序
		# 若後接數字, 則 1 空二格, 2 空三格, 3 空四格 , 4 空二格, 5 空三格, ......
		# 若沒數字, 則空二格.
		
		if($thistag =~ /<X,?(\d)?>/i)
		{
			my $num = $1;
			if($num eq "")
			{
				s/<X,?(\d)?>/$fullspace2/;
			}
			else
			{
				s/<X,[147]>/$fullspace2/;
				s/<X,[258]>/$fullspace3/;
				s/<X,[39]>/$fullspace4/;
			}
			next;
		}
		
		if($thistag =~ /<\/Q\d*>/)
		{
			s/<\/Q\d*>//;
			next;
		}

		if($thistag =~ /<L(,[^>]*)?>/)
		{
			s/<L(,[^>]*)?>//;
			next;
		}

		if($thistag =~ /<\/L\d?>/)
		{
			s/<\/L\d?>//;
			next;
		}
		
		if($thistag =~ /<L_sp.*?>/)
		{
			s/<L_sp.*?>//;
			next;
		}

		if($thistag eq "</P>")
		{
			s/<\/P>//;
			next;
		}

		if($thistag =~ /(<Q\d*(,[cr])?=?>)/)		# 標記型的 I
		{
			my $Qtag = $1;
			$Qtag =~ s/=//;	# 把 = 去掉
			$Qtag =~ s/,[cr]//;	# 把 ,[cr] 去掉
			if($Qtag eq "<Q>")  {s/<Q(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q1>") {s/<Q1(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q2>") {s/<Q2(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q3>") {s/<Q3(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q4>") {s/<Q4(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q5>") {s/<Q5(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q6>") {s/<Q6(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q7>") {s/<Q7(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q8>") {s/<Q8(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q9>") {s/<Q9(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q10>") {s/<Q10(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q11>") {s/<Q11(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q12>") {s/<Q12(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q13>") {s/<Q13(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q14>") {s/<Q14(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q15>") {s/<Q15(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q16>") {s/<Q16(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q17>") {s/<Q17(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q18>") {s/<Q18(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q19>") {s/<Q19(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q20>") {s/<Q20(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q21>") {s/<Q21(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q22>") {s/<Q22(,[cr])?=?>/$fullspace2/;}
			elsif($Qtag eq "<Q23>") {s/<Q23(,[cr])?=?>/$fullspace3/;}
			elsif($Qtag eq "<Q24>") {s/<Q24(,[cr])?=?>/$fullspace4/;}
			elsif($Qtag eq "<Q25>") {s/<Q25(,[cr])?=?>/$fullspace2/;}
			else
			{
				print "<Qxx> too much, ask heaven to update program.";
				exit;
			}
			next;
		}

		if($thistag eq "<d>")	# 不管 <d> , 但要處理 $has_d
		{
			s/<d>//;
			$has_d = 1;
			next;
		}
		if($thistag =~ /<F(,[^>]*)?>/)	# 不管 <F,xxx>
		{
			s/<F(,[^>]*)?>//;
			next;
		}
		if($thistag =~ /<[waouJsi]>/)	# 不管 <w> , <a> , <J>, <s>, <o>, <u>, <i>
		{
			s/<[waoudJsi]>//;
			next;
		}
		# 忽略 <hi,...> 標記
		if($thistag =~ /<\/?hi.*?>/)
		{
			s/<\/?hi.*?>//;
			next;
		}
		if($thistag =~ /<J\->/)	# 不管 <J->
		{
			s/<J\->//;
			next;
		}
		if($thistag eq "<r>")
		{
			$ctag_num = 0;	# f 也是比照處理
			s/<r>//;
			next;
		}

		if($thistag =~ /<\/?reg>/)	# 不管 <reg> </reg>
		{
			s/<\/?reg>//;
			next;
		}
		if($thistag =~ /<mj \d\d\d>/)	# 不管 <mj xxx>
		{
			s/<mj \d\d\d>//;
			next;
		}
		if($thistag =~ /<K.*?>/)	# 不管 <K1 初序分(二)> 這種科判
		{
			s/<K.*?>//;
			next;
		}
		if($thistag =~ /<\/[wouFTSiPp]>/)	# 不管 </w> , </e>, </F>, </T, </S>, </i>, </P>, </p>
		{
			s/<\/[wouFTSiPp]>//;
			next;
		}
		if($thistag =~ /<\/[ne]>/)	# 不管 </n>, </e> , 但要解除 $has_d
		{
			s/<\/[ne]>//;
			$has_d = 0;
			$smalln1 = 0;
			$smalln2 = 0;
			next;
		}
		# 迷<note type="okuri" place="inline"></note> 這應該變成 迷()
		if($thistag =~ /<note type="okuri" place="inline">/)
		{
			s/<note type="okuri" place="inline">/(/;
			next;
		}
		if($thistag =~ /<\/note>/)
		{
			s/<\/note>/)/;
			next;
		}
		# 修訂的作者名稱 [A>B]<resp="CBETA.maha">
		if($thistag =~ /<resp=.*?>/)
		{
			s/<resp=.*?>//;
			next;
		}
		# <ruby><rb>也</rb><rt></rt></ruby>  這應該變成 也() 
		if($thistag =~ /<\/?ruby>/)
		{
			s/<\/?ruby>//;
			next;
		}
		if($thistag =~ /<\/?rb>/)
		{
			s/<\/?rb>//;
			next;
		}
		if($thistag =~ /<row.*?>/)	
		{
			s/<row.*?>//;
			next;
		}
		if($thistag eq "<rt>")
		{
			s/<rt>/(/;
			next;
		}
		if($thistag eq "</rt>")
		{
			s/<\/rt>/)/;
			next;
		}
		# 忽略 <S,...> 標記
		if($thistag =~ /<S(,[^>]+)?>/)
		{
			s/<S(,[^>]+)?>//;
			next;
		}
		# <sd>&SD-xxxx;</sd>  這應該變成 &SD-xxxx;
		if($thistag =~ /<\/?sd>/)
		{
			s/<\/?sd>//;
			next;
		}
		# 忽略 <seg,...> 標記
		if($thistag =~ /<\/?seg.*?>/)
		{
			s/<\/?seg.*?>//;
			next;
		}
		# 忽略 <formula> 標記
		if($thistag =~ /<\/?formula>/)
		{
			s/<\/?formula>//;
			next;
		}
		# 忽略 <sub> 及 <sup> 標記
		if($thistag =~ /<\/?su[bp]>/)
		{
			s/<\/?su[bp]>//;
			next;
		}
		# 忽略 <del>,<under>,<over> 標記
		# 忽略 <it> <bold> <kai> <ming> <hei> <song>
		# 忽略 <sanot>
		if($thistag =~ /<\/?((it)|(bold)|(no\-it)|(no\-bold)|(kai)|(ming)|(hei)|(song)|(del)|(under)|(over)|(larger)|(smaller)|(sanot))>/)
		{
			s/<\/?((it)|(bold)|(no\-it)|(no\-bold)|(kai)|(ming)|(hei)|(song)|(del)|(under)|(over)|(larger)|(smaller)|(sanot))>//;
			next;
		}
		
		# <e...> 全換成 <n...> 了
		#if($thistag =~ /<e>/)	# <n> <e> 空三格 , 不過後來 <n> 另外處理了
		#{
		#	s/<e>/$fullspace3/;
		#	next;
		#}
		#if($thistag =~ /<e,\d+>/)	# <n,1> <e,1> 空三格 , 不過後來 <n> 另外處理了
		#{
		#	s/<e,\d+>/$fullspace3/;
		#	next;
		#}
		# <e...> 全換成 <n...> 了
		if($thistag =~ /<n[,>]/)	# 處理 <n,x,y>
		{
			$thistag =~ s/<n>/<n,0,3>/;
			if($thistag =~ /<n,(\d)>/)
			{
				my $x = $1;
				my $y = 3-$x;
				$thistag =~ s/<n,(\d)>/<n,$x,$y>/;
			}
			$thistag =~ /<n,(\d),(\d)>/;
			$smalln1 = $1;
			$smalln2 = $2;
			
			$smallp1 = $smalln1;
			$smallp2 = $smalln2;
			$is_p = 1;		# 現在是新的段落開始
			
			my $space = "　" x ($smallp1+$smallp2);

			s/<n.*?>/$space/;
			$has_d = 0;		# 解除 <d>
			next;
		}

		if($thistag =~ /<table.*?>/)	
		{
			s/<table.*?>//;
			next;
		}
		
		# 20130627 <T,y> 改成 <T,x,y>
		#if($thistag =~ /<T,(\d+)>/)	# <T,n> 依 n 空格
		#{
		#	my $space_num = $1;
		#	my $space = "　" x $space_num;
		#	s/<T,(\d+)>/$space/;
		#	next;
		#}

		# 2020/06/30
		# <TL,x,y,z> 類似 <p,x,y><T,z>
		if($thistag =~ /<TL?(,[^>]*?)?,?(-?\d*),?(-?\d*),?(-?\d*)[^>]*>/)	
		{
			my $smallt1 = $1;
			my $smallt2 = $2;
			my $smallt3 = $3;
			
			$smallt1 = 0 if($smallt1 eq "");
			$smallt2 = 0 if($smallt2 eq "");
			$smallt3 = 0 if($smallt3 eq "");
			
			my $space_num = $smallt1 + $smallt2 + $smallt3;
			my $space = "　" x $space_num;
			s/<TL?(,[^>]*?)?,?(-?\d*),?(-?\d*),?(-?\d*)[^>]*>/$space/;
			next;
		}
		if($thistag =~ /<\/TL>/)
		{
			s/<\/TL>//;
			next;
		}
		if($thistag =~ /<[MRWj]>/)
		{
			s/<[MRWj]>/$fullspace/;
			next;
		}
		if($thistag =~/<c([\s,\d][^>]*)?>/)	# <c2 r3,2>
		{
		    $ctag_num++;
		    if($ctag_num == 1)
		    {
		        s/<c([\s,\d][^>]*)?>/$fullspace/;
		    }
		    else
		    {
		        s/<c([\s,\d][^>]*)?>/$fullspace3/;
		    }
			next;
		}
		#if($thistag =~ /<(annals)|(date)|(event)>/)
		if($thistag =~ /<annals>/)
		{
			s/<annals>//;
			next;
		}
		if($thistag =~ /<\/annals>/)
		{
			s/<\/annals>//;
			next;
		}
		if($thistag =~ /<date>/)
		{
			s/<date>//;
			next;
		}
		if($thistag =~ /<event>/)
		{
			s/<event>//;
			next;
		}
		if($thistag =~ /<[kf]1?>/)	# 百品特有標記 high <k> above_medium <k1> medium <f1> low <f>
		{
			s/<[kf]1?>//;
			next;
		}
		if($thistag =~ /<\/[kf]1?>/)	# 百品特有標記
		{
			s/<\/[kf]1?>//;
			next;
		}
		if($thistag =~ /<N>/)
		{
			s/<N>/$fullspace2/;
			next;
		}
		if($thistag =~ /<\/?tt>/)
		{
			s/<\/?tt>//;
			next;
		}
		if($thistag =~ /<PTS\..*?\.(\d+)>/)
		{
			s/<PTS\..*?\.(\d+)>/ $1 /;
			next;
		}
		if($thistag =~ /<trans-mark,(.*?)>/)
		{
			s/<trans-mark,(.*?)>/$1/;
			next;
		}
		if($thistag =~ /(<quote .*?>)|(<quote>)/)	# 西蓮出處連結, 例如 : ZY01n0001_p0020a02_##...佛於經中說，<quote T09n0262_p0007c07-09>舍利弗！汝等當一心...</quote>
		{
			s/(<quote .*?>)|(<quote>)//;
			next;
		}
		if($thistag =~ /<\/quote>/)
		{
			s/<\/quote>//;
			next;
		}		
		if($thistag =~ /<[ABCEY](,[^>]*)?>/)	# <A>, <B>, <C>, <E>, <Y> 都空四格
		{
			s/<[ABCEY](,[^>]*)?>/$fullspace8/;
			next;
		}
		if($thistag =~ /<\/?border>/)
		{
			s/<\/?border>//;
			next;
		}	
		if($thistag =~ /<\/?circle>/)
		{
			s/<\/?circle>//;
			next;
		}	
		if($thistag =~ /<㊣.*?>/)
		{
			s/<㊣.*?>//;
			next;
		}	
		
=begin		
		if($thistag eq "Ｐ")
		{
			#s/^($big5*)Ｐ(.*\n)/$1。$2/;
			#s/^($big5*)Ｐ(.*\n)/$1$2/;
			# 分成三種情況
			# 1.簡單標記沒數字, 繼承 <p,x,y>
			# 2.簡單標記有數字, 
			
			if($sign =~ /Q/i and $is_p == 0)
			{
				$myspace = 0;
				
				$is_p = 1;
				s/^(.*?)Ｐ/$1<<p>>/;	# Q之後的第一個Ｐ變成句點(後來改成空格)
				s/）<<p>>/）/;			# 如果是括號, 就不加句點
				s/<<p>>/$fullspace/;	# 如果不是括號, 才加句點(後來改成空格)
			}
			elsif($sign =~ /s/ and $is_p == 0)		# 若 Ｐ 的前面是 s，則Ｐ轉出兩個空格。
			{
				$is_p = 1;
				s/^(.*?)Ｐ/$1$fullspace2/;
			}
			else
			{
				$is_p = 1;
				my $myspace = $smallp1 + $smallp2;		# 先要處理的空格, 繼承之前的
				if($sign !~ /[QI]/)
				{
					while($sign =~ /(\d)/g)
					{
						$myspace += $1;
					}
				}
				$myspace = 1 if ($myspace == 0);
				$myspace = '　' x $myspace;
				if($linehead =~ /^T/) {s/^(.*?)Ｐ/$1$myspace/;}
				else {s/^(.*?)Ｐ/$1$myspace/;}
			}
			next;
		}
		if($thistag eq "Ｓ")
		{
			s/Ｓ//;	#Ｓ直接變成空字串
			next;
		}
		if($thistag eq "ｓ")
		{
			s/ｓ//;	#ｓ直接變成空字串
			next;
		}
		if($thistag eq "Ｗ")
		{
			s/Ｗ/$fullspace/;	#Ｗ直接變成空一格
			next;
		}
		# Ｚ 改成和行中的 Ｐ 一樣了
		#if($thistag eq "Ｚ")
		#{
		#	s/^($big5*?)Ｚ/$1$fullspace/;
		#	next;
		#}
		if($thistag eq "Ｚ")
		{
			my $myspace = $smallp1 + $smallp2;		# 先要處理的空格, 繼承之前的
			if($sign !~ /I/)
			{
				while($sign =~ /(\d)/g)
				{
					$myspace += $1;
				}
			}
			$myspace = 1 if ($myspace == 0);
			$myspace = '　' x $myspace;
			if($linehead =~ /^T/) {s/Ｚ/$myspace/;}
			else {s/Ｚ/$myspace/;}
			next;
		}
		#if($thistag eq "Ｉ")
		#{
		#	#s/^($big5*?)Ｉ/$1$fullspace/;
		#	#next;
		#}
		if($thistag eq "Ｍ")
		{
			s/Ｍ/$fullspace/;
			next;
		}
		if($thistag eq "Ｒ")
		{
			s/Ｒ/$fullspace/;
			next;
		}
		if($thistag eq "ｊ")
		{
			s/ｊ/$fullspace/;
			next;
		}
		if($thistag eq "Ｔ")
		{
			s/Ｔ/$fullspace/;
			next;
		}
		if($thistag eq "Ｄ")
		{
			s/Ｄ/$fullspace2/;
			next;
		}
		if($thistag eq "Ｑ")
		{
			s/Ｑ/$fullspace2/;
			next;
		}			
=end
=cut	
		
		print STDERR tobig5("錯誤 : 遇到無法處理的標記 => $thistag\n");
		print STDERR tobig5("內容 : $_\n");
		print STDERR tobig5("...任意鍵結束...");
		<STDIN>;
		exit;
	}

	$_ = $linehead . $preline . $_;
	#s/。。/。/g;
	
	s/(　)*$//;		# 去除行尾空格

	return $_;
}

#############################################################
# 由 xml 經文取得各經的版本與日期
#############################################################

sub get_ver_date_from_xml()
{
	my $xmlpath = $xml_root_path . $T_vol . "/";
	
	return until(-d $xmlpath);		# 有目錄才繼續下去
	
	my $xmlfiles = $xmlpath . "$T_vol*.xml";
	
	my @files = <${xmlfiles}>;
	
	foreach my $file (sort(@files))
	{
		# 取出版本
		
		$file =~ /n(.{4,5})\.xml/;
		my $sutranum = $1;
		if(length($sutranum) == 4) {$sutranum .= "_";}	# 補足 5 位數

		open IN, "$file";

		while(<IN>)
		{
			#<edition>.Revision: 1.63 . (Big5)<date>.Date: 2005/02/19 15:38:28 .</date></edition>
			if(/<edition>.Revision:\s(.*?)\s.*?Date:\s(.*?)\s/)
			{
				$xmlver{"${T_vol}n${sutranum}"} = "V$1";
				$xmldate{"${T_vol}n${sutranum}"} = $2;
				#print "$file , $sutranum , $xmlver{$sutranum} , $xmldate{$sutranum}\n";
				last;
			}
			if(/<\/teiHeader>/)
			{
				# 找不到版本, 不找了
				last;
			}
		}
		close IN;
	}
}

#############################################################
# prenormal.pl		~by heaven 2003/08/13 
#
# 將簡單標記版-> pre 普及版 (去符號, 換通用字, 換勘誤)
# 只剩簡單標記沒處理
#
#############################################################

sub prenormal
{
	local $_;
	
	$loseutf8='(?:[^\[\]\|>])';	# 忽略 > [ ] | (百品特有的 [A||B]) (不能加入空格, 以免無法處理 [[No. 123]>])
	$normalutf8 = '(?:[^\[\]; ])';	# 忽略 ; [ ] 及空格, 避免換 [No. 297; cf. 293(Fasc. 40)]

	open (IN, "<:utf8", "${cbwork_dir}/bm/$vol_head/$T_vol/new.txt");

	my $no_chg = 0;	# 這是在處理通用字的 <no_chg> 的數量
	
	while(<IN>)
	{
		# 如果行末沒有換行符號, 則要加上去
		$_ .= "\n" if($_ !~ /\n/);
		
		# 移除校勘數字
		if($jk_num == 0)
		{
			s/\[\d{2,3}[a-zA-Z]?\]//g;
			s/\[＊\]//g;		
			s/◎//g if(/^T\d/);	# 大正藏的 ◎ 才需要移除
		}
	
		# 將勘誤[a>b]換成 b , 將移位[a>>b]換成 b , 要二次, 因為移位中會有修訂 [[巳>已]>>] 或 [了[伹>但]>但了]
		if(/>/)	{ $_ = select_corr($_);	}	
		if(/>/)	{ $_ = select_corr($_);	}
		
		# 新的通用詞處理法, 適用一些選字詞[A;B] , 要用通詞選 B 字, 不然就用 A
		# 通用詞後來取消了, 2016/12/3 印老資料有了規範字詞, 用 [A=B]		
		if(/=/)
		{
			$_ = select_normal_words($_);
		}
		
		# 百品特有的 [A||B] , 表示選用 B 字, 要換成 B		
		if(/\|\|/)
		{
			$_ = select_baipin($_);
		}
		
		# 處理通用字
		$_ = select_normal($_);
				
		# 處理 &SD-XXXX;
		
		s/(&SD\-[^;]*?;){2,}/【◇】/g;
		s/&SD\-[^;]*?;/◇/g;
	
		# 密教部才要換
		$lsiddam = '(？)|(…)|(（)';
		$rsiddam = '(？)|(…)|(）)';
		$siddam = '(◇)|( )|(　)|(．)|(（)|(）)|(？)|(…)';
		
		if(/^[TX]((18)|(19)|(20)|(21)|(39)|(54))/)
		{
			s/【◇】/◇◇/g;
			s/($lsiddam)*◇($siddam)*◇($rsiddam)*/【◇】/g;
		}
		push(@all_sutra, $_);	# 將處理好的經文推入陣入中, 取代 new4.txt 檔案
	}

	$all_sutra[0] =~ s/^\x{FEFF}//;	# 移除 UTF8 的 BOM
	
	close(IN);
	
	###############################################################
	# 處理 source.txt 來源檔
	###############################################################
	
	open (IN, "<:utf8", "${cbwork_dir}/bm/$vol_head/$T_vol/source.txt");
	
	$no_chg = 0;	# 這是在處理通用字的 <no_chg> 的數量
	while(<IN>)
	{
		# 將勘誤[a>b]換成 b , 將移位[a>>b]換成 b , 要二次, 因為移位中會有修訂 [[巳>已]>>]
		if(/>/) { $_ = select_corr($_); }
		if(/>/)	{ $_ = select_corr($_);	}
		
		# 處理通用字
		$_ = select_normal($_);
		
		push(@all_source,$_);
	}
	close(IN);
}

####################################################
# 將勘誤[a>b]換成 b 
# 將移位[a>>b]換成 b 
# 不過要先將組字式 [xxx] 換成 :1az1:xxx:2az2:
# 最後再換回來
####################################################

sub select_corr
{
	local $_ = shift;
	my $loseutf8='(?:[^\[\]>])';	# 忽略 > [ ] (不能加入空格, 以免無法處理 [[No. 123]>])
	
	s/\[($loseutf8*?)\]/:1az1:$1:2az2:/g;
	s/<([^>]{1,10})>/:3az3:$1:4az4:/g;	# 標記也先換掉
	s/<(.?no_chg)>/:3az3:$1:4az4:/g;	# 標記也先換掉
	# 太虛大師全集 TX 的修訂有點奇特，BM 都是 [A>B] ，XML 則有時是A有時是B，所以 BM 二者都要呈現。
	if($vol_head eq "TX") {
		s/\[($loseutf8*?)>{1,2}($loseutf8*?)\]/【$1,$2】/g;
	} else {
		s/\[$loseutf8*?>{1,2}($loseutf8*?)\]/$1/g;
	}
	s/:1az1:/\[/g;
	s/:2az2:/\]/g;
	s/:3az3:/</g;
	s/:4az4:/>/g;
	
	return $_;
}

####################################################
# 新的通用詞處理法, 適用一些選字詞
# [A;B] 表示選用 B 字, 要換成 B , 雖然 A 不一定全等於 B
# 不過要先將組字式 [xxx] 換成 :1az1:xxx:2az2:
# 最後再換回來
####################################################

sub select_normal_words
{
	local $_ = shift;
	
	my $loseutf8 = '(?:[^\[\]=])';	# 忽略 ; [ ] 及空格, 避免換 [No. 297; cf. 293(Fasc. 40)] . 後來改成 = 之後, 允許 ; 及空格了
	
	s/\[($loseutf8+?)\]/:1az1:$1:2az2:/g;
	#if($no_normal == 0)		# 要換成通用詞
	#{
	#	s/\[$loseutf8*?=($loseutf8*?)\]/$1/g;
	#}
	#else					# 不要換, 用原來的詞
	#{
		s/\[$loseutf8*?=($loseutf8*?)\]/$1/g;
	#}
	s/:1az1:/\[/g;
	s/:2az2:/\]/g;
	
	return $_;
}

####################################################
# 百品特有的 [A||B] , 表示選用 B 字, 要換成 B
# 不過要先將組字式 [xxx] 換成 :1az1:xxx:2az2:
# 最後再換回來
####################################################

sub select_baipin
{
	local $_ = shift;
	my $loseutf8='(?:[^\[\]\|])';	# 忽略 [ ] | (百品特有的 [A||B])

	s/\[($loseutf8+?)\]/:1az1:$1:2az2:/g;
	s/\[$loseutf8*?\|\|($loseutf8*?)\]/$1/g;
	s/:1az1:/\[/g;
	s/:2az2:/\]/g;

	return $_;
}

####################################################
# 將組字式及 unicode 換成通用字
####################################################

sub select_normal
{
=BEGIN

	不用通用字有幾個情況:
	
	a. 程式一開始就指定 $no_normal = 1
	b. 行中有 <no_nor> 標記 , 則 $no_nor = 1
	c. 文字用 <no_chg> </no_chg> 包起來 , 則 $no_chg = 1
	
	流程說明:
	
	1. 如果本行有 <no_nor> , 表示整行不用通用字, 則 $no_nor = 1 否則 $no_nor = 0
	2. 逐一取出 <標記> [組字式] 或一般文字
	3. 如果是 <no_chg> 標記, 就記錄 $no_chg++ , 若是 </no_chg> 則 $no_chg--
	4. if 文字 {
			if (文字版本 < 要求的版本 (預設 1.1)) { 使用文字 } # 例如可使用至 3.0 版, 因此 3.0 版的 unicode 可以呈現
			else { 換成 [組字式] } # 直接跳到下一步
		}
	5. if [組字式] {
			if ([組字式] 有 unicode && 文字版本 < 要求的版本) { 使用文字 }	# 避免某文字已有 unicode , 卻依然呈現 unicode
			elsif ($no_normal = 1 || $no_nor > 0 || $no_chg > 0) { 使用 [組字式] }
			else {
				if (有通用字) { 使用 通用字}
				else { 使用 [組字式] }
			}
		}
=cut

	local $_ = shift;
	my $out = "";
	my $pattern = '(<[^<]*?>)|(\[[^\[ 0-9a-z]{2,}?\])|(.)|\n';	# 標記, 組字或一般字的 pattern
	
	# 先處理行首
	
	s/(^\D+\d+n.*?_p.{10})//;
	$out .= $1;
	
	# 判斷有沒有 <no_nor> 標記
	
	my $no_nor = 0;
	if(/<no_nor>/)		# 有 no_nor 表示整行都不用通用字
	{
		$no_nor = 1;
		s/<no_nor>//;
	}
	
	# 逐字處理
	
	while(/^$pattern/)
	{
		s/^($pattern)//;		# 取出一個字
		$word = $1;
		
		if($word =~ /<.*?>/)	###################### 取出的是標記
		{
			if ($word eq "<no_chg>")
			{
				$no_chg++;
				if($no_chg > 1)
				{						
					# 某一字無法找到組字式
					print ERR "錯誤, <no_chg> 超過一層了, 應無此必要.\n";
					print ERR "$out 【 $word 】 $_ \n";
					exit_show_err_msg("錯誤, <no_chg> 超過一層了, 應無此必要.");
				}
			}
			elsif ($word eq "</no_chg>")
			{
				$no_chg--;
				if($no_chg < 0)
				{						
					# 某一字無法找到組字式
					print ERR "錯誤, 此 </no_chg> 為多出來的.\n";
					print ERR "$out 【 $word 】 $_ \n";
					exit_show_err_msg("錯誤, 此 </no_chg> 為多出來的.");
				}
			}
			else
			{
				$out .= $word;
			}
		}
		else
		{
			if(length($word) <=2)	#################### 非組字式 (組字式至少大於 2)
			{
				#if (文字版本 < 要求的版本 (預設 1.1)) { 使用文字 } # 例如可使用至 3.0 版, 因此 3.0 版的 unicode 可以呈現
				#else { 換成 [組字式] } 	# 直接跳到下一步
				
				# 最基本的文字就不檢查了 (T01 快了二秒)
				if(index("。，、？！：；「」『』　", $word) >= 0)
				{
					$out .= $word;		# 直接呈現 $word
					next;
				}
				
				my $uni = sprintf("%04X",ord($word));
				if($gaiji->get_unicode_ver($uni) <= $show_uni_ver)
				{
					$out .= $word;		# 直接呈現 $word
					next;
				}
				elsif($word =~ /[ȧ⏑⏓]/)
				{
					# 特殊字, 直接呈現
					$out .= $word;		# 直接呈現 $word
					next;
				}
				else
				{
					my $cb = $gaiji->uni2cb($uni);
					my $des = $gaiji->cb2des($cb);
					if($des)
					{
						$word = $des;	# 換成組字式, 交給下一段程式去處理
					}
					else
					{
						# 某一字無法找到組字式
						print ERR "錯誤, 此字 $word 非 unicode $show_uni_ver 以下, 但無法轉成組字式, 故無法呈現:\n";
						print ERR "$out 【 $word 】 $_ \n";
						exit_show_err_msg("錯誤, 某一字非 unicode $show_uni_ver 以下, 但無法轉成組字式, 故無法呈現.");
					}
				}
			}
			
			################# 此時應該是組字式了
			
			# 判斷是不是組字式 , [ ] 中不能有 [ , 數字, 空白, 英文字 (因為經文中有 [ka] 這一類的)
			# 數字不能用 \d 判斷了，要用 [0-9]，因為全型數字也會被視為 \d，但組字式有這種 [１２．] = ⒓
			if($word =~ /^\[[^\[ 0-9a-z]+?\]$/)	
			{
				# 找出其 CB 碼
				my $cb = $gaiji->des2cb($word);
				if($cb eq "")
				{
					# 無 CB 碼, 表示此組字式在缺字資料庫中找不到 (其實有可能是羅馬轉寫字)
					print ERR "錯誤, 此組字式 $word 在缺字資料庫中找不到:\n";
					print ERR "$out 【 $word 】 $_ \n";
					exit_show_err_msg("錯誤, 此組字式 $word 在缺字資料庫中找不到.");
				}
				
				$uni = $gaiji->cb2uni($cb);		# 查詢此字是否有 unicode
				
				# if ([組字式] 有 unicode && 文字版本 < 要求的版本) { 使用文字 }	# 避免某文字已有 unicode , 卻依然呈現 unicode
				# elsif ($no_normal = 1 || $no_nor > 0 || $no_chg > 0) { 使用 [組字式] }
				# else {
				#	if (有通用字) { 使用 通用字}
				#	else { 使用 [組字式] }
				# }
				
				if($uni && $gaiji->get_unicode_ver($uni) <= $show_uni_ver)
				{
					# 此字其實有可以呈現的 unicode , 所以還是呈現 unicode
					$out .= chr(hex($uni));
				}
				elsif ($no_normal == 1 || $no_nor > 0 || $no_chg > 0)
				{
					$out .= $word;	# 使用組字式
				}
				else
				{
					my $nor = $gaiji->cb2nor($cb);	# 查詢是否有通用字
					if($nor)
					{
						$out .= $nor;	# 使用通用字
					}
					else
					{
						$out .= $word;	#使用組字式
					}
				}
			}
			else
			{
				# 某一字無法找到組字式
				print ERR "錯誤, 此字 $word 應該要是組字式:\n";
				print ERR "$out 【 $word 】 $_ \n";
				exit_show_err_msg("錯誤, 某一字應該要是組字式.");
			}
		}
	}
	return $out;
}

####################################################
# 有錯誤, 要求執行者看錯誤報告
####################################################

sub exit_show_err_msg
{
	local $_ = shift;
	print tobig5("\n".$_);
	print tobig5("\n請看 bm2nor_err.txt , 任意鍵結束...");
	<>;
	exit;	
}

####################################################
# 將文字轉成 big5 , 以便在 DOS 視窗輸出
####################################################

sub tobig5
{
	my $str = shift;
	return encode("big5",$str);
}

###  END  ####################################################

