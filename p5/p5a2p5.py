# -*- coding: utf8 -*-
''' CBETA XML P5a 轉 P5
2013.1.4 周邦信 改寫自 cbp4top5.py

Heaven 修改:
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

import configparser, collections, csv, datetime, glob, os, re, shutil, sys, time
from optparse import OptionParser
from lxml import etree
import zbxxml, siddam, ranjana
import win32com.client # 要安裝 PythonWin

# 使用 lxml 3.0.2 的 RelaxNG 在 validate T18n0850 時有問題
#relaxng_doc = etree.parse('D:/git-repos/ddbc-cbeta/schema/cbeta-p5.rng')
#RELAXNG = etree.RelaxNG(relaxng_doc)

time_format='%Y.%m.%d %H:%M'

EMPTY=['anchor', 'lb', 'milestone', 'mulu', 'pb', 'space']

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
	'I' : '【史】',
	'J' : '【嘉興】',
	'K' : '【麗】',
	'L' : '【龍】',
	'M' : '【卍正】',
	'N' : '【南傳】',
	'P' : '【北藏】',
	'Q' : '【磧砂】',
	'S' : '【宋遺】',
	'T' : '【大】',
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
	'ZS' : 'Dudoucheng',
	'J' : 'Jiaxing',
	'T' : 'Taisho',
	'ZW' : 'ZangWai',
	'X' : 'Xuzangjing',
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

###############################################
# 讀取 unicode 的版本, 參考 cbwork/bin/cbeta.pm
###############################################

def get_unicode_ver(uni):	

	#這幾個移到前面, 速度看會不會快一點
	if(uni >= 0x4E00 and uni <= 0x9FA5):	return "1.0" 	#4E00～9FA5：CJK Unified Ideographs (Han) 中日韓統一表意文字區 (原本標準是到 9FCC)。(20,902 字, Unicode 1.0 , 1993)
	if(uni >= 0x3000 and uni <= 0x3036):	return "1.0" 	#3000～3036：CJK Symbols and Punctuation 符號和標點符號 (Unicode 1.0)
	if(uni >= 0x3400 and uni <= 0x4DB5):	return "3.0" 	#3400～4DB5：CJK Extension A 中日韓統一表意文字擴充 A 區。(6582 字, Unicode 3.0 , 1999)
	if(uni >= 0x20000 and uni <= 0x2A6D6):	return "3.1" 	#20000～2A6D6：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (42711 字, Unicode 3.1 , 2001)

	#底下是完整的
	if(uni >= 0x0000 and uni <= 0x017E) :	return "1.0"     #0000～017E： (Unicode 1.0)
	if(uni == 0x017F) :						return "1.1"     #017F： (Unicode 1.1)
	if(uni >= 0x0180 and uni <= 0x01F0) :	return "1.0"     #0180～01F0： (Unicode 1.0)
	if(uni >= 0x01F1 and uni <= 0x01F5) :	return "1.1"     #01F1～01F5： (Unicode 1.1)
	if(uni >= 0x01F6 and uni <= 0x01F9) :	return "3.0"     #01F6～01F9： (Unicode 3.0)
	if(uni >= 0x01FA and uni <= 0x0217) :	return "1.1"     #01FA～0217： (Unicode 1.1)
	if(uni >= 0x0218 and uni <= 0x021F) :	return "3.0"     #0218～021F： (Unicode 3.0)
	if(uni == 0x0220) :						return "3.2"     #0220： (Unicode 3.2)
	if(uni == 0x0221) :						return "4.0"     #0221： (Unicode 4.0)
	if(uni >= 0x0222 and uni <= 0x0233) :	return "3.0"     #0222～0233： (Unicode 3.0)
	if(uni >= 0x0234 and uni <= 0x0236) :	return "4.0"     #0234～0236： (Unicode 4.0)
	if(uni >= 0x0237 and uni <= 0x0241) :	return "4.1"     #0237～0241： (Unicode 4.1)
	if(uni >= 0x0242 and uni <= 0x024F) :	return "5.0"     #0242～024F： (Unicode 5.0)
	if(uni >= 0x0250 and uni <= 0x02A8) :	return "1.0"     #0250～02A8： (Unicode 1.0)
	if(uni >= 0x02A9 and uni <= 0x02AD) :	return "3.0"     #02A9～02AD： (Unicode 3.0)
	if(uni >= 0x02AE and uni <= 0x02AF) :	return "4.0"     #02AE～02AF： (Unicode 4.0)
	if(uni >= 0x02B0 and uni <= 0x02DE) :	return "1.0"     #02B0～02DE： (Unicode 1.0)
	if(uni == 0x02DF) :						return "3.0"     #02DF： (Unicode 3.0)
	if(uni >= 0x02E0 and uni <= 0x02E9) :	return "1.0"     #02E0～02E9： (Unicode 1.0)
	if(uni >= 0x02EA and uni <= 0x02EE) :	return "3.0"     #02EA～02EE： (Unicode 3.0)
	if(uni >= 0x02EF and uni <= 0x02FF) :	return "4.0"     #02EF～02FF： (Unicode 4.0)
	if(uni >= 0x0300 and uni <= 0x0341) :	return "1.0"     #0300～0341： (Unicode 1.0)
	if(uni >= 0x0401 and uni <= 0x040C) :	return "1.0"     #0401～040C： (Unicode 1.0)
	if(uni == 0x040D) :						return "3.0"     #040D： (Unicode 3.0)
	if(uni >= 0x040E and uni <= 0x044F) :	return "1.0"     #040E～044F： (Unicode 1.0)
	if(uni >= 0x1E00 and uni <= 0x1E9A) :	return "1.1"     #1E00～1E9A： (Unicode 1.1)
	if(uni == 0x1E9B) :						return "2.0"     #1E9B： (Unicode 2.0)
	if(uni >= 0x1E9C and uni <= 0x1E9F) :	return "5.1"     #1E9C～1E9F： (Unicode 5.1)
	if(uni >= 0x1EA0 and uni <= 0x1EF9) :	return "1.1"     #1EA0～1EF9： (Unicode 1.1)
	if(uni >= 0x1EFA and uni <= 0x1EFF) :	return "5.1"     #1EFA～1EFF： (Unicode 5.1)
	if(uni >= 0x2000 and uni <= 0x202E) :	return "1.0"     #2000～202E： (Unicode 1.0)
	if(uni >= 0x2045 and uni <= 0x2046) :	return "1.1"     #2045～2046： (Unicode 1.1)
	if(uni == 0x2047) :						return "3.2"     #2047： (Unicode 3.2)
	if(uni >= 0x2048 and uni <= 0x204F) :	return "3.0"     #2048～204F： (Unicode 3.0)
	if(uni >= 0x2100 and uni <= 0x2138) :	return "1.0"     #2100～2138： (Unicode 1.0)
	if(uni >= 0x2153 and uni <= 0x2182) :	return "1.0"     #2153～2182： (Unicode 1.0)
	if(uni >= 0x2190 and uni <= 0x21EA) :	return "1.0"     #2190～21EA： (Unicode 1.0)
	if(uni >= 0x2200 and uni <= 0x22F1) :	return "1.0"     #2200～22F1： (Unicode 1.0)
	if(uni >= 0x2460 and uni <= 0x24EA) :	return "1.0"     #2460～24EA：Enclosed Alphanumerics 括號及圓圈各種數字英文 (Unicode 1.0)
	if(uni >= 0x24EB and uni <= 0x24FE) :	return "3.2"     #24EB～24FE：Enclosed Alphanumerics 括號及圓圈各種數字英文 (Unicode 3.2)
	if(uni == 0x24FF) :						return "4.0"     #24FF： (Unicode 4.0)
	if(uni >= 0x2500 and uni <= 0x2595) :	return "1.0"     #2500～2595： (Unicode 1.0)
	if(uni >= 0x2596 and uni <= 0x259F) :	return "3.2"     #2596～259F： (Unicode 3.2)
	if(uni >= 0x25A0 and uni <= 0x25EE) :	return "1.0"     #25A0～25EE： (Unicode 1.0)
	if(uni == 0x25EF) :						return "1.1"     #25EF： (Unicode 1.1)
	if(uni >= 0x2600 and uni <= 0x2613) :	return "1.0"     #2600～2613： (Unicode 1.0)
	if(uni >= 0x261A and uni <= 0x266F) :	return "1.0"     #261A～266F： (Unicode 1.0)
	if(uni >= 0x2E80 and uni <= 0x2EF3) :	return "3.0"     #2E80～2EF3：CJK Radicals Supplement 部首補充 (128 字, Unicode 3.0 , 1999)
	if(uni >= 0x2F00 and uni <= 0x2FD5) :	return "3.0"     #2F00～2FD5：CJK Radicals / KangXi Radicals 部首 / 康熙字典部首 (224 字, Unicode 3.0 , 1999)
	if(uni >= 0x2FF0 and uni <= 0x2FFB) :	return "3.0"     #2FF0～2FFB：Ideographic Description Characters 表意文字描述字符 (中研院的組字符號, Unicode 3.0 , 1999)
	#if(uni >= 0x3000 and uni <= 0x3036) :	return "1.0"     #3000～3036：CJK Symbols and Punctuation 符號和標點符號 (Unicode 1.0)
	if(uni == 0x3037) :						return "1.1"     #3037：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 1.1 , 1993)
	if(uni >= 0x3038 and uni <= 0x303A) :	return "3.0"     #3038～303A：CJK Symbols and Punctuation 符號和標點符號 (3 字, Unicode 3.0 , 1999)
	if(uni >= 0x303B and uni <= 0x303D) :	return "3.2"     #303B～303D：CJK Symbols and Punctuation 符號和標點符號 (3 字, Unicode 3.2 , 2002)
	if(uni == 0x303E) :						return "3.0"     #303E：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 3.0 , 1999)
	if(uni == 0x303F) :						return "1.0"     #303F：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 1.0)
	if(uni >= 0x3041 and uni <= 0x3094) :	return "1.0"     #3041～3094：Hiragana 日文平假名 (Unicode 1.0)
	if(uni >= 0x3095 and uni <= 0x3096) :	return "3.2"     #3095～3096：Hiragana 日文平假名 (Unicode 3.2)
	if(uni >= 0x3099 and uni <= 0x309E) :	return "1.0"     #3099～309E：Hiragana 日文平假名 (Unicode 1.0)
	if(uni == 0x309F) :						return "3.2"     #309F：Hiragana 日文平假名 (Unicode 3.2)
	if(uni == 0x30A0) :						return "3.2"     #30A0：Katakana 日文片假名 (Unicode 3.2)
	if(uni >= 0x30A1 and uni <= 0x30F6) :	return "1.0"     #30A1～30F6：Katakana 日文片假名 (Unicode 1.0)
	if(uni >= 0x30F7 and uni <= 0x30FA) :	return "1.1"     #30F7～30FA：Katakana 日文片假名 (Unicode 1.1)
	if(uni >= 0x30FB and uni <= 0x30FE) :	return "1.0"     #30FB～30FE：Katakana 日文片假名 (Unicode 1.0)
	if(uni == 0x30FF) :						return "3.2"     #30FF：Katakana 日文片假名 (Unicode 3.2)
	if(uni >= 0x3105 and uni <= 0x312C) :	return "1.0"     #3105～312C：Bopomofo 注音符號 (Unicode 1.0)
	if(uni == 0x312D) :						return "5.1"     #312D：Bopomofo 上下顛倒的 'ㄓ' (Unicode 5.1)
	if(uni >= 0x3131 and uni <= 0x318E) :	return "1.0"     #3131～318E：Hangul Compatibility Jamo 韓文 (Unicode 1.0)
	if(uni >= 0x3190 and uni <= 0x319F) :	return "1.0"     #3190～319F：Kanbun 在上方的小漢字 (Unicode 1.0)
	if(uni >= 0x31A0 and uni <= 0x31B7) :	return "3.0"     #31A0～31B7：Bopomofo Extended 注音擴展 (Unicode 3.0)
	if(uni >= 0x31B8 and uni <= 0x31BA) :	return "6.0"     #31B8～31BA：Bopomofo Extended 注音擴展 (Unicode 6.0)
	if(uni >= 0x31C0 and uni <= 0x31CF) :	return "4.1"     #31C0～31CF：CJK Strokes 筆劃 (基本筆劃, 如撇, 勾, 點...) (Unicode 4.1)
	if(uni >= 0x31D0 and uni <= 0x31E3) :	return "5.1"     #31D0～31E3：CJK Strokes 筆劃 (基本筆劃, 如撇, 勾, 點...) (Unicode 5.1)
	if(uni >= 0x31F0 and uni <= 0x31FF) :	return "3.2"     #31F0～31FF：Katakana Phonetic Extensions 日文片假名語音擴展 (Unicode 3.2)
	if(uni >= 0x3200 and uni <= 0x321C) :	return "1.0"     #3200～321C：Enclosed CJK Letters and Months 括號韓文 (Unicode 1.0)
	if(uni >= 0x321D and uni <= 0x321E) :	return "4.0"     #321D～321E：Enclosed CJK Letters and Months 括號韓文 (Unicode 4.0)
	if(uni >= 0x3220 and uni <= 0x3243) :	return "1.0"     #3220～3243：Enclosed CJK Letters and Months 括號一~十及漢字 (Unicode 1.0)
	if(uni >= 0x3244 and uni <= 0x324F) :	return "5.2"     #3244～324F：Enclosed CJK Letters and Months 圓圈中有字及10~80 (Unicode 5.2)
	if(uni == 0x3250) :						return "4.0"     #3250：Enclosed CJK Letters and Months 'PTE' 組成一字 (Unicode 4.0)
	if(uni >= 0x3251 and uni <= 0x325F) :	return "3.2"     #3251～325F：Enclosed CJK Letters and Months 圓圈 21~35 (Unicode 3.2)
	if(uni >= 0x3260 and uni <= 0x327B) :	return "1.0"     #3260～327B：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 1.0)
	if(uni >= 0x327C and uni <= 0x327D) :	return "4.0"     #327C～327D：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 4.0)
	if(uni == 0x327E) :						return "4.1"     #327E：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 4.1)
	if(uni >= 0x327F and uni <= 0x32B0) :	return "1.0"     #327F～32B0：Enclosed CJK Letters and Months 圓圈一~十及漢字 (Unicode 1.0)
	if(uni >= 0x32B1 and uni <= 0x32BF) :	return "3.2"     #32B1～32BF：Enclosed CJK Letters and Months 圓圈 36~50 (Unicode 3.2)
	if(uni >= 0x32C0 and uni <= 0x32CB) :	return "1.1"     #32C0～32CB：Enclosed CJK Letters and Months 1月~12月 (Unicode 1.1)
	if(uni >= 0x32CC and uni <= 0x32CF) :	return "4.0"     #32CC～32CF：Enclosed CJK Letters and Months 多英文組成一個字 (Unicode 4.0)
	if(uni >= 0x32D0 and uni <= 0x32FE) :	return "1.0"     #32D0～32FE：Enclosed CJK Letters and Months 圓圈日文 (Unicode 1.0)
	if(uni >= 0x3300 and uni <= 0x3357) :	return "1.0"     #3300～3357：CJK Compatibility 多個日文組成一字 (Unicode 1.0)
	if(uni >= 0x3358 and uni <= 0x3376) :	return "1.1"     #3358～3376：CJK Compatibility 0奌~24奌 及多英文組成一字 (Unicode 1.1)
	if(uni >= 0x3377 and uni <= 0x337A) :	return "4.0"     #3377～337A：CJK Compatibility 多英文組成一字 (Unicode 4.0)
	if(uni >= 0x337B and uni <= 0x33DD) :	return "1.0"     #337B～33DD：CJK Compatibility 多日本漢字及多英文組成一字 (Unicode 1.0)
	if(uni >= 0x33DE and uni <= 0x33DF) :	return "4.0"     #33DE～33DF：CJK Compatibility 多英文組成一字 (Unicode 4.0)
	if(uni >= 0x33E0 and uni <= 0x33FE) :	return "1.1"     #33E0～33FE：CJK Compatibility 1日~31日 (Unicode 1.1)
	if(uni == 0x33FF) :						return "4.0"     #33FF：CJK Compatibility 'gal' 組成一字 (Unicode 4.0)
	#if(uni >= 0x3400 and uni <= 0x4DB5) :	return "3.0"     #3400～4DB5：CJK Extension A 中日韓統一表意文字擴充 A 區。(6582 字, Unicode 3.0 , 1999)
	if(uni >= 0x4DC0 and uni <= 0x4DFF) :	return "4.0"     #4DC0～4DFF：易經六十四卦符號。(64 字, Unicode 4.0)
	#if(uni >= 0x4E00 and uni <= 0x9FA5) :	return "1.0"     #4E00～9FA5：CJK Unified Ideographs (Han) 中日韓統一表意文字區 (原本標準是到 9FCC)。(20,902 字, Unicode 1.0 , 1993)
	if(uni >= 0x9FA6 and uni <= 0x9FBB) :	return "4.1"     #9FA6～9FBB：14 個香港增補字符集的用字和 8 個 GB 18030 用字 (22 字, Unicode 4.1 , 2005)
	if(uni >= 0x9FBC and uni <= 0x9FC3) :	return "5.1"     #9FBC～9FC3：7 個日語漢字及 U+9FC3 (8 字, Unicode 5.1 , 2008)
	if(uni >= 0x9FC4 and uni <= 0x9FCB) :	return "5.2"     #9FC4～9FCB：2 個日語用漢字, 1 個新增漢字, 5 個香港漢字 (8 字, Unicode 5.2 , 2009)
	if(uni == 0x9FCC) :						return "6.1"     #9FCC：1 個漢字 (1 字, Unicode 6.1 , 2012)
	if(uni >= 0xA000 and uni <= 0xA48C) :	return "3.0"     #A000～A48C：Yi Syllables 彝族文字區 (Unicode 3.0)
	if(uni >= 0xAC00 and uni <= 0xD7A3) :	return "2.0"     #AC00～D7A3：Hangul Syllables 韓文拼音 (Unicode 2.0)
	if(uni >= 0xF900 and uni <= 0xFA2D) :	return "1.0"     #F900～FA2D：CJK Compatibility Ideographs 相容表意字 (Unicode 1.0 , 1993)
	if(uni >= 0xFA30 and uni <= 0xFA6A) :	return "3.2"     #FA30～FA6A：CJK Compatibility Ideographs 相容表意字 (Unicode 3.2)
	if(uni >= 0xFA70 and uni <= 0xFAD9) :	return "4.1"     #FA70～FAD9：CJK Compatibility Ideographs 相容表意字 - 106個來自北韓的相容漢字 (106 字, Unicode 4.1 , 2005)
	if(uni >= 0xFE10 and uni <= 0xFE19) :	return "4.1"     #FE10～FE19：Vertical Forms 中文直排標點 (Unicode 4.1)
	if(uni >= 0xFE20 and uni <= 0xFE23) :	return "1.1"     #FE20～FE23：Combining Half Marks (Unicode 1.1)
	if(uni >= 0xFE24 and uni <= 0xFE26) :	return "5.1"     #FE24～FE26：Combining Half Marks (Unicode 5.1)
	if(uni >= 0xFE30 and uni <= 0xFE44) :	return "1.0"     #FE30～FE44：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 1.0)
	if(uni >= 0xFE45 and uni <= 0xFE46) :	return "3.2"     #FE45～FE46：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 3.2)
	if(uni >= 0xFE47 and uni <= 0xFE48) :	return "4.0"     #FE47～FE48：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 4.0)
	if(uni >= 0xFE49 and uni <= 0xFE4F) :	return "1.0"     #FE49～FE4F：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 1.0)
	if(uni >= 0xFE50 and uni <= 0xFE52) :	return "1.0"     #FE50～FE52：Small Form Variants (Unicode 1.0)
	if(uni >= 0xFE54 and uni <= 0xFE66) :	return "1.0"     #FE54～FE66：Small Form Variants (Unicode 1.0)
	if(uni >= 0xFE68 and uni <= 0xFE6B) :	return "1.0"     #FE68～FE6B：Small Form Variants (Unicode 1.0)
	if(uni >= 0xFF01 and uni <= 0xFF5E) :	return "1.0"     #FF01～FF5E：Halfwidth and Fullwidth Forms (Unicode 1.0)
	if(uni >= 0xFF5F and uni <= 0xFF60) :	return "3.2"     #FF5F～FF60：Halfwidth and Fullwidth Forms (Unicode 3.2)
	if(uni >= 0xFF61 and uni <= 0xFF9F) :	return "1.0"     #FF61～FF9F：Halfwidth and Fullwidth Forms (Unicode 1.0)
	#if(uni >= 0x20000 and uni <= 0x2A6D6) : return "3.1"    #20000～2A6D6：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (42711 字, Unicode 3.1 , 2001)
	if(uni >= 0x2A700 and uni <= 0x2B734) :	return "5.2"     #2A700～2B734：CJK Unified Ideographs Extension C 中日韓統一表意文字擴展 C 區 (4149 字, Unicode 5.2 , 2009)
	if(uni >= 0x2B740 and uni <= 0x2B81D) :	return "6.0"	 #2B740～2B81D：CJK Unified Ideographs Extension D 中日韓統一表意文字擴展 D 區 (222 字, Unicode 6.0 , 2010)
	if(uni >= 0x2B820 and uni <= 0x2F7FF) :	return "8.0"	 #2B820～2F7FF：CJK Unified Ideographs Extension E 中日韓統一表意文字擴展 E 區 (Unicode 8.0)
	if(uni >= 0x2F800 and uni <= 0x2FA1D) :	return "3.1"	 #2F800～2FA1D：CJK Compatibility Ideographs Supplement 相容表意字補充 - 台灣的相容漢字 (542 字, Unicode 3.1 , 2001)
	
	
	return ""
	
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
	wit_id={}			# 先清掉舊的記錄, 免得愈累積愈多	--2013/08/13
	for e in root.iter(tag=etree.Element):
		wit=e.get('wit', '')
		wits = re.findall('【.*?】', wit)
		for w in wits:
			if w not in wit_id:
				wit_id[w]='wit{}'.format(len(wit_id)+1)

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
			wit_id[w] = 'wit{}'.format(len(wit_id)+1)
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
			# Ext-A: U+3400~U+4DFF, Ext-B: U+FFFF 之上, 而 U+2E80 ~ U+2EF3 屬於 Unicode 3.0
			# if code>0xffff or (code>=0x3400 and code<=0x4DFF) or (code>=0x2E80 and code<=0x2EF3):
			# if get_unicode_ver(code) != "1.0" and get_unicode_ver(code) != "1.1" and get_unicode_ver(code) != "" :
			if get_unicode_ver(code) > "2.0" :
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
			r += '<char xml:id="{}">\n'.format(cb)
			r += '\t<charName>CBETA CHARACTER {}</charName>\n'.format(cb)
			attrib = get_gaiji_info(cb)
			for k, v in sorted(attrib.items()):
				if k != 'unicode' and  k != 'nor_unicode':
					r += '\t<charProp>\n'
					r += '\t\t<localName>'
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
					r += '\t\t<value>{}</value>\n'.format(v)
					r += '\t</charProp>\n'
			if 'unicode' in attrib:
				r += '\t<mapping type="unicode">U+{}</mapping>\n'.format(attrib['unicode'])
			if 'nor_unicode' in attrib:
				r += '\t<mapping type="normal_unicode">U+{}</mapping>\n'.format(attrib['nor_unicode'])
			r += '\t<mapping cb:dec="{0}" type="PUA">U+{0:X}</mapping>\n'.format(cb2pua(cb))
			r += '</char>\n'
		if r != '':
			r = '<charDecl>\n' + r + '</charDecl>\n'
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
			if type in ('cf1', 'cf2', 'cf3'):
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
			r = node.open_tag() + self.traverse(e, mode)
			if 'cf1' in e.attrib: 
				cf1 = e.get('cf1')
				r += '<note type="cf1">' + cf1 + '</note>'
			if 'cf2' in e.attrib: 
				cf2 = e.get('cf2')
				r += '<note type="cf2">' + cf2 + '</note>'
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
				if e.get('place')=='inline':
					if e.get('rend') is None:
						node.attrib['rend'] = 'inline'
						del node.attrib['place']
					else:
						sys.exit('error 441')
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
		if 'place' in node.attrib:
			if place=='inline':
				if 'rend' in node.attrib:
					node.attrib['rend'] += ';' + node.attrib['place']
				else:
					node.attrib['rend'] = node.attrib['place']
				del node.attrib['place']
			else:
				node.attrib['cb:type'] = place
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
			
	def handle_sourcedesc(self, e, mode):
		node=MyNode(e)
		r = node.open_tag()
		if globals['coll'] != 'D':
			r += self.traverse(e, mode)
		else:
			bibl = e.find('bibl')
			bibl_text = self.traverse(bibl, mode)
			mo = re.search(r'Vol. (\d+), No. (\d+)', bibl_text)
			r += '\n\t\t<bibl>' + bibl_text + '</bibl>'
			r += '''\n\t\t<msDesc>
			<msIdentifier>
				<settlement>Taipei</settlement>
				<repository>National Central Library</repository>
				<idno>Vol. {}, No. {}</idno>
			</msIdentifier>'''.format(mo.group(1), mo.group(2))
			p = e.find('p')
			if p is not None:
				p_text = self.traverse(p, mode)
				r += '\n\t\t\t<p>{}</p>'.format(p_text)
			r += '\n\t\t</msDesc>\n'
		if len(wit_id) > 0:
			r += '<listWit>\n'
			for k, v in sorted(wit_id.items(), key=lambda a: a[1]):
				r += '\t\t<witness xml:id="{}">{}</witness>\n'.format(v, k)
			r += '\t</listWit>\n\t'
		r += node.end_tag()
		return r

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
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			for k, v in sorted(resp_id.items(), key=lambda a: a[1]):
				r += '\n\t\t<respStmt xml:id="{}"><resp>corrections</resp><name>{}</name></respStmt>'.format(v, k)
		elif tag=='encodingDesc':
			node = MyNode(e)
			r = node.open_tag() + self.traverse(e, mode)
			r += '<charDecl></charDecl>'
			r += node.end_tag()
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
					if get_unicode_ver(this_code) <= "2.0" :
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
		elif tag=='sourceDesc':
			r = self.handle_sourcedesc(e, mode)
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
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
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
			self.write_log(node.open_tag())
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
			if k=='cert':
				if self.tag in ('foreign'):
					k = 'cb:' + k
			elif k=='id':
				k = 'xml:id'
			elif k=='lang':
				k = 'xml:lang'
			elif k=='place':
				if self.tag in ('entry', 'foreign', 'lg'):
					k = 'cb:place'
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
			r += '<head>正史佛教資料類编 校註</head>\n'
		elif k=='ihp':
			r += '<cb:div type="ihp-notes">\n'
			r += '<head>中央研究院歷史語言研究所 校註</head>\n'
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
	global globals, x2r
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
		phase1(vol,p)
		
	# phase- 2 #################################
	
	print(vol, 'phase-2')
	my_mkdir(OUT_P5+'/'+coll)
	my_mkdir(OUT_P5+'/'+coll+'/'+vol)
	for p in glob.iglob(PHASE1DIR+'/'+coll+'/'+vol+'/*.xml'): 
		phase2(vol,p)
	
	# 驗證 #################################
	
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
		if coll in ('.git', 'schema', '.gitignore'): continue
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
#parser.add_option('-g', dest='gaiji_txt', help='use gaiji-m_u8.txt e.g. -g txt (default use gaiji-m.mdb)')
(options, args) = parser.parse_args()

if options.collection is not None:
	options.collection = options.collection.upper()
if options.vol_start is not None:
	options.vol_start = options.vol_start.upper()

# 讀取設定檔 cbwork_bin.ini
config = configparser.SafeConfigParser()
config.read('../cbwork_bin.ini')
CBTEMP = config.get('default', 'temp')
cbwork_dir = config.get('default', 'cbwork')
JING = config.get('default', 'jing.jar_file')
gaijiMdb = config.get('default', 'gaiji-m.mdb_file')

IN_P5a = cbwork_dir + '/xml-p5a' 		# XML P5a 來源資料夾
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