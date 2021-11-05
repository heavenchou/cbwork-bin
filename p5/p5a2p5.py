# -*- coding: utf8 -*-
''' CBETA XML P5a 轉 P5
2013.1.4 周邦信 改寫自 cbp4top5.py

Heaven 修改:
2021/07/21 支援太虛大師全書.
2020/07/20 支援西蓮淨苑資料, 要修改 git 的查詢目錄.
2019/09/15 修改成也支援 P5b 版。
2019/09/14 支援新改版的檔頭，檔頭中的日期是 P5a 最後一次提交 GitHub 的日期。
		   <listWit> 改變位置。
		   <edition> 標記改成 <edition>XML TEI P5</edition>。
		   加上 --nv 參數, 表示不要執行驗證。
2018/12/19 支援在 note, lem, rdg 的 cb:provider="xxx" 屬性
2018/10/31 支援 <text cb:behaviour="no-norm"> 標記 
2018/08/17 1. place="inline" 不用再移到 rend 中.
		   2. 支援 <term cb:behaviour="no-norm"> 標記 
2018/07/24 加入惠敏法師著作 HM
2018/06/06 P5b 格式將 </row>...<row><cell> 轉成 </row><row><cell>... 以利 cbreader 處理
2018/03/27 處理屬性中的 & 轉成 &amp; , < 轉成 &lt;
2018/03/23 校註 resp 加上正聞出版社
2017/11/25 增加 -b 參數, 產生 CBReader 專用的 P5b 格式, 特點為:
           1. 沒有 <back> 區, 校勘等資料都和 p5a 一樣, 不做任何移動.
		   2. 缺字是單一標記 <g xxx/> , 沒有包含任何文字, 因為 Mac 版不接受有 Ext-B 的 XML.
           3. 驗證規則和 P5a 一樣.
2017/11/08 增加缺字版本判斷, 並將預設缺字資料庫由 MS Access 改為 CVS 檔
2017/11/03 處理特例字 ȧ , 雖然是 unicode 3.0 , 但直接呈現
2016/12/04 支援印順法師佛學著作集新增的 : 規範字詞 <choice cb:type="規範字詞">, 
           行首頁碼有英文字母 _pa001
2016/11/01 將藏外佛教文獻的藏經代碼 W 改成 ZW , 正史佛教資料類編的 H 改成 ZS
2016/08/02 原本【？】有特殊意義, 要轉成 type="variantRemark" , 現在不用了, 【？】當成是版本不明的版本.
2016/05/20 P5a 轉 P5 的標準由 unicode 1.1 改為 2.0 , 因為韓文是 2.0
2016/05/17 unicode 的版本判斷改用較精準的版本
2016/05/16 1. 修正前一版的小錯誤, 缺字忘了考慮有悉曇及蘭札的情況.
           2. 加上 -g txt 參數, 表示讀取缺字用 gaiji-m_u8.txt , 無參數就是預設的 gaiji-m.mdb
2016/05/16 若 P5a 的缺字有 unicode 1.0 的字, 轉成 p5 時直接採用 unicode 的字
2016/05/05 所有 "校勘記" 或 "註解" 都改成 "校註"
2016/05/05 佛寺志加入法鼓文理學院註解
2016/04/19 加入佛寺志 GA 與 GB
2016/01/14 改了一個版本, 可以不再使用 gaiji-m_u8.txt , 不過變的很慢...
2014/12/23 增加道安長老全集的註解標記
2014/06/17 原西蓮代碼 "SL" 改成 智諭 "ZY", 取消西蓮專用目錄
2014/03/30 1.修改南傳校勘星號處理錯誤的地方.
           2.anchor 標記也要在 back 區出現, 為了避免 xml:id 重覆, back 區的 xml:id 最後加上 '_back'
           3.南傳特有的 note 有星號, 這類 <note type="star"...> 要加上 n 屬性以資區別
2014/03/20 修改 tt , app 及 foreign 三個標記的處理法.
2014/03/14 許多標記原本沒有加在 back區, 本版一一加進去, 這樣 CBReader 處理 back 區中的 lem 及 tt 標記時才不會漏掉那些標記.
2014/03/08 增加 Unicode 區段 U+2E80 ~ U+2EF3 為 unicode 3.0 版
2014/02/09 unclear 標記並非單獨標記, 在百品是有頭尾的, 因此由 EMPTY 中移除.
2013/10/30 處理南傳校勘的 note 星號, 因為過去的星號都在 app 中, 南傳則有在 note 中的星號.
2013/09/29 在 back 區, 只有校勘 note 中的 <p> 要處理, 其他如 app 內不能有 <p> , 所以再度改程式
2013/09/23 校勘 note 中的 <p> 也要處理, 這是因為遇到了 N27 p217 的 0217001 校勘有 <p> 標記 
2013/08/26 處理藏經代碼為二位數的情況, 例如西蓮淨苑的 'SL'
2013/08/22 全部處理時忽略 .git 及 schema 目錄
2013/08/13 各經的 resp 及 wit 記錄不要累積, 各經用各經的記錄. 另外程式中也加上一些註解文字.
2013/07/29 1.將 resp="【甲】【乙】" 這一類的格式插入空格, 【甲】與【乙】才能分離出來
           2.加入通用 unicode 的處理
2013/07/25 將一些 from="beg_xxx" 改成 from="#beg_xxx"
2013/06/24 增加漢譯南傳大藏經的校勘支援
2013/06/09 變數改用設定檔 ../cbwork_bin.ini
'''

import configparser, collections, csv, datetime, glob, os, re, shutil, sys, time, subprocess
from optparse import OptionParser
from lxml import etree
import zbxxml, siddam, ranjana
#import win32com.client # 要安裝 PythonWin

# 使用 lxml 3.0.2 的 RelaxNG 在 validate T18n0850 時有問題
#relaxng_doc = etree.parse('D:/git-repos/ddbc-cbeta/schema/cbeta-p5.rng')
#RELAXNG = etree.RelaxNG(relaxng_doc)

time_format='%Y.%m.%d %H:%M'

EMPTY=['anchor', 'caesura', 'lb', 'milestone', 'mulu', 'pb', 'space']

WITS = {
	'A' : '【金藏】',
	'B' : '【補編】',
	'C' : '【中華】',
	'D' : '【國圖】',
	'DA' : '【道安】',
	'F' : '【房山】',
	'G' : '【佛教】',
	'GA': '【志彙】',
	'GB': '【志叢】',
	'HM': '【惠敏】',
	'I' : '【佛拓】',
	'J' : '【嘉興】',
	'K' : '【麗】',
	'L' : '【龍】',
	'LC' : '【呂澂】',
	'M' : '【卍正】',
	'N' : '【南傳】',
	'P' : '【北藏】',
	'Q' : '【磧砂】',
	'S' : '【宋遺】',
	'T' : '【大】',
	'TX' : '【太虛】',
	'U' : '【洪武】',
	'X' : '【卍續】',
	'Y' : '【印順】',
	'ZS' : '【正史】',
	'ZW' : '【藏外】',
	'ZY' : '【智諭】',
}

RESPS = {
	'B' : 'BuBian',
	'D' : 'NCLRareBook',
	'J' : 'Jiaxing',
	'T' : 'Taisho',
	'TX' : 'TaiXu',
	'X' : 'Xuzangjing',
	'ZS' : 'Dudoucheng',
	'ZW' : 'ZangWai',
}

RESP2WIT = {
	'Taisho' : '【大】',
}

# global variables
resp_id={}
wit_id={}

##########################################
# 羅馬轉寫字轉換, 這應該可以在缺字表中處理 ????
##########################################

def dia2uni(s):
	s = s.replace('a^', 'ā')
	s = s.replace('i^', 'ī')
	s = s.replace('u^', 'ū')
	s = s.replace('n~', 'ñ')
	s = s.replace('a^', 'ā')
	s = s.replace('i^', 'ī')
	s = s.replace('s/', 'ś')
	s = s.replace('u^', 'ū')
	s = s.replace('d!', 'ḍ')
	s = s.replace('h!', 'ḥ')
	s = s.replace('l!^', 'ḹ')
	s = s.replace('l!', 'ḷ')
	s = s.replace('m!', 'ṃ')
	s = s.replace('n%', 'ṅ')
	s = s.replace('n!', 'ṇ')
	s = s.replace('r!^', 'ṝ')
	s = s.replace('r^!', 'ṝ')
	s = s.replace('r!', 'ṛ')
	s = s.replace('s!', 'ṣ')
	s = s.replace('t!', 'ṭ')
	return s

def cbdia2smdia(s):
	s = s.replace('a^', 'aa')
	s = s.replace('i^', 'ii')
	s = s.replace('u^', 'uu')
	s = s.replace('n~', '~n')
	s = s.replace('s/', '`s')
	s = s.replace('d!', '.d')
	s = s.replace('h!', '.h')
	s = s.replace('l!^', '.ll')
	s = s.replace('l!', '.l')
	s = s.replace('m!', '.m')
	s = s.replace('n%', '^n')
	s = s.replace('n!', '.n')
	s = s.replace('r!^', '.rr')
	s = s.replace('r!', '.r')
	s = s.replace('s!', '.s')
	s = s.replace('t!', '.t')
	return s

def big5_uni(s):
	data = (int(s[:2],16), int(s[2:],16))
	big5_bytes = bytes(data)
	return big5_bytes.decode('big5')

################################################
# 讀取 unicode 的版本, 參考 cbwork/UnicodeCharVer
################################################

def get_unicode_ver(uni):

	# 常用的先放前面
	if(uni >= 0x4E00 and uni <= 0x9FA5) : return "1.1"
	# 符號和標點符號
	if(uni >= 0x3000 and uni <= 0x3037) : return "1.1"
	if(uni <= 0x01F5) : return "1.1"
	if(uni >= 0x3400 and uni <= 0x4DB5) : return "3.0"
	if(uni >= 0x20000 and uni <= 0x2A6D6) : return "3.1"
	# 相容表意字補充 - 台灣的相容漢字
	if(uni >= 0x2F800 and uni <= 0x2FA1D) : return "3.1"
	if(uni >= 0x2A700 and uni <= 0x2B734) : return "5.2"
	if(uni >= 0x2B740 and uni <= 0x2B81D) : return "6.0"
	if(uni >= 0x2B820 and uni <= 0x2CEA1) : return "8.0"
	if(uni >= 0x2CEB0 and uni <= 0x2EBE0) : return "10.0"

	if(uni >= 0x0000 and uni <= 0x01F5) : return "1.1"
	if(uni >= 0x01F6 and uni <= 0x01F9) : return "3.0"
	if(uni >= 0x01FA and uni <= 0x0217) : return "1.1"
	if(uni >= 0x0218 and uni <= 0x021F) : return "3.0"
	if(uni == 0x0220) : return "3.2"
	if(uni == 0x0221) : return "4.0"
	if(uni >= 0x0222 and uni <= 0x0233) : return "3.0"
	if(uni >= 0x0234 and uni <= 0x0236) : return "4.0"
	if(uni >= 0x0237 and uni <= 0x0241) : return "4.1"
	if(uni >= 0x0242 and uni <= 0x024F) : return "5.0"
	if(uni >= 0x0250 and uni <= 0x02A8) : return "1.1"
	if(uni >= 0x02A9 and uni <= 0x02AD) : return "3.0"
	if(uni >= 0x02AE and uni <= 0x02AF) : return "4.0"
	if(uni >= 0x02B0 and uni <= 0x02DE) : return "1.1"
	if(uni == 0x02DF) : return "3.0"
	if(uni >= 0x02E0 and uni <= 0x02E9) : return "1.1"
	if(uni >= 0x02EA and uni <= 0x02EE) : return "3.0"
	if(uni >= 0x02EF and uni <= 0x02FF) : return "4.0"
	if(uni >= 0x0300 and uni <= 0x0345) : return "1.1"
	if(uni >= 0x0346 and uni <= 0x034E) : return "3.0"
	if(uni == 0x034F) : return "3.2"
	if(uni >= 0x0350 and uni <= 0x0357) : return "4.0"
	if(uni >= 0x0358 and uni <= 0x035C) : return "4.1"
	if(uni >= 0x035D and uni <= 0x035F) : return "4.0"
	if(uni >= 0x0360 and uni <= 0x0361) : return "1.1"
	if(uni == 0x0362) : return "3.0"
	if(uni >= 0x0363 and uni <= 0x036F) : return "3.2"
	if(uni >= 0x0370 and uni <= 0x0373) : return "5.1"
	if(uni >= 0x0374 and uni <= 0x0375) : return "1.1"
	if(uni >= 0x0376 and uni <= 0x0377) : return "5.1"
	if(uni == 0x037A) : return "1.1"
	if(uni >= 0x037B and uni <= 0x037D) : return "5.0"
	if(uni == 0x037E) : return "1.1"
	if(uni == 0x037F) : return "7.0"
	if(uni >= 0x0384 and uni <= 0x038A) : return "1.1"
	if(uni == 0x038C) : return "1.1"
	if(uni >= 0x038E and uni <= 0x03A1) : return "1.1"
	if(uni >= 0x03A3 and uni <= 0x03CE) : return "1.1"
	if(uni == 0x03CF) : return "5.1"
	if(uni >= 0x03D0 and uni <= 0x03D6) : return "1.1"
	if(uni == 0x03D7) : return "3.0"
	if(uni >= 0x03D8 and uni <= 0x03D9) : return "3.2"
	if(uni == 0x03DA) : return "1.1"
	if(uni == 0x03DB) : return "3.0"
	if(uni == 0x03DC) : return "1.1"
	if(uni == 0x03DD) : return "3.0"
	if(uni == 0x03DE) : return "1.1"
	if(uni == 0x03DF) : return "3.0"
	if(uni == 0x03E0) : return "1.1"
	if(uni == 0x03E1) : return "3.0"
	if(uni >= 0x03E2 and uni <= 0x03F3) : return "1.1"
	if(uni >= 0x03F4 and uni <= 0x03F5) : return "3.1"
	if(uni == 0x03F6) : return "3.2"
	if(uni >= 0x03F7 and uni <= 0x03FB) : return "4.0"
	if(uni >= 0x03FC and uni <= 0x03FF) : return "4.1"
	if(uni == 0x0400) : return "3.0"
	if(uni >= 0x0401 and uni <= 0x040C) : return "1.1"
	if(uni == 0x040D) : return "3.0"
	if(uni >= 0x040E and uni <= 0x044F) : return "1.1"
	if(uni == 0x0450) : return "3.0"
	if(uni >= 0x0451 and uni <= 0x045C) : return "1.1"
	if(uni == 0x045D) : return "3.0"
	if(uni >= 0x045E and uni <= 0x0486) : return "1.1"
	if(uni == 0x0487) : return "5.1"
	if(uni >= 0x0488 and uni <= 0x0489) : return "3.0"
	if(uni >= 0x048A and uni <= 0x048B) : return "3.2"
	if(uni >= 0x048C and uni <= 0x048F) : return "3.0"
	if(uni >= 0x0490 and uni <= 0x04C4) : return "1.1"
	if(uni >= 0x04C5 and uni <= 0x04C6) : return "3.2"
	if(uni >= 0x04C7 and uni <= 0x04C8) : return "1.1"
	if(uni >= 0x04C9 and uni <= 0x04CA) : return "3.2"
	if(uni >= 0x04CB and uni <= 0x04CC) : return "1.1"
	if(uni >= 0x04CD and uni <= 0x04CE) : return "3.2"
	if(uni == 0x04CF) : return "5.0"
	if(uni >= 0x04D0 and uni <= 0x04EB) : return "1.1"
	if(uni >= 0x04EC and uni <= 0x04ED) : return "3.0"
	if(uni >= 0x04EE and uni <= 0x04F5) : return "1.1"
	if(uni >= 0x04F6 and uni <= 0x04F7) : return "4.1"
	if(uni >= 0x04F8 and uni <= 0x04F9) : return "1.1"
	if(uni >= 0x04FA and uni <= 0x04FF) : return "5.0"
	if(uni >= 0x0500 and uni <= 0x050F) : return "3.2"
	if(uni >= 0x0510 and uni <= 0x0513) : return "5.0"
	if(uni >= 0x0514 and uni <= 0x0523) : return "5.1"
	if(uni >= 0x0524 and uni <= 0x0525) : return "5.2"
	if(uni >= 0x0526 and uni <= 0x0527) : return "6.0"
	if(uni >= 0x0528 and uni <= 0x052F) : return "7.0"
	if(uni >= 0x0531 and uni <= 0x0556) : return "1.1"
	if(uni >= 0x0559 and uni <= 0x055F) : return "1.1"
	if(uni == 0x0560) : return "11.0"
	if(uni >= 0x0561 and uni <= 0x0587) : return "1.1"
	if(uni == 0x0588) : return "11.0"
	if(uni == 0x0589) : return "1.1"
	if(uni == 0x058A) : return "3.0"
	if(uni >= 0x058D and uni <= 0x058E) : return "7.0"
	if(uni == 0x058F) : return "6.1"
	if(uni >= 0x0591 and uni <= 0x05A1) : return "2.0"
	if(uni == 0x05A2) : return "4.1"
	if(uni >= 0x05A3 and uni <= 0x05AF) : return "2.0"
	if(uni >= 0x05B0 and uni <= 0x05B9) : return "1.1"
	if(uni == 0x05BA) : return "5.0"
	if(uni >= 0x05BB and uni <= 0x05C3) : return "1.1"
	if(uni == 0x05C4) : return "2.0"
	if(uni >= 0x05C5 and uni <= 0x05C7) : return "4.1"
	if(uni >= 0x05D0 and uni <= 0x05EA) : return "1.1"
	if(uni == 0x05EF) : return "11.0"
	if(uni >= 0x05F0 and uni <= 0x05F4) : return "1.1"
	if(uni >= 0x0600 and uni <= 0x0603) : return "4.0"
	if(uni == 0x0604) : return "6.1"
	if(uni == 0x0605) : return "7.0"
	if(uni >= 0x0606 and uni <= 0x060A) : return "5.1"
	if(uni == 0x060B) : return "4.1"
	if(uni == 0x060C) : return "1.1"
	if(uni >= 0x060D and uni <= 0x0615) : return "4.0"
	if(uni >= 0x0616 and uni <= 0x061A) : return "5.1"
	if(uni == 0x061B) : return "1.1"
	if(uni == 0x061C) : return "6.3"
	if(uni == 0x061E) : return "4.1"
	if(uni == 0x061F) : return "1.1"
	if(uni == 0x0620) : return "6.0"
	if(uni >= 0x0621 and uni <= 0x063A) : return "1.1"
	if(uni >= 0x063B and uni <= 0x063F) : return "5.1"
	if(uni >= 0x0640 and uni <= 0x0652) : return "1.1"
	if(uni >= 0x0653 and uni <= 0x0655) : return "3.0"
	if(uni >= 0x0656 and uni <= 0x0658) : return "4.0"
	if(uni >= 0x0659 and uni <= 0x065E) : return "4.1"
	if(uni == 0x065F) : return "6.0"
	if(uni >= 0x0660 and uni <= 0x066D) : return "1.1"
	if(uni >= 0x066E and uni <= 0x066F) : return "3.2"
	if(uni >= 0x0670 and uni <= 0x06B7) : return "1.1"
	if(uni >= 0x06B8 and uni <= 0x06B9) : return "3.0"
	if(uni >= 0x06BA and uni <= 0x06BE) : return "1.1"
	if(uni == 0x06BF) : return "3.0"
	if(uni >= 0x06C0 and uni <= 0x06CE) : return "1.1"
	if(uni == 0x06CF) : return "3.0"
	if(uni >= 0x06D0 and uni <= 0x06ED) : return "1.1"
	if(uni >= 0x06EE and uni <= 0x06EF) : return "4.0"
	if(uni >= 0x06F0 and uni <= 0x06F9) : return "1.1"
	if(uni >= 0x06FA and uni <= 0x06FE) : return "3.0"
	if(uni == 0x06FF) : return "4.0"
	if(uni >= 0x0700 and uni <= 0x070D) : return "3.0"
	if(uni >= 0x070F and uni <= 0x072C) : return "3.0"
	if(uni >= 0x072D and uni <= 0x072F) : return "4.0"
	if(uni >= 0x0730 and uni <= 0x074A) : return "3.0"
	if(uni >= 0x074D and uni <= 0x074F) : return "4.0"
	if(uni >= 0x0750 and uni <= 0x076D) : return "4.1"
	if(uni >= 0x076E and uni <= 0x077F) : return "5.1"
	if(uni >= 0x0780 and uni <= 0x07B0) : return "3.0"
	if(uni == 0x07B1) : return "3.2"
	if(uni >= 0x07C0 and uni <= 0x07FA) : return "5.0"
	if(uni >= 0x07FD and uni <= 0x07FF) : return "11.0"
	if(uni >= 0x0800 and uni <= 0x082D) : return "5.2"
	if(uni >= 0x0830 and uni <= 0x083E) : return "5.2"
	if(uni >= 0x0840 and uni <= 0x085B) : return "6.0"
	if(uni == 0x085E) : return "6.0"
	if(uni >= 0x0860 and uni <= 0x086A) : return "10.0"
	if(uni == 0x08A0) : return "6.1"
	if(uni == 0x08A1) : return "7.0"
	if(uni >= 0x08A2 and uni <= 0x08AC) : return "6.1"
	if(uni >= 0x08AD and uni <= 0x08B2) : return "7.0"
	if(uni >= 0x08B3 and uni <= 0x08B4) : return "8.0"
	if(uni >= 0x08B6 and uni <= 0x08BD) : return "9.0"
	if(uni == 0x08D3) : return "11.0"
	if(uni >= 0x08D4 and uni <= 0x08E2) : return "9.0"
	if(uni == 0x08E3) : return "8.0"
	if(uni >= 0x08E4 and uni <= 0x08FE) : return "6.1"
	if(uni == 0x08FF) : return "7.0"
	if(uni == 0x0900) : return "5.2"
	if(uni >= 0x0901 and uni <= 0x0903) : return "1.1"
	if(uni == 0x0904) : return "4.0"
	if(uni >= 0x0905 and uni <= 0x0939) : return "1.1"
	if(uni >= 0x093A and uni <= 0x093B) : return "6.0"
	if(uni >= 0x093C and uni <= 0x094D) : return "1.1"
	if(uni == 0x094E) : return "5.2"
	if(uni == 0x094F) : return "6.0"
	if(uni >= 0x0950 and uni <= 0x0954) : return "1.1"
	if(uni == 0x0955) : return "5.2"
	if(uni >= 0x0956 and uni <= 0x0957) : return "6.0"
	if(uni >= 0x0958 and uni <= 0x0970) : return "1.1"
	if(uni >= 0x0971 and uni <= 0x0972) : return "5.1"
	if(uni >= 0x0973 and uni <= 0x0977) : return "6.0"
	if(uni == 0x0978) : return "7.0"
	if(uni >= 0x0979 and uni <= 0x097A) : return "5.2"
	if(uni >= 0x097B and uni <= 0x097C) : return "5.0"
	if(uni == 0x097D) : return "4.1"
	if(uni >= 0x097E and uni <= 0x097F) : return "5.0"
	if(uni == 0x0980) : return "7.0"
	if(uni >= 0x0981 and uni <= 0x0983) : return "1.1"
	if(uni >= 0x0985 and uni <= 0x098C) : return "1.1"
	if(uni >= 0x098F and uni <= 0x0990) : return "1.1"
	if(uni >= 0x0993 and uni <= 0x09A8) : return "1.1"
	if(uni >= 0x09AA and uni <= 0x09B0) : return "1.1"
	if(uni == 0x09B2) : return "1.1"
	if(uni >= 0x09B6 and uni <= 0x09B9) : return "1.1"
	if(uni == 0x09BC) : return "1.1"
	if(uni == 0x09BD) : return "4.0"
	if(uni >= 0x09BE and uni <= 0x09C4) : return "1.1"
	if(uni >= 0x09C7 and uni <= 0x09C8) : return "1.1"
	if(uni >= 0x09CB and uni <= 0x09CD) : return "1.1"
	if(uni == 0x09CE) : return "4.1"
	if(uni == 0x09D7) : return "1.1"
	if(uni >= 0x09DC and uni <= 0x09DD) : return "1.1"
	if(uni >= 0x09DF and uni <= 0x09E3) : return "1.1"
	if(uni >= 0x09E6 and uni <= 0x09FA) : return "1.1"
	if(uni == 0x09FB) : return "5.2"
	if(uni >= 0x09FC and uni <= 0x09FD) : return "10.0"
	if(uni == 0x09FE) : return "11.0"
	if(uni == 0x0A01) : return "4.0"
	if(uni == 0x0A02) : return "1.1"
	if(uni == 0x0A03) : return "4.0"
	if(uni >= 0x0A05 and uni <= 0x0A0A) : return "1.1"
	if(uni >= 0x0A0F and uni <= 0x0A10) : return "1.1"
	if(uni >= 0x0A13 and uni <= 0x0A28) : return "1.1"
	if(uni >= 0x0A2A and uni <= 0x0A30) : return "1.1"
	if(uni >= 0x0A32 and uni <= 0x0A33) : return "1.1"
	if(uni >= 0x0A35 and uni <= 0x0A36) : return "1.1"
	if(uni >= 0x0A38 and uni <= 0x0A39) : return "1.1"
	if(uni == 0x0A3C) : return "1.1"
	if(uni >= 0x0A3E and uni <= 0x0A42) : return "1.1"
	if(uni >= 0x0A47 and uni <= 0x0A48) : return "1.1"
	if(uni >= 0x0A4B and uni <= 0x0A4D) : return "1.1"
	if(uni == 0x0A51) : return "5.1"
	if(uni >= 0x0A59 and uni <= 0x0A5C) : return "1.1"
	if(uni == 0x0A5E) : return "1.1"
	if(uni >= 0x0A66 and uni <= 0x0A74) : return "1.1"
	if(uni == 0x0A75) : return "5.1"
	if(uni == 0x0A76) : return "11.0"
	if(uni >= 0x0A81 and uni <= 0x0A83) : return "1.1"
	if(uni >= 0x0A85 and uni <= 0x0A8B) : return "1.1"
	if(uni == 0x0A8C) : return "4.0"
	if(uni == 0x0A8D) : return "1.1"
	if(uni >= 0x0A8F and uni <= 0x0A91) : return "1.1"
	if(uni >= 0x0A93 and uni <= 0x0AA8) : return "1.1"
	if(uni >= 0x0AAA and uni <= 0x0AB0) : return "1.1"
	if(uni >= 0x0AB2 and uni <= 0x0AB3) : return "1.1"
	if(uni >= 0x0AB5 and uni <= 0x0AB9) : return "1.1"
	if(uni >= 0x0ABC and uni <= 0x0AC5) : return "1.1"
	if(uni >= 0x0AC7 and uni <= 0x0AC9) : return "1.1"
	if(uni >= 0x0ACB and uni <= 0x0ACD) : return "1.1"
	if(uni == 0x0AD0) : return "1.1"
	if(uni == 0x0AE0) : return "1.1"
	if(uni >= 0x0AE1 and uni <= 0x0AE3) : return "4.0"
	if(uni >= 0x0AE6 and uni <= 0x0AEF) : return "1.1"
	if(uni == 0x0AF0) : return "6.1"
	if(uni == 0x0AF1) : return "4.0"
	if(uni == 0x0AF9) : return "8.0"
	if(uni >= 0x0AFA and uni <= 0x0AFF) : return "10.0"
	if(uni >= 0x0B01 and uni <= 0x0B03) : return "1.1"
	if(uni >= 0x0B05 and uni <= 0x0B0C) : return "1.1"
	if(uni >= 0x0B0F and uni <= 0x0B10) : return "1.1"
	if(uni >= 0x0B13 and uni <= 0x0B28) : return "1.1"
	if(uni >= 0x0B2A and uni <= 0x0B30) : return "1.1"
	if(uni >= 0x0B32 and uni <= 0x0B33) : return "1.1"
	if(uni == 0x0B35) : return "4.0"
	if(uni >= 0x0B36 and uni <= 0x0B39) : return "1.1"
	if(uni >= 0x0B3C and uni <= 0x0B43) : return "1.1"
	if(uni == 0x0B44) : return "5.1"
	if(uni >= 0x0B47 and uni <= 0x0B48) : return "1.1"
	if(uni >= 0x0B4B and uni <= 0x0B4D) : return "1.1"
	if(uni >= 0x0B56 and uni <= 0x0B57) : return "1.1"
	if(uni >= 0x0B5C and uni <= 0x0B5D) : return "1.1"
	if(uni >= 0x0B5F and uni <= 0x0B61) : return "1.1"
	if(uni >= 0x0B62 and uni <= 0x0B63) : return "5.1"
	if(uni >= 0x0B66 and uni <= 0x0B70) : return "1.1"
	if(uni == 0x0B71) : return "4.0"
	if(uni >= 0x0B72 and uni <= 0x0B77) : return "6.0"
	if(uni >= 0x0B82 and uni <= 0x0B83) : return "1.1"
	if(uni >= 0x0B85 and uni <= 0x0B8A) : return "1.1"
	if(uni >= 0x0B8E and uni <= 0x0B90) : return "1.1"
	if(uni >= 0x0B92 and uni <= 0x0B95) : return "1.1"
	if(uni >= 0x0B99 and uni <= 0x0B9A) : return "1.1"
	if(uni == 0x0B9C) : return "1.1"
	if(uni >= 0x0B9E and uni <= 0x0B9F) : return "1.1"
	if(uni >= 0x0BA3 and uni <= 0x0BA4) : return "1.1"
	if(uni >= 0x0BA8 and uni <= 0x0BAA) : return "1.1"
	if(uni >= 0x0BAE and uni <= 0x0BB5) : return "1.1"
	if(uni == 0x0BB6) : return "4.1"
	if(uni >= 0x0BB7 and uni <= 0x0BB9) : return "1.1"
	if(uni >= 0x0BBE and uni <= 0x0BC2) : return "1.1"
	if(uni >= 0x0BC6 and uni <= 0x0BC8) : return "1.1"
	if(uni >= 0x0BCA and uni <= 0x0BCD) : return "1.1"
	if(uni == 0x0BD0) : return "5.1"
	if(uni == 0x0BD7) : return "1.1"
	if(uni == 0x0BE6) : return "4.1"
	if(uni >= 0x0BE7 and uni <= 0x0BF2) : return "1.1"
	if(uni >= 0x0BF3 and uni <= 0x0BFA) : return "4.0"
	if(uni == 0x0C00) : return "7.0"
	if(uni >= 0x0C01 and uni <= 0x0C03) : return "1.1"
	if(uni == 0x0C04) : return "11.0"
	if(uni >= 0x0C05 and uni <= 0x0C0C) : return "1.1"
	if(uni >= 0x0C0E and uni <= 0x0C10) : return "1.1"
	if(uni >= 0x0C12 and uni <= 0x0C28) : return "1.1"
	if(uni >= 0x0C2A and uni <= 0x0C33) : return "1.1"
	if(uni == 0x0C34) : return "7.0"
	if(uni >= 0x0C35 and uni <= 0x0C39) : return "1.1"
	if(uni == 0x0C3D) : return "5.1"
	if(uni >= 0x0C3E and uni <= 0x0C44) : return "1.1"
	if(uni >= 0x0C46 and uni <= 0x0C48) : return "1.1"
	if(uni >= 0x0C4A and uni <= 0x0C4D) : return "1.1"
	if(uni >= 0x0C55 and uni <= 0x0C56) : return "1.1"
	if(uni >= 0x0C58 and uni <= 0x0C59) : return "5.1"
	if(uni == 0x0C5A) : return "8.0"
	if(uni >= 0x0C60 and uni <= 0x0C61) : return "1.1"
	if(uni >= 0x0C62 and uni <= 0x0C63) : return "5.1"
	if(uni >= 0x0C66 and uni <= 0x0C6F) : return "1.1"
	if(uni == 0x0C77) : return "12.0"
	if(uni >= 0x0C78 and uni <= 0x0C7F) : return "5.1"
	if(uni == 0x0C80) : return "9.0"
	if(uni == 0x0C81) : return "7.0"
	if(uni >= 0x0C82 and uni <= 0x0C83) : return "1.1"
	if(uni == 0x0C84) : return "11.0"
	if(uni >= 0x0C85 and uni <= 0x0C8C) : return "1.1"
	if(uni >= 0x0C8E and uni <= 0x0C90) : return "1.1"
	if(uni >= 0x0C92 and uni <= 0x0CA8) : return "1.1"
	if(uni >= 0x0CAA and uni <= 0x0CB3) : return "1.1"
	if(uni >= 0x0CB5 and uni <= 0x0CB9) : return "1.1"
	if(uni >= 0x0CBC and uni <= 0x0CBD) : return "4.0"
	if(uni >= 0x0CBE and uni <= 0x0CC4) : return "1.1"
	if(uni >= 0x0CC6 and uni <= 0x0CC8) : return "1.1"
	if(uni >= 0x0CCA and uni <= 0x0CCD) : return "1.1"
	if(uni >= 0x0CD5 and uni <= 0x0CD6) : return "1.1"
	if(uni == 0x0CDE) : return "1.1"
	if(uni >= 0x0CE0 and uni <= 0x0CE1) : return "1.1"
	if(uni >= 0x0CE2 and uni <= 0x0CE3) : return "5.0"
	if(uni >= 0x0CE6 and uni <= 0x0CEF) : return "1.1"
	if(uni >= 0x0CF1 and uni <= 0x0CF2) : return "5.0"
	if(uni == 0x0D00) : return "10.0"
	if(uni == 0x0D01) : return "7.0"
	if(uni >= 0x0D02 and uni <= 0x0D03) : return "1.1"
	if(uni >= 0x0D05 and uni <= 0x0D0C) : return "1.1"
	if(uni >= 0x0D0E and uni <= 0x0D10) : return "1.1"
	if(uni >= 0x0D12 and uni <= 0x0D28) : return "1.1"
	if(uni == 0x0D29) : return "6.0"
	if(uni >= 0x0D2A and uni <= 0x0D39) : return "1.1"
	if(uni == 0x0D3A) : return "6.0"
	if(uni >= 0x0D3B and uni <= 0x0D3C) : return "10.0"
	if(uni == 0x0D3D) : return "5.1"
	if(uni >= 0x0D3E and uni <= 0x0D43) : return "1.1"
	if(uni == 0x0D44) : return "5.1"
	if(uni >= 0x0D46 and uni <= 0x0D48) : return "1.1"
	if(uni >= 0x0D4A and uni <= 0x0D4D) : return "1.1"
	if(uni == 0x0D4E) : return "6.0"
	if(uni == 0x0D4F) : return "9.0"
	if(uni >= 0x0D54 and uni <= 0x0D56) : return "9.0"
	if(uni == 0x0D57) : return "1.1"
	if(uni >= 0x0D58 and uni <= 0x0D5E) : return "9.0"
	if(uni == 0x0D5F) : return "8.0"
	if(uni >= 0x0D60 and uni <= 0x0D61) : return "1.1"
	if(uni >= 0x0D62 and uni <= 0x0D63) : return "5.1"
	if(uni >= 0x0D66 and uni <= 0x0D6F) : return "1.1"
	if(uni >= 0x0D70 and uni <= 0x0D75) : return "5.1"
	if(uni >= 0x0D76 and uni <= 0x0D78) : return "9.0"
	if(uni >= 0x0D79 and uni <= 0x0D7F) : return "5.1"
	if(uni >= 0x0D82 and uni <= 0x0D83) : return "3.0"
	if(uni >= 0x0D85 and uni <= 0x0D96) : return "3.0"
	if(uni >= 0x0D9A and uni <= 0x0DB1) : return "3.0"
	if(uni >= 0x0DB3 and uni <= 0x0DBB) : return "3.0"
	if(uni == 0x0DBD) : return "3.0"
	if(uni >= 0x0DC0 and uni <= 0x0DC6) : return "3.0"
	if(uni == 0x0DCA) : return "3.0"
	if(uni >= 0x0DCF and uni <= 0x0DD4) : return "3.0"
	if(uni == 0x0DD6) : return "3.0"
	if(uni >= 0x0DD8 and uni <= 0x0DDF) : return "3.0"
	if(uni >= 0x0DE6 and uni <= 0x0DEF) : return "7.0"
	if(uni >= 0x0DF2 and uni <= 0x0DF4) : return "3.0"
	if(uni >= 0x0E01 and uni <= 0x0E3A) : return "1.1"
	if(uni >= 0x0E3F and uni <= 0x0E5B) : return "1.1"
	if(uni >= 0x0E81 and uni <= 0x0E82) : return "1.1"
	if(uni == 0x0E84) : return "1.1"
	if(uni == 0x0E86) : return "12.0"
	if(uni >= 0x0E87 and uni <= 0x0E88) : return "1.1"
	if(uni == 0x0E89) : return "12.0"
	if(uni == 0x0E8A) : return "1.1"
	if(uni == 0x0E8C) : return "12.0"
	if(uni == 0x0E8D) : return "1.1"
	if(uni >= 0x0E8E and uni <= 0x0E93) : return "12.0"
	if(uni >= 0x0E94 and uni <= 0x0E97) : return "1.1"
	if(uni == 0x0E98) : return "12.0"
	if(uni >= 0x0E99 and uni <= 0x0E9F) : return "1.1"
	if(uni == 0x0EA0) : return "12.0"
	if(uni >= 0x0EA1 and uni <= 0x0EA3) : return "1.1"
	if(uni == 0x0EA5) : return "1.1"
	if(uni == 0x0EA7) : return "1.1"
	if(uni >= 0x0EA8 and uni <= 0x0EA9) : return "12.0"
	if(uni >= 0x0EAA and uni <= 0x0EAB) : return "1.1"
	if(uni == 0x0EAC) : return "12.0"
	if(uni >= 0x0EAD and uni <= 0x0EB9) : return "1.1"
	if(uni == 0x0EBA) : return "12.0"
	if(uni >= 0x0EBB and uni <= 0x0EBD) : return "1.1"
	if(uni >= 0x0EC0 and uni <= 0x0EC4) : return "1.1"
	if(uni == 0x0EC6) : return "1.1"
	if(uni >= 0x0EC8 and uni <= 0x0ECD) : return "1.1"
	if(uni >= 0x0ED0 and uni <= 0x0ED9) : return "1.1"
	if(uni >= 0x0EDC and uni <= 0x0EDD) : return "1.1"
	if(uni >= 0x0EDE and uni <= 0x0EDF) : return "6.1"
	if(uni >= 0x0F00 and uni <= 0x0F47) : return "2.0"
	if(uni >= 0x0F49 and uni <= 0x0F69) : return "2.0"
	if(uni == 0x0F6A) : return "3.0"
	if(uni >= 0x0F6B and uni <= 0x0F6C) : return "5.1"
	if(uni >= 0x0F71 and uni <= 0x0F8B) : return "2.0"
	if(uni >= 0x0F8C and uni <= 0x0F8F) : return "6.0"
	if(uni >= 0x0F90 and uni <= 0x0F95) : return "2.0"
	if(uni == 0x0F96) : return "3.0"
	if(uni == 0x0F97) : return "2.0"
	if(uni >= 0x0F99 and uni <= 0x0FAD) : return "2.0"
	if(uni >= 0x0FAE and uni <= 0x0FB0) : return "3.0"
	if(uni >= 0x0FB1 and uni <= 0x0FB7) : return "2.0"
	if(uni == 0x0FB8) : return "3.0"
	if(uni == 0x0FB9) : return "2.0"
	if(uni >= 0x0FBA and uni <= 0x0FBC) : return "3.0"
	if(uni >= 0x0FBE and uni <= 0x0FCC) : return "3.0"
	if(uni == 0x0FCE) : return "5.1"
	if(uni == 0x0FCF) : return "3.0"
	if(uni >= 0x0FD0 and uni <= 0x0FD1) : return "4.1"
	if(uni >= 0x0FD2 and uni <= 0x0FD4) : return "5.1"
	if(uni >= 0x0FD5 and uni <= 0x0FD8) : return "5.2"
	if(uni >= 0x0FD9 and uni <= 0x0FDA) : return "6.0"
	if(uni >= 0x1000 and uni <= 0x1021) : return "3.0"
	if(uni == 0x1022) : return "5.1"
	if(uni >= 0x1023 and uni <= 0x1027) : return "3.0"
	if(uni == 0x1028) : return "5.1"
	if(uni >= 0x1029 and uni <= 0x102A) : return "3.0"
	if(uni == 0x102B) : return "5.1"
	if(uni >= 0x102C and uni <= 0x1032) : return "3.0"
	if(uni >= 0x1033 and uni <= 0x1035) : return "5.1"
	if(uni >= 0x1036 and uni <= 0x1039) : return "3.0"
	if(uni >= 0x103A and uni <= 0x103F) : return "5.1"
	if(uni >= 0x1040 and uni <= 0x1059) : return "3.0"
	if(uni >= 0x105A and uni <= 0x1099) : return "5.1"
	if(uni >= 0x109A and uni <= 0x109D) : return "5.2"
	if(uni >= 0x109E and uni <= 0x109F) : return "5.1"
	if(uni >= 0x10A0 and uni <= 0x10C5) : return "1.1"
	if(uni == 0x10C7) : return "6.1"
	if(uni == 0x10CD) : return "6.1"
	if(uni >= 0x10D0 and uni <= 0x10F6) : return "1.1"
	if(uni >= 0x10F7 and uni <= 0x10F8) : return "3.2"
	if(uni >= 0x10F9 and uni <= 0x10FA) : return "4.1"
	if(uni == 0x10FB) : return "1.1"
	if(uni == 0x10FC) : return "4.1"
	if(uni >= 0x10FD and uni <= 0x10FF) : return "6.1"
	if(uni >= 0x1100 and uni <= 0x1159) : return "1.1"
	if(uni >= 0x115A and uni <= 0x115E) : return "5.2"
	if(uni >= 0x115F and uni <= 0x11A2) : return "1.1"
	if(uni >= 0x11A3 and uni <= 0x11A7) : return "5.2"
	if(uni >= 0x11A8 and uni <= 0x11F9) : return "1.1"
	if(uni >= 0x11FA and uni <= 0x11FF) : return "5.2"
	if(uni >= 0x1200 and uni <= 0x1206) : return "3.0"
	if(uni == 0x1207) : return "4.1"
	if(uni >= 0x1208 and uni <= 0x1246) : return "3.0"
	if(uni == 0x1247) : return "4.1"
	if(uni == 0x1248) : return "3.0"
	if(uni >= 0x124A and uni <= 0x124D) : return "3.0"
	if(uni >= 0x1250 and uni <= 0x1256) : return "3.0"
	if(uni == 0x1258) : return "3.0"
	if(uni >= 0x125A and uni <= 0x125D) : return "3.0"
	if(uni >= 0x1260 and uni <= 0x1286) : return "3.0"
	if(uni == 0x1287) : return "4.1"
	if(uni == 0x1288) : return "3.0"
	if(uni >= 0x128A and uni <= 0x128D) : return "3.0"
	if(uni >= 0x1290 and uni <= 0x12AE) : return "3.0"
	if(uni == 0x12AF) : return "4.1"
	if(uni == 0x12B0) : return "3.0"
	if(uni >= 0x12B2 and uni <= 0x12B5) : return "3.0"
	if(uni >= 0x12B8 and uni <= 0x12BE) : return "3.0"
	if(uni == 0x12C0) : return "3.0"
	if(uni >= 0x12C2 and uni <= 0x12C5) : return "3.0"
	if(uni >= 0x12C8 and uni <= 0x12CE) : return "3.0"
	if(uni == 0x12CF) : return "4.1"
	if(uni >= 0x12D0 and uni <= 0x12D6) : return "3.0"
	if(uni >= 0x12D8 and uni <= 0x12EE) : return "3.0"
	if(uni == 0x12EF) : return "4.1"
	if(uni >= 0x12F0 and uni <= 0x130E) : return "3.0"
	if(uni == 0x130F) : return "4.1"
	if(uni == 0x1310) : return "3.0"
	if(uni >= 0x1312 and uni <= 0x1315) : return "3.0"
	if(uni >= 0x1318 and uni <= 0x131E) : return "3.0"
	if(uni == 0x131F) : return "4.1"
	if(uni >= 0x1320 and uni <= 0x1346) : return "3.0"
	if(uni == 0x1347) : return "4.1"
	if(uni >= 0x1348 and uni <= 0x135A) : return "3.0"
	if(uni >= 0x135D and uni <= 0x135E) : return "6.0"
	if(uni >= 0x135F and uni <= 0x1360) : return "4.1"
	if(uni >= 0x1361 and uni <= 0x137C) : return "3.0"
	if(uni >= 0x1380 and uni <= 0x1399) : return "4.1"
	if(uni >= 0x13A0 and uni <= 0x13F4) : return "3.0"
	if(uni == 0x13F5) : return "8.0"
	if(uni >= 0x13F8 and uni <= 0x13FD) : return "8.0"
	if(uni == 0x1400) : return "5.2"
	if(uni >= 0x1401 and uni <= 0x1676) : return "3.0"
	if(uni >= 0x1677 and uni <= 0x167F) : return "5.2"
	if(uni >= 0x1680 and uni <= 0x169C) : return "3.0"
	if(uni >= 0x16A0 and uni <= 0x16F0) : return "3.0"
	if(uni >= 0x16F1 and uni <= 0x16F8) : return "7.0"
	if(uni >= 0x1700 and uni <= 0x170C) : return "3.2"
	if(uni >= 0x170E and uni <= 0x1714) : return "3.2"
	if(uni >= 0x1720 and uni <= 0x1736) : return "3.2"
	if(uni >= 0x1740 and uni <= 0x1753) : return "3.2"
	if(uni >= 0x1760 and uni <= 0x176C) : return "3.2"
	if(uni >= 0x176E and uni <= 0x1770) : return "3.2"
	if(uni >= 0x1772 and uni <= 0x1773) : return "3.2"
	if(uni >= 0x1780 and uni <= 0x17DC) : return "3.0"
	if(uni == 0x17DD) : return "4.0"
	if(uni >= 0x17E0 and uni <= 0x17E9) : return "3.0"
	if(uni >= 0x17F0 and uni <= 0x17F9) : return "4.0"
	if(uni >= 0x1800 and uni <= 0x180E) : return "3.0"
	if(uni >= 0x1810 and uni <= 0x1819) : return "3.0"
	if(uni >= 0x1820 and uni <= 0x1877) : return "3.0"
	if(uni == 0x1878) : return "11.0"
	if(uni >= 0x1880 and uni <= 0x18A9) : return "3.0"
	if(uni == 0x18AA) : return "5.1"
	if(uni >= 0x18B0 and uni <= 0x18F5) : return "5.2"
	if(uni >= 0x1900 and uni <= 0x191C) : return "4.0"
	if(uni >= 0x191D and uni <= 0x191E) : return "7.0"
	if(uni >= 0x1920 and uni <= 0x192B) : return "4.0"
	if(uni >= 0x1930 and uni <= 0x193B) : return "4.0"
	if(uni == 0x1940) : return "4.0"
	if(uni >= 0x1944 and uni <= 0x196D) : return "4.0"
	if(uni >= 0x1970 and uni <= 0x1974) : return "4.0"
	if(uni >= 0x1980 and uni <= 0x19A9) : return "4.1"
	if(uni >= 0x19AA and uni <= 0x19AB) : return "5.2"
	if(uni >= 0x19B0 and uni <= 0x19C9) : return "4.1"
	if(uni >= 0x19D0 and uni <= 0x19D9) : return "4.1"
	if(uni == 0x19DA) : return "5.2"
	if(uni >= 0x19DE and uni <= 0x19DF) : return "4.1"
	if(uni >= 0x19E0 and uni <= 0x19FF) : return "4.0"
	if(uni >= 0x1A00 and uni <= 0x1A1B) : return "4.1"
	if(uni >= 0x1A1E and uni <= 0x1A1F) : return "4.1"
	if(uni >= 0x1A20 and uni <= 0x1A5E) : return "5.2"
	if(uni >= 0x1A60 and uni <= 0x1A7C) : return "5.2"
	if(uni >= 0x1A7F and uni <= 0x1A89) : return "5.2"
	if(uni >= 0x1A90 and uni <= 0x1A99) : return "5.2"
	if(uni >= 0x1AA0 and uni <= 0x1AAD) : return "5.2"
	if(uni >= 0x1AB0 and uni <= 0x1ABE) : return "7.0"
	if(uni >= 0x1B00 and uni <= 0x1B4B) : return "5.0"
	if(uni >= 0x1B50 and uni <= 0x1B7C) : return "5.0"
	if(uni >= 0x1B80 and uni <= 0x1BAA) : return "5.1"
	if(uni >= 0x1BAB and uni <= 0x1BAD) : return "6.1"
	if(uni >= 0x1BAE and uni <= 0x1BB9) : return "5.1"
	if(uni >= 0x1BBA and uni <= 0x1BBF) : return "6.1"
	if(uni >= 0x1BC0 and uni <= 0x1BF3) : return "6.0"
	if(uni >= 0x1BFC and uni <= 0x1BFF) : return "6.0"
	if(uni >= 0x1C00 and uni <= 0x1C37) : return "5.1"
	if(uni >= 0x1C3B and uni <= 0x1C49) : return "5.1"
	if(uni >= 0x1C4D and uni <= 0x1C7F) : return "5.1"
	if(uni >= 0x1C80 and uni <= 0x1C88) : return "9.0"
	if(uni >= 0x1C90 and uni <= 0x1CBA) : return "11.0"
	if(uni >= 0x1CBD and uni <= 0x1CBF) : return "11.0"
	if(uni >= 0x1CC0 and uni <= 0x1CC7) : return "6.1"
	if(uni >= 0x1CD0 and uni <= 0x1CF2) : return "5.2"
	if(uni >= 0x1CF3 and uni <= 0x1CF6) : return "6.1"
	if(uni == 0x1CF7) : return "10.0"
	if(uni >= 0x1CF8 and uni <= 0x1CF9) : return "7.0"
	if(uni == 0x1CFA) : return "12.0"
	if(uni >= 0x1D00 and uni <= 0x1D6B) : return "4.0"
	if(uni >= 0x1D6C and uni <= 0x1DC3) : return "4.1"
	if(uni >= 0x1DC4 and uni <= 0x1DCA) : return "5.0"
	if(uni >= 0x1DCB and uni <= 0x1DE6) : return "5.1"
	if(uni >= 0x1DE7 and uni <= 0x1DF5) : return "7.0"
	if(uni >= 0x1DF6 and uni <= 0x1DF9) : return "10.0"
	if(uni == 0x1DFB) : return "9.0"
	if(uni == 0x1DFC) : return "6.0"
	if(uni == 0x1DFD) : return "5.2"
	if(uni >= 0x1DFE and uni <= 0x1DFF) : return "5.0"
	if(uni >= 0x1E00 and uni <= 0x1E9A) : return "1.1"
	if(uni == 0x1E9B) : return "2.0"
	if(uni >= 0x1E9C and uni <= 0x1E9F) : return "5.1"
	if(uni >= 0x1EA0 and uni <= 0x1EF9) : return "1.1"
	if(uni >= 0x1EFA and uni <= 0x1EFF) : return "5.1"
	if(uni >= 0x1F00 and uni <= 0x1F15) : return "1.1"
	if(uni >= 0x1F18 and uni <= 0x1F1D) : return "1.1"
	if(uni >= 0x1F20 and uni <= 0x1F45) : return "1.1"
	if(uni >= 0x1F48 and uni <= 0x1F4D) : return "1.1"
	if(uni >= 0x1F50 and uni <= 0x1F57) : return "1.1"
	if(uni == 0x1F59) : return "1.1"
	if(uni == 0x1F5B) : return "1.1"
	if(uni == 0x1F5D) : return "1.1"
	if(uni >= 0x1F5F and uni <= 0x1F7D) : return "1.1"
	if(uni >= 0x1F80 and uni <= 0x1FB4) : return "1.1"
	if(uni >= 0x1FB6 and uni <= 0x1FC4) : return "1.1"
	if(uni >= 0x1FC6 and uni <= 0x1FD3) : return "1.1"
	if(uni >= 0x1FD6 and uni <= 0x1FDB) : return "1.1"
	if(uni >= 0x1FDD and uni <= 0x1FEF) : return "1.1"
	if(uni >= 0x1FF2 and uni <= 0x1FF4) : return "1.1"
	if(uni >= 0x1FF6 and uni <= 0x1FFE) : return "1.1"
	if(uni >= 0x2000 and uni <= 0x202E) : return "1.1"
	if(uni == 0x202F) : return "3.0"
	if(uni >= 0x2030 and uni <= 0x2046) : return "1.1"
	if(uni == 0x2047) : return "3.2"
	if(uni >= 0x2048 and uni <= 0x204D) : return "3.0"
	if(uni >= 0x204E and uni <= 0x2052) : return "3.2"
	if(uni >= 0x2053 and uni <= 0x2054) : return "4.0"
	if(uni >= 0x2055 and uni <= 0x2056) : return "4.1"
	if(uni == 0x2057) : return "3.2"
	if(uni >= 0x2058 and uni <= 0x205E) : return "4.1"
	if(uni >= 0x205F and uni <= 0x2063) : return "3.2"
	if(uni == 0x2064) : return "5.1"
	if(uni >= 0x2066 and uni <= 0x2069) : return "6.3"
	if(uni >= 0x206A and uni <= 0x2070) : return "1.1"
	if(uni == 0x2071) : return "3.2"
	if(uni >= 0x2074 and uni <= 0x208E) : return "1.1"
	if(uni >= 0x2090 and uni <= 0x2094) : return "4.1"
	if(uni >= 0x2095 and uni <= 0x209C) : return "6.0"
	if(uni >= 0x20A0 and uni <= 0x20AA) : return "1.1"
	if(uni == 0x20AB) : return "2.0"
	if(uni == 0x20AC) : return "2.1"
	if(uni >= 0x20AD and uni <= 0x20AF) : return "3.0"
	if(uni >= 0x20B0 and uni <= 0x20B1) : return "3.2"
	if(uni >= 0x20B2 and uni <= 0x20B5) : return "4.1"
	if(uni >= 0x20B6 and uni <= 0x20B8) : return "5.2"
	if(uni == 0x20B9) : return "6.0"
	if(uni == 0x20BA) : return "6.2"
	if(uni >= 0x20BB and uni <= 0x20BD) : return "7.0"
	if(uni == 0x20BE) : return "8.0"
	if(uni == 0x20BF) : return "10.0"
	if(uni >= 0x20D0 and uni <= 0x20E1) : return "1.1"
	if(uni >= 0x20E2 and uni <= 0x20E3) : return "3.0"
	if(uni >= 0x20E4 and uni <= 0x20EA) : return "3.2"
	if(uni == 0x20EB) : return "4.1"
	if(uni >= 0x20EC and uni <= 0x20EF) : return "5.0"
	if(uni == 0x20F0) : return "5.1"
	if(uni >= 0x2100 and uni <= 0x2138) : return "1.1"
	if(uni >= 0x2139 and uni <= 0x213A) : return "3.0"
	if(uni == 0x213B) : return "4.0"
	if(uni == 0x213C) : return "4.1"
	if(uni >= 0x213D and uni <= 0x214B) : return "3.2"
	if(uni == 0x214C) : return "4.1"
	if(uni >= 0x214D and uni <= 0x214E) : return "5.0"
	if(uni == 0x214F) : return "5.1"
	if(uni >= 0x2150 and uni <= 0x2152) : return "5.2"
	if(uni >= 0x2153 and uni <= 0x2182) : return "1.1"
	if(uni == 0x2183) : return "3.0"
	if(uni == 0x2184) : return "5.0"
	if(uni >= 0x2185 and uni <= 0x2188) : return "5.1"
	if(uni == 0x2189) : return "5.2"
	if(uni >= 0x218A and uni <= 0x218B) : return "8.0"
	if(uni >= 0x2190 and uni <= 0x21EA) : return "1.1"
	if(uni >= 0x21EB and uni <= 0x21F3) : return "3.0"
	if(uni >= 0x21F4 and uni <= 0x21FF) : return "3.2"
	if(uni >= 0x2200 and uni <= 0x22F1) : return "1.1"
	if(uni >= 0x22F2 and uni <= 0x22FF) : return "3.2"
	if(uni == 0x2300) : return "1.1"
	if(uni == 0x2301) : return "3.0"
	if(uni >= 0x2302 and uni <= 0x237A) : return "1.1"
	if(uni == 0x237B) : return "3.0"
	if(uni == 0x237C) : return "3.2"
	if(uni >= 0x237D and uni <= 0x239A) : return "3.0"
	if(uni >= 0x239B and uni <= 0x23CE) : return "3.2"
	if(uni >= 0x23CF and uni <= 0x23D0) : return "4.0"
	if(uni >= 0x23D1 and uni <= 0x23DB) : return "4.1"
	if(uni >= 0x23DC and uni <= 0x23E7) : return "5.0"
	if(uni == 0x23E8) : return "5.2"
	if(uni >= 0x23E9 and uni <= 0x23F3) : return "6.0"
	if(uni >= 0x23F4 and uni <= 0x23FA) : return "7.0"
	if(uni >= 0x23FB and uni <= 0x23FE) : return "9.0"
	if(uni == 0x23FF) : return "10.0"
	if(uni >= 0x2400 and uni <= 0x2424) : return "1.1"
	if(uni >= 0x2425 and uni <= 0x2426) : return "3.0"
	if(uni >= 0x2440 and uni <= 0x244A) : return "1.1"
	if(uni >= 0x2460 and uni <= 0x24EA) : return "1.1"
	if(uni >= 0x24EB and uni <= 0x24FE) : return "3.2"
	if(uni == 0x24FF) : return "4.0"
	if(uni >= 0x2500 and uni <= 0x2595) : return "1.1"
	if(uni >= 0x2596 and uni <= 0x259F) : return "3.2"
	if(uni >= 0x25A0 and uni <= 0x25EF) : return "1.1"
	if(uni >= 0x25F0 and uni <= 0x25F7) : return "3.0"
	if(uni >= 0x25F8 and uni <= 0x25FF) : return "3.2"
	if(uni >= 0x2600 and uni <= 0x2613) : return "1.1"
	if(uni >= 0x2614 and uni <= 0x2615) : return "4.0"
	if(uni >= 0x2616 and uni <= 0x2617) : return "3.2"
	if(uni == 0x2618) : return "4.1"
	if(uni == 0x2619) : return "3.0"
	if(uni >= 0x261A and uni <= 0x266F) : return "1.1"
	if(uni >= 0x2670 and uni <= 0x2671) : return "3.0"
	if(uni >= 0x2672 and uni <= 0x267D) : return "3.2"
	if(uni >= 0x267E and uni <= 0x267F) : return "4.1"
	if(uni >= 0x2680 and uni <= 0x2689) : return "3.2"
	if(uni >= 0x268A and uni <= 0x2691) : return "4.0"
	if(uni >= 0x2692 and uni <= 0x269C) : return "4.1"
	if(uni == 0x269D) : return "5.1"
	if(uni >= 0x269E and uni <= 0x269F) : return "5.2"
	if(uni >= 0x26A0 and uni <= 0x26A1) : return "4.0"
	if(uni >= 0x26A2 and uni <= 0x26B1) : return "4.1"
	if(uni == 0x26B2) : return "5.0"
	if(uni >= 0x26B3 and uni <= 0x26BC) : return "5.1"
	if(uni >= 0x26BD and uni <= 0x26BF) : return "5.2"
	if(uni >= 0x26C0 and uni <= 0x26C3) : return "5.1"
	if(uni >= 0x26C4 and uni <= 0x26CD) : return "5.2"
	if(uni == 0x26CE) : return "6.0"
	if(uni >= 0x26CF and uni <= 0x26E1) : return "5.2"
	if(uni == 0x26E2) : return "6.0"
	if(uni == 0x26E3) : return "5.2"
	if(uni >= 0x26E4 and uni <= 0x26E7) : return "6.0"
	if(uni >= 0x26E8 and uni <= 0x26FF) : return "5.2"
	if(uni == 0x2700) : return "7.0"
	if(uni >= 0x2701 and uni <= 0x2704) : return "1.1"
	if(uni == 0x2705) : return "6.0"
	if(uni >= 0x2706 and uni <= 0x2709) : return "1.1"
	if(uni >= 0x270A and uni <= 0x270B) : return "6.0"
	if(uni >= 0x270C and uni <= 0x2727) : return "1.1"
	if(uni == 0x2728) : return "6.0"
	if(uni >= 0x2729 and uni <= 0x274B) : return "1.1"
	if(uni == 0x274C) : return "6.0"
	if(uni == 0x274D) : return "1.1"
	if(uni == 0x274E) : return "6.0"
	if(uni >= 0x274F and uni <= 0x2752) : return "1.1"
	if(uni >= 0x2753 and uni <= 0x2755) : return "6.0"
	if(uni == 0x2756) : return "1.1"
	if(uni == 0x2757) : return "5.2"
	if(uni >= 0x2758 and uni <= 0x275E) : return "1.1"
	if(uni >= 0x275F and uni <= 0x2760) : return "6.0"
	if(uni >= 0x2761 and uni <= 0x2767) : return "1.1"
	if(uni >= 0x2768 and uni <= 0x2775) : return "3.2"
	if(uni >= 0x2776 and uni <= 0x2794) : return "1.1"
	if(uni >= 0x2795 and uni <= 0x2797) : return "6.0"
	if(uni >= 0x2798 and uni <= 0x27AF) : return "1.1"
	if(uni == 0x27B0) : return "6.0"
	if(uni >= 0x27B1 and uni <= 0x27BE) : return "1.1"
	if(uni == 0x27BF) : return "6.0"
	if(uni >= 0x27C0 and uni <= 0x27C6) : return "4.1"
	if(uni >= 0x27C7 and uni <= 0x27CA) : return "5.0"
	if(uni == 0x27CB) : return "6.1"
	if(uni == 0x27CC) : return "5.1"
	if(uni == 0x27CD) : return "6.1"
	if(uni >= 0x27CE and uni <= 0x27CF) : return "6.0"
	if(uni >= 0x27D0 and uni <= 0x27EB) : return "3.2"
	if(uni >= 0x27EC and uni <= 0x27EF) : return "5.1"
	if(uni >= 0x27F0 and uni <= 0x27FF) : return "3.2"
	if(uni >= 0x2800 and uni <= 0x28FF) : return "3.0"
	if(uni >= 0x2900 and uni <= 0x2AFF) : return "3.2"
	if(uni >= 0x2B00 and uni <= 0x2B0D) : return "4.0"
	if(uni >= 0x2B0E and uni <= 0x2B13) : return "4.1"
	if(uni >= 0x2B14 and uni <= 0x2B1A) : return "5.0"
	if(uni >= 0x2B1B and uni <= 0x2B1F) : return "5.1"
	if(uni >= 0x2B20 and uni <= 0x2B23) : return "5.0"
	if(uni >= 0x2B24 and uni <= 0x2B4C) : return "5.1"
	if(uni >= 0x2B4D and uni <= 0x2B4F) : return "7.0"
	if(uni >= 0x2B50 and uni <= 0x2B54) : return "5.1"
	if(uni >= 0x2B55 and uni <= 0x2B59) : return "5.2"
	if(uni >= 0x2B5A and uni <= 0x2B73) : return "7.0"
	if(uni >= 0x2B76 and uni <= 0x2B95) : return "7.0"
	if(uni >= 0x2B98 and uni <= 0x2BB9) : return "7.0"
	if(uni >= 0x2BBA and uni <= 0x2BBC) : return "11.0"
	if(uni >= 0x2BBD and uni <= 0x2BC8) : return "7.0"
	if(uni == 0x2BC9) : return "12.0"
	if(uni >= 0x2BCA and uni <= 0x2BD1) : return "7.0"
	if(uni == 0x2BD2) : return "10.0"
	if(uni >= 0x2BD3 and uni <= 0x2BEB) : return "11.0"
	if(uni >= 0x2BEC and uni <= 0x2BEF) : return "8.0"
	if(uni >= 0x2BF0 and uni <= 0x2BFE) : return "11.0"
	if(uni == 0x2BFF) : return "12.0"
	if(uni >= 0x2C00 and uni <= 0x2C2E) : return "4.1"
	if(uni >= 0x2C30 and uni <= 0x2C5E) : return "4.1"
	if(uni >= 0x2C60 and uni <= 0x2C6C) : return "5.0"
	if(uni >= 0x2C6D and uni <= 0x2C6F) : return "5.1"
	if(uni == 0x2C70) : return "5.2"
	if(uni >= 0x2C71 and uni <= 0x2C73) : return "5.1"
	if(uni >= 0x2C74 and uni <= 0x2C77) : return "5.0"
	if(uni >= 0x2C78 and uni <= 0x2C7D) : return "5.1"
	if(uni >= 0x2C7E and uni <= 0x2C7F) : return "5.2"
	if(uni >= 0x2C80 and uni <= 0x2CEA) : return "4.1"
	if(uni >= 0x2CEB and uni <= 0x2CF1) : return "5.2"
	if(uni >= 0x2CF2 and uni <= 0x2CF3) : return "6.1"
	if(uni >= 0x2CF9 and uni <= 0x2D25) : return "4.1"
	if(uni == 0x2D27) : return "6.1"
	if(uni == 0x2D2D) : return "6.1"
	if(uni >= 0x2D30 and uni <= 0x2D65) : return "4.1"
	if(uni >= 0x2D66 and uni <= 0x2D67) : return "6.1"
	if(uni == 0x2D6F) : return "4.1"
	if(uni == 0x2D70) : return "6.0"
	if(uni == 0x2D7F) : return "6.0"
	if(uni >= 0x2D80 and uni <= 0x2D96) : return "4.1"
	if(uni >= 0x2DA0 and uni <= 0x2DA6) : return "4.1"
	if(uni >= 0x2DA8 and uni <= 0x2DAE) : return "4.1"
	if(uni >= 0x2DB0 and uni <= 0x2DB6) : return "4.1"
	if(uni >= 0x2DB8 and uni <= 0x2DBE) : return "4.1"
	if(uni >= 0x2DC0 and uni <= 0x2DC6) : return "4.1"
	if(uni >= 0x2DC8 and uni <= 0x2DCE) : return "4.1"
	if(uni >= 0x2DD0 and uni <= 0x2DD6) : return "4.1"
	if(uni >= 0x2DD8 and uni <= 0x2DDE) : return "4.1"
	if(uni >= 0x2DE0 and uni <= 0x2DFF) : return "5.1"
	if(uni >= 0x2E00 and uni <= 0x2E17) : return "4.1"
	if(uni >= 0x2E18 and uni <= 0x2E1B) : return "5.1"
	if(uni >= 0x2E1C and uni <= 0x2E1D) : return "4.1"
	if(uni >= 0x2E1E and uni <= 0x2E30) : return "5.1"
	if(uni == 0x2E31) : return "5.2"
	if(uni >= 0x2E32 and uni <= 0x2E3B) : return "6.1"
	if(uni >= 0x2E3C and uni <= 0x2E42) : return "7.0"
	if(uni >= 0x2E43 and uni <= 0x2E44) : return "9.0"
	if(uni >= 0x2E45 and uni <= 0x2E49) : return "10.0"
	if(uni >= 0x2E4A and uni <= 0x2E4E) : return "11.0"
	if(uni == 0x2E4F) : return "12.0"
	if(uni >= 0x2E80 and uni <= 0x2E99) : return "3.0"
	if(uni >= 0x2E9B and uni <= 0x2EF3) : return "3.0"
	if(uni >= 0x2F00 and uni <= 0x2FD5) : return "3.0"
	if(uni >= 0x2FF0 and uni <= 0x2FFB) : return "3.0"
	if(uni >= 0x3000 and uni <= 0x3037) : return "1.1"
	if(uni >= 0x3038 and uni <= 0x303A) : return "3.0"
	if(uni >= 0x303B and uni <= 0x303D) : return "3.2"
	if(uni == 0x303E) : return "3.0"
	if(uni == 0x303F) : return "1.1"
	if(uni >= 0x3041 and uni <= 0x3094) : return "1.1"
	if(uni >= 0x3095 and uni <= 0x3096) : return "3.2"
	if(uni >= 0x3099 and uni <= 0x309E) : return "1.1"
	if(uni >= 0x309F and uni <= 0x30A0) : return "3.2"
	if(uni >= 0x30A1 and uni <= 0x30FE) : return "1.1"
	if(uni == 0x30FF) : return "3.2"
	if(uni >= 0x3105 and uni <= 0x312C) : return "1.1"
	if(uni == 0x312D) : return "5.1"
	if(uni == 0x312E) : return "10.0"
	if(uni == 0x312F) : return "11.0"
	if(uni >= 0x3131 and uni <= 0x318E) : return "1.1"
	if(uni >= 0x3190 and uni <= 0x319F) : return "1.1"
	if(uni >= 0x31A0 and uni <= 0x31B7) : return "3.0"
	if(uni >= 0x31B8 and uni <= 0x31BA) : return "6.0"
	if(uni >= 0x31C0 and uni <= 0x31CF) : return "4.1"
	if(uni >= 0x31D0 and uni <= 0x31E3) : return "5.1"
	if(uni >= 0x31F0 and uni <= 0x31FF) : return "3.2"
	if(uni >= 0x3200 and uni <= 0x321C) : return "1.1"
	if(uni >= 0x321D and uni <= 0x321E) : return "4.0"
	if(uni >= 0x3220 and uni <= 0x3243) : return "1.1"
	if(uni >= 0x3244 and uni <= 0x324F) : return "5.2"
	if(uni == 0x3250) : return "4.0"
	if(uni >= 0x3251 and uni <= 0x325F) : return "3.2"
	if(uni >= 0x3260 and uni <= 0x327B) : return "1.1"
	if(uni >= 0x327C and uni <= 0x327D) : return "4.0"
	if(uni == 0x327E) : return "4.1"
	if(uni >= 0x327F and uni <= 0x32B0) : return "1.1"
	if(uni >= 0x32B1 and uni <= 0x32BF) : return "3.2"
	if(uni >= 0x32C0 and uni <= 0x32CB) : return "1.1"
	if(uni >= 0x32CC and uni <= 0x32CF) : return "4.0"
	if(uni >= 0x32D0 and uni <= 0x32FE) : return "1.1"
	if(uni == 0x32FF) : return "12.1"
	if(uni >= 0x3300 and uni <= 0x3376) : return "1.1"
	if(uni >= 0x3377 and uni <= 0x337A) : return "4.0"
	if(uni >= 0x337B and uni <= 0x33DD) : return "1.1"
	if(uni >= 0x33DE and uni <= 0x33DF) : return "4.0"
	if(uni >= 0x33E0 and uni <= 0x33FE) : return "1.1"
	if(uni == 0x33FF) : return "4.0"
	if(uni >= 0x3400 and uni <= 0x4DB5) : return "3.0"
	if(uni >= 0x4DC0 and uni <= 0x4DFF) : return "4.0"
	if(uni >= 0x4E00 and uni <= 0x9FA5) : return "1.1"
	if(uni >= 0x9FA6 and uni <= 0x9FBB) : return "4.1"
	if(uni >= 0x9FBC and uni <= 0x9FC3) : return "5.1"
	if(uni >= 0x9FC4 and uni <= 0x9FCB) : return "5.2"
	if(uni == 0x9FCC) : return "6.1"
	if(uni >= 0x9FCD and uni <= 0x9FD5) : return "8.0"
	if(uni >= 0x9FD6 and uni <= 0x9FEA) : return "10.0"
	if(uni >= 0x9FEB and uni <= 0x9FEF) : return "11.0"
	if(uni >= 0xA000 and uni <= 0xA48C) : return "3.0"
	if(uni >= 0xA490 and uni <= 0xA4A1) : return "3.0"
	if(uni >= 0xA4A2 and uni <= 0xA4A3) : return "3.2"
	if(uni >= 0xA4A4 and uni <= 0xA4B3) : return "3.0"
	if(uni == 0xA4B4) : return "3.2"
	if(uni >= 0xA4B5 and uni <= 0xA4C0) : return "3.0"
	if(uni == 0xA4C1) : return "3.2"
	if(uni >= 0xA4C2 and uni <= 0xA4C4) : return "3.0"
	if(uni == 0xA4C5) : return "3.2"
	if(uni == 0xA4C6) : return "3.0"
	if(uni >= 0xA4D0 and uni <= 0xA4FF) : return "5.2"
	if(uni >= 0xA500 and uni <= 0xA62B) : return "5.1"
	if(uni >= 0xA640 and uni <= 0xA65F) : return "5.1"
	if(uni >= 0xA660 and uni <= 0xA661) : return "6.0"
	if(uni >= 0xA662 and uni <= 0xA673) : return "5.1"
	if(uni >= 0xA674 and uni <= 0xA67B) : return "6.1"
	if(uni >= 0xA67C and uni <= 0xA697) : return "5.1"
	if(uni >= 0xA698 and uni <= 0xA69D) : return "7.0"
	if(uni == 0xA69E) : return "8.0"
	if(uni == 0xA69F) : return "6.1"
	if(uni >= 0xA6A0 and uni <= 0xA6F7) : return "5.2"
	if(uni >= 0xA700 and uni <= 0xA716) : return "4.1"
	if(uni >= 0xA717 and uni <= 0xA71A) : return "5.0"
	if(uni >= 0xA71B and uni <= 0xA71F) : return "5.1"
	if(uni >= 0xA720 and uni <= 0xA721) : return "5.0"
	if(uni >= 0xA722 and uni <= 0xA78C) : return "5.1"
	if(uni >= 0xA78D and uni <= 0xA78E) : return "6.0"
	if(uni == 0xA78F) : return "8.0"
	if(uni >= 0xA790 and uni <= 0xA791) : return "6.0"
	if(uni >= 0xA792 and uni <= 0xA793) : return "6.1"
	if(uni >= 0xA794 and uni <= 0xA79F) : return "7.0"
	if(uni >= 0xA7A0 and uni <= 0xA7A9) : return "6.0"
	if(uni == 0xA7AA) : return "6.1"
	if(uni >= 0xA7AB and uni <= 0xA7AD) : return "7.0"
	if(uni == 0xA7AE) : return "9.0"
	if(uni == 0xA7AF) : return "11.0"
	if(uni >= 0xA7B0 and uni <= 0xA7B1) : return "7.0"
	if(uni >= 0xA7B2 and uni <= 0xA7B7) : return "8.0"
	if(uni >= 0xA7B8 and uni <= 0xA7B9) : return "11.0"
	if(uni >= 0xA7BA and uni <= 0xA7BF) : return "12.0"
	if(uni >= 0xA7C2 and uni <= 0xA7C6) : return "12.0"
	if(uni == 0xA7F7) : return "7.0"
	if(uni >= 0xA7F8 and uni <= 0xA7F9) : return "6.1"
	if(uni == 0xA7FA) : return "6.0"
	if(uni >= 0xA7FB and uni <= 0xA7FF) : return "5.1"
	if(uni >= 0xA800 and uni <= 0xA82B) : return "4.1"
	if(uni >= 0xA830 and uni <= 0xA839) : return "5.2"
	if(uni >= 0xA840 and uni <= 0xA877) : return "5.0"
	if(uni >= 0xA880 and uni <= 0xA8C4) : return "5.1"
	if(uni == 0xA8C5) : return "9.0"
	if(uni >= 0xA8CE and uni <= 0xA8D9) : return "5.1"
	if(uni >= 0xA8E0 and uni <= 0xA8FB) : return "5.2"
	if(uni >= 0xA8FC and uni <= 0xA8FD) : return "8.0"
	if(uni >= 0xA8FE and uni <= 0xA8FF) : return "11.0"
	if(uni >= 0xA900 and uni <= 0xA953) : return "5.1"
	if(uni == 0xA95F) : return "5.1"
	if(uni >= 0xA960 and uni <= 0xA97C) : return "5.2"
	if(uni >= 0xA980 and uni <= 0xA9CD) : return "5.2"
	if(uni >= 0xA9CF and uni <= 0xA9D9) : return "5.2"
	if(uni >= 0xA9DE and uni <= 0xA9DF) : return "5.2"
	if(uni >= 0xA9E0 and uni <= 0xA9FE) : return "7.0"
	if(uni >= 0xAA00 and uni <= 0xAA36) : return "5.1"
	if(uni >= 0xAA40 and uni <= 0xAA4D) : return "5.1"
	if(uni >= 0xAA50 and uni <= 0xAA59) : return "5.1"
	if(uni >= 0xAA5C and uni <= 0xAA5F) : return "5.1"
	if(uni >= 0xAA60 and uni <= 0xAA7B) : return "5.2"
	if(uni >= 0xAA7C and uni <= 0xAA7F) : return "7.0"
	if(uni >= 0xAA80 and uni <= 0xAAC2) : return "5.2"
	if(uni >= 0xAADB and uni <= 0xAADF) : return "5.2"
	if(uni >= 0xAAE0 and uni <= 0xAAF6) : return "6.1"
	if(uni >= 0xAB01 and uni <= 0xAB06) : return "6.0"
	if(uni >= 0xAB09 and uni <= 0xAB0E) : return "6.0"
	if(uni >= 0xAB11 and uni <= 0xAB16) : return "6.0"
	if(uni >= 0xAB20 and uni <= 0xAB26) : return "6.0"
	if(uni >= 0xAB28 and uni <= 0xAB2E) : return "6.0"
	if(uni >= 0xAB30 and uni <= 0xAB5F) : return "7.0"
	if(uni >= 0xAB60 and uni <= 0xAB63) : return "8.0"
	if(uni >= 0xAB64 and uni <= 0xAB65) : return "7.0"
	if(uni >= 0xAB66 and uni <= 0xAB67) : return "12.0"
	if(uni >= 0xAB70 and uni <= 0xABBF) : return "8.0"
	if(uni >= 0xABC0 and uni <= 0xABED) : return "5.2"
	if(uni >= 0xABF0 and uni <= 0xABF9) : return "5.2"
	if(uni >= 0xAC00 and uni <= 0xD7A3) : return "2.0"
	if(uni >= 0xD7B0 and uni <= 0xD7C6) : return "5.2"
	if(uni >= 0xD7CB and uni <= 0xD7FB) : return "5.2"
	if(uni >= 0xD800 and uni <= 0xDFFF) : return "2.0"
	if(uni >= 0xE000 and uni <= 0xFA2D) : return "1.1"
	if(uni >= 0xFA2E and uni <= 0xFA2F) : return "6.1"
	if(uni >= 0xFA30 and uni <= 0xFA6A) : return "3.2"
	if(uni >= 0xFA6B and uni <= 0xFA6D) : return "5.2"
	if(uni >= 0xFA70 and uni <= 0xFAD9) : return "4.1"
	if(uni >= 0xFB00 and uni <= 0xFB06) : return "1.1"
	if(uni >= 0xFB13 and uni <= 0xFB17) : return "1.1"
	if(uni == 0xFB1D) : return "3.0"
	if(uni >= 0xFB1E and uni <= 0xFB36) : return "1.1"
	if(uni >= 0xFB38 and uni <= 0xFB3C) : return "1.1"
	if(uni == 0xFB3E) : return "1.1"
	if(uni >= 0xFB40 and uni <= 0xFB41) : return "1.1"
	if(uni >= 0xFB43 and uni <= 0xFB44) : return "1.1"
	if(uni >= 0xFB46 and uni <= 0xFBB1) : return "1.1"
	if(uni >= 0xFBB2 and uni <= 0xFBC1) : return "6.0"
	if(uni >= 0xFBD3 and uni <= 0xFD3F) : return "1.1"
	if(uni >= 0xFD50 and uni <= 0xFD8F) : return "1.1"
	if(uni >= 0xFD92 and uni <= 0xFDC7) : return "1.1"
	if(uni >= 0xFDD0 and uni <= 0xFDEF) : return "3.1"
	if(uni >= 0xFDF0 and uni <= 0xFDFB) : return "1.1"
	if(uni == 0xFDFC) : return "3.2"
	if(uni == 0xFDFD) : return "4.0"
	if(uni >= 0xFE00 and uni <= 0xFE0F) : return "3.2"
	if(uni >= 0xFE10 and uni <= 0xFE19) : return "4.1"
	if(uni >= 0xFE20 and uni <= 0xFE23) : return "1.1"
	if(uni >= 0xFE24 and uni <= 0xFE26) : return "5.1"
	if(uni >= 0xFE27 and uni <= 0xFE2D) : return "7.0"
	if(uni >= 0xFE2E and uni <= 0xFE2F) : return "8.0"
	if(uni >= 0xFE30 and uni <= 0xFE44) : return "1.1"
	if(uni >= 0xFE45 and uni <= 0xFE46) : return "3.2"
	if(uni >= 0xFE47 and uni <= 0xFE48) : return "4.0"
	if(uni >= 0xFE49 and uni <= 0xFE52) : return "1.1"
	if(uni >= 0xFE54 and uni <= 0xFE66) : return "1.1"
	if(uni >= 0xFE68 and uni <= 0xFE6B) : return "1.1"
	if(uni >= 0xFE70 and uni <= 0xFE72) : return "1.1"
	if(uni == 0xFE73) : return "3.2"
	if(uni == 0xFE74) : return "1.1"
	if(uni >= 0xFE76 and uni <= 0xFEFC) : return "1.1"
	if(uni == 0xFEFF) : return "1.1"
	if(uni >= 0xFF01 and uni <= 0xFF5E) : return "1.1"
	if(uni >= 0xFF5F and uni <= 0xFF60) : return "3.2"
	if(uni >= 0xFF61 and uni <= 0xFFBE) : return "1.1"
	if(uni >= 0xFFC2 and uni <= 0xFFC7) : return "1.1"
	if(uni >= 0xFFCA and uni <= 0xFFCF) : return "1.1"
	if(uni >= 0xFFD2 and uni <= 0xFFD7) : return "1.1"
	if(uni >= 0xFFDA and uni <= 0xFFDC) : return "1.1"
	if(uni >= 0xFFE0 and uni <= 0xFFE6) : return "1.1"
	if(uni >= 0xFFE8 and uni <= 0xFFEE) : return "1.1"
	if(uni >= 0xFFF9 and uni <= 0xFFFB) : return "3.0"
	if(uni == 0xFFFC) : return "2.1"
	if(uni == 0xFFFD) : return "1.1"
	if(uni >= 0xFFFE and uni <= 0xFFFF) : return "1.1"
	if(uni >= 0x10000 and uni <= 0x1000B) : return "4.0"
	if(uni >= 0x1000D and uni <= 0x10026) : return "4.0"
	if(uni >= 0x10028 and uni <= 0x1003A) : return "4.0"
	if(uni >= 0x1003C and uni <= 0x1003D) : return "4.0"
	if(uni >= 0x1003F and uni <= 0x1004D) : return "4.0"
	if(uni >= 0x10050 and uni <= 0x1005D) : return "4.0"
	if(uni >= 0x10080 and uni <= 0x100FA) : return "4.0"
	if(uni >= 0x10100 and uni <= 0x10102) : return "4.0"
	if(uni >= 0x10107 and uni <= 0x10133) : return "4.0"
	if(uni >= 0x10137 and uni <= 0x1013F) : return "4.0"
	if(uni >= 0x10140 and uni <= 0x1018A) : return "4.1"
	if(uni >= 0x1018B and uni <= 0x1018C) : return "7.0"
	if(uni >= 0x1018D and uni <= 0x1018E) : return "9.0"
	if(uni >= 0x10190 and uni <= 0x1019B) : return "5.1"
	if(uni == 0x101A0) : return "7.0"
	if(uni >= 0x101D0 and uni <= 0x101FD) : return "5.1"
	if(uni >= 0x10280 and uni <= 0x1029C) : return "5.1"
	if(uni >= 0x102A0 and uni <= 0x102D0) : return "5.1"
	if(uni >= 0x102E0 and uni <= 0x102FB) : return "7.0"
	if(uni >= 0x10300 and uni <= 0x1031E) : return "3.1"
	if(uni == 0x1031F) : return "7.0"
	if(uni >= 0x10320 and uni <= 0x10323) : return "3.1"
	if(uni >= 0x1032D and uni <= 0x1032F) : return "10.0"
	if(uni >= 0x10330 and uni <= 0x1034A) : return "3.1"
	if(uni >= 0x10350 and uni <= 0x1037A) : return "7.0"
	if(uni >= 0x10380 and uni <= 0x1039D) : return "4.0"
	if(uni == 0x1039F) : return "4.0"
	if(uni >= 0x103A0 and uni <= 0x103C3) : return "4.1"
	if(uni >= 0x103C8 and uni <= 0x103D5) : return "4.1"
	if(uni >= 0x10400 and uni <= 0x10425) : return "3.1"
	if(uni >= 0x10426 and uni <= 0x10427) : return "4.0"
	if(uni >= 0x10428 and uni <= 0x1044D) : return "3.1"
	if(uni >= 0x1044E and uni <= 0x1049D) : return "4.0"
	if(uni >= 0x104A0 and uni <= 0x104A9) : return "4.0"
	if(uni >= 0x104B0 and uni <= 0x104D3) : return "9.0"
	if(uni >= 0x104D8 and uni <= 0x104FB) : return "9.0"
	if(uni >= 0x10500 and uni <= 0x10527) : return "7.0"
	if(uni >= 0x10530 and uni <= 0x10563) : return "7.0"
	if(uni == 0x1056F) : return "7.0"
	if(uni >= 0x10600 and uni <= 0x10736) : return "7.0"
	if(uni >= 0x10740 and uni <= 0x10755) : return "7.0"
	if(uni >= 0x10760 and uni <= 0x10767) : return "7.0"
	if(uni >= 0x10800 and uni <= 0x10805) : return "4.0"
	if(uni == 0x10808) : return "4.0"
	if(uni >= 0x1080A and uni <= 0x10835) : return "4.0"
	if(uni >= 0x10837 and uni <= 0x10838) : return "4.0"
	if(uni == 0x1083C) : return "4.0"
	if(uni == 0x1083F) : return "4.0"
	if(uni >= 0x10840 and uni <= 0x10855) : return "5.2"
	if(uni >= 0x10857 and uni <= 0x1085F) : return "5.2"
	if(uni >= 0x10860 and uni <= 0x1089E) : return "7.0"
	if(uni >= 0x108A7 and uni <= 0x108AF) : return "7.0"
	if(uni >= 0x108E0 and uni <= 0x108F2) : return "8.0"
	if(uni >= 0x108F4 and uni <= 0x108F5) : return "8.0"
	if(uni >= 0x108FB and uni <= 0x108FF) : return "8.0"
	if(uni >= 0x10900 and uni <= 0x10919) : return "5.0"
	if(uni >= 0x1091A and uni <= 0x1091B) : return "5.2"
	if(uni == 0x1091F) : return "5.0"
	if(uni >= 0x10920 and uni <= 0x10939) : return "5.1"
	if(uni == 0x1093F) : return "5.1"
	if(uni >= 0x10980 and uni <= 0x109B7) : return "6.1"
	if(uni >= 0x109BC and uni <= 0x109BD) : return "8.0"
	if(uni >= 0x109BE and uni <= 0x109BF) : return "6.1"
	if(uni >= 0x109C0 and uni <= 0x109CF) : return "8.0"
	if(uni >= 0x109D2 and uni <= 0x109FF) : return "8.0"
	if(uni >= 0x10A00 and uni <= 0x10A03) : return "4.1"
	if(uni >= 0x10A05 and uni <= 0x10A06) : return "4.1"
	if(uni >= 0x10A0C and uni <= 0x10A13) : return "4.1"
	if(uni >= 0x10A15 and uni <= 0x10A17) : return "4.1"
	if(uni >= 0x10A19 and uni <= 0x10A33) : return "4.1"
	if(uni >= 0x10A34 and uni <= 0x10A35) : return "11.0"
	if(uni >= 0x10A38 and uni <= 0x10A3A) : return "4.1"
	if(uni >= 0x10A3F and uni <= 0x10A47) : return "4.1"
	if(uni == 0x10A48) : return "11.0"
	if(uni >= 0x10A50 and uni <= 0x10A58) : return "4.1"
	if(uni >= 0x10A60 and uni <= 0x10A7F) : return "5.2"
	if(uni >= 0x10A80 and uni <= 0x10A9F) : return "7.0"
	if(uni >= 0x10AC0 and uni <= 0x10AE6) : return "7.0"
	if(uni >= 0x10AEB and uni <= 0x10AF6) : return "7.0"
	if(uni >= 0x10B00 and uni <= 0x10B35) : return "5.2"
	if(uni >= 0x10B39 and uni <= 0x10B55) : return "5.2"
	if(uni >= 0x10B58 and uni <= 0x10B72) : return "5.2"
	if(uni >= 0x10B78 and uni <= 0x10B7F) : return "5.2"
	if(uni >= 0x10B80 and uni <= 0x10B91) : return "7.0"
	if(uni >= 0x10B99 and uni <= 0x10B9C) : return "7.0"
	if(uni >= 0x10BA9 and uni <= 0x10BAF) : return "7.0"
	if(uni >= 0x10C00 and uni <= 0x10C48) : return "5.2"
	if(uni >= 0x10C80 and uni <= 0x10CB2) : return "8.0"
	if(uni >= 0x10CC0 and uni <= 0x10CF2) : return "8.0"
	if(uni >= 0x10CFA and uni <= 0x10CFF) : return "8.0"
	if(uni >= 0x10D00 and uni <= 0x10D27) : return "11.0"
	if(uni >= 0x10D30 and uni <= 0x10D39) : return "11.0"
	if(uni >= 0x10E60 and uni <= 0x10E7E) : return "5.2"
	if(uni >= 0x10F00 and uni <= 0x10F27) : return "11.0"
	if(uni >= 0x10F30 and uni <= 0x10F59) : return "11.0"
	if(uni >= 0x10FE0 and uni <= 0x10FF6) : return "12.0"
	if(uni >= 0x11000 and uni <= 0x1104D) : return "6.0"
	if(uni >= 0x11052 and uni <= 0x1106F) : return "6.0"
	if(uni == 0x1107F) : return "7.0"
	if(uni >= 0x11080 and uni <= 0x110C1) : return "5.2"
	if(uni == 0x110CD) : return "11.0"
	if(uni >= 0x110D0 and uni <= 0x110E8) : return "6.1"
	if(uni >= 0x110F0 and uni <= 0x110F9) : return "6.1"
	if(uni >= 0x11100 and uni <= 0x11134) : return "6.1"
	if(uni >= 0x11136 and uni <= 0x11143) : return "6.1"
	if(uni >= 0x11144 and uni <= 0x11146) : return "11.0"
	if(uni >= 0x11150 and uni <= 0x11176) : return "7.0"
	if(uni >= 0x11180 and uni <= 0x111C8) : return "6.1"
	if(uni >= 0x111C9 and uni <= 0x111CC) : return "8.0"
	if(uni == 0x111CD) : return "7.0"
	if(uni >= 0x111D0 and uni <= 0x111D9) : return "6.1"
	if(uni == 0x111DA) : return "7.0"
	if(uni >= 0x111DB and uni <= 0x111DF) : return "8.0"
	if(uni >= 0x111E1 and uni <= 0x111F4) : return "7.0"
	if(uni >= 0x11200 and uni <= 0x11211) : return "7.0"
	if(uni >= 0x11213 and uni <= 0x1123D) : return "7.0"
	if(uni == 0x1123E) : return "9.0"
	if(uni >= 0x11280 and uni <= 0x11286) : return "8.0"
	if(uni == 0x11288) : return "8.0"
	if(uni >= 0x1128A and uni <= 0x1128D) : return "8.0"
	if(uni >= 0x1128F and uni <= 0x1129D) : return "8.0"
	if(uni >= 0x1129F and uni <= 0x112A9) : return "8.0"
	if(uni >= 0x112B0 and uni <= 0x112EA) : return "7.0"
	if(uni >= 0x112F0 and uni <= 0x112F9) : return "7.0"
	if(uni == 0x11300) : return "8.0"
	if(uni >= 0x11301 and uni <= 0x11303) : return "7.0"
	if(uni >= 0x11305 and uni <= 0x1130C) : return "7.0"
	if(uni >= 0x1130F and uni <= 0x11310) : return "7.0"
	if(uni >= 0x11313 and uni <= 0x11328) : return "7.0"
	if(uni >= 0x1132A and uni <= 0x11330) : return "7.0"
	if(uni >= 0x11332 and uni <= 0x11333) : return "7.0"
	if(uni >= 0x11335 and uni <= 0x11339) : return "7.0"
	if(uni == 0x1133B) : return "11.0"
	if(uni >= 0x1133C and uni <= 0x11344) : return "7.0"
	if(uni >= 0x11347 and uni <= 0x11348) : return "7.0"
	if(uni >= 0x1134B and uni <= 0x1134D) : return "7.0"
	if(uni == 0x11350) : return "8.0"
	if(uni == 0x11357) : return "7.0"
	if(uni >= 0x1135D and uni <= 0x11363) : return "7.0"
	if(uni >= 0x11366 and uni <= 0x1136C) : return "7.0"
	if(uni >= 0x11370 and uni <= 0x11374) : return "7.0"
	if(uni >= 0x11400 and uni <= 0x11459) : return "9.0"
	if(uni == 0x1145B) : return "9.0"
	if(uni == 0x1145D) : return "9.0"
	if(uni == 0x1145E) : return "11.0"
	if(uni == 0x1145F) : return "12.0"
	if(uni >= 0x11480 and uni <= 0x114C7) : return "7.0"
	if(uni >= 0x114D0 and uni <= 0x114D9) : return "7.0"
	if(uni >= 0x11580 and uni <= 0x115B5) : return "7.0"
	if(uni >= 0x115B8 and uni <= 0x115C9) : return "7.0"
	if(uni >= 0x115CA and uni <= 0x115DD) : return "8.0"
	if(uni >= 0x11600 and uni <= 0x11644) : return "7.0"
	if(uni >= 0x11650 and uni <= 0x11659) : return "7.0"
	if(uni >= 0x11660 and uni <= 0x1166C) : return "9.0"
	if(uni >= 0x11680 and uni <= 0x116B7) : return "6.1"
	if(uni == 0x116B8) : return "12.0"
	if(uni >= 0x116C0 and uni <= 0x116C9) : return "6.1"
	if(uni >= 0x11700 and uni <= 0x11719) : return "8.0"
	if(uni == 0x1171A) : return "11.0"
	if(uni >= 0x1171D and uni <= 0x1172B) : return "8.0"
	if(uni >= 0x11730 and uni <= 0x1173F) : return "8.0"
	if(uni >= 0x11800 and uni <= 0x1183B) : return "11.0"
	if(uni >= 0x118A0 and uni <= 0x118F2) : return "7.0"
	if(uni == 0x118FF) : return "7.0"
	if(uni >= 0x119A0 and uni <= 0x119A7) : return "12.0"
	if(uni >= 0x119AA and uni <= 0x119D7) : return "12.0"
	if(uni >= 0x119DA and uni <= 0x119E4) : return "12.0"
	if(uni >= 0x11A00 and uni <= 0x11A47) : return "10.0"
	if(uni >= 0x11A50 and uni <= 0x11A83) : return "10.0"
	if(uni >= 0x11A84 and uni <= 0x11A85) : return "12.0"
	if(uni >= 0x11A86 and uni <= 0x11A9C) : return "10.0"
	if(uni == 0x11A9D) : return "11.0"
	if(uni >= 0x11A9E and uni <= 0x11AA2) : return "10.0"
	if(uni >= 0x11AC0 and uni <= 0x11AF8) : return "7.0"
	if(uni >= 0x11C00 and uni <= 0x11C08) : return "9.0"
	if(uni >= 0x11C0A and uni <= 0x11C36) : return "9.0"
	if(uni >= 0x11C38 and uni <= 0x11C45) : return "9.0"
	if(uni >= 0x11C50 and uni <= 0x11C6C) : return "9.0"
	if(uni >= 0x11C70 and uni <= 0x11C8F) : return "9.0"
	if(uni >= 0x11C92 and uni <= 0x11CA7) : return "9.0"
	if(uni >= 0x11CA9 and uni <= 0x11CB6) : return "9.0"
	if(uni >= 0x11D00 and uni <= 0x11D06) : return "10.0"
	if(uni >= 0x11D08 and uni <= 0x11D09) : return "10.0"
	if(uni >= 0x11D0B and uni <= 0x11D36) : return "10.0"
	if(uni == 0x11D3A) : return "10.0"
	if(uni >= 0x11D3C and uni <= 0x11D3D) : return "10.0"
	if(uni >= 0x11D3F and uni <= 0x11D47) : return "10.0"
	if(uni >= 0x11D50 and uni <= 0x11D59) : return "10.0"
	if(uni >= 0x11D60 and uni <= 0x11D65) : return "11.0"
	if(uni >= 0x11D67 and uni <= 0x11D68) : return "11.0"
	if(uni >= 0x11D6A and uni <= 0x11D8E) : return "11.0"
	if(uni >= 0x11D90 and uni <= 0x11D91) : return "11.0"
	if(uni >= 0x11D93 and uni <= 0x11D98) : return "11.0"
	if(uni >= 0x11DA0 and uni <= 0x11DA9) : return "11.0"
	if(uni >= 0x11EE0 and uni <= 0x11EF8) : return "11.0"
	if(uni >= 0x11FC0 and uni <= 0x11FF1) : return "12.0"
	if(uni == 0x11FFF) : return "12.0"
	if(uni >= 0x12000 and uni <= 0x1236E) : return "5.0"
	if(uni >= 0x1236F and uni <= 0x12398) : return "7.0"
	if(uni == 0x12399) : return "8.0"
	if(uni >= 0x12400 and uni <= 0x12462) : return "5.0"
	if(uni >= 0x12463 and uni <= 0x1246E) : return "7.0"
	if(uni >= 0x12470 and uni <= 0x12473) : return "5.0"
	if(uni == 0x12474) : return "7.0"
	if(uni >= 0x12480 and uni <= 0x12543) : return "8.0"
	if(uni >= 0x13000 and uni <= 0x1342E) : return "5.2"
	if(uni >= 0x13430 and uni <= 0x13438) : return "12.0"
	if(uni >= 0x14400 and uni <= 0x14646) : return "8.0"
	if(uni >= 0x16800 and uni <= 0x16A38) : return "6.0"
	if(uni >= 0x16A40 and uni <= 0x16A5E) : return "7.0"
	if(uni >= 0x16A60 and uni <= 0x16A69) : return "7.0"
	if(uni >= 0x16A6E and uni <= 0x16A6F) : return "7.0"
	if(uni >= 0x16AD0 and uni <= 0x16AED) : return "7.0"
	if(uni >= 0x16AF0 and uni <= 0x16AF5) : return "7.0"
	if(uni >= 0x16B00 and uni <= 0x16B45) : return "7.0"
	if(uni >= 0x16B50 and uni <= 0x16B59) : return "7.0"
	if(uni >= 0x16B5B and uni <= 0x16B61) : return "7.0"
	if(uni >= 0x16B63 and uni <= 0x16B77) : return "7.0"
	if(uni >= 0x16B7D and uni <= 0x16B8F) : return "7.0"
	if(uni >= 0x16E40 and uni <= 0x16E9A) : return "11.0"
	if(uni >= 0x16F00 and uni <= 0x16F44) : return "6.1"
	if(uni >= 0x16F45 and uni <= 0x16F4A) : return "12.0"
	if(uni == 0x16F4F) : return "12.0"
	if(uni >= 0x16F50 and uni <= 0x16F7E) : return "6.1"
	if(uni >= 0x16F7F and uni <= 0x16F87) : return "12.0"
	if(uni >= 0x16F8F and uni <= 0x16F9F) : return "6.1"
	if(uni == 0x16FE0) : return "9.0"
	if(uni == 0x16FE1) : return "10.0"
	if(uni >= 0x16FE2 and uni <= 0x16FE3) : return "12.0"
	if(uni >= 0x17000 and uni <= 0x187EC) : return "9.0"
	if(uni >= 0x187ED and uni <= 0x187F1) : return "11.0"
	if(uni >= 0x187F2 and uni <= 0x187F7) : return "12.0"
	if(uni >= 0x18800 and uni <= 0x18AF2) : return "9.0"
	if(uni >= 0x1B000 and uni <= 0x1B001) : return "6.0"
	if(uni >= 0x1B002 and uni <= 0x1B11E) : return "10.0"
	if(uni >= 0x1B150 and uni <= 0x1B152) : return "12.0"
	if(uni >= 0x1B164 and uni <= 0x1B167) : return "12.0"
	if(uni >= 0x1B170 and uni <= 0x1B2FB) : return "10.0"
	if(uni >= 0x1BC00 and uni <= 0x1BC6A) : return "7.0"
	if(uni >= 0x1BC70 and uni <= 0x1BC7C) : return "7.0"
	if(uni >= 0x1BC80 and uni <= 0x1BC88) : return "7.0"
	if(uni >= 0x1BC90 and uni <= 0x1BC99) : return "7.0"
	if(uni >= 0x1BC9C and uni <= 0x1BCA3) : return "7.0"
	if(uni >= 0x1D000 and uni <= 0x1D0F5) : return "3.1"
	if(uni >= 0x1D100 and uni <= 0x1D126) : return "3.1"
	if(uni == 0x1D129) : return "5.1"
	if(uni >= 0x1D12A and uni <= 0x1D1DD) : return "3.1"
	if(uni >= 0x1D1DE and uni <= 0x1D1E8) : return "8.0"
	if(uni >= 0x1D200 and uni <= 0x1D245) : return "4.1"
	if(uni >= 0x1D2E0 and uni <= 0x1D2F3) : return "11.0"
	if(uni >= 0x1D300 and uni <= 0x1D356) : return "4.0"
	if(uni >= 0x1D360 and uni <= 0x1D371) : return "5.0"
	if(uni >= 0x1D372 and uni <= 0x1D378) : return "11.0"
	if(uni >= 0x1D400 and uni <= 0x1D454) : return "3.1"
	if(uni >= 0x1D456 and uni <= 0x1D49C) : return "3.1"
	if(uni >= 0x1D49E and uni <= 0x1D49F) : return "3.1"
	if(uni == 0x1D4A2) : return "3.1"
	if(uni >= 0x1D4A5 and uni <= 0x1D4A6) : return "3.1"
	if(uni >= 0x1D4A9 and uni <= 0x1D4AC) : return "3.1"
	if(uni >= 0x1D4AE and uni <= 0x1D4B9) : return "3.1"
	if(uni == 0x1D4BB) : return "3.1"
	if(uni >= 0x1D4BD and uni <= 0x1D4C0) : return "3.1"
	if(uni == 0x1D4C1) : return "4.0"
	if(uni >= 0x1D4C2 and uni <= 0x1D4C3) : return "3.1"
	if(uni >= 0x1D4C5 and uni <= 0x1D505) : return "3.1"
	if(uni >= 0x1D507 and uni <= 0x1D50A) : return "3.1"
	if(uni >= 0x1D50D and uni <= 0x1D514) : return "3.1"
	if(uni >= 0x1D516 and uni <= 0x1D51C) : return "3.1"
	if(uni >= 0x1D51E and uni <= 0x1D539) : return "3.1"
	if(uni >= 0x1D53B and uni <= 0x1D53E) : return "3.1"
	if(uni >= 0x1D540 and uni <= 0x1D544) : return "3.1"
	if(uni == 0x1D546) : return "3.1"
	if(uni >= 0x1D54A and uni <= 0x1D550) : return "3.1"
	if(uni >= 0x1D552 and uni <= 0x1D6A3) : return "3.1"
	if(uni >= 0x1D6A4 and uni <= 0x1D6A5) : return "4.1"
	if(uni >= 0x1D6A8 and uni <= 0x1D7C9) : return "3.1"
	if(uni >= 0x1D7CA and uni <= 0x1D7CB) : return "5.0"
	if(uni >= 0x1D7CE and uni <= 0x1D7FF) : return "3.1"
	if(uni >= 0x1D800 and uni <= 0x1DA8B) : return "8.0"
	if(uni >= 0x1DA9B and uni <= 0x1DA9F) : return "8.0"
	if(uni >= 0x1DAA1 and uni <= 0x1DAAF) : return "8.0"
	if(uni >= 0x1E000 and uni <= 0x1E006) : return "9.0"
	if(uni >= 0x1E008 and uni <= 0x1E018) : return "9.0"
	if(uni >= 0x1E01B and uni <= 0x1E021) : return "9.0"
	if(uni >= 0x1E023 and uni <= 0x1E024) : return "9.0"
	if(uni >= 0x1E026 and uni <= 0x1E02A) : return "9.0"
	if(uni >= 0x1E100 and uni <= 0x1E12C) : return "12.0"
	if(uni >= 0x1E130 and uni <= 0x1E13D) : return "12.0"
	if(uni >= 0x1E140 and uni <= 0x1E149) : return "12.0"
	if(uni >= 0x1E14E and uni <= 0x1E14F) : return "12.0"
	if(uni >= 0x1E2C0 and uni <= 0x1E2F9) : return "12.0"
	if(uni == 0x1E2FF) : return "12.0"
	if(uni >= 0x1E800 and uni <= 0x1E8C4) : return "7.0"
	if(uni >= 0x1E8C7 and uni <= 0x1E8D6) : return "7.0"
	if(uni >= 0x1E900 and uni <= 0x1E94A) : return "9.0"
	if(uni == 0x1E94B) : return "12.0"
	if(uni >= 0x1E950 and uni <= 0x1E959) : return "9.0"
	if(uni >= 0x1E95E and uni <= 0x1E95F) : return "9.0"
	if(uni >= 0x1EC71 and uni <= 0x1ECB4) : return "11.0"
	if(uni >= 0x1ED01 and uni <= 0x1ED3D) : return "12.0"
	if(uni >= 0x1EE00 and uni <= 0x1EE03) : return "6.1"
	if(uni >= 0x1EE05 and uni <= 0x1EE1F) : return "6.1"
	if(uni >= 0x1EE21 and uni <= 0x1EE22) : return "6.1"
	if(uni == 0x1EE24) : return "6.1"
	if(uni == 0x1EE27) : return "6.1"
	if(uni >= 0x1EE29 and uni <= 0x1EE32) : return "6.1"
	if(uni >= 0x1EE34 and uni <= 0x1EE37) : return "6.1"
	if(uni == 0x1EE39) : return "6.1"
	if(uni == 0x1EE3B) : return "6.1"
	if(uni == 0x1EE42) : return "6.1"
	if(uni == 0x1EE47) : return "6.1"
	if(uni == 0x1EE49) : return "6.1"
	if(uni == 0x1EE4B) : return "6.1"
	if(uni >= 0x1EE4D and uni <= 0x1EE4F) : return "6.1"
	if(uni >= 0x1EE51 and uni <= 0x1EE52) : return "6.1"
	if(uni == 0x1EE54) : return "6.1"
	if(uni == 0x1EE57) : return "6.1"
	if(uni == 0x1EE59) : return "6.1"
	if(uni == 0x1EE5B) : return "6.1"
	if(uni == 0x1EE5D) : return "6.1"
	if(uni == 0x1EE5F) : return "6.1"
	if(uni >= 0x1EE61 and uni <= 0x1EE62) : return "6.1"
	if(uni == 0x1EE64) : return "6.1"
	if(uni >= 0x1EE67 and uni <= 0x1EE6A) : return "6.1"
	if(uni >= 0x1EE6C and uni <= 0x1EE72) : return "6.1"
	if(uni >= 0x1EE74 and uni <= 0x1EE77) : return "6.1"
	if(uni >= 0x1EE79 and uni <= 0x1EE7C) : return "6.1"
	if(uni == 0x1EE7E) : return "6.1"
	if(uni >= 0x1EE80 and uni <= 0x1EE89) : return "6.1"
	if(uni >= 0x1EE8B and uni <= 0x1EE9B) : return "6.1"
	if(uni >= 0x1EEA1 and uni <= 0x1EEA3) : return "6.1"
	if(uni >= 0x1EEA5 and uni <= 0x1EEA9) : return "6.1"
	if(uni >= 0x1EEAB and uni <= 0x1EEBB) : return "6.1"
	if(uni >= 0x1EEF0 and uni <= 0x1EEF1) : return "6.1"
	if(uni >= 0x1F000 and uni <= 0x1F02B) : return "5.1"
	if(uni >= 0x1F030 and uni <= 0x1F093) : return "5.1"
	if(uni >= 0x1F0A0 and uni <= 0x1F0AE) : return "6.0"
	if(uni >= 0x1F0B1 and uni <= 0x1F0BE) : return "6.0"
	if(uni == 0x1F0BF) : return "7.0"
	if(uni >= 0x1F0C1 and uni <= 0x1F0CF) : return "6.0"
	if(uni >= 0x1F0D1 and uni <= 0x1F0DF) : return "6.0"
	if(uni >= 0x1F0E0 and uni <= 0x1F0F5) : return "7.0"
	if(uni >= 0x1F100 and uni <= 0x1F10A) : return "5.2"
	if(uni >= 0x1F10B and uni <= 0x1F10C) : return "7.0"
	if(uni >= 0x1F110 and uni <= 0x1F12E) : return "5.2"
	if(uni == 0x1F12F) : return "11.0"
	if(uni == 0x1F130) : return "6.0"
	if(uni == 0x1F131) : return "5.2"
	if(uni >= 0x1F132 and uni <= 0x1F13C) : return "6.0"
	if(uni == 0x1F13D) : return "5.2"
	if(uni == 0x1F13E) : return "6.0"
	if(uni == 0x1F13F) : return "5.2"
	if(uni >= 0x1F140 and uni <= 0x1F141) : return "6.0"
	if(uni == 0x1F142) : return "5.2"
	if(uni >= 0x1F143 and uni <= 0x1F145) : return "6.0"
	if(uni == 0x1F146) : return "5.2"
	if(uni >= 0x1F147 and uni <= 0x1F149) : return "6.0"
	if(uni >= 0x1F14A and uni <= 0x1F14E) : return "5.2"
	if(uni >= 0x1F14F and uni <= 0x1F156) : return "6.0"
	if(uni == 0x1F157) : return "5.2"
	if(uni >= 0x1F158 and uni <= 0x1F15E) : return "6.0"
	if(uni == 0x1F15F) : return "5.2"
	if(uni >= 0x1F160 and uni <= 0x1F169) : return "6.0"
	if(uni >= 0x1F16A and uni <= 0x1F16B) : return "6.1"
	if(uni == 0x1F16C) : return "12.0"
	if(uni >= 0x1F170 and uni <= 0x1F178) : return "6.0"
	if(uni == 0x1F179) : return "5.2"
	if(uni == 0x1F17A) : return "6.0"
	if(uni >= 0x1F17B and uni <= 0x1F17C) : return "5.2"
	if(uni >= 0x1F17D and uni <= 0x1F17E) : return "6.0"
	if(uni == 0x1F17F) : return "5.2"
	if(uni >= 0x1F180 and uni <= 0x1F189) : return "6.0"
	if(uni >= 0x1F18A and uni <= 0x1F18D) : return "5.2"
	if(uni >= 0x1F18E and uni <= 0x1F18F) : return "6.0"
	if(uni == 0x1F190) : return "5.2"
	if(uni >= 0x1F191 and uni <= 0x1F19A) : return "6.0"
	if(uni >= 0x1F19B and uni <= 0x1F1AC) : return "9.0"
	if(uni >= 0x1F1E6 and uni <= 0x1F1FF) : return "6.0"
	if(uni == 0x1F200) : return "5.2"
	if(uni >= 0x1F201 and uni <= 0x1F202) : return "6.0"
	if(uni >= 0x1F210 and uni <= 0x1F231) : return "5.2"
	if(uni >= 0x1F232 and uni <= 0x1F23A) : return "6.0"
	if(uni == 0x1F23B) : return "9.0"
	if(uni >= 0x1F240 and uni <= 0x1F248) : return "5.2"
	if(uni >= 0x1F250 and uni <= 0x1F251) : return "6.0"
	if(uni >= 0x1F260 and uni <= 0x1F265) : return "10.0"
	if(uni >= 0x1F300 and uni <= 0x1F320) : return "6.0"
	if(uni >= 0x1F321 and uni <= 0x1F32C) : return "7.0"
	if(uni >= 0x1F32D and uni <= 0x1F32F) : return "8.0"
	if(uni >= 0x1F330 and uni <= 0x1F335) : return "6.0"
	if(uni == 0x1F336) : return "7.0"
	if(uni >= 0x1F337 and uni <= 0x1F37C) : return "6.0"
	if(uni == 0x1F37D) : return "7.0"
	if(uni >= 0x1F37E and uni <= 0x1F37F) : return "8.0"
	if(uni >= 0x1F380 and uni <= 0x1F393) : return "6.0"
	if(uni >= 0x1F394 and uni <= 0x1F39F) : return "7.0"
	if(uni >= 0x1F3A0 and uni <= 0x1F3C4) : return "6.0"
	if(uni == 0x1F3C5) : return "7.0"
	if(uni >= 0x1F3C6 and uni <= 0x1F3CA) : return "6.0"
	if(uni >= 0x1F3CB and uni <= 0x1F3CE) : return "7.0"
	if(uni >= 0x1F3CF and uni <= 0x1F3D3) : return "8.0"
	if(uni >= 0x1F3D4 and uni <= 0x1F3DF) : return "7.0"
	if(uni >= 0x1F3E0 and uni <= 0x1F3F0) : return "6.0"
	if(uni >= 0x1F3F1 and uni <= 0x1F3F7) : return "7.0"
	if(uni >= 0x1F3F8 and uni <= 0x1F3FF) : return "8.0"
	if(uni >= 0x1F400 and uni <= 0x1F43E) : return "6.0"
	if(uni == 0x1F43F) : return "7.0"
	if(uni == 0x1F440) : return "6.0"
	if(uni == 0x1F441) : return "7.0"
	if(uni >= 0x1F442 and uni <= 0x1F4F7) : return "6.0"
	if(uni == 0x1F4F8) : return "7.0"
	if(uni >= 0x1F4F9 and uni <= 0x1F4FC) : return "6.0"
	if(uni >= 0x1F4FD and uni <= 0x1F4FE) : return "7.0"
	if(uni == 0x1F4FF) : return "8.0"
	if(uni >= 0x1F500 and uni <= 0x1F53D) : return "6.0"
	if(uni >= 0x1F53E and uni <= 0x1F53F) : return "7.0"
	if(uni >= 0x1F540 and uni <= 0x1F543) : return "6.1"
	if(uni >= 0x1F544 and uni <= 0x1F54A) : return "7.0"
	if(uni >= 0x1F54B and uni <= 0x1F54F) : return "8.0"
	if(uni >= 0x1F550 and uni <= 0x1F567) : return "6.0"
	if(uni >= 0x1F568 and uni <= 0x1F579) : return "7.0"
	if(uni == 0x1F57A) : return "9.0"
	if(uni >= 0x1F57B and uni <= 0x1F5A3) : return "7.0"
	if(uni == 0x1F5A4) : return "9.0"
	if(uni >= 0x1F5A5 and uni <= 0x1F5FA) : return "7.0"
	if(uni >= 0x1F5FB and uni <= 0x1F5FF) : return "6.0"
	if(uni == 0x1F600) : return "6.1"
	if(uni >= 0x1F601 and uni <= 0x1F610) : return "6.0"
	if(uni == 0x1F611) : return "6.1"
	if(uni >= 0x1F612 and uni <= 0x1F614) : return "6.0"
	if(uni == 0x1F615) : return "6.1"
	if(uni == 0x1F616) : return "6.0"
	if(uni == 0x1F617) : return "6.1"
	if(uni == 0x1F618) : return "6.0"
	if(uni == 0x1F619) : return "6.1"
	if(uni == 0x1F61A) : return "6.0"
	if(uni == 0x1F61B) : return "6.1"
	if(uni >= 0x1F61C and uni <= 0x1F61E) : return "6.0"
	if(uni == 0x1F61F) : return "6.1"
	if(uni >= 0x1F620 and uni <= 0x1F625) : return "6.0"
	if(uni >= 0x1F626 and uni <= 0x1F627) : return "6.1"
	if(uni >= 0x1F628 and uni <= 0x1F62B) : return "6.0"
	if(uni == 0x1F62C) : return "6.1"
	if(uni == 0x1F62D) : return "6.0"
	if(uni >= 0x1F62E and uni <= 0x1F62F) : return "6.1"
	if(uni >= 0x1F630 and uni <= 0x1F633) : return "6.0"
	if(uni == 0x1F634) : return "6.1"
	if(uni >= 0x1F635 and uni <= 0x1F640) : return "6.0"
	if(uni >= 0x1F641 and uni <= 0x1F642) : return "7.0"
	if(uni >= 0x1F643 and uni <= 0x1F644) : return "8.0"
	if(uni >= 0x1F645 and uni <= 0x1F64F) : return "6.0"
	if(uni >= 0x1F650 and uni <= 0x1F67F) : return "7.0"
	if(uni >= 0x1F680 and uni <= 0x1F6C5) : return "6.0"
	if(uni >= 0x1F6C6 and uni <= 0x1F6CF) : return "7.0"
	if(uni == 0x1F6D0) : return "8.0"
	if(uni >= 0x1F6D1 and uni <= 0x1F6D2) : return "9.0"
	if(uni >= 0x1F6D3 and uni <= 0x1F6D4) : return "10.0"
	if(uni == 0x1F6D5) : return "12.0"
	if(uni >= 0x1F6E0 and uni <= 0x1F6EC) : return "7.0"
	if(uni >= 0x1F6F0 and uni <= 0x1F6F3) : return "7.0"
	if(uni >= 0x1F6F4 and uni <= 0x1F6F6) : return "9.0"
	if(uni >= 0x1F6F7 and uni <= 0x1F6F8) : return "10.0"
	if(uni == 0x1F6F9) : return "11.0"
	if(uni == 0x1F6FA) : return "12.0"
	if(uni >= 0x1F700 and uni <= 0x1F773) : return "6.0"
	if(uni >= 0x1F780 and uni <= 0x1F7D4) : return "7.0"
	if(uni >= 0x1F7D5 and uni <= 0x1F7D8) : return "11.0"
	if(uni >= 0x1F7E0 and uni <= 0x1F7EB) : return "12.0"
	if(uni >= 0x1F800 and uni <= 0x1F80B) : return "7.0"
	if(uni >= 0x1F810 and uni <= 0x1F847) : return "7.0"
	if(uni >= 0x1F850 and uni <= 0x1F859) : return "7.0"
	if(uni >= 0x1F860 and uni <= 0x1F887) : return "7.0"
	if(uni >= 0x1F890 and uni <= 0x1F8AD) : return "7.0"
	if(uni >= 0x1F900 and uni <= 0x1F90B) : return "10.0"
	if(uni >= 0x1F90D and uni <= 0x1F90F) : return "12.0"
	if(uni >= 0x1F910 and uni <= 0x1F918) : return "8.0"
	if(uni >= 0x1F919 and uni <= 0x1F91E) : return "9.0"
	if(uni == 0x1F91F) : return "10.0"
	if(uni >= 0x1F920 and uni <= 0x1F927) : return "9.0"
	if(uni >= 0x1F928 and uni <= 0x1F92F) : return "10.0"
	if(uni == 0x1F930) : return "9.0"
	if(uni >= 0x1F931 and uni <= 0x1F932) : return "10.0"
	if(uni >= 0x1F933 and uni <= 0x1F93E) : return "9.0"
	if(uni == 0x1F93F) : return "12.0"
	if(uni >= 0x1F940 and uni <= 0x1F94B) : return "9.0"
	if(uni == 0x1F94C) : return "10.0"
	if(uni >= 0x1F94D and uni <= 0x1F94F) : return "11.0"
	if(uni >= 0x1F950 and uni <= 0x1F95E) : return "9.0"
	if(uni >= 0x1F95F and uni <= 0x1F96B) : return "10.0"
	if(uni >= 0x1F96C and uni <= 0x1F970) : return "11.0"
	if(uni == 0x1F971) : return "12.0"
	if(uni >= 0x1F973 and uni <= 0x1F976) : return "11.0"
	if(uni == 0x1F97A) : return "11.0"
	if(uni == 0x1F97B) : return "12.0"
	if(uni >= 0x1F97C and uni <= 0x1F97F) : return "11.0"
	if(uni >= 0x1F980 and uni <= 0x1F984) : return "8.0"
	if(uni >= 0x1F985 and uni <= 0x1F991) : return "9.0"
	if(uni >= 0x1F992 and uni <= 0x1F997) : return "10.0"
	if(uni >= 0x1F998 and uni <= 0x1F9A2) : return "11.0"
	if(uni >= 0x1F9A5 and uni <= 0x1F9AA) : return "12.0"
	if(uni >= 0x1F9AE and uni <= 0x1F9AF) : return "12.0"
	if(uni >= 0x1F9B0 and uni <= 0x1F9B9) : return "11.0"
	if(uni >= 0x1F9BA and uni <= 0x1F9BF) : return "12.0"
	if(uni == 0x1F9C0) : return "8.0"
	if(uni >= 0x1F9C1 and uni <= 0x1F9C2) : return "11.0"
	if(uni >= 0x1F9C3 and uni <= 0x1F9CA) : return "12.0"
	if(uni >= 0x1F9CD and uni <= 0x1F9CF) : return "12.0"
	if(uni >= 0x1F9D0 and uni <= 0x1F9E6) : return "10.0"
	if(uni >= 0x1F9E7 and uni <= 0x1F9FF) : return "11.0"
	if(uni >= 0x1FA00 and uni <= 0x1FA53) : return "12.0"
	if(uni >= 0x1FA60 and uni <= 0x1FA6D) : return "11.0"
	if(uni >= 0x1FA70 and uni <= 0x1FA73) : return "12.0"
	if(uni >= 0x1FA78 and uni <= 0x1FA7A) : return "12.0"
	if(uni >= 0x1FA80 and uni <= 0x1FA82) : return "12.0"
	if(uni >= 0x1FA90 and uni <= 0x1FA95) : return "12.0"
	if(uni >= 0x1FFFE and uni <= 0x1FFFF) : return "2.0"
	if(uni >= 0x20000 and uni <= 0x2A6D6) : return "3.1"
	if(uni >= 0x2A700 and uni <= 0x2B734) : return "5.2"
	if(uni >= 0x2B740 and uni <= 0x2B81D) : return "6.0"
	if(uni >= 0x2B820 and uni <= 0x2CEA1) : return "8.0"
	if(uni >= 0x2CEB0 and uni <= 0x2EBE0) : return "10.0"
	if(uni >= 0x2F800 and uni <= 0x2FA1D) : return "3.1"
	if(uni >= 0x2FFFE and uni <= 0x2FFFF) : return "2.0"
	if(uni >= 0x3FFFE and uni <= 0x3FFFF) : return "2.0"
	if(uni >= 0x4FFFE and uni <= 0x4FFFF) : return "2.0"
	if(uni >= 0x5FFFE and uni <= 0x5FFFF) : return "2.0"
	if(uni >= 0x6FFFE and uni <= 0x6FFFF) : return "2.0"
	if(uni >= 0x7FFFE and uni <= 0x7FFFF) : return "2.0"
	if(uni >= 0x8FFFE and uni <= 0x8FFFF) : return "2.0"
	if(uni >= 0x9FFFE and uni <= 0x9FFFF) : return "2.0"
	if(uni >= 0xAFFFE and uni <= 0xAFFFF) : return "2.0"
	if(uni >= 0xBFFFE and uni <= 0xBFFFF) : return "2.0"
	if(uni >= 0xCFFFE and uni <= 0xCFFFF) : return "2.0"
	if(uni >= 0xDFFFE and uni <= 0xDFFFF) : return "2.0"
	if(uni == 0xE0001) : return "3.1"
	if(uni >= 0xE0020 and uni <= 0xE007F) : return "3.1"
	if(uni >= 0xE0100 and uni <= 0xE01EF) : return "4.0"
	if(uni >= 0xEFFFE and uni <= 0xEFFFF) : return "2.0"
	if(uni >= 0xF0000 and uni <= 0xFFFFD) : return "2.0"
	if(uni >= 0xFFFFE and uni <= 0xFFFFF) : return "2.0"
	if(uni >= 0x100000 and uni <= 0x10FFFD) : return "2.0"
	if(uni >= 0x10FFFE and uni <= 0x10FFFF) : return "2.0"
	return "999"
	
##########################################
# 處理缺字資料
##########################################

def get_gaiji_info(cb):
	if cb.startswith('SD-'):
		r = {}
		sd = cb[3:]
		if sd in siddam.sd2b5:
			r['big5'] = siddam.sd2b5[sd]
		if sd in siddam.sd2dia:
			dia = siddam.sd2dia[sd]
			r['udia'] = dia2uni(dia)
			r['cbdia'] = cbdia2smdia(dia)
		r['sdchar'] = big5_uni(sd)
		return r
	elif cb.startswith('RJ-'):
		r = {}
		code = cb[3:]
		if code in ranjana.rj2b5:
			r['big5'] = ranjana.rj2b5[code]
		if code in ranjana.rj2dia:
			dia = ranjana.rj2dia[code]
			r['udia'] = dia2uni(dia)
			r['cbdia'] = cbdia2smdia(dia)
		r['rjchar'] = big5_uni(code)
		return r
	else:
		return all_gaijis[cb]
	
def resp2wit(resp):
	if '【' in resp:
		return resp
	if resp in RESP2WIT:
		return RESP2WIT[resp]
	else:
		sys.exit('error 73: ' + resp)
		
####################################
# 讀取所有的 resp 屬性
####################################

def read_all_resp(root):
	global resp_id
	resp_id={}			# 先清掉舊的記錄, 免得愈累積愈多	--2013/08/13
	for e in root.iter(tag=etree.Element):
		resp=e.get('resp', '')
		# 將 resp="【甲】【乙】" 這一類的格式插入空格, 【甲】與【乙】才能分離出來 --2013/07/29
		resp = resp.replace(u'】【','】 【')
		resps = resp.split()
		for r in resps:
			if r not in resp_id:
					resp_id[r]='resp{}'.format(len(resp_id)+1)
					
def handle_resp(resp):
	# 將 resp="【甲】【乙】" 這一類的格式插入空格, 【甲】與【乙】才能分離出來 --2013/07/29
	resp = resp.replace(u'】【','】 【')
    # P5b 不用轉成 #resp 代碼, 直接傳回
	if options.P5b_Format == True:
		return resp
	resps = resp.split()
	result = []
	for r in resps:
		result.append(resp_id[r])
	return '#' + ' '.join(result)

####################################
# 讀取所有的 wit 屬性
####################################

def read_all_wit(root):
	global wit_id
	global globals
	wit_id={}			# 先清掉舊的記錄, 免得愈累積愈多	--2013/08/13
	# 找尋原書的 wit 和 CBETA 的 wit, 先加到 wit_id 記錄中
	# <witness xml:id="wit.orig">【龍】</witness>
	# <witness xml:id="wit.cbeta">【CB】</witness>
	all_witness = root.findall("./teiHeader/encodingDesc//witness")
	for e in all_witness:
		wit_id[e.text] = e.attrib['id']

	# 判斷預設的版本和 p5a 記錄的版本是否相同
	if wit_id[globals['collection-wit']] != "wit.orig":
		sys.exit("error 392, default WITS[ed] is not wit.orig:" + globals['collection-wit'])

	witcount = 1
	for e in root.iter(tag=etree.Element):
		wit=e.get('wit', '')
		wits = re.findall('【.*?】', wit)
		for w in wits:
			if w not in wit_id:
				wit_id[w]='wit{}'.format(witcount)
				witcount = witcount + 1

def handle_wit(wit):
	global wit_id
	# P5b 不用轉成 #wit 代碼, 直接傳回
	if options.P5b_Format == True:
		wit = wit.replace(u'】【','】 【')
		return wit
	wits = re.findall('【.*?】', wit)
	if len(wits)==0:
		sys.exit('error 91: ' + wit)
	r=[]
	for w in wits:
		if w not in wit_id:
			#不應該發生
			#wit_id[w] = 'wit{}'.format(len(wit_id)+1)
			print("error 412, wit no id.")
			sys.exit()
		r.append('#' + wit_id[w])
	return ' '.join(r)

def cb2pua(cb):
	if cb.startswith('CB'):
		pua=int(cb[2:])+0xF0000
	elif cb.startswith('SD'):
		pua=int(cb[3:],16)+0xFA000
	elif cb.startswith('RJ'):
		pua=int(cb[3:],16)+0x100000
	return pua

def change_mode(mode, old, new):
	new_mode = mode.copy()
	if old in new_mode:
		new_mode.remove(old)
	new_mode.add(new)
	return new_mode

############################
# MyTransformer 物件
############################

class MyTransformer():
	def __init__(self, xml_file):
		self.xml_file = xml_file
		tree = etree.parse(xml_file)
		tree = zbxxml.stripNamespaces(tree)
		
		self.root=tree.getroot()
		self.back_notes={'rest' : ''}
		self.back={'app':'', 'tt':'', 'equivalent':''}
		self.anchors=[]
		self.counter=collections.Counter()
		#self.apps={}
		self.gaijis=set()
		# 大部份經文的星號都在 app 標記處理, 南傳 note 有星號沒 app , 這是用來記錄哪些 note 有哪些 star
		# note_star['#nkr_note_orig_0228007'] = ' #note_star_1 #note_star_5 #note_star_12'
		self.note_star={}

	def handle_text(self, s, mode):
		if s is None: return ''
		text = s
		if 'back' in mode:
			text = text.replace('\n', '')
		text = text.replace('&', '&amp;')
		text = text.replace('<', '&lt;')
		r = ''
		# unicode 1.0 以外的字就使用 <g> 標記
		for c in text:
			code = ord(c)
			if float(get_unicode_ver(code)) > 2.0 :
				if(code == 0x227):	# 特例 ȧ
					r += c
				else:
					hex = '{:X}'.format(code)
					cb = unicode2cb[hex]
					if options.P5b_Format == True:
						# P5b 版不可以有 unicode 太高的字, 以免 Mac 版 CBR 無法處理
						r += '<g ref="#{}"/>'.format(cb)
					else:
						r += '<g ref="#{}">{}</g>'.format(cb, c)
					self.gaijis.add(cb)
			else:
				r += c
		return r
		
	def traverse(self, e, mode):
		self.counter['traverse']+=1
		if e is None: 
			self.counter['traverse'] -= 1
			return ''
		r=''
		tag=e.tag
		r += self.handle_text(e.text, mode)
		for n in e.iterchildren(): 
			r += self.handle_node(n, mode)
			r += self.handle_text(n.tail, mode)
		self.counter['traverse'] -= 1
		return r
		
	def write_log(self, msg):
		print('\t'*(self.counter['traverse']+1)+msg, file=log)

	def handle_head(self, e, mode):
		type=e.get('type', '')
		node=MyNode(e)
		parent = e.getparent()
		if parent.tag=='juan':
			node.tag = 'cb:jhead'
		'''
		# old
		if 'body' in mode:
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			r = self.traverse(e, mode)
		'''
		# new
		r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		
		
		return r
		
	def prepare_charDecl(self):
		r = ''
		for cb in sorted(self.gaijis):
			r += '\t\t\t<char xml:id="{}">\n'.format(cb)
			r += '\t\t\t\t<charName>CBETA CHARACTER {}</charName>\n'.format(cb)
			attrib = get_gaiji_info(cb)
			for k, v in sorted(attrib.items()):
				if k != 'unicode' and  k != 'nor_unicode':
					r += '\t\t\t\t<charProp>\n'
					r += '\t\t\t\t\t<localName>'
					if k == 'des':
						r += 'composition'
					elif k in ('big5', 'uniflag', 'rjchar'):
						r += k
					elif k=='cb':
						r += 'entity'
					elif k=='nor':
						r += 'normalized form'
					elif k=='mojikyo':
						r += 'Mojikyo number'
					elif k=='mofont':
						r += 'Mojikyo font name'
					elif k=='mochar':
						r += 'Mojikyo character value'
					elif k=='cbdia':
						r += 'Romanized form in CBETA transcription'
					elif k=='udia':
						r += 'Romanized form in Unicode transcription'
					elif k=='sdchar':
						r += 'Character in the Siddham font'
					elif k=='unicode':
						pass
					else:
						print('error 130', k)
						sys.exit()
					r += '</localName>\n'
					r += '\t\t\t\t\t<value>{}</value>\n'.format(v)
					r += '\t\t\t\t</charProp>\n'
			if 'unicode' in attrib:
				r += '\t\t\t\t<mapping type="unicode">U+{}</mapping>\n'.format(attrib['unicode'])
			if 'nor_unicode' in attrib:
				r += '\t\t\t\t<mapping type="normal_unicode">U+{}</mapping>\n'.format(attrib['nor_unicode'])
			r += '\t\t\t\t<mapping cb:dec="{0}" type="PUA">U+{0:X}</mapping>\n'.format(cb2pua(cb))
			r += '\t\t\t</char>\n'
		if r != '':
			r = '\t<charDecl>\n' + r + '\t\t</charDecl>\n'
		return r

	def handle_note_back(self, e, type, target, mode):
		if type not in self.back_notes:
			self.back_notes[type]=''
		node=MyNode(e)
		node.attrib['target'] = '#' + target
		
		# type="orig jie" 轉為 type="orig_jie"
		if 'type' in node.attrib:
			t = e.get('type')
			node.attrib['type'] = t.replace(' ', '_')
			
		new_mode = change_mode(mode, 'body', 'back')	# mode 換成 back , 表示接下來的資料都是在 back 區的, 不是在 body 區的
		new_mode.add('note')		# 加入 note 判斷, 如 p 在 back 中, 且在 note 中, 就可以呈現, 但若只在 back 中就不可呈現 (例如在 app 中)  -- 2013/09/29
		back = node.open_tag() + self.traverse(e, new_mode) + node.end_tag() + '\n'
		self.write_log('247 back: ' + back)
		self.back_notes[type] += back
		
	def handle_note(self, e, mode):
		r=''

		# P5b 不把 note 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r
		
		type = e.get('type', '')
		n=e.get('n')
		resp=e.get('resp', '')
		if 'body' in mode:
			if type in ('cf1', 'cf2', 'cf3', 'cf4', 'cf5', 'cf6', 'cf7', 'cf8', 'cf9'):
				pass
			elif (n is not None) and (n != ''):
				# <note> 的 n 屬性相同, 但位置可能不同.
				# T02, n0125
				# <note n="0613019" resp="Taisho" place="foot text" type="orig">木蜜＝木櫁【元】【明】＊</note>「木<note n="0613019" resp="CBETA" type="mod">蜜＝櫁【元】【明】＊</note>
				#target = 'beg' + n
				target = 'nkr_note_{}_{}'.format(type, n)
				if target not in self.anchors:
					self.anchors.append(target)
					r='<anchor xml:id="{}" n="{}"/>'.format(target, n)
				if type=='equivalent':
					self.handle_note_back(e, type, target, mode)
				elif type in ('rest', 'cf.'):
					self.handle_note_back(e, 'rest', target, mode)
				elif type=='add':
					self.handle_note_back(e, type, target, mode)
				elif resp!='':
					self.handle_note_back(e, resp, target, mode)
				else:
					print('error 236')
			elif resp!='':
				if resp.startswith('CBETA'):
					id = self.new_anchor_id()
					target = 'nkr_{}'.format(id)
					r='<anchor xml:id="{}"/>'.format(target)
					self.handle_note_back(e, 'CBETA', target, mode)
				else:
					print('error 242')
					sys.exit()
			elif type=='star':
				# P5a <note type="star" corresp="#0228007"/> 南傳特有的, 有星號的校勘, 但沒有 app 
				# p5 要做成 <anchor xml:id="note_star_1" type="star"/>
				# 並在 back 區做成 <note n="0228007" resp="#respx" type="orig" place="foot text" target="#nkr_note_orig_0228007 #note_star_1">....</note>
				corresp=e.get('corresp', '')
				new_n = corresp[1:]
				corresp = '#nkr_note_orig_' + new_n
				id = self.new_anchor_id()
				target = 'note_star_{}'.format(id)
				r='<anchor xml:id="{}" n="{}" type="star"/>'.format(target, new_n)		# 此時已做出經文區的 <anchor xml:id="note_star_1" n="0228007" type="star"/>
				if corresp in self.note_star:
					self.note_star[corresp] += ' #' + target	# 此時要在 note_star[#nkr_note_orig_0228007] 加上 "#note_star_1"
				else:
					self.note_star[corresp] = ' #' + target
			else:
				node=MyNode(e)
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			'''
			# old
			if (e.get('place') in ('inline', 'interlinear')) or type in ('cf1', 'cf2', 'cf3'):
				node=MyNode(e)
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			'''
			# new
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			
		return r
	
	# 取得一個新的 id , 主要是在星號校勘要提供不重複的代號
	def new_anchor_id(self):
		self.counter['anchor']+=1
		return '{:x}'.format(self.counter['anchor'])
		
	def handle_app_star(self, e, mode):
		r = ''
		if 'body' in mode:
			id = self.new_anchor_id()
			r = '<anchor xml:id="beg_{}" type="star"/>'.format(id)
			r += self.traverse(e, mode)
			r += '<anchor xml:id="end_{}"/>'.format(id)
			node = MyNode(e)
			node.attrib['from'] = '#beg_{}'.format(id)
			node.attrib['to'] = '#end_{}'.format(id)
			del node.attrib['corresp']
			node.attrib['corresp'] = e.get('corresp')
			del node.attrib['type']
			new_mode = change_mode(mode, 'body', 'back')
			self.back['app'] += node.open_tag()
			self.back['app'] += self.traverse(e, new_mode)
			self.back['app'] +=  node.end_tag() + '\n'
		else:
			node = MyNode(e)
			node.attrib['type'] = 'star'
			r += node.open_tag()
			r += self.traverse(e, mode)
			r += node.end_tag()
		return r
		
	def handle_app_nor(self, e,  mode):
		self.write_log('handle_app_nor')
		n = e.get('n')
		if n is None:
			node=MyNode(e)
			print(node.open_tag())
			sys.exit()
		target='beg' + n
		r = ''
		'''
		# 舊的
		if target not in self.anchors:
			self.anchors.append(target)
			r+='<anchor xml:id="{}" n="{}"/>'.format(target, n)
		r += self.traverse(e, mode)
		id = 'end' + n
		if id not in self.anchors:
			self.anchors.append(id)
			r+='<anchor xml:id="{}"/>'.format(id)
		'''
		# 新的 2014/03/20
		end_str = ''
		if target not in self.anchors:
			self.anchors.append(target)
			r += '<anchor xml:id="{}" n="{}"/>'.format(target, n)
			id = 'end' + n
			self.anchors.append(id)
			end_str = '<anchor xml:id="{}"/>'.format(id)
		r += self.traverse(e, mode)
		r += end_str
		
		node=MyNode(e)
		node.attrib['from']='#beg{}'.format(n)
		node.attrib['to']='#end{}'.format(n)
		del node.attrib['n']
		
		new_mode = change_mode(mode, 'body', 'back')
		self.back['app'] += node.open_tag()
		self.back['app'] += self.traverse(e, new_mode)
		self.back['app'] += node.end_tag() + '\n'
		return r
		
	def handle_app_cb(self, e, mode):
		new_type = app_new_type(e)
		id = self.new_anchor_id()
		r = '<anchor xml:id="beg_{}" type="cb-app"/>'.format(id)
		lem=e.find('lem')
		r += self.traverse(lem, mode)
		r += '<anchor xml:id="end_{}"/>'.format(id)
		if new_type=='choice':
			node = MyNode()
			node.tag = 'choice'
			node.attrib['cb:from'] = '#beg_{}'.format(id)
			node.attrib['cb:to'] = '#end_{}'.format(id)
			lem = e.find('lem')
			resp = lem.get('resp')
			if resp is not None:
				node.attrib['resp'] = resp
			type = e.get('cb:type')
			if type is not None:
				node.attrib['cb:type'] = type
			self.back['app'] += node.open_tag()
			new_mode = change_mode(mode, 'body', 'back')
			new_mode.add('choice')
			self.back['app'] += self.traverse(e, new_mode)
			self.back['app'] += node.end_tag() + '\n'
		else:
			node = MyNode(e)
			node.attrib['from'] = '#beg_{}'.format(id)
			node.attrib['to'] = '#end_{}'.format(id)
			new_mode = change_mode(mode, 'body', 'back')
			self.back['app'] += node.open_tag()
			self.back['app'] += self.traverse(e, new_mode)
			self.back['app'] += node.end_tag() + '\n'
		return r
		
	def handle_app(self, e, mode):
		self.write_log('handle_app mode:' + str(mode) + ', n:' + e.get('n', ''))
		r=''
		
		# P5b 不把 app 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r

		type=e.get('type')
		if 'body' in mode:
			n=e.get('n')
			if type=='star':
				r += self.handle_app_star(e, mode)
			elif type=='◎':
				node=MyNode(e)
				print(node.open_tag())
				sys.exit()
			elif n is not None:
				r = self. handle_app_nor(e, mode)
			else:
				r = self.handle_app_cb(e, mode)
		elif 'back' in mode:
			if type == '＊':
				return self.handle_app_star(e, mode)
			new_type = app_new_type(e)
			if new_type == 'choice':
				node = MyNode(e)
				node.tag = 'choice'
				r += node.open_tag()
				new_mode = mode.copy()
				new_mode.add('choice')
				r += self.traverse(e, new_mode)
				r += node.end_tag()
			else:
				node=MyNode(e)
				r += node.open_tag()
				r += self.traverse(e, mode)
				r += node.end_tag()
		return r
		
	def handle_choice(self, e, mode):
    	# P5b 不把 choice 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r
		
		if 'body' in mode:
			id = self.new_anchor_id()
			r = '<anchor xml:id="beg_{}" type="cb-app"/>'.format(id)
			corr = e.find('corr')
			if corr is None:
				reg = e.find('reg')
				r += self.traverse(reg, mode)
			else:
				r += self.traverse(corr, mode)
			r += '<anchor xml:id="end_{}"/>'.format(id)
			
			node = MyNode(e)
			node.attrib['cb:from'] = '#beg_{}'.format(id)
			node.attrib['cb:to'] = '#end_{}'.format(id)
			corr = e.find('corr')
			if corr is not None:
				resp = corr.get('resp')
				if resp is not None:
					node.attrib['resp'] = resp
			type = e.get('type')
			if type is not None:
				node.attrib['cb:type'] = type
				del node.attrib['type']
			self.back['app'] += node.open_tag()
			new_mode = change_mode(mode, 'body', 'back')
			new_mode.add('choice')
			self.back['app'] += self.traverse(e, new_mode)
			self.back['app'] += node.end_tag() + '\n'
		else:
			node = MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
		
	def handle_lem(self, e, mode):
		self.write_log('handle_lem mode:' + str(mode))
		r = ''
		# P5b 不把 lem 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r
		if 'choice' in mode:
			node = MyNode()
			node.tag = 'corr'
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif 'body' in mode:
			r = self.traverse(e, mode)
		elif 'back' in mode:
			node=MyNode(e)
			r += node.open_tag()
			r += self.traverse(e, mode)
			r += node.end_tag()
		return r
	
	def handle_listwit(self, e, mode):
		node=MyNode(e)
		r = node.open_tag() + '\n'
		if len(wit_id) > 0:
			for k, v in sorted(wit_id.items(), key=lambda a: a[1]):
				r += '\t\t\t\t\t\t<witness xml:id="{}">{}</witness>\n'.format(v, k)
		r += '\t\t\t\t\t'
		r += node.end_tag()
		return r

	def handle_rdg(self, e, mode):
		self.write_log('handle_rdg mode:' + str(mode) + ', wit:' + e.get('wit', ''))
		r = ''
		# P5b 不把 rdg 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r
		if 'choice' in mode:
			if 'back' in mode:
				node = MyNode()
				node.tag = 'sic'
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif 'back' in mode:
			node=MyNode(e)
			wit = e.get('wit')
			#if wit=='【？】':
			#	node.attrib['resp'] = globals['collection-resp']
			#	node.attrib['wit'] = resp2wit(e.get('resp'))
			#	node.attrib['type'] = 'variantRemark'
			if 'cf1' in node.attrib: 
				del node.attrib['cf1']
			if 'cf2' in node.attrib: 
				del node.attrib['cf2']
			if 'cf3' in node.attrib: 
				del node.attrib['cf3']
			if 'cf4' in node.attrib: 
				del node.attrib['cf4']
			if 'cf5' in node.attrib: 
				del node.attrib['cf5']
			if 'cf6' in node.attrib: 
				del node.attrib['cf6']
			if 'cf7' in node.attrib: 
				del node.attrib['cf7']
			if 'cf8' in node.attrib: 
				del node.attrib['cf8']
			if 'cf9' in node.attrib: 
				del node.attrib['cf9']
			r = node.open_tag() + self.traverse(e, mode)
			if 'cf1' in e.attrib: 
				cf1 = e.get('cf1')
				r += '<note type="cf1">' + cf1 + '</note>'
			if 'cf2' in e.attrib: 
				cf2 = e.get('cf2')
				r += '<note type="cf2">' + cf2 + '</note>'
			if 'cf3' in e.attrib: 
				cf3 = e.get('cf3')
				r += '<note type="cf3">' + cf3 + '</note>'
			if 'cf4' in e.attrib: 
				cf4 = e.get('cf4')
				r += '<note type="cf4">' + cf4 + '</note>'
			if 'cf5' in e.attrib: 
				cf5 = e.get('cf5')
				r += '<note type="cf5">' + cf5 + '</note>'
			if 'cf6' in e.attrib: 
				cf6 = e.get('cf6')
				r += '<note type="cf6">' + cf6 + '</note>'
			if 'cf7' in e.attrib: 
				cf7 = e.get('cf7')
				r += '<note type="cf7">' + cf7 + '</note>'
			if 'cf8' in e.attrib: 
				cf8 = e.get('cf8')
				r += '<note type="cf8">' + cf8 + '</note>'
			if 'cf9' in e.attrib: 
				cf9 = e.get('cf9')
				r += '<note type="cf9">' + cf9 + '</note>'
			r += node.end_tag()
		return r
		
	def handle_tt(self, e, mode):
		r = ''
		# P5b 不把 tt 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r
		if 'body' in mode:
			type=e.get('type', '')
			if type=='app':
				''' 舊的
				n = e.get('n')
				id = 'beg' + n
				if id not in self.anchors:
					self.anchors.append(id)
					r='<anchor xml:id="{}" n="{}"/>'.format(id, n)
				r += self.traverse(e, mode)
				id = 'end' + n
				if id not in self.anchors:
					self.anchors.append(id)
					r += '<anchor xml:id="{}"/>'.format(id)
				'''
				# 新的 2014/03/20
				end_str = ''
				n = e.get('n')
				id = 'beg' + n
				if id not in self.anchors:
					self.anchors.append(id)
					r='<anchor xml:id="{}" n="{}"/>'.format(id, n)
					id = 'end' + n
					self.anchors.append(id)
					end_str = '<anchor xml:id="{}"/>'.format(id)	
				r += self.traverse(e, mode)
				r += end_str
				
				node = MyNode(e)
				node.attrib['from'] = '#beg{}'.format(n)
				node.attrib['to'] = '#end{}'.format(n)
				del node.attrib['n']
				new_mode = change_mode(mode, 'body', 'back')
				back = node.open_tag() + '\n' + self.traverse(e, new_mode) + node.end_tag()
				self.back['tt'] += back + '\n'
			else:
				node = MyNode(e)
				'''
				2018/08/17 inline 改放在 place , 所以不用移到 rend 了
				if e.get('place')=='inline':
					if e.get('rend') is None:
						node.attrib['rend'] = 'inline'
						del node.attrib['place']
					else:
						sys.exit('error 441')
				'''
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			node = MyNode(e)
			if 'n' in node.attrib:
				del node.attrib['n']
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
	
	def handle_p(self, e, mode):
		parent = e.getparent()
		if 'event' in mode:
			if parent.tag == 'date':
				return self.traverse(e, mode)
			else:
				node=MyNode(e)
				return node.open_tag() + self.traverse(e, mode) + '</p>'
		place = e.get('place', '')
		node=MyNode(e)
		if 'id' in node.attrib:
			node.attrib['xml:id'] = node.attrib['id']
			del node.attrib['id']
		if 'rend' in node.attrib: # 為了讓 rend 屬性出現在 xml:id 之後
			del node.attrib['rend']
			node.attrib['rend'] = e.get('rend')
		if 'style' in node.attrib:
			del node.attrib['style']
			node.attrib['style'] = e.get('style')
		if 'place' in node.attrib:
			# old , place 不用移到 rend 了 - 2018/08/17
			'''
			if place=='inline':
				if 'rend' in node.attrib:
					node.attrib['rend'] += ';' + node.attrib['place']
				else:
					node.attrib['rend'] = node.attrib['place']
				del node.attrib['place']
			else:
				node.attrib['cb:type'] = place
				del node.attrib['place']
			'''
			# new
			node.attrib['cb:place'] = place
			del node.attrib['place']
		if 'body' in mode:
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			'''
		# old
		elif ('back' in mode) and ('note' in mode):
			# 校勘 note 中的 <p> 也要處理, 這是因為遇到了 N27 p217 的 0217001 校勘有 <p> 標記  -- 2013/09/23
			# 加入 note 判斷, 如 p 在 back 中, 且在 note 中, 就可以呈現, 但若只在 back 中就不可呈現 (例如在 app 中)	-- 2013/09/29
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			r = self.traverse(e, mode)
			'''
		# new
		else:
			if 'id' in node.attrib:
				del node.attrib['id']
			if 'xml:id' in node.attrib:
				del node.attrib['xml:id']
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			
		return r
		
	def handle_publicationstmt(self, e, mode):
		global p5a_filename, globals, cbwork_dir
		r =''
		node=MyNode(e)
		r += node.open_tag()
		r += self.traverse(e, mode)
		# 加上日期 <data>....</date>, 此日期由 git 取出 p5a 最後提交的日期
		# git log -1 --pretty=format:"%ai" file.xml

		# 西蓮的 git 目錄不同, 所以要另外處理
		if globals['coll'] == 'DA' or globals['coll'] == 'HM' or globals['coll'] == 'ZY':
			IN_Seeland = cbwork_dir + '/cbeta_project/' + globals['coll']
			# c:/cbwork/xml-p5a/HM/HM01\HM01n0001.xml
			# c:/cbwork/cbeta_project/HM/xml-p5a/HM01\HM01n0001.xml
			see_filename = p5a_filename
			see_filename = see_filename.replace('xml-p5a/HM','cbeta_project/HM/xml-p5a')
			see_filename = see_filename.replace('xml-p5a/DA','cbeta_project/DA/xml-p5a')
			see_filename = see_filename.replace('xml-p5a/ZY','cbeta_project/ZY/xml-p5a')
			
			git_date = subprocess.check_output('git log -1 --pretty=format:"%ai" ' + see_filename, cwd=IN_Seeland)
		else:
			git_date = subprocess.check_output('git log -1 --pretty=format:"%ai" ' + p5a_filename, cwd=IN_P5a)

		r += '\t<date>' + git_date.decode() + '</date>\n'
		r += '\t\t' + node.end_tag()
		return r
	
	def handle_foreign(self, e, mode):
		r =''
		place = e.get('place', '')
		n = e.get('n')
		node=MyNode(e)
		resp = e.get('resp')
		if place=='foot':
			target = 'nkr_note_foreign_' + n	# 原本為 'beg' , 改成 'nkr_note_foreign_' 2014/03/20
			if target not in self.anchors:
				self.anchors.append(target)
				r += '<anchor xml:id="{}" n="{}"/>'.format(target, n)
			back = '<note target="#{}">'.format(target)
			new_mode = change_mode(mode, 'body', 'back')
			back += node.open_tag() + self.traverse(e, new_mode) + node.end_tag()
			back += '</note>\n'
			self.back_notes['rest'] += back
		else:
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
		
	def handle_sic(self, e, mode):
    	# P5b 不把 choice 放在 back 區了
		if options.P5b_Format == True:
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			return r
		if not 'back' in mode:
			return ''
		node = MyNode(e)
		return node.open_tag() + self.traverse(e, mode) + node.end_tag()
			
	def handle_node(self, e, mode):
		tag=e.tag
		parent = e.getparent()
		if tag==etree.Comment: return str(e)
		r=''
		if tag=='anchor':
			node = MyNode(e)
			type = e.get('type')
			if type=='◎':
				node.attrib['type'] = 'circle'
			'''
			# old
			if 'body' in mode:
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			'''
			# new
			if 'body' in mode:
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			elif 'back' in mode:
				if 'id' in node.attrib:
					node.attrib['id'] = node.attrib['id'] + '_back'		# xml:id 的尾部加上 '_back' , 以資區別
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
			
		elif tag=='annals':
			r = '<cb:event>'
			d = e.find('date')
			if d is None:
				r += '<date/>'
			new_mode = mode.copy()
			new_mode.add('event')
			r += self.traverse(e, new_mode)
			r += '</cb:event>'
		elif tag=='app':
			r=self.handle_app(e, mode)
		elif tag=='byline':
			node=MyNode(e)
			# T19n0945: type="Oral translator" => type="Oral_translator"
			if 'type' in node.attrib:
				t = e.get('type')
				node.attrib['type'] = t.replace(' ', '_')
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='change':
			node = MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='choice':
			r = self.handle_choice(e, mode)
		elif tag=='date':
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='div':
			if 'body' in mode:
				node=MyNode(e)
				node.tag='cb:div'
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				'''
				# old
				r += self.traverse(e, mode)
				'''
				# new , T12n0377.xml , T14n0434.xml 遇到
				node=MyNode(e)
				node.tag='cb:div'
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
				
		elif tag=='docNumber':
			node=MyNode(e)
			node.tag = 'cb:docNumber'
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='edition':
			node=MyNode(e)
			r += node.open_tag()
			# 把 XML TEI P5a 換成 XML TEI P5
			edition_txt = self.traverse(e, mode)
			if options.P5b_Format == True:
				r += edition_txt.replace("XML TEI P5a", "XML TEI P5b")
			else:
				r += edition_txt.replace("XML TEI P5a", "XML TEI P5")
			r += node.end_tag()
			for k, v in sorted(resp_id.items(), key=lambda a: a[1]):
				r += '\n\t\t\t<respStmt xml:id="{}"><resp>corrections</resp><name>{}</name></respStmt>'.format(v, k)
		elif tag=='encodingDesc':
			node = MyNode(e)
			r = node.open_tag() + self.traverse(e, mode)
			r += '<charDecl></charDecl>'
			r += '\t' + node.end_tag()
		elif tag=='entry':
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='event':
			if 'event' in mode:
				r = self.traverse(e, mode)
			else:
				node=MyNode(e)
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='figure':
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='foreign':
			r = self.handle_foreign(e, mode)
		elif tag=='g':
			cb = e.get('ref')[1:]
			
			# 要判斷是不是有 unicode 1.0 的缺字
			if cb.startswith('CB'):
				if('unicode' in all_gaijis[cb]):
					this_uni = '0x' + all_gaijis[cb]['unicode']
					this_code = int(this_uni, 16)
					# Ext-A: U+3400~U+4DFF, Ext-B: U+FFFF 之上, 而 U+2E80 ~ U+2EF3 屬於 Unicode 3.0
					# if this_code>0xffff or (this_code>=0x3400 and this_code<=0x4DFF) or (this_code>=0x2E80 and this_code<=0x2EF3):
					# if get_unicode_ver(this_code) == "1.0" or get_unicode_ver(this_code) == "1.1"  or get_unicode_ver(this_code) == "" :
					if float(get_unicode_ver(this_code)) <= 2.0 :
						r = chr(this_code)
					else:
						self.gaijis.add(cb)
						node = MyNode(e)
						if options.P5b_Format == True:
							r = node.open_tag()
						else:
							r = node.open_tag() + chr(this_code) + node.end_tag()
					return r
			self.gaijis.add(cb)
			node = MyNode(e)
			if options.P5b_Format == True:
				r = node.open_tag()
			else:
				r = node.open_tag() + chr(cb2pua(cb)) + node.end_tag()
		elif tag=='graphic':
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='head':
			r += self.handle_head(e, mode)
		elif tag=='item':
			if 'back' in mode:
				'''
				# old
				r = self.traverse(e, mode)
				'''
				# new , T08 遇到
				node = MyNode(e)
				if 'id' in node.attrib:
					del node.attrib['id']
				if 'xml:id' in node.attrib:
					del node.attrib['xml:id']
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
				
			else:
				node = MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='jhead':
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='juan':
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='l':
			'''
			# old
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.traverse(e, mode)
			'''
			# new
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			
		elif tag=='label':
			node = MyNode(e)
			if parent.tag == 'lg':
				node.tag = 'head'
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='language':
			node = MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='lb':
			n = e.get('n')
			self.write_log('lb ' + n)
			ed = e.get('ed')
			print('lb:', n, file=log)
			'''
			# old
			if 'body' in mode:	# lb 也要在 back 區呈現
				node=MyNode(e)
				if 'C ' in ed:
					node.attrib['type'] = 'honorific'
					node.attrib['ed'] = ed.replace('C ', '')
				r += node.open_tag()
				#if (globals['coll']=='X') and (n not in x2r):
				#	sys.exit('error 814: ' + n + ' not in x2r')
				#if globals['vol'].startswith('X') and 'x' not in x2r[n]:
				#	r += x2r[n]
			'''
			# new
			node=MyNode(e)
			if 'C ' in ed:
				node.attrib['type'] = 'honorific'
				node.attrib['ed'] = ed.replace('C ', '')
			r += node.open_tag()
			
		elif tag=='lem':
			r += self.handle_lem(e, mode)
		elif tag=='lg':
			'''
			# old
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.traverse(e, mode)
			'''
			# new
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				node=MyNode(e)
				if 'id' in node.attrib:		# 不明白為什麼是 id 而不是 xml:id ?
					del node.attrib['id']
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			
		elif tag=='list':
			'''
			# old
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.traverse(e, mode)
			'''
			# new , T08 遇到
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='listWit':
			if options.P5b_Format == True:
				# p5b 用一般的方法處理即可
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.handle_listwit(e, mode)
		elif tag=='mulu':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='name':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='note':
			r += self.handle_note(e, mode)
		elif tag=='p':
			r += self.handle_p(e, mode)
		elif tag=='pb':
			if 'body' in mode:
				node = MyNode(e)
				r = node.open_tag()
		elif tag=='publicationStmt':
			r += self.handle_publicationstmt(e, mode)
		elif tag=='rdg':
			r += self.handle_rdg(e, mode)
		elif tag=='ref':
			node = MyNode(e)
			if 'target' in node.attrib:
				target = node.attrib['target']
				if not target.startswith('..') and not target.startswith('#'):
					node.attrib['target'] = '#' + node.attrib['target']
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='resp':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='respStmt':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='revisionDesc':
			node=MyNode(e)
			r += node.open_tag()
			r += self.traverse(e, mode) + node.end_tag()
		elif tag=='sic':
			r = self.handle_sic(e, mode)
		elif tag=='sup':
			r = '<formula rend="vertical-align:super">'
			r += self.traverse(e, mode) + '</formula>'
		elif tag=='t':
    		# P5b 不把 t 放在 back 區了
			if options.P5b_Format == True:
				node=MyNode(e)
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
				return r
			tt = e.getparent()
			tt_type = tt.get('type')
			if 'body' in mode:
				place=e.get('place', '')
				if place != 'foot':
					if tt_type == 'app':
						r += self.traverse(e, mode)
					else:
						node = MyNode(e)
						r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				node = MyNode(e)
				if tt_type == 'app':
					r += '\t'
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag() + '\n'
		elif tag=='table':
			node = MyNode(e)
			if 'border' in node.attrib:
				node.attrib['rend'] = 'border:' + node.attrib['border']
				del node.attrib['border']
			tbody = self.traverse(e, mode)
			# 把 </row>....<row><cell> 改成 </row><row><cell>....
			# P5b 才要改的
			if options.P5b_Format == True:
				tbody = re.sub(r"(<\/row>)(.*?)(<row[^>]*><cell[^>]*>)", r"\1\3\2", tbody,0,re.DOTALL)
			r += node.open_tag() + tbody + node.end_tag()
		elif tag=='text':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode)
			if options.P5b_Format == False:
    			# p5b 不用處理 back
				r += handle_back(self)
			r += node.end_tag()
		elif tag=='todo':
			r = '<!--CBETA todo type: {}-->'.format(e.get('type'))
		elif tag=='tt':
			r += self.handle_tt(e, mode)
		elif tag=='xref':
			doc = e.get('doc')
			vol = doc[:3]
			node = MyNode(e)
			node.tag = 'ref'
			node.attrib['target'] = '../{}/{}.xml#xpath2(//{})'.format(vol, doc, e.get('loc'))
			del node.attrib['doc']
			del node.attrib['loc']
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			node=MyNode(e)
			#self.write_log(node.open_tag())
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r

############################
# MyNode 物件
############################

class MyNode():
	def __init__(self, e=None):
		if e is None:
			self.tag = ''
			self.attrib = collections.OrderedDict()
		else:
			self.tag = e.tag
			self.attrib = collections.OrderedDict(e.attrib)
			
	def open_tag(self):
		# 要歸入 cbeta namespace 的元素
		if self.tag in ('def', 'dialog', 'event', 'fan', 'jhead', 'jl_byline', 'jl_juan', 'jl_title', 'juan', 'mulu', 'sg', 't', 'tt', 'yin', 'zi'):
			self.tag = 'cb:' + self.tag
		r = '<' + self.tag
		for k, v in self.attrib.items():
			v = v.replace('&', '&amp;')
			v = v.replace('<', '&lt;')
			if k=='behaviour':
				if self.tag in ('term','text'):
					k = 'cb:' + k
			elif k=='cert':
				if self.tag in ('foreign'):
					k = 'cb:' + k
			elif k=='id':
				k = 'xml:id'
			elif k=='lang':
				k = 'xml:lang'
			elif k=='place':
				if self.tag in ('entry', 'foreign', 'lg'):
					k = 'cb:place'
			elif k=='provider':
				if self.tag in ('note', 'lem', 'rdg'):
					k = 'cb:provider'
			elif k=='resp':
				v = handle_resp(v)
				if self.tag in ('choice', 'foreign'):
					k = 'cb:resp'
			elif k=='type':
				if self.tag in ('byline', 'choice', 'p', 'sp'):
					k = 'cb:type'
			elif k=='wit':
				v = handle_wit(v)
			elif k=='word-count':
				if self.tag != 'cb:tt':
					k = 'cb:' + k
			r += ' {}="{}"'.format(k, v)
		if self.tag in EMPTY:
			r += '/'
		r += '>'
		return r
		
	def end_tag(self):
		if self.tag in EMPTY:
			return ''
		else:
			return '</'+self.tag+'>'
			
	def get(self, name):
		return self.attrib.get(name)

################################################################

def app_new_type(e):
	''' lem 及 rdg 最多只有 【CBETA】【CB】【大】 , 沒有其他的版本, 就是 choice 
	lem 或 rdg 有出現  【CBETA】【CB】【大】之外其他的版本, 就是 app
	以上是針對大正藏, 若是嘉興, 就是把【大】換成【嘉興】, 其餘類推. '''

	wits=''
	for c in e.iterchildren():
		wits += c.get('wit', '')
	wits = wits.replace('【CBETA】','')
	wits = wits.replace('【CB】','')

	#col=globals['vol'][:1]
	mo = re.search(r'^\D+', globals['vol'])
	col = mo.group()
	
	wits = wits.replace(WITS[col], '')
	if wits=='':
		return 'choice'
	else:
		return 'app'

def my_mkdir(p):
	if not os.path.exists(p): os.mkdir(p)

def handle_back_note_star(text, note_star):
	'''
	處理南傳校勘星號的問題.
	如果有這種資料 note_star['#nkr_note_orig_0228007'] = ' #note_star_1 #note_star_5 #note_star_12'
	則要把 back 區的校勘 note
	<note n="0228007" resp="#respx" type="orig" place="foot text" target="#nkr_note_orig_0228007">........</note>
	變成
	<note n="0228007" resp="#respx" type="orig" place="foot text" target="#nkr_note_orig_0228007 #note_star_1 #note_star_5 #note_star_12">........</note>
	'''
	for k in sorted(note_star):
		key = 'target="' + k + '"'
		value = 'target="' + k + note_star[k] + '"'
		text = text.replace(key, value)
	return text

#處理最後的 back 區資料
def handle_back(t):
	r = '\n<back>\n'
	if t.back['app']!='':
		r += '<cb:div type="apparatus">\n'
		r += '<head>校註</head>\n'
		r += '<p>\n'
		r += t.back['app']
		r += '</p>\n'
		r += '</cb:div>\n'
		
	if t.back['tt'] != '':
		r += '<cb:div type="tt">\n'
		r += '<head>多語詞條對照</head>\n'
		r += '<p>\n'
		r += t.back['tt']
		r += '</p>\n'
		r += '</cb:div>\n'
		
	for k in sorted(t.back_notes):
		if k=='add':
			r += '<cb:div type="add-notes">\n'
			r += '<head>新增校註</head>\n'
		elif k=='BuBian':
			r += '<cb:div type="bubian-notes">\n'
			r += '<head>大藏經補編 校註</head>\n'
		elif k=='CBETA':
			r += '<cb:div type="cbeta-notes">\n'
			r += '<head>CBETA 校註</head>\n'
		elif k=='Daoan':
			r += '<cb:div type="daoan-notes">\n'
			r += '<head>道安長老全集 校註</head>\n'
		elif k=='DILA':
			r += '<cb:div type="dila-notes">\n'
			r += '<head>法鼓文理學院 校註</head>\n'
		elif k=='Dudoucheng':
			r += '<cb:div type="dudoucheng-notes">\n'
			r += '<head>正史佛教資料類編 校註</head>\n'
		elif k=='Huimin':
			r += '<cb:div type="huimin-notes">\n'
			r += '<head>惠敏法師 校註</head>\n'
		elif k=='ihp':
			r += '<cb:div type="ihp-notes">\n'
			r += '<head>中央研究院歷史語言研究所 校註</head>\n'
		elif k=='LüCheng':
			r += '<cb:div type="lüCheng-notes">\n'
			r += '<head>呂澂佛學著作集 校註</head>\n'
		elif k=='NanChuan':
			r += '<cb:div type="nanchuan-notes">\n'
			r += '<head>漢譯南傳大藏經 校註</head>\n'
		elif k=='NCLRareBook':
			r += '<cb:div type="ncl-notes">\n'
			r += '<head>國家圖書館善本佛典 校註</head>\n'
		#elif k=='Northern Yongle Edition of the Canon':
		elif k=='Taisho':
			r += '<cb:div type="taisho-notes">\n'
			r += '<head>大正 校註</head>\n'
		elif k=='TaiXu':
			r += '<cb:div type="taixu-notes">\n'
			r += '<head>太虛大師全書 校註</head>\n'
		elif k=='Xuzangjing':
			r += '<cb:div type="xuzang-notes">\n'
			r += '<head>卍續藏 校註</head>\n'
		elif k=='Yonglebei':
			r += '<cb:div type="yongle-notes">\n'
			r += '<head>永樂北藏 校註</head>\n'
		elif k=='ZangWai':
			r += '<cb:div type="zangwai-notes">\n'
			r += '<head>方廣錩 校註</head>\n'
		elif k=='釋印順':
			r += '<cb:div type="yinshun-notes">\n'
			r += '<head>印順法師 校註</head>\n'
		elif k=='正聞出版社':
			r += '<cb:div type="zhengwen-notes">\n'
			r += '<head>正聞出版社 校註</head>\n'
		elif k=='equivalent':
			r += '<cb:div type="equiv-notes">\n'
			r += '<head>相對應巴利文書名</head>\n'
		elif k=='rest':
			if t.back_notes[k] =='':
				continue
			r += '<cb:div type="rest-notes">\n'
			r += '<head>其他校註</head>\n'
		else:
			sys.exit('error 1000: ' + k)
		r += '<p>\n'
		r += handle_back_note_star(t.back_notes[k], t.note_star)	# 要處理可能有星號的 note
		r += '</p>\n'
		r += '</cb:div>\n'
		
	r += '</back>'
	return r

############################
# phase1
############################

def phase1(vol,path):
	print('phase1', path)
	print(path, file=log)			# ex. path = c:/cbwork/xml-p5a/N/N10\N10n0003.xml
	fn=os.path.basename(path)		#	fn = N10n0003.xml
	file_id=fn.rpartition('.')[0]	#	file_id = N10n0003
	text = '''<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" xml:id="{}">'''.format(file_id)

	t=MyTransformer(path)
	# P5b 不用轉成 #wit #resp 代碼
	if options.P5b_Format == False:
		read_all_resp(t.root)
		read_all_wit(t.root)
	text += t.traverse(t.root, mode=set(['body']))	# mode = body , 表示處理的都在 body 區, 若遇到校勘, mode 換成 back , 表示接下來的資料都是在 back 區的
	text += '</TEI>'
	
	char_decl = t.prepare_charDecl()
	text = text.replace('<charDecl></charDecl>', char_decl)
	mo = re.search(r'^\D+', vol)
	coll = mo.group()
	out_fn=os.path.join(PHASE1DIR, coll, vol, fn)
	fo=open(out_fn, 'w', encoding='utf8')
	fo.write(text)
	fo.close()

def repl_lg(mo):
	''' 開始 anchor 與 結束 anchor 之間維持巢狀 '''
	r = mo.group(1)
	s = mo.group(2)
	mo2 = re.match(r'.*<l>「<anchor xml:id="beg(\d+)"[^>]*/>.*?</l><anchor xml:id="end\1"/>', s, flags=re.DOTALL)
	if mo2 is not None:
		s = re.sub('<l>「(<anchor [^>]*/>)', r'\1<l>「', s)
	r += s
	r += mo.group(3)
	return r

############################
# phase2
############################

def phase2(vol,p):
	print('phase2 vol=%s p=%s' % (vol,p))
	fi=open(p, 'r', encoding='utf8')
	s=fi.read()
	fi.close()
	
	# P5b 不要移到 <l> 裡, 不然會有巢狀錯誤
	if options.P5b_Format == False:
		# 把 <lg> 下面的文字, 移到第一個 <l> 裏
		s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?(?:<note.*?</note>)?(?:<note.*?</note>)?(?:<app[^>]*?>)?(?:<lem[^>]*?>)?(?:<cb:tt[^>]*?>)?(?:<cb:t[^>]*?>)?)(.*?)((?:<l [^>]*?>)|(?:<l>))', r'\1\3\2', s) 
		
		#s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(<l[^>]*?>「)((?:<anchor[^>]*?/>)+)', r'\1\3\2', s)
		s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?(?:<note.*?</note>)?(?:<note.*?</note>)?(?:<app[^>]*?>)?(?:<lem[^>]*?>)?(?:<cb:tt[^>]*?>)?(?:<cb:t[^>]*?>)?)(.*?)(</lg>)', repl_lg, s, flags=re.DOTALL)
	
	# 把 <anchor> 前後多餘的換行去掉
	s=re.sub(r'\n+(<anchor )', r'\1', s)
	s=re.sub(r'(<anchor [^>]*>)\n+', r'\1', s)
	
	# lb, pb 之前要換行
	s=re.sub('>(<lb[^>]*?ed="%s)' % vol[0], r'>\n\1', s)
	s=re.sub(r'([^\n])<pb ', r'\1\n<pb ', s)
	# type="old" 的 lb 和 pb 不換行 (印順導師全集才有的)
	s=re.sub('\n(<[lp]b[^>]*type="old")', r'\1', s)
	
	# 如果 sourceDesc 下有 <p> 的話, listWit 要放在 p 裡面.
	s = re.sub(r'(</p>)\s*(<listWit>.*?</listWit>)', r'\n\2\1', s, flags=re.DOTALL)
	mo = re.search(r'^\D+', vol)
	coll = mo.group()
	fo=open(OUT_P5+'/'+coll+'/'+vol+'/'+os.path.basename(p),'w', encoding='utf8')
	fo.write(s)
	fo.close()

def spend_time(secs):
	r='Spend time: '
	if secs<60: r+='%.2f seconds' % secs
	else: r+='%.1f minutes' % (secs/60)
	return r

###########################################
# 這段應該沒用了
# P5a 已有卍續藏的 R 版行號, 就不需再產生了
###########################################
'''
def read_x2r(vol):
	fn='D:/cbwork/common/X2R/' + vol + 'R.txt'
	fi = open(fn, 'r', encoding='cp950')
	result = {}
	for line in fi:
		line = line.rstrip()
		mo = re.match('.*?p(.*?)║(.*?)_p(.*)$', line)
		if mo is None:
			continue
		x = mo.group(1)
		r = '<lb ed="{}" n="{}"/>'.format(mo.group(2), mo.group(3))
		result[x] = r
	fi.close()
	return result
'''

############################
# 處理一冊
############################

def do1vol(vol):
	global globals, x2r, p5a_filename
	globals['vol'] = vol
	#coll = vol[:1]
	mo = re.search(r'^\D+', vol)
	coll = mo.group()
	globals['coll'] = coll
	globals['collection-wit'] = WITS[coll] # 如果冊數 T 開頭, 就是 【大】
	if coll in RESPS:
		globals['collection-resp'] = RESPS[coll] # 如果冊數 T 開頭, 就是 Taisho
	
	time_begin=time.time()
	print(now())
	
	# P5a 已有卍續藏的 R 版行號, 就不需再產生了
	#if vol.startswith('X'):
	#	x2r = read_x2r(vol)
	
	# phase- 1 #################################
	
	print(vol, 'phase-1')
	my_mkdir(PHASE1DIR+'/'+coll)
	my_mkdir(PHASE1DIR+'/'+coll+'/'+vol)
	print (IN_P5a+'/'+coll+'/'+vol+'/*.xml')
	for p in glob.iglob(IN_P5a+'/'+coll+'/'+vol+'/*.xml'):
		p5a_filename = p
		phase1(vol,p)
		
	# phase- 2 #################################
	
	print(vol, 'phase-2')
	my_mkdir(OUT_P5+'/'+coll)
	my_mkdir(OUT_P5+'/'+coll+'/'+vol)
	for p in glob.iglob(PHASE1DIR+'/'+coll+'/'+vol+'/*.xml'): 
		phase2(vol,p)
	
	# 驗證 #################################
	if options.No_Valid == False:
		for p in glob.iglob(OUT_P5+'/'+coll+'/'+vol+'/*.xml'): 
			print('validate', p)
			#tree = etree.parse(p)
			#if not RELAXNG.validate(tree):
			if not zbxxml.validate(p, RNC, JING):
				sys.exit(p + ' is not valid')

	s=spend_time(time.time()-time_begin)
	print(vol, s)
	log.write(vol+' '+s+'\n')

############################
# 處理整個目錄
############################

def do1dir(dir):
	colls=os.listdir(dir)
	colls.sort()
	for coll in colls:
		if coll in ('.git', 'schema', '.gitignore', 'README.md'): continue
		if (options.collection is None) or coll.startswith(options.collection): 
			path = os.path.join(dir, coll)
			vols = os.listdir(path)
			vols.sort()
			for vol in vols:
				if vol in ('T56', 'T57'): continue
				if options.vol_start is not None:
					if vol<options.vol_start: continue
				do1vol(vol)
			
def now():
	return time.strftime(time_format)

def read_all_gaijis():
	r = {}
	with open(GAIJI, encoding='utf8') as infile:
		reader = csv.DictReader(infile,  delimiter='\t')
		for row in reader:
			cb = row['cb']
			uni = row['unicode']
			# print (cb)
			if cb != '':
				cb = 'CB' + cb
				r[cb] = {}
				if row['des'] != '':
					r[cb]['des'] = row['des']
				if row['nor'] != '':
					r[cb]['nor'] = row['nor']
				if row['nor_unicode'] != '':
					r[cb]['nor_unicode'] = row['nor_unicode']
				if uni != '':
					r[cb]['unicode'] = uni
			if uni != '':
				unicode2cb[uni] = cb
	return r

def read_all_gaijis_by_mdb():
	r = {}
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	sql = "SELECT cb, unicode, des, nor, uni FROM gaiji WHERE cb Is Not Null"
	rs.Open(sql, conn, 1, 3)
	if rs.RecordCount > 0:
		rs.MoveFirst()
		while 1:
			if rs.EOF:
				break
			else:
				cb = rs.Fields.Item('cb').Value
				# print (cb)
				unicode = rs.Fields.Item('unicode').Value	# 此欄位只有有 unicode 的才有, 不包含 nor_unicode , 反之 uni 欄位就包含 nor_uni 了
				des = rs.Fields.Item('des').Value
				nor = rs.Fields.Item('nor').Value
				# 因為在 gaiji-m.mdb 中, 'uni' 欄位是同時包含有 unicode 及 nor_uni 的
				# 所以只有當 'unicode' 欄位為空白時, 'uni' 欄位的才是真正代表 nor_uni 的內容
				if unicode == '' or unicode == None :
					nor_unicode = rs.Fields.Item('uni').Value
				else:
					nor_unicode = '';
					
				if cb != '' and cb != None:
					cb = 'CB' + cb
					r[cb] = {}
					if des != '' and des != None:
						r[cb]['des'] = des
					if nor != '' and nor != None:
						r[cb]['nor'] = nor
					if nor_unicode != '' and nor_unicode != None:
						r[cb]['nor_unicode'] = nor_unicode
					if unicode != '' and unicode != None:
						r[cb]['unicode'] = unicode
				if unicode != '' and unicode != None:
					unicode2cb[unicode] = cb
			rs.MoveNext()
	return r

####################################################################
# 主程式
####################################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option('-c', dest='collection', help='collections (e.g. TXJ...)')
parser.add_option('-s', dest='vol_start', help='start volumn (e.g. X55)')
parser.add_option('-v', dest='volumn', help='volumn (e.g. X55)')
parser.add_option("-b", action="store_true", dest="P5b_Format", default=False, help="轉成 P5b 格式 (CBReader 專用)")
parser.add_option("--nv", action="store_true", dest="No_Valid", default=False, help="不要執行驗證")
#parser.add_option('-g', dest='gaiji_txt', help='use gaiji-m_u8.txt e.g. -g txt (default use gaiji-m.mdb)')
(options, args) = parser.parse_args()

if options.collection is not None:
	options.collection = options.collection.upper()
if options.vol_start is not None:
	options.vol_start = options.vol_start.upper()

# 讀取設定檔 cbwork_bin.ini
config = configparser.ConfigParser()
config.read('../cbwork_bin.ini')
CBTEMP = config.get('default', 'temp')
cbwork_dir = config.get('default', 'cbwork')
JING = config.get('default', 'jing.jar_file')
gaijiMdb = config.get('default', 'gaiji-m.mdb_file')

IN_P5a = cbwork_dir + '/xml-p5a' 		# XML P5a 來源資料夾
p5a_filename = ''							# c:\cbwork\xml-p5a\T\T01\T01n0001.xml
if options.P5b_Format == True:
	PHASE1DIR = CBTEMP + '/cbetap5b-tmp1'	# 暫存資料夾
	OUT_P5 = CBTEMP + '/cbetap5b-ok'			# 最後結果   
	EMPTY.append("g");					# P5b 缺字不能有內容, 完全靠屬性處理
else:
	PHASE1DIR = CBTEMP + '/cbetap5-tmp1'	# 暫存資料夾
	OUT_P5 = CBTEMP + '/cbetap5-ok'			# 最後結果

#GAIJI = cbwork_dir + '/bin/gaiji-m_u8.txt'
GAIJI = gaijiMdb.replace('gaiji-m.mdb', "gaiji-m_u8.txt")
if options.P5b_Format == True:
	RNC = cbwork_dir + '/xml-p5a/schema/cbeta-p5a.rnc'
else:
	RNC = cbwork_dir + '/xml-p5/schema/cbeta-p5.rnc'

globals={}
unicode2cb = {}

# 準備存取 gaiji-m.mdb
#conn = win32com.client.Dispatch(r'ADODB.Connection')
#DSN = 'PROVIDER=Microsoft.Jet.OLEDB.4.0;DATA SOURCE=%s;' % gaijiMdb
#conn.Open(DSN)

#if options.gaiji_txt is not None:
#	all_gaijis=read_all_gaijis()	# 開啟 cvs 的資料庫
#else:
#	all_gaijis=read_all_gaijis_by_mdb()	# 開啟 MS Access 的 mdb 資料庫, 不過很慢

all_gaijis=read_all_gaijis()	# 預設改為直接開啟 cvs 的資料庫

log=open('p5a2p5.log', 'w', encoding='utf8')
log.write(now()+'\n')
my_mkdir(PHASE1DIR)
my_mkdir(OUT_P5)
if options.volumn is not None:
	do1vol(options.volumn.upper())
else:
	do1dir(IN_P5a)
print()
print(now())
log.write(now())