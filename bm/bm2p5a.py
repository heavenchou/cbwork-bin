﻿# -*- coding: utf-8 *-*
'''
功能: CBETA BM-UTF8 (簡單標記版) 轉為 XML-P5-UTF8
設定檔: ../cbwork_bin.ini
命令列參數:
	bm2p5a.py -h 可以看參數說明
需求: Python 3, PythonWin
作者: 周邦信 2009.06.02-2011.8.4
$Revision: 1.7 $
$Date: 2013/04/23 19:42:06 $

Heaven 修改:
2022/03/29 處理 <p_c> , <p_r>, 加上 rend="text-center" , rend="text-right"
2021/12/08 太虛大師全書 TX 的校註採用特殊格式 <note ... rend="hide">....</note>
2021/12/07 太虛大師全書 TX 的校註採用特殊格式 <rdg resp="CBETA" type="cbetaRemark">....</rdg>
2021/07/19 新增支援太虛大師全書 TX。
2020/12/22 支援斜體<it>、粗體<bold>及楷<kai>、明<ming>、宋<song>、黑體<hei>標記。
2020/12/08 <sub>, <sup> 標記要由 rend 改成 style。
2020/09/06 改用新的偈頌規則，支援 caesura。
2020/06/05 修訂中若沒有文字，則在註解中要使用〔－〕來表示。
2020/06/01 處理作譯者全型空格變成半型的問題。
2020/06/01 處理 ZW10 一些標記巢狀問題。
2020/05/28 支援經號第一個字可以是英文的狀況，主要是在序、跋、書前語等資料也加入經文中。
2020/03/07 修改缺字產生重複 CB 的問題
2019/12/26 若某行 <B>....</Q> , </Q> 標記要先結束 byline
2019/12/24 規範符號[A=B]由 <choice><reg><orig> 格式改成 <note><app><lem><rdg> 格式
2019/09/12 配合 XML 檔頭大改版, 修改檔頭呈現的格式.
2019/08/31 1.修訂符號[A>B]由 <choice><corr><sic> 格式改成 <note><app><lem><rdg> 格式
           2.調整 XML 檔首的資訊
2019/08/29 加入LC【呂澂】相關訊息
2018/08/18 1.XML 大改版, 原本許多 rend 的屬性分布到 style 和其他, 同時修改 rend 規範
           2.缺字由 Access 資料庫改成 csv 格式的缺字資料檔案
2018/07/24 新增 <border>..</border> 轉成 <seg rend="border">..</seg>
2018/07/21 版本加上 HM，惠敏法師著作集
2017/05/01 支援 <Q3=> 這類標記, 表示延續上一行的 <Q3> 標記
2016/12/04 支援印順法師佛學著作集新增的 : 規範字詞 [A=B], 行首頁碼有英文字母 _pa001
2016/04/15 <Ix> 及 <L_sp> 標記要結束 head 標記，<[ABCEY]> byline 標記要結束 p 標記.
2016/04/14 上一版只修正這種情況 W##<Qn>，這一版修正 WQn 這種行首標記的情況。
2016/04/12 附文底下的目錄 type 要用 "附文" 而不是 "其他"
2016/04/11 取消 <Qx m=> 及 <h m=> 造成的空目錄, 也就是取消 2015/11/27 所做的修改.
2016/04/07 <cb:juan> 的卷數若沒有資料, 就預設加 1
2016/04/07 修改 </L> 沒有取消前一組 <L_SP> 的問題
2016/03/31 新增 GA, GB 二種經文代碼，支援法鼓山做的佛寺志，修訂一律預設為 <choice cb:resp="DILA">
           如果 BM 的修訂是 [Ａ>Ｂ]<resp="XXX">，則 p5a 變成 <choice cb:resp="XXX"><corr>Ｂ</corr><sic>Ａ</sic></choice>
2016/02/23 處理在表格的 cell 中也會有 <p> 的情況
2015/12/31 第一個 <n> 標記, 要加上 <cb:div type="note"> ,直到 </n> 才結束 </cb:div>
2015/12/30 遇到 <L_sp> , 則底下所有的 <I> 都要處理成 <list rendition="simple">, 而不是只有第一層處理.
2015/12/29 修改 <no_chg> 的處理順序
2015/12/25 如果 W## 接著 <Q , 也不用執行 start_div, 因為 <Q 會執行
2015/11/27 1.處理 <Qn m=> 這種空標記, 轉出正確的空目錄 <cb:mulu type="其他" level="n"/> (同時, <hn m=> 比照辦理, 同時 <hn m=xxxx> 的 xxx 也要處理組字式)
           2.處理空目錄, 一律轉成單一標記 <cb:mulu type="其他" level="n"/>
2015/11/27 處理 <n><d></n> 標記
2015/11/24 因為標題也可能有組字式, 所以 <Q m=xxxx> 的 xxx 也要處理組字式
2015/11/20 <annals> 裡面也可能沒有 <event> , 所以 <annals> 也要結束 <date>
2015/11/03 修改雙行標題在附文中會造成標題無法接成一行的問題
2015/10/08 把 <list rend="simple"> 改成 <list rendition="simple">
2015/09/04 <Q> 標記要先結束 <form> 標記 (因為有些 e 標記不一定有 d 標記來結束 <form> , ex:B19n0103_p0049a08)
2015/09/02 <Q> 標記要先結束 e 及 d 標記 (<entry> 及 <cb:def>)
2015/06/24 <table> 標記要先結束 <byline> 標記
2015/06/23 1. <p> 標記要先結束 <byline> 標記
           2. 處理行首 J= 的標記
2015/06/12 <p> 標記支援小數點, 例如 <p,1,-1.5>
2015/06/12 處理 <L_sp> 標記, 呈現 <list rend="simple">
2015/05/19 增加行首有誤的判斷
2015/05/18 處理 <annals><date><event> 標記
2015/04/29 處理 <e><d></e> 標記
2015/03/18 處理 Z 行首標記
2015/03/10 處理 <no_chg> 標記
2015/03/08 1. 行首標記 j 要結束 <p> 標記 (<j> 已經有處理這部份了)
           2. <S> 標記處理不夠完整, 同時處理偈頌末有 </Qn> 標記的情況
           3. <T> 在非行首時, 在 xml:id 要記錄字數，以及加上 cb:place="inline" 屬性
2015/02/13 處理 <S> 標記
2014/12/27 處理 formula 標記, 它和 sub, sup 是一組的.
2014/12/25 處理 <sub> 及 <sup> 標記
2014/12/04 處理<Ixx>標記中, 數字xx超過一位數的情況
2014/11/27 處理行首標記有 S 及 s 的情況
2014/07/09 1. byline 要結束 head
           2. <u> 要結束 byline
           3. <o> 與 <u> 要結束 head
           4. 沒資料的 <corr></corr> 及 <sic></sic> 要在中間加入 <space quantity="0"/>
           5. <mj> 要結尾卷尾卷名的 <cb:jhead> 與 <cb:juan>
2014/07/04 處理行首資訊中的 r 標記 => <p xml:id="xxx" cb:type="pre">
2014/07/03 悉曇字 &SD-CFC5; 要變成 <g ref="#SD-CFC5"/> 這種格式
2014/06/27 1.處理 <z> 標記
           2.處理 <sd> 標記
2014/06/17 原西蓮代碼 "SL" 改成 智諭 "ZY", 取消西蓮專用目錄
2014/06/10 譯者要結束 </p> 標記
2014/06/06 經末也要考慮結束 </cb:jhead> 標記
2014/06/05 <J> 標記要結束 <p> 標記
2014/06/05 處理 BM 的表格標記, 也就是行首的 F, f 及行中的 <c> 標記
2014/05/29 處理 BM 的 <A>, <B>, <C>, <E>, <Y> 標記
2014/05/27 <cb:mulu type="卷" n="{}"/> 原本在 <J> 或 Ｊ 卷標記處理, 只有南傳因為無 <J> 所以在 <mj> 標記處理 , 後來全部在 <mj> 處理, 因為西蓮有些也沒有 <J> 標記.
2014/05/26 處理 BM 的 </p> 及 </P> 標記要結束 <p> 標記
2014/05/16 1.處理<Q>標記要結束<w><a>標記. 2.處理 <o><u> 標記的結束問題
2014/05/14 昨天 BM 的 <w>, <a> 標記誤處理成 P4 版本的標記, 應該成 P5a 的版本.
2014/05/13 處理 BM 的 <w>, <a> 標記
2014/02/12 行中段落由 <p cb:type="inline"> 改成 <p rend="inline"> 或 <p rend="margin-left:xem;text-indent:xem;inline">
2013/12/31 處理 <T,-x> 沒有處理負數的問題. 
2013/11/25 處理 <I> 標記
2013/11/15 新增 <h1> (<hx>) 的處理, 類似 <Q1> 但只有 mulu 及 head , 沒有 div 
2013/11/06 處理 <p,3,-2> 這類標記也支援負數
2013/11/01 處理 <J> 標記
2013/10/28 處理行首標記 Y 及處理 </o> 標記
2013/09/30 卷的結尾要考慮是否加上 </l>, </lg>
2013/09/24 把 & 換成 &amp;
2013/09/11 處理 <p=h1> 這種格式
2013/08/29 處理藏西蓮淨苑的 "引文" 標記 <quote ...>...</quote>
2013/08/26 處理藏經代碼為二位數的情況, 例如西蓮淨苑的 'SL'
2013/07/20 處理修訂格式中包含組字式、校勘數字的問題, 以及一些小問題.
2013/06/27 1.<T,y> 格式改成 <T,x,y> , 與 <p,x,y> 同步. 
           2.若遇到 <p>, <Q> P, Q 自動結束偈頌, 不一定要用 </T>
2013/06/24 BM 版經文最後的空白行也要轉出 XML 來
2013/06/19 修改漢譯南傳大藏經的中英文
2013/06/09 將設定檔改為 ../cbwork_bin.ini
'''

import collections, configparser, datetime, os, re, struct, sys, csv
from optparse import OptionParser
#import win32com.client # 要安裝 PythonWin

wits={
'A': '【金藏】',
'B': '【補編】',
'C': '【中華】',
'D': '【國圖】',
'DA': '【道安】',
'F': '【房山】',
'G': '【佛教】',
'GA': '【志彙】',
'GB': '【志叢】',
'HM': '【惠敏】',
'I': '【佛拓】',
'J': '【嘉興】',
'K': '【麗】',
'L': '【龍】',
'LC': '【呂澂】',
'M': '【卍正】',
'N': '【南傳】',
'P': '【北藏】',
'Q': '【磧砂】',
'S': '【宋遺】',
'T': '【大】', 
'TX': '【太虛】', 
'U': '【洪武】',
'X': '【卍續】', 
'Y': '【印順】', 
'ZS': '【正史】',
'ZW': '【藏外】',
'ZY': '【智諭】',
}

collectionZh={
'B': '大藏經補編',
'DA': '道安法師著作全集',
'GA': '中國佛寺史志彙刊',
'GB': '中國佛寺志叢刊',
'HM': '惠敏法師著作集',
'LC': '呂澂佛學著作集',
'N': '漢譯南傳大藏經（元亨寺版）',
'TX': '太虛大師全書',
'Y': '印順法師佛學著作集',
'ZS': '正史佛教資料類編',
'ZW': '藏外佛教文獻',
'ZY': '智諭法師著作全集'
}

collectionEng={
'A': 'Jin Edition of the Canon',
'B': 'Supplement to the Dazangjing',
'C': 'Zhonghua Canon - Zhonghua shuju Edition',
'D': 'Selections from the Taipei National Central Library Buddhist Rare Book Collection',
'DA': 'the Complete Works of Ven Daoan',
'F': 'Fangshan shijing',
'G': 'Fojiao Canon',
'GA': 'Zhongguo Fosi Shizhi Huikan',
'GB': 'Zhongguo fosizhi congkan',
'HM': 'the Complete Works of Ven Huimin',
'I': 'Selections of Buddhist Stone Rubbings from the Northern Dynasties',
'J': 'Jiaxing Canon (Shinwenfeng Edition)',
'K': 'Tripiṭaka Koreana (Shinwenfeng Edition)',
'L': 'Qianlong Edition of the Canon (Shinwenfeng Edition)',
'LC': 'Corpus of Lü Cheng\'s Buddhist Studies',
'M': 'Manji Daizōkyō (Shinwenfeng Edition)',
'N': 'Chinese Translation of the Pāḷi Tipiṭaka (Yuan Heng Temple Edition)',
'P': 'Northern Yongle Edition of the Canon',
'Q': 'Qisha Edition of the Canon (Shinwenfeng Edition)',
'R': 'Manji Zokuzōkyō (Shinwenfeng Edition)',
'S': 'Songzang yizhen (Shinwenfeng Edition)',
'T': 'Taishō Tripiṭaka',
'TX': 'Corpus of Venerable Tai Xu\'s Buddhist Studies',
'U': 'Southern Hongwu Edition of the Canon',
'X': 'Manji Shinsan Dainihon Zokuzōkyō',
'Y': 'Corpus of Venerable Yin Shun\'s Buddhist Studies',
'Z': 'Manji Dainihon Zokuzōkyō',
'ZS': 'Passages concerning Buddhism from the Official Histories',
'ZW': 'Buddhist Texts not contained in the Tripiṭaka',
'ZY': 'the Complete Works of Ven Zhiyu'
}

'''
##########################################
心得

buf1 是全部資料暫存變數
buf 是給 <pb><lb> 等儲存變數

因為有時在行首資訊之後, 才出現 BM 版的 Ｐ 標記, 此時就要在前一行尾端加上 </p> 標記.
因此才要先把行首儲存 buf , 等到遇到 p 標記, 才依次做出如下動作:

1. 將 </p> 加到 buf1 中, 但不處理 buf 中的 <lb> 等標記 (使用 out1() )
2. 將 <p> 加到 buf1 中, 但先處理 buf 中的 <lb> 等標記 (使用 out() )
3. 這樣就會呈現  </p><lb><p> 的合理順序.

所以 :
經文是交給 out2() 處理, 因為可能有些文字要記錄在 head 中
起始標記才直接給 out(), 因為要先處理 buf 中的 <lb> 標記
需要保留在前一行的結尾標記就由 out1() 處理, 因為它先不會輸出 buf

##########################################
'''

# 先處理 buf , 再處理傳入的資料至 buf1
def out(s):
	global buf
	out1(buf)
	buf = ''
	out1(s)

# 處理傳入的資料至 buf1
def out1(s):
	# global buf1
	# buf1 += s
	global buf11
	buf11.append(s)

# 當 globals['head_start'] 為真時, div_head 及 buf 都要記錄下來
def out2(s):
	global div_head, buf
	if globals['head_start']: 
		div_head += s
		buf += s
	elif s!='': 
		out(s)

def start_i(tag):
	global L_type
	level = 1
	mo = re.search(r'\d+', tag)
	if mo!=None: level = int(mo.group())
	if not 'item' in opens: opens['item'] = 0
	if not 'list' in opens: opens['list'] = 0
	closeTags('cb:jhead', 'cb:juan', 'p')
	close_head()
	while level<opens['list']:
		out1('</item></list>')
		opens['list'] -= 1
		opens['item'] -= 1
	if  level==opens['list']:
		out1('</item>')
		opens['item'] -= 1
	if level>opens['list']:
		record_open('list')
		if L_type == 'simple':
			out('<list rend="no-marker">')
		else:
			out('<list>')
	s = '<item xml:id="item{}p{}{}{:02d}">'.format(vol, old_pb, line_num, char_count)
	out(s)
	opens['item'] += 1

# 處理 PTS 標記 BM版:<PTS.Vin.1.101> => XML:<ref cRef="PTS.Vin.1.101"/>
def start_PTS(tag):
	global buf
	mo = re.search(r'<(PTS.*?)>', tag)
	s = '<ref cRef="%s"/>' % mo.groups()
	buf += s 
	
	''' 
	##################################################################
	不可用 out(s) , 也不可用 out1(s), 說明如下:
	
	out(s) 會先印出 buf 中的 <lb> 等標記, 會有如下結果
	<lb ed="N" n="0009a06"/>久住，拘樓孫佛、拘那含牟尼佛、迦葉佛之梵行久住也。」
	<lb ed="N" n="0009a07"/><ref cRef="PTS.Vin.8.8"/></p></cb:div><cb:div type="other">
	
	out1(s) 直接加入 buf1 中, 會有如下結果
	<lb ed="N" n="0009a06"/>久住，拘樓孫佛、拘那含牟尼佛、迦葉佛之梵行久住也。」<ref cRef="PTS.Vin.8.8"/></p></cb:div>
	<lb ed="N" n="0009a07"/><cb:div type="other">（二）
	##################################################################
	'''

# BM 版 : <trans-mark,a'> => XML P5 版 : <label type="translation-mark">a'</label>
def start_trans_mark(tag):
	global buf
	mo = re.search(r'<trans-mark,(.*?)>', tag)
	s = '<label type="translation-mark">%s</label>' % mo.groups()
	out(s)

def start_p(tag):
	closeTags('seg', 'cb:jhead', 'cb:juan', 'p', 'byline', 'head')
	closeTags('l', 'lg')
	r = get_number(tag)
	out('<p xml:id="p%sp%s%s01"' % (vol, old_pb, line_num))
	if 'r' in head_tag:
		out(' cb:type="pre"')
	if 'Z' in head_tag:
		out(' cb:type="dharani"')
	if r!='':
		out(' style="margin-left:%sem"' % r)
	out('>')
	opens['p']=1

def start_inline_p(tag):
	closeTags('seg', 'cb:jhead', 'cb:juan', 'p', 'byline')
	close_head()
	closeTags('l', 'lg')
	s = '<p xml:id="p%sp%s%s%02d"' % (vol, old_pb, line_num, char_count)
	
	# 如果 tag 是 <z 開頭的, 就要變成
	#<p xml:id="pxxxxxxxx" cb:type="dharani"
	mo = re.search(r'<z', tag)
	if mo!=None:
		s += ' cb:type="dharani"'
	
	# 處理 <p,1,2> 這種格式
	mo = re.search(r'<[pz],(\-?[\d\.]+),(\-?[\d\.]+)>', tag)
	if mo!=None:
		s += ' style="margin-left:%sem;text-indent:%sem"' % mo.groups()
		#if char_count>1: s += ';inline'		# 若是行中段落, 則加上 inline
		#s += '"'
	
	# 處理 <p,1> 這種格式
	mo = re.search(r'<[pz],(\-?[\d\.]+)>', tag)
	if mo!=None:
		s += ' style="margin-left:%sem"' % mo.group(1)
		#if char_count>1: s += ';inline'		# 若是行中段落, 則加上 inline
		#s += '"'
	
	# 若都沒有 <p,1 這種格式, 又是在行中, 則用 rend="inline"
	#mo = re.search(r'<[pz],(\-?[\d\.]+)', tag)
	#if mo==None:
	#	if char_count>1: s += ' rend="inline"'
	
	if char_count>1: s += ' cb:place="inline"'

	
	# 處理 <p=h1> 這種格式	- 2013/09/11
	mo = re.search(r'<p=h(\d+)>', tag)
	if mo!=None:
		s += ' cb:type="head{}"'.format(mo.group(1))

	# 處理 <p_c> , <p_r> - 2022-03-29
	
	mo = re.search(r'<[pz]_c', tag)
	if mo!=None:
		s += ' rend="text-center"'
	mo = re.search(r'<[pz]_r', tag)
	if mo!=None:
		s += ' rend="text-right"'

	s += '>'
	out(s)
	opens['p']=1
	
def start_div(level, type):
	closeTags('byline', 'p', 'cb:jhead', 'cb:juan')
	close_div(level)
	closeTags('l', 'lg')
	opens['div'] = level
	if type=='other' and 'W' in head_tag:
		out('<cb:div type="w">')
	else:
		out('<cb:div type="%s">' % type)
	
def start_inline_q(tag):
	if(re.search("<Q\d?=",tag)):	# <Q3=> 這一種的表示是延續上一行的 <Q3>
		return
	global buf, div_head, head_tag, globals
	close_head()
	closeTags('l', 'lg', 'p', 'sp', 'cb:dialog', 'cb:event', 'form', 'cb:def', 'entry')
	i=tag.find('m=')
	div_head = ''
	level = 0
	
	mo=re.match('<Q(\d+)', tag)
	level=int(mo.group(1))
	
	start_div(level, 'other')

	mo=re.search('m=(.*?)>', tag)
	if mo is None:
		label = ''
		globals['mulu_start'] = True
		if 'W' in head_tag:
			globals['muluType']='附文'
		else:
			globals['muluType']='其他'
	else:
		label=mo.group(1)

		# 標題也可能會有組字式
		mo2=re.search(r'(\[[^>\[ ]+?\])', label)
		while mo2 is not None:
			des = mo2.group(1)
			des2 = gaiji(des)
			label = label.replace(des,des2)
			mo2=re.search(r'(\[[^>\[ ]+?\])', label)
		
		if label != '':
			if 'W' in head_tag:
				out('<cb:mulu type="附文" level="%d">%s</cb:mulu>' % (level, label))			
			else:
				out('<cb:mulu type="其他" level="%d">%s</cb:mulu>' % (level, label))
		# 取消 cb:mulu 的空標記 2016/04/11	
		# else:
		# 	out('<cb:mulu type="其他" level="%d"/>' % (level))
		globals['mulu_start'] = False
	globals['head_start'] = True
	buf += '<head>'
	opens['head'] = 1

# 2013/11/15 新增
def start_inline_h(tag):
	global buf, div_head, head_tag, globals
	close_head()
	closeTags('l', 'lg')
	i=tag.find('m=')
	div_head = ''
	level = 0
	
	mo=re.match('<h(\d+)', tag)
	level=int(mo.group(1))
	
	#start_div(level, 'other')
	closeTags('byline', 'p', 'cb:jhead', 'cb:juan')	# 因為沒有 start_div , 所以要自己執行這一行
	
	mo=re.search('m=(.*?)>', tag)
	if mo is None:
		out('')					# 因為沒有 start_div , 所以要自己執行這一行
		label = ''
		globals['mulu_start'] = True
		if 'W' in head_tag:
			globals['muluType']='附文'
		else:
			globals['muluType']='其他'
	else:
		label=mo.group(1)
		
		# 標題也可能會有組字式
		mo2=re.search(r'(\[[^>\[ ]+?\])', label)
		while mo2 is not None:
			des = mo2.group(1)
			des2 = gaiji(des)
			label = label.replace(des,des2)
			mo2=re.search(r'(\[[^>\[ ]+?\])', label)
		
		if label != '':
			if 'W' in head_tag:
				out('<cb:mulu type="附文" level="%d">%s</cb:mulu>' % (level, label))			
			else:
				out('<cb:mulu type="其他" level="%d">%s</cb:mulu>' % (level, label))			
		# 取消 cb:mulu 的空標記 2016/04/11
		# else:
		#	out('<cb:mulu type="其他" level="%d"/>' % (level))
		globals['mulu_start'] = False
	globals['head_start'] = True
	buf += '<head>'
	opens['head'] = 1

def close_div(level):
	while opens['div'] >= level:
		out1('</cb:div>')
		opens['div'] -= 1

def start_q(tag):
	global buf, current_div_level, div_head, globals
	
	if '=' in head_tag:
		return
	
	closeTags('l', 'lg', 'sp', 'cb:dialog', 'form', 'cb:def', 'entry')
	div_head = ''
	level = 0
	
	mo = re.search(r'\d+', tag)
	if mo!=None:
		level = int(mo.group())
		
	globals['mulu_start'] = True
	globals['head_start'] = True
	
	if 'W' in head_tag:
		globals['muluType']='附文'
		start_div(level, 'w')
	else:
		globals['muluType']='其他'
		start_div(level, 'other')

	buf += '<head>'
	opens['head'] = 1

# 悉曇字或蘭札字
# &SD-CFC5; => <g ref="#SD-CFC5"/>
def start_inline_SDRJ(tag):
	global char_count
	mo = re.search(r'&(((SD)|(RJ))\-\w{4});', tag)
	if mo!=None:
		out2('<g ref="#{}"/>'.format(mo.group(1)))
		char_count+=1

######################################################
# P5a 的版本在修訂不是傳回 <anchor , 而是直接傳回 <choice
#	globals['backApp'] += s + '\n'
#	r = '<anchor xml:id="{}" type="cb-app"/>'.format(id1)
#	r += mo.group(2)
#	r += '<anchor xml:id="{}"/>'.format(id2)
#	return r
######################################################

# 計算經文的長度
def myLength(s):
	len = 0
	#s = re.sub(r'\[[^>\]]*?>(.*?)\]', r'\1', s)
	#s = re.sub(r'\[[^>\]]*?\]', '缺', s) # 將組字式取代為單個字
	for c in s:
		if c in '◎。，、；：「」『』（）？！—…《》〈〉．“”　〔〕【】()': continue
		len += 1
	return len

# 表格中的 cell , 有這些形式
# <c> => <cell>
# <c3> => <cell cols="3">
# <c r3> => <cell rows="3">
# <c3 r3> => <cell cols="3" rows="3">
def start_inline_c(tag):
	closeTags('p', 'cell')
	# 檢查有沒有 c3 這種格式
	cols = ''
	mo = re.search(r'c(\d+)', tag)
	if mo!=None:
		cols = mo.group(1)
	# 檢查有沒有 r3 這種格式
	rows = ''
	mo = re.search(r'r(\d+)', tag)
	if mo!=None:
		rows = mo.group(1)
	out('<cell')
	if cols != '': out(' cols="{}"'.format(cols))
	if rows != '': out(' rows="{}"'.format(rows))
	out('>')
	record_open('cell')

def start_inline_d(tag):
	closeTags('form')
	out('<cb:def>')
	record_open('cb:def')
	
def start_inline_e(tag):
	close_head()
	closeTags('p', 'cb:def', 'entry')
	out('<entry')
	if char_count>1: out(' cb:place="inline"')		# 若是行中段落, 則加上 inline
	out('><form>')
	record_open('entry')
	record_open('form')

def close_annals(tag):
	closeTags('p', 'cb:event')
	
def close_e(tag):
	closeTags('p', 'cb:def', 'entry')

def close_F(tag):
	closeTags('p', 'cell', 'row', 'table')

def close_q(tag):
	closeTags('byline', 'cb:jhead', 'cb:juan', 'p')
	close_head()
	level = int(tag[3:-1])
	close_div(level)

# 2013/11/15 新增
def close_h(tag):
	closeTags('cb:jhead', 'cb:juan', 'p')
	close_head()
	#level = int(tag[3:-1])
	#close_div(level)

def start_inline_Lsp(tag):
	global L_type
	close_head()
	L_type = 'simple'

def start_inline_n(tag):
	global div_type_note
	closeTags('p', 'cb:def', 'entry')
	
	# 第一個 n 要加上 <cb:div type="note"><entry><form>...</form><cb:def>...</cb:def>...</div>
	if div_type_note == 0:
		start_div(opens['div']+1, 'note')
		div_type_note = 1
		
	out('<entry')
	if char_count>1: out(' cb:place="inline"')		# 若是行中段落, 則加上 inline
	out('><form>')
	record_open('entry')
	record_open('form')

def close_n(tag):
	global div_type_note
	closeTags('p', 'cb:def', 'entry')
	close_div(opens['div'])
	div_type_note = 0

def start_inline_o(tag):
	closeTags('p')
	close_head()
	if 'commentary' in opens and opens['commentary']>0:
		out1('</cb:div>')
		opens['div'] -= 1
		opens['commentary'] -= 1
	start_div(opens['div']+1, 'orig')
	opens['orig'] = 1

def start_inline_S(tag):
	global globals
	if not 'lg' in opens: opens['lg'] = 0
	if not 'lg_marginleft' in globals: globals['lg_marginleft'] = 0
	if not 'normal_lg' in globals: globals['normal_lg'] = True
	
	if opens['lg'] == 1:
		closeTags('l','lg')
	if opens['lg'] == 0:
		closeTags('cb:jhead', 'cb:juan', 'byline', 'p')
		close_head()
		opens['lg'] = 1
	globals['lg_marginleft'] = 1
	mo = re.search(r'<S,?(\d*),?(\-?\d*),?(\d*)>', tag)
	if mo!=None:
		globals['normal_lg'] = True
		# <lg xml:id="..."
		out('<lg xml:id="lg%sp%s%s%02d"' % (vol, old_pb, line_num, char_count))
		# style="..."
		if(mo.group(1) != '' and mo.group(1) != '1') or (mo.group(2) != '' and mo.group(2) != '0'):
			out(' style="')
			if mo.group(1) != '' and mo.group(1) != '1':
				out('margin-left:%sem;' % mo.group(1))
				globals['lg_marginleft'] = int(mo.group(1))
			if mo.group(2) != '' and mo.group(2) != '0':
				out('text-indent:%sem;' % mo.group(2))
			out('"')
		# cb:place="..."
		if char_count>1: out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
		out('>')

		# <l style="...">'
		if mo.group(3) != '' and mo.group(3) != '0':
			out('<l style="text-indent:%sem;">' % mo.group(3))
		else:
			out('<l>')
		record_open('l')
		globals['lg_space_count'] = 1
	else:
		out('<err S 標記不合法 %s>' % tag)
		print('錯誤 : S 標記不合法 %s' % tag)

# 處理空白, 主要是針對偈頌的空白
# 行首空白換成 <l>, 要考慮偈頌的 left-margin
# 行中空白換成 <caesura>
def start_inline_space(tag):
	global globals
	if tag == '<nosp>':	space_length = 0
	else: space_length = len(tag)

	# 在 lg 中才要處理
	if opens['lg'] == 1:
		if globals['lg_space_count'] == 0:
			# 第一個空白要處理成 <l>
			s = space_length - int(globals['lg_marginleft'])
			if s == 0:
				# l 空白和 lg 的移位相同, 就用 <l> 即可
				out('<l>')
			elif s > 0:
				out('<l style="text-indent:%sem">' % s)
			else:
				# 錯誤, s 不可以為負
				out('<err 有負數的 text-indent:%sem:%s>' % (s, tag))
				print('錯誤 : 算出負數的 text-indent:%s:%s:' % (s, tag))
			record_open('l')
			globals['lg_space_count'] += 1
		else:
			# 其他空白要處理成 <casesura>
			if space_length == 2:
				out('<caesura/>')
			else:
				out('<caesura style="text-indent:%sem;"/>' % space_length)
	else:
		# 非偈頌空白就交給 do_chars
		do_chars(tag)

def start_inline_T(tag):
	global globals, opens
	if not 'lg' in opens: opens['lg'] = 0
	if not 'TL_count' in globals: globals['TL_count'] = 0
	if not 'lg_marginleft' in globals: globals['lg_marginleft'] = 0

	if opens['lg']==0:
		closeTags('cb:jhead', 'cb:juan', 'byline', 'p')
		close_head()

	moTL = re.search(r'<TL,?(\d*),?(\-?\d*),?(\d*)>', tag)
	moT = re.search(r'<T,?(\d*)>', tag)
	
	if moTL!=None:
		if globals['TL_count'] == 0:
			# 第一個 TL
				
			# <lg xml:id="..."
			out('<lg xml:id="lg%sp%s%s%02d"' % (vol, old_pb, line_num, char_count))
			# style="..."
			if(moTL.group(1) != '' and moTL.group(1) != '1') or (moTL.group(2) != '' and moTL.group(2) != '0'):
				out(' style="')
				if moTL.group(1) != '' and moTL.group(1) != '1':
					out('margin-left:%sem;' % moTL.group(1))
					globals['lg_marginleft'] = moTL.group(1)
				if moTL.group(2) != '' and moTL.group(2) != '0':
					out('text-indent:%sem;' % moTL.group(2))
				out('"')
			# cb:place="..."
			if char_count>1: out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
			out('>')

			# <l style="...">'
			if moTL.group(3) != '' and moTL.group(3) != '0':
				out('<l style="text-indent:%sem;">' % moTL.group(3))
			else:
				out('<l>')
			opens['lg'] = 1
			record_open('l')
			globals['TL_count'] += 1
		else:
			# 第二個 TL
			closeTags('l')
			# <l style="...">'
			if moTL.group(1) != '' and moTL.group(1) != '0':
				out('<l style="text-indent:%sem;">' % moTL.group(1))
			else:
				out('<l>')
			record_open('l')
	elif moT!=None:
		# <T,x>
		# <caesura style="..."/>'
		if moT.group(1) == '':
			out('<caesura style="text-indent:0em;"/>')
		elif moT.group(1) == '2':
			out('<caesura/>')
		else:
			out('<caesura style="text-indent:%sem;"/>' % moT.group(1))
	else:
		out('<err T 標記不合法 %s>' % tag)
		print('錯誤 : T 標記不合法 %s' % tag)

def start_inline_T_old(tag):
	if not 'lg' in opens: opens['lg'] = 0
	if opens['lg']==0:
		closeTags('cb:jhead', 'cb:juan', 'byline', 'p')
		close_head()
		out('<lg xml:id="lg%sp%s%s%02d" type="abnormal"' % (vol, old_pb, line_num, char_count))
		if char_count>1: out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
		out('>')
		opens['lg'] = 1
	closeTags('l')
	mo = re.search(r'<T,(\-?[\d\.]+),(\-?[\d\.]+)>', tag)
	if mo!=None:
		if(mo.group(1) == '0'):
			out('<l style="text-indent:%sem">' % mo.group(2))
		elif(mo.group(2) == '0'):
			out('<l style="margin-left:%sem">' % mo.group(1))
		else:
			out('<l style="margin-left:%sem;text-indent:%sem">' % mo.groups())
	else:
		mo = re.search(r'\-?[\d\.]+', tag)
		if mo!=None:
			out('<l style="margin-left:%sem">' % mo.group())
	record_open('l')

def start_inline_u(tag):
	closeTags('byline', 'p')
	close_head()
	if 'orig' in opens and opens['orig']>0:
		out1('</cb:div>')
		opens['div'] -= 1
		opens['orig'] -= 1
	start_div(opens['div']+1, 'commentary')
	opens['commentary'] = 1

def start_inline_w(tag):
	closeTags('p','sp','cb:dialog')
	out('<cb:dialog type="qa"><sp cb:type="question">')
	opens['cb:dialog'] = 1
	opens['sp'] = 1
	
def start_inline_a(tag):
	closeTags('p','sp')
	out('<sp cb:type="answer">')
	opens['sp'] = 1

# 處理經文中的標記
def inline_tag(tag):
	global char_count, buf, L_type, globals
	#print(tag, sep=' ', end='')
	if re.match(r'<\[(([\da-zA-Z]{2,3})|＊)\]>', tag):	# 在 do_corr_normalize 處理過的校勘數字 , 原來為 <[01]> , 要直接處理成 [01]
		out(tag[1:-1])
	elif re.match(r'\[([\da-zA-Z]+?)\]', tag):	# 處理校勘數字
		out('<anchor xml:id="fn%sp%s%s"/>' % (vol, old_pb, tag[1:-1]))
	elif re.match(r'\[[^>\[ ]+?\]', tag):		# 處理組字式
		char_count+=1
		out2(gaiji(tag))
	elif tag=='<□>':							# 未知字
		out('<unclear/>')
	elif tag=='(':
		out2('<note place="inline">')
		
	# J01nA042_p0793a14_##<Q2 m=哲宗><annals><date><p>哲宗皇帝元祐四年[已>己]巳
	# J01nA042_p0793a15_##<event><p,1>師宣州寧國縣人也姓奚氏其母初夢神人衛一
	# ... </annals>
	# 還有 <Q> <annals> 也可以結束 <annals>
	# <event> 是用來結束 <date> 的
	# 轉成
	# <cb:event><date>ＸＸＸ</date><p,1>ＹＹＹ</p></cb:event>
	elif tag=='<annals>':
		start_inline_annals(tag)
	elif tag=='</annals>':
		close_annals(tag)
	elif tag.startswith('<app'):
		out(tag)
	elif tag=='</app>':
		out(tag)
	elif re.match(r'<[ABCEY]>', tag):
		start_inline_byline(tag)
	elif tag=='<bold>':
		out('<seg rend="bold">')
	elif tag=='</bold>':
		out('</seg>')	
	elif tag=='<border>':
		out('<seg rend="border">')
	elif tag=='</border>':
		out('</seg>')
	elif re.match(r'<c[\d\s>]', tag):
		start_inline_c(tag)
	elif tag=='<corr>':
		out(tag)
	elif tag=='</corr>':
		out(tag)
	#以下這些直接輸出 <choice cb:resp="CBETA.maha"><corr>Ｂ</corr><sic>Ａ</sic></choice>
	elif tag.startswith('<choice'):
		out(tag)
	elif tag=='</choice>':
		out(tag)
	elif tag=='<d>':
		start_inline_d(tag)
	elif tag=='<date>':
		start_inline_date(tag)
	elif tag=='<e>':
		start_inline_e(tag)
	elif tag=='</e>':
		close_e(tag)
	elif tag=='<event>':
		start_inline_event(tag)
	elif tag=='<formula>':
		out('<formula>')
	elif tag=='</formula>':
		out2("</formula>")
	elif tag=='</F>':
		close_F(tag)
	elif tag=='<hei>':
		out('<seg rend="heiti">')
	elif tag=='</hei>':
		out('</seg>')
	elif tag.startswith('<h'):
		start_inline_h(tag)
	elif tag.startswith('</h'):
		close_h(tag)
	elif re.match(r'<I\d*>', tag):
		start_i(tag)
	elif tag=='<i>(':
		out2('<note place="interlinear">')
	elif tag==')' or tag==")</i>":
		out2('</note>')
	elif tag=='<it>':
		out('<seg rend="italic">')
	elif tag=='</it>':
		out('</seg>')
	elif tag =='<j>':
		closeTags('p')
		out('<cb:juan fun="close"><cb:jhead>')
		record_open('cb:juan')
		record_open('cb:jhead')
	elif tag.startswith('<J'):
		start_J(tag)
	elif tag=='<kai>':
		out('<seg rend="kaiti">')
	elif tag=='</kai>':
		out('</seg>')
	elif tag=='<L_sp>':
		start_inline_Lsp(tag)		
	elif tag.startswith('<lem'):
		out(tag)
	elif tag=='</lem>':
		out(tag)
	elif tag=='</l>':
		closeTags('l')
	elif tag=='</L>':
		closeTags('p')
		L_type = ""
		while opens['list']>0:
			closeTag('item', 'list')
	elif tag=='<ming>':
		out('<seg rend="mingti">')
	elif tag=='</ming>':
		out('</seg>')
	elif tag.startswith('<mj'):
		closeTags('byline', 'cb:jhead', 'cb:juan')

		#n=get_number(tag)
		mo = re.search(r'\d+', tag)
		if mo!=None: globals['juan_num'] = int(mo.group())
		else: globals['juan_num']+=1
		#out('<milestone unit="juan" n="{}"/>'.format(globals['juan_num']))		# 若用 out() , 會有一堆 </p></cb:div> 標記出現在 <milestone> 後面

		# <milestone> 要移到 <pb><lb> 之前

		mo = re.search(r'(<pb [^>]*>\n?)?<lb [^>]*>\n?$', buf)
		if mo!=None:
			pblb = mo.group()
			buf = re.sub(r'(<pb [^>]*>\n?)?<lb [^>]*>\n?$', r'', buf)
			buf += '<milestone unit="juan" n="{}"/>\n'.format(globals['juan_num'])
			buf += pblb
		else:
			print("milestone must after <pb><lb>")
			print(tag)
			sys.exit()
		# 原本<cb:mulu type="卷" n="{}"/>是在 <J> 或 Ｊ卷標記處理, 只有南傳在 <mj> 處理, 現在全部移到 <mj> 處理, 因為有卷沒有卷標記
		buf += '<cb:mulu type="卷" n="{}"/>'.format(globals['juan_num'])
	elif tag=='<no_chg>':
		out('<term cb:behaviour="no-norm">')
	elif tag=='</no_chg>':
		out('</term>')
	elif tag=='<nosp>':
		start_inline_space(tag)
	elif tag.startswith('　'):
		start_inline_space(tag)
	elif tag.startswith('<note'):
		out(tag)
	elif tag=='</note>':
		out(tag)
	elif tag.startswith('<n'):
		start_inline_n(tag)
	elif tag=='</n>':
		close_n(tag)
	elif tag=='<o>':
		start_inline_o(tag)
	elif tag=='</o>':
		closeTags('byline','p')
		out1('</cb:div>')
		opens['div'] -= 1
		opens['orig'] -= 1
	elif tag=='<orig>':
		out(tag)
	elif tag=='</orig>':
		out(tag)
	elif re.match(r'<PTS.', tag):
		start_PTS(tag)
	elif tag.startswith('<p'):
		start_inline_p(tag)
	elif tag == '</p>':
		closeTags('p')
	elif re.match(r'<quote .*?>', tag):	# 出處連結, 例如 : ZY01n0001_p0020a02_##...佛於經中說，<quote T09n0262_p0007c07-09>舍利弗！汝等當一心...</quote>
		# 要做成 <quote source="CBETA.T09n0262_p0007c07-09">
		mo = re.match(r'<quote (.*?)>', tag)
		out('<quote source="CBETA.{}">'.format(mo.group(1)))
	elif tag == '</quote>':
		out('</quote>')
	elif tag.startswith('<Q'):
		start_inline_q(tag)
	elif tag.startswith('</Q'):
		close_q(tag)
	elif tag.startswith('<rdg'):
		out(tag)
	elif tag=='</rdg>':
		out(tag)
	elif tag=='<reg>':
		out(tag)
	elif tag=='</reg>':
		out(tag)
	elif tag=='<S>':
		start_inline_S(tag)
	elif tag.startswith('<S,'):
		start_inline_S(tag)
	elif tag=='</S>':
		globals['normal_lg'] = False
		closeTags('lg')
	elif tag=='<sd>':
		out('<term xml:lang="sa-Sidd">')
		opens['term'] = 1
	elif tag=='</sd>':
		closeTags('term')
	elif tag=='<song>':
		out('<seg rend="songti">')
	elif tag=='</song>':
		out('</seg>')
	elif tag=='<space quantity="0"/>':
		out2(tag)
	elif tag=='<sub>':
		out('<hi style="vertical-align:sub">')
	elif tag=='</sub>':
		out2("</hi>")
	elif tag=='<sup>':
		out('<hi style="vertical-align:super">')
	elif tag=='</sup>':
		out2("</hi>")
	elif tag=='<sic>':
		out(tag)
	elif tag=='</sic>':
		out(tag)
	elif re.match(r'<trans-mark', tag):
		start_trans_mark(tag)
	elif tag.startswith('<T'):
		start_inline_T(tag)
	elif tag=='</T>' or tag=='</TL>':
		globals['TL_count'] = 0
		closeTags('l', 'lg')
	elif tag=='<u>':
		start_inline_u(tag)
	elif tag=='</u>':
		closeTags('p')
		out1('</cb:div>')
		opens['div'] -= 1
		opens['commentary'] -= 1
	elif tag.startswith('<w>'):
		start_inline_w(tag)
	elif tag.startswith('<a>'):
		start_inline_a(tag)
	elif tag=='</w>':
		closeTags('p','sp','cb:dialog')
	elif tag.startswith('<z'):	# 和 <p 一樣的處理法
		start_inline_p(tag)
	elif tag=='</z>':
		closeTags('p')
	elif re.match(r'&((SD)|(RJ))\-\w{4};', tag):	# 悉曇字或蘭札字
		start_inline_SDRJ(tag)
	elif tag=='&':
		out2("&")
	else:
		print(old_pb+line_num+'未處理的標記: ' + tag)

def gaiji(zuzi):
	print('gaiji()', zuzi, file=log)
	if zuzi=='[＊]': return zuzi
	if re.match(r'\[\d+\]', zuzi): return zuzi
	
	if(zuzi in des2cb):
		return '<g ref="#{}"/>'.format(des2cb[zuzi])
	else:
		print('組字式找不到: ' + zuzi)
		return ''

	''' 不使用 Access 了
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	sql = "SELECT cb, unicode, nor_uni FROM gaiji WHERE des='%s'" % zuzi
	rs.Open(sql, conn, 1, 3)
	if rs.RecordCount > 0:
		cb = rs.Fields.Item('cb').Value
		u = rs.Fields.Item('unicode').Value
		nor_uni = rs.Fields.Item('nor_uni').Value
		if not cb in gaijis:
			gaijis[cb]={}
			gaijis[cb]['des'] = zuzi
		if u is not None and u!='':
			return chr(int(u,16))
		else:
			# here we add an appropriate PUA character to the g element 
			# (strictly speaking, we could then eliminate the g, iff the PUA value is defined in the header) 
			# on the other hand, P5 explicitly says, these PUA chars should be removed for exchange. 
			
			#c=chr(0xF0000+int(cb))
			#return '<g ref="#CB{}">{}</g>'.format(cb, c)	# 不使用 PUA 了, # 也要移除, 因為無此 id
			return '<g ref="#CB{}"/>'.format(cb)
	else:
		print('組字式找不到: ' + zuzi)
		return ''
	'''
		
# 處理經文中的文字
def do_chars(s):
	global buf, char_count, div_head
	#print('char_count:', char_count, file=log)
	#print('chars:', s, file=log)
	char_count += myLength(s)
	out2(s)


'''
先把 [Ａ>Ｂ] 換成
<note n="0001b0201" resp="CBETA.maha" type="add">念【CB】，忘【大】</note>
<app n="0001b0201"><lem wit="【CB】" resp="CBETA">念</lem><rdg wit="【大】">忘</rdg></app>
因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [[金*本]>[口*兄]] , [[01]>]
也把 [Ａ=Ｂ] 換成 
<note n="0002a0201" resp="CBETA" type="add" subtype="規範字詞">系統【CB】，係統【呂澂】</note>
<app n="0002a0201"><lem wit="【CB】" resp="CBETA">系統</lem><rdg wit="【呂澂】">係統</rdg></app>
因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [千[金*本]=千[金*本]經]
'''

def do_corr_normalize(text):
	global ed, old_pb, line_num, wit
	'''
	先把 [xxx] 組字或校勘數字變成 :gaiji1:xxx:gaiji2:
	先把 <xxx> 組字或校勘數字變成 :gaiji3:xxx:gaiji4:

	resp 預設為 CBETA
	如果是佛寺志版本 (ed = GA or GB) 則 resp = "DILA"
	[Ａ>Ｂ]<resp="xxx"> 則 resp = "xxx"

	把[Ａ>Ｂ](<resp="xxx">)?換成 
	
	<note n="...." resp="CBETA" type="add">B【CB】，A【xx】</note>
	<app n="...."><lem wit="【CB】" resp="xxx">B</lem><rdg wit="【xx】">A</rdg></app>

	B【CB】，A【xx】若 A 與 B 是空的，要換成 〔－〕【CB】，〔－〕【xx】

	把[Ａ=Ｂ](<resp="xxx">)?換成 
	
	<note n="...." resp="CBETA" type="add" subtype="規範字詞">B【CB】，A【xx】</note>
	<app n="...."><lem wit="【CB】" resp="xxx">B</lem><rdg wit="【xx】">A</rdg></app>
	
	再把:gaiji1:xxx:gaiji2: 換回 [xxx]

	再把 <lem ..>[01]</lem> 這一類換成 <lem ..><[01]></lem> , 而 <[01]> 之後會換成 [01], 如不這樣處理, [01] 會被變成一般的校勘數字標記, note 和 rdg 比照處理.

	再把:gaiji3:xxx:gaiji4: 換回 <xxx>
	再把 <lem ..></lem> 換成 <lem ..><space quantity="0"/></lem>, <rdg> 比照處理.
	'''
	resp = 'CBETA'
	if(ed == 'GA' or ed == 'GB'): resp = 'DILA'

	# 換掉 []<> 符號
	text = re.sub(r"\[([^>=\[\]]+?)\]", r":gaiji1:\1:gaiji2:", text)
	text = re.sub(r"<([^<>]+?)>", r":gaiji3:\1:gaiji4:", text)

	# 每次處理一個校註
	note_count = 1
	FindCorr = True
	while(FindCorr):
		mo = re.search(r"\[(?:[^\]]*?)([>=])(?:[^\]]*?)\](:gaiji3:resp=\"(.*?)\":gaiji4:)?",text)
		if(mo != None):
			subtype = ""
			if mo.group(3) != None:
				resp = mo.group(2)
			if mo.group(1) == "=":
				subtype = " subtype=\"規範字詞\""
			if ed == 'TX' :
				text = re.sub(r"\[([^\]]*?)(?:[>=])([^\]]*?)\](:gaiji3:resp=\"(.*?)\":gaiji4:)?", r'<note n="{p}{l}{n:02d}" resp="CBETA" type="add"{st} rend="hide">\2【CB】，\1{ed}</note><app n="{p}{l}{n:02d}"><lem wit="{ed}">\1</lem><rdg resp="{r}" type="cbetaRemark">\2</rdg></app>'.format(p=old_pb, l=line_num, st=subtype, ed=wit, r=resp, n=note_count), text, count=1)
			else :
				text = re.sub(r"\[([^\]]*?)(?:[>=])([^\]]*?)\](:gaiji3:resp=\"(.*?)\":gaiji4:)?", r'<note n="{p}{l}{n:02d}" resp="CBETA" type="add"{st}>\2【CB】，\1{ed}</note><app n="{p}{l}{n:02d}"><lem wit="【CB】" resp="{r}">\2</lem><rdg wit="{ed}">\1</rdg></app>'.format(p=old_pb, l=line_num, st=subtype, ed=wit, r=resp, n=note_count), text, count=1)
			note_count = note_count + 1
		else:
			FindCorr = False
	
	# B【CB】，A【xx】若 A 與 B 是空的，要換成 〔－〕【CB】，〔－〕【xx】

	text = re.sub(r"(<note[^>]*>)【CB】", r'\1〔－〕【CB】', text)
	text = re.sub(r"【CB】，(【.*?】)", r'【CB】，〔－〕\1', text)

	# 換回 [] 符號
	text = re.sub(":gaiji1:", "[", text)
	text = re.sub(":gaiji2:", "]", text)
	
	# 校勘數字或星號換成 <[01]> , <[＊]>
	# <note...>[01]【CB】 改成 <note...><[01]>【CB】
	text = re.sub(r"(<note[^>]*>)(\[(([\da-zA-Z]{2,3})|＊)\])【CB】", r'\1<\2>【CB】', text)
	# ，[01]【xx】 改成 ，<[01]>【xx】
	text = re.sub(r"【CB】，(\[(?:(?:[\da-zA-Z]{2,3})|＊)\])(【.*?】)", r'【CB】，<\1>\2', text)
	
	text = re.sub(r"(<lem[^>]*>)(\[(([\da-zA-Z]{2,3})|＊)\])<\/lem>", r'\1<\2></lem>', text)
	text = re.sub(r"(<rdg[^>]*>)(\[(([\da-zA-Z]{2,3})|＊)\])<\/rdg>", r'\1<\2></rdg>', text)
	# 沒文字換成 <space quantity="0"/>
	text = re.sub(r"(<lem[^>]*>)<\/lem>", r'\1<space quantity="0"/></lem>', text)
	text = re.sub(r"(<rdg[^>]*>)<\/rdg>", r'\1<space quantity="0"/></rdg>', text)

	# 換回 <> 符號
	text = re.sub(":gaiji3:", "<", text)
	text = re.sub(":gaiji4:", ">", text)

	return text

'''
先把 [Ａ=Ｂ] 換成 
<note n="0027a1301" resp="CBETA" type="add" subtype="規範字詞">Ｂ【CB】，Ａ【呂澂】</note><app n="0027a1301"><lem wit="【CB】" resp="CBETA">Ｂ</lem><rdg wit="【呂澂】">Ａ</rdg></app>
'''
def do_normalize_new(text):
	'''
	先把 [xxx] 組字或校勘數字變成 :gaiji1:xxx:gaiji2:
	先把 <xxx> 組字或校勘數字變成 :gaiji3:xxx:gaiji4:
	把[Ａ=Ｂ] 換成 
	<note n="0027a1301" resp="CBETA" type="add" subtype="規範字詞">Ｂ【CB】，Ａ【呂澂】</note><app n="0027a1301"><lem wit="【CB】" resp="CBETA">Ｂ</lem><rdg wit="【呂澂】">Ａ</rdg></app>
	再把:gaiji1:xxx:gaiji2: 換回 [xxx]
	再把:gaiji3:xxx:gaiji4: 換回 <xxx>
	'''
	text = re.sub(r"\[([^=>\[\]]+?)\]", r":gaiji1:\1:gaiji2:", text)
	text = re.sub(r"<([^<>]+?)>", r":gaiji3:\1:gaiji4:", text)
	text = re.sub(r"\[([^\]]*?)=([^\]]*?)\]:gaiji3:resp=\"(.*?)\":gaiji4:", r'<choice cb:type="規範字詞" cb:resp="\3"><reg>\2</reg><orig>\1</orig></choice>', text)
	text = re.sub(r"\[([^\]]*?)=([^\]]*?)\]", r'<choice cb:type="規範字詞"><reg>\2</reg><orig>\1</orig></choice>', text)
	text = re.sub(":gaiji1:", "[", text)
	text = re.sub(":gaiji2:", "]", text)
	text = re.sub(":gaiji3:", "<", text)
	text = re.sub(":gaiji4:", ">", text)
	return text
	
'''
先把 [Ａ=Ｂ] 換成 <choice cb:type="規範字詞"><reg>Ｂ</reg><orig>Ａ</orig></choice>
因為 Ａ 與 B 也有可能是組字式或校勘數字, 例如 [千[金*本]=千[金*本]經]
'''
def do_normalize_old(text):
	'''
	先把 [xxx] 組字或校勘數字變成 :gaiji1:xxx:gaiji2:
	先把 <xxx> 組字或校勘數字變成 :gaiji3:xxx:gaiji4:
	把[Ａ=Ｂ] 換成 <choice cb:type="規範字詞"><reg>Ｂ</reg><orig>Ａ</orig></choice>
	再把:gaiji1:xxx:gaiji2: 換回 [xxx]
	再把:gaiji3:xxx:gaiji4: 換回 <xxx>
	'''
	text = re.sub(r"\[([^=>\[\]]+?)\]", r":gaiji1:\1:gaiji2:", text)
	text = re.sub(r"<([^<>]+?)>", r":gaiji3:\1:gaiji4:", text)
	text = re.sub(r"\[([^\]]*?)=([^\]]*?)\]:gaiji3:resp=\"(.*?)\":gaiji4:", r'<choice cb:type="規範字詞" cb:resp="\3"><reg>\2</reg><orig>\1</orig></choice>', text)
	text = re.sub(r"\[([^\]]*?)=([^\]]*?)\]", r'<choice cb:type="規範字詞"><reg>\2</reg><orig>\1</orig></choice>', text)
	text = re.sub(":gaiji1:", "[", text)
	text = re.sub(":gaiji2:", "]", text)
	text = re.sub(":gaiji3:", "<", text)
	text = re.sub(":gaiji4:", ">", text)
	return text
	
# 分析每一行經文
def do_text(s):
	tokens = re.findall(r'(<i>\(|\)</i>|<.*?>|\[[^\]]*?>.*?\]|\[[^>\[ ]+?\]|\(|\)|&SD\-\w{4};|&RJ\-\w{4};|　+|.)', s)
	for t in tokens:
		if re.match('[<\(\)\[&　]', t): inline_tag(t)	# 處理經文中的標記和空格
		else: do_chars(t)							# 處理經文中的文字
	return s

def closeTag(*tags):
	for t in tags:
		if t in opens:
			out1('</' + t + '>')
			opens[t] -= 1

def closeTags(*tags):
	for t in tags:
		if t in opens:
			while opens[t]>0:
				out1('</' + t + '>')
				opens[t] -= 1

def get_number(s):
	mo=re.search(r'\d+', s)
	if mo==None: return ''
	return mo.group(0)

# 記錄標記的層次
def record_open(tag):
	if not tag in opens: opens[tag] = 0
	opens[tag] += 1

# J01nA042_p0793a14_##<Q2 m=哲宗><annals><date><p>哲宗皇帝元祐四年[已>己]巳
# J01nA042_p0793a15_##<event><p,1>師宣州寧國縣人也姓奚氏其母初夢神人衛一
# ... </annals>
# 還有 <Q> <annals> 也可以結束 <annals>
# <event> 是用來結束 <date> 的
# 轉成
# <cb:event><date>ＸＸＸ</date><p,1>ＹＹＹ</p></cb:event>

# <annals> 裡面也可能沒有 <event> , 所以 <annals> 也可以結束 <date>
# <annals><date>......
# <event><p>..........
# <annals><date>......
# <annals><date>......

def start_inline_annals(tag):
	close_head()
	closeTags('date', 'p', 'cb:event')
	out('<cb:event>')
	opens['cb:event'] = 1

def start_inline_date(tag):
	out('<date>')
	opens['date'] = 1

# 參考 <annals> 標記, 此標記是用來結束 <date> 用的
def start_inline_event(tag):
	closeTags('p', 'date')

def start_J(tag):
	global globals
	if '=' in head_tag:
		return
	closeTags('p')
	n = get_number(tag)
	if n != None and  n != "" : globals['juan_num'] = int(n)
	out('<cb:juan fun="open" n="%s"><cb:jhead>' % globals['juan_num'])
	record_open('cb:juan')
	record_open('cb:jhead')

def start_j(tag):
	global globals
	closeTags('p')
	out('<cb:juan fun="close" n="{}"><cb:jhead>'.format(globals['juan_num']))
	record_open('cb:juan')
	record_open('cb:jhead')

def start_byline(tag):
	if '=' in tag: return
	closeTags('p', 'byline', 'cb:jhead', 'cb:juan')
	if 'A' in tag:
		out('<byline cb:type="author">')
	elif 'B' in tag:
		out('<byline cb:type="other">')
	elif 'C' in tag:
		out('<byline cb:type="collector">')
	elif 'E' in tag:
		out('<byline cb:type="editor">')
	elif 'Y' in tag:
		out('<byline cb:type="translator">')
	opens['byline'] = 1
	
def start_inline_byline(tag):
	closeTags('byline', 'cb:jhead', 'cb:juan', 'p')
	close_head()
	if tag == '<A>':
		out('<byline cb:type="author">')
	elif tag == '<B>':
		out('<byline cb:type="other">')
	elif tag == '<C>':
		out('<byline cb:type="collector">')
	elif tag == '<E>':
		out('<byline cb:type="editor">')
	elif tag == '<Y>':
		out('<byline cb:type="translator">')
	opens['byline'] = 1

def start_S(tag):
	global globals
	if not 'lg' in opens: opens['lg'] = 0
	if not 'lg_marginleft' in globals: globals['lg_marginleft'] = 0
	if not 'normal_lg' in globals: globals['normal_lg'] = True
	if opens['lg']==0:
		closeTags('cb:jhead', 'cb:juan', 'byline', 'p')
		close_head()
		globals['lg_marginleft'] = 1
		out('<lg xml:id="lg%sp%s%s01">' % (vol, old_pb, line_num))
		opens['lg'] = 1
		globals['normal_lg'] = True
	closeTags('l')

def start_x(tag):
	global buf, div_head, globals
	start_div(1, 'xu')
	buf += '<head>'
	opens['head'] = 1
	globals['mulu_start'] = True
	globals['head_start'] = True
	div_head = ''

# 計算一行有多少 <c> 標記
# <c> 算 1 個
# <c3> 算 3 個
# <c4 r3> 算 4 個
# <c r3> 算 1 個
def count_c_from_line(text):
	cnum = 0
	# 算有多少個 <c> 或 <c r3>
	findc = True
	while(findc):
		mo = re.search(r'<c[\s>]', text)
		if mo!=None: 
			text = re.sub(r'<c[\s>]', '', text, count=1)
			cnum += 1
		else:
			findc = False
	# 算有多少個 <c3> 或 <c3 r3>
	findc = True
	while(findc):
		mo = re.search(r'<c(\d+)', text)
		if mo!=None: 
			cnum += int(mo.group(1))
			text = re.sub(r'<c(\d+)', '', text, count=1)
		else:
			findc = False
	return cnum

# 處理表格 F 表格開始
def start_F(tag, text):
	closeTags('byline','p')
	# 計算一行有多少個 c 標記
	cnum = count_c_from_line(text)
	out('<table cols="{0:0d}"><row>'.format(cnum))
	record_open('table')
	record_open('row')

# 處理表格 f 表示 <row> 的範圍
def start_f(tag):
	closeTags('p', 'cell', 'row')
	out('<row>')
	record_open('row')

# 處理行首標記
def do_line_head(tag, text):
	if 'W' in tag:
		tag = tag.replace('W', '')
		if not globals['inw']:
			globals['inw']=True
			if 'Q' not in tag and 'x' not in tag:
				if not re.match(r'^<Q', text):	# 如果 W## 接著 <Q , 也不用執行 start_div, 因為 <Q 會執行
					start_div(1, 'w')
	elif globals['inw']:
		globals['inw']=False
		
	if 'r' not in tag:
		globals['inr']=False
	
	if ('A' in tag) or ('B' in tag) or ('C' in tag) or ('E' in tag) or ('Y' in tag):
		start_byline(tag)
	elif 'F' in tag: start_F(tag, text)
	elif 'f' in tag: start_f(tag)
	elif 'I' in tag:
		start_i(tag)
		if 'P' in tag: start_p(tag)
	elif 'J' in tag: start_J(tag)
	elif 'j' in tag: start_j(tag)
	elif 'P' in tag: start_p(tag)
	elif 'Q' in tag: start_q(tag)
	elif 'r' in tag: 
		if(globals['inr'] == False):	# 第一個 r 才需要處理成 <p xml:id="xxx" cb:type="pre">
			globals['inr'] = True
			start_p(tag)	# 依 p 的方式處理
	elif 'S' in tag: start_S(tag)
	elif 's' in tag: text = text + "</S>"
	elif 'x' in tag: start_x(tag)
	elif 'Z' in tag: start_p(tag)
	else: 
		tag = tag.replace('#', '')
		tag = tag.replace('_', '')
		tag = tag.replace('k', '')
		tag = re.sub(r'\d*', '', tag)
		if tag!= '': print(old_pb+line_num+'未處理的標記: ' + tag)
	return text

# 結束一部經, 全部印出來
def close_sutra(num):
	global buf11
	today=datetime.date.today().strftime('%Y-%m-%d')
	out_path = dir_out+'/'+vol+num+'.xml'
	print('out_path:', out_path)
	fo=open(out_path, 'w', encoding='utf8')
	s = """<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" xml:id="%s%s">\n""" % (vol, num)
	n = num[1:]
	n0 = n.lstrip('0')
	s += '''<teiHeader>
	<fileDesc>
		<titleStmt>
			<title>{col}, Electronic version, No. {n0} {t}</title>
			<title xml:lang="zh-Hant">{colzh}數位版, No. {n0} {t}</title>\n'''.format(col=collectionEng[ed], colzh=collectionZh[ed], n0=n0, t=sutras[n]['title'])
	s += '\t\t\t<author>%s</author>\n' % sutras[n]['author']
	s += '''\t\t\t<respStmt>
				<resp>Electronic Version by</resp>
				<name>CBETA</name>
			</respStmt>
		</titleStmt>
		<editionStmt>
			<edition>XML TEI P5a</edition>
		</editionStmt>
		<extent>{juan}卷</extent>\n'''.format(juan=sutras[n]['juan'])
	mo = re.search(r'\D+(\d+)', vol)
	v = mo.group(1)
	v = v.lstrip('0')
	if (v == ''): v = '0'
	s += '''\t\t<publicationStmt>
			<idno type="CBETA">
				<idno type="canon">{ed}</idno>.<idno type="vol">{v}</idno>.<idno type="no">{n}</idno>
			</idno>
			<distributor>
				<name>中華電子佛典協會 (CBETA)</name>
				<address>
					<addrLine><email>service@cbeta.org</email></addrLine>
				</address>
			</distributor>
			<availability>
				<p>Available for non-commercial use when distributed with this header intact.</p>
			</availability>
		</publicationStmt>
		<sourceDesc>
			<bibl>
				<title level="s">{col}</title>
				<title level="s" xml:lang="zh-Hant">{colzh}</title>
				<title level="m" xml:lang="zh-Hant">{sn}</title>
			</bibl>
		</sourceDesc>
	</fileDesc>'''.format(col=collectionEng[ed], colzh=collectionZh[ed], v=v, n=n0, ed=ed, sn=sutras[n]['title'])

	s += '''
	<encodingDesc>
		<projectDesc>
			<p xml:lang="en" cb:type="ly">{lyen}</p>
			<p xml:lang="zh-Hant" cb:type="ly">{lyzh}</p>
		</projectDesc>
		<editorialDecl>
			<punctuation resp="orig"><p>原書標點</p></punctuation>
		</editorialDecl>
		<tagsDecl>
			<namespace name="http://www.tei-c.org/ns/1.0">
				<tagUsage gi="rdg">
					<listWit>
						<witness xml:id="wit.orig">{wit}</witness>
						<witness xml:id="wit.cbeta">【CB】</witness>
					</listWit>
				</tagUsage>
			</namespace>
		</tagsDecl>
	</encodingDesc>'''.format(lyen=sutras[n]['laiyuan_e'], lyzh=sutras[n]['laiyuan_c'], wit=wits[ed])
	
	'''
	# P5a 不需要 <charDecl> 缺字資訊
	s += '\t\t<charDecl>\n'
	for cb in gaijis:
		s += '\t\t\t<char xml:id="CB%s">\n' % cb
		s += '\t\t\t\t<charName>CBETA CHARACTER CB%s</charName>\n' % cb
		s += '\t\t\t\t<charProp>\n'
		s += '\t\t\t\t\t<localName>composition</localName>\n'
		s += '\t\t\t\t\t<value>%s</value>\n' % gaijis[cb]['des']
		s += '\t\t\t\t</charProp>\n'
		s += '\t\t\t</char>\n'
	s += '\t\t</charDecl>\n'
	'''
	
	s += '''
	<profileDesc>
		<langUsage>
			<language ident="en">English</language>
			<language ident="zh-Hant">Chinese (Traditional)</language>
		</langUsage>
	</profileDesc>
	<revisionDesc>
		<change when="{today}">
			<name>Ray Chou 周邦信</name>Created initial TEI XML P5a version with bm2p5a.py
		</change>
	</revisionDesc>
</teiHeader>
<text><body>'''.format(today = datetime.date.today().strftime('%Y-%m-%d'))
	fo.write(s)
	closeTags('l','lg','byline','cb:jhead','p')		# 加上 l, lg  -- 2013/09/30 # 加上 cb:jhead 2014/06/06
	close_div(1)
	out('')		# 處理最後的 <lb> , 因為 BM 版經文最後可能會有空白行, 也要轉出 XML 來
	
	#最後的要處理一些特例
	#移除 <head></head> 及將 <ref cRef="PTS.Vin.3.110"/></head> 換成 <ref cRef="PTS.Vin.3.110"/>
	buf1 = ''.join(buf11)
	buf1 = re.sub('<head>((?:<ref cRef="PTS.[^>]*>)?)</head>',r'\1',buf1)
	
	buf1 = buf1.replace('&', '&amp;')	# 把 & 換成 &amp;  - 2013/09/24
	buf1 = buf1.replace('&amp;SD-', '&SD-')	# 把 &amp;SD- 換成 &SD-
	buf1 = buf1.replace('&amp;RJ-', '&RJ-')	# 把 &amp;RJ- 換成 &SD-
	
	fo.write(buf1)
	buf1 = ''
	buf11 = []
	fo.write('\n</body></text></TEI>\n')
##############################################
# P5a 的版本不需要底下的校勘記
#	fo.write('<back>\n')
#	fo.write(' <cb:div type="apparatus">\n')
#	fo.write('  <head>校勘記</head>\n')
#	fo.write('  <p>\n')
#	fo.write(globals['backApp'])
#	fo.write('''  </p>
# </cb:div>
#</back>
#''')
#	fo.write('</text></TEI>')
##############################################
	fo.close()
	#gaijis = {}
	
# 初值化
def sutraInit(newSutraNumber):
	if globals['sutraNumber']!='': close_sutra(globals['sutraNumber'])
	globals['anchorCount']=0
	globals['backApp']=''
	globals['head_start'] = False
	globals['inw'] = False
	globals['inr'] = False
	globals['juan_num'] = 0
	globals['mulu_start'] = False
	globals['sutraNumber'] = newSutraNumber

def convert():
	global buf, char_count, fo, head_tag, line_num, old_pb, globals
	print('BMJingWen:', BMJingWen, file=log)
	f1=open(BMJingWen, "r", encoding="utf8")
	reo=re.compile(r'\[[^>\[]*?\]') # 組字式
	globals['sutraNumber'] = ''
	if not 'normal_lg' in globals: globals['normal_lg'] = False
	for line in f1:
		char_count = 1
		line=line.rstrip()
		if (line[:1] == "\ufeff"): line = line[1:]	# 扣除 utf8 格式有 feff 的檔頭
		aline = line[:len(options.vol)+17]
		text = line[len(options.vol)+17:]
		mo=re.match(r'([A-Z]+\d{2,3})(n.\d+.)(p.\d{3}[a-z])(\d\d)(.+)$', aline)
		if mo!=None:
			(vol, num, pb, line_num, head_tag) = mo.groups()
		else:
			print("行首有錯:", aline)
		#print('line_num:', pb+line_num, file=log)
		num=num.rstrip('_')
		if num!=globals['sutraNumber']:
			sutraInit(num)
		pb=pb.lstrip('p')
		# 換行時, 發現前一行是 head , 而且沒有延續到本行, 就要印出相關文字
		if globals['head_start'] and not re.search(r'Q\d?=', head_tag) and not re.search(r'<Q\d?=', text):
			close_head()
			'''
			# 底下全部移到 close_head 裡面處理
			if globals['mulu_start']:
				if div_head != '':
					out1('<cb:mulu type="{}" level="{}">{}</cb:mulu>'.format(globals['muluType'], opens['div'], div_head))
				globals['mulu_start'] = False
			out('')
			closeTags('head')
			globals['head_start']=False
			'''
		
		# 判斷有沒有換頁
		if pb != old_pb:
			buf += '\n<pb ed="{e}" xml:id="{v}.{n}.{p}" n="{p}"/>'.format(e=ed, v=vol, n=num[1:], p=pb)
			old_pb = pb
			
		buf += '\n<lb'
		if 'k' in head_tag:
			buf += ' type="honorific"'  # 強迫換行
		buf += ' ed="{}" n="{}"/>'.format(ed, pb+line_num)
		
		text = do_line_head(head_tag, text)	# 因為 S 標記會把空格處理成 <l></l> , 所以要有傳回處理過的 text
		globals['lg_space_count'] = 0	# 每一行的空格數歸0

		# 變數
		# globals['lg_space_count'] : 每一行第 n 個 <l>，計數會在每一行歸零, 在偈頌中遇到空白就會 +1
		# globals['lg_marginleft'] : 偈頌的整段位移，會在 lg 產生時重設, 通常預設是 1
		# globals['normal_lg'] : 表示是使用 S## 或 <S> 的標準偈頌, 不是 <T> 的偈頌
		if not 'lg' in opens: opens['lg'] = 0
		if opens['lg'] == 1 and globals['normal_lg'] == True:
			if not re.match(r'^　', text): text = "<nosp>" + text
		if (opens['lg'] == 1 and globals['normal_lg'] == True) or '<S' in text: # <S 會在行中
			if text[-4:] == "</S>": text = text[:-4] + "</l></S>"
			else: text = text + "</l>"
			text = re.sub(r"(</Q\d*>)(</l></S>)$", r"\2\1", text)	# 把 </Qx> 移到後面, 例: 	B10n0068_p0839b03s##　能令清淨諸儀軌　　如智者論顯了說</Q1>

		'''
		先把 [Ａ>Ｂ] 換成
		<note n="0001b0201" resp="CBETA.maha" type="add">念【CB】，忘【大】</note>
		<app n="0001b0201"><lem wit="【CB】" resp="CBETA">念</lem><rdg wit="【大】">忘</rdg></app>
		因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [[金*本]>[口*兄]] , [[01]>]
		
		也把 [Ａ=Ｂ] 換成 
		<note n="0002a0201" resp="CBETA" type="add" subtype="規範字詞">系統【CB】，係統【呂澂】</note>
		<app n="0002a0201"><lem wit="【CB】" resp="CBETA">系統</lem><rdg wit="【呂澂】">係統</rdg></app>
		因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [千[金*本]=千[金*本]經]
		'''
		text = do_corr_normalize(text)
				
		# 處理一般文字
		do_text(text)
	close_sutra(globals['sutraNumber'])
	f1.close()

def close_head():
	if globals['head_start']:
		if globals['mulu_start']:
			if div_head != '':
				out1('<cb:mulu type="{}" level="{}">{}</cb:mulu>'.format(globals['muluType'], opens['div'], div_head))
			# 取消 cb:mulu 的空標記 2016/04/11
			# else:
			#	out1('<cb:mulu type="{}" level="{}"/>'.format(globals['muluType'], opens['div']))
			globals['mulu_start'] = False
		out('')
		closeTags('head')
		globals['head_start']=False

def read_source():
	global sutras
	fi=open(BMLaiYuan, 'r', encoding='utf8')
	laiyuan={}
	for line in fi:
		line = line.rstrip()
		if line[1:2]==':':
			v=line[0:1]
			l=line[2:].split(',')
			laiyuan[v]=l
		else:
			fields = line.split()
			if len(fields)<5: continue
			if not re.match('[A-Z]', fields[1]): continue
			if len(ed) == 2:		# ex. ed=ZY (??? 有大於二位數的就再說了) - 2013/08/26
				n = fields[1][2:7]	# ZY0001_01_p0017
			else:
				n = fields[1][1:6]	# T0099-02-p0001 or T0128a02-p0835
			if n[-1:] == '-' or n[-1:] == '_':
				n = n[0:-1]
			sutras[n] = {}
			sutras[n]['title'] = fields[5]
			sutras[n]['juan'] = fields[4]
			s = ' '.join(fields[6:])		
			#sutras[n]['author'] = s[1:-1]		# 這樣用有危險, 有時譯者之後還有其他欄位, 例如 T02 有高麗藏的對應 - 2013/08/26
			mo = re.search(r'【(.*?)】', line)
			sutras[n]['author'] = mo.group(1)
			c = ''
			e = ''
			for s in fields[0]:
				c += laiyuan[s][0].strip() + '，'
				e += laiyuan[s][1].strip() + ', '
			sutras[n]['laiyuan_c'] = c.rstrip('，')
			sutras[n]['laiyuan_e'] = e.rstrip(', ')
	fi.close()


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
					des = row['des']
					r[cb]['des'] = des
					des2cb[des] = cb
				if row['nor'] != '':
					r[cb]['nor'] = row['nor']
				if row['nor_unicode'] != '':
					r[cb]['nor_unicode'] = row['nor_unicode']
				if uni != '':
					r[cb]['unicode'] = uni
			if uni != '':
				unicode2cb[uni] = cb
	return r


# main
# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-v", dest="vol", help="指定要轉換哪一冊")
parser.add_option("-o", action='store', dest="output", help="輸出資料夾")
(options, args) = parser.parse_args()
vol = options.vol.upper()
mo = re.search(r'^\D+', vol)	# 因為會有兩位數以上的代碼, 例如 ZY01 - 2013/08/26
ed = mo.group()


# 讀取 設定檔 cbwork_bin.ini
config = configparser.ConfigParser()
config.read('../cbwork_bin.ini','UTF-8')
gaijiMdb = config.get('default', 'gaiji-m.mdb_file')
cbwork_dir = config.get('default', 'cbwork')
BMLaiYuan = cbwork_dir + '/bm/{ed}/{vol}/source.txt'.format(vol=vol, ed=ed)
BMJingWen = cbwork_dir + '/bm/{ed}/{vol}/new.txt'.format(vol=vol, ed=ed)

log=open('bm2p5a.log', 'w', encoding='utf8')

dir_out = os.path.join(options.output, ed, vol)
if not os.path.exists(dir_out): os.makedirs(dir_out)

EditionDate = datetime.date.today()

wit = wits[ed]

debug = True

buf = ''			# 似乎是放 <lb> <pb> 及 head 的內容
buf1 = ''
buf11 = []
char_count = 1
fo = ''
head_tag = ''
hold = False
div_head = ''
#gaijis = {}
des2cb = {}
unicode2cb = {}
line_num = ''
opens = {}			# 記錄每一個標記的層次
opens['div'] = 0
old_pb = ''
sutras = {}
globals={}
L_type = ""		# 記錄 <L> 的type , 若是 <L_sp> 則 L_type="simple"
div_type_note = 0 # 記錄是否有在 <cb:div type="note"> 之中

# 準備存取 gaiji-m.mdb
''' 不用 Access 了
conn = win32com.client.Dispatch(r'ADODB.Connection')
DSN = 'PROVIDER=Microsoft.Jet.OLEDB.4.0;DATA SOURCE=%s;' % gaijiMdb
conn.Open(DSN)
'''

GAIJI = gaijiMdb.replace('gaiji-m.mdb', "gaiji-m_u8.txt")
all_gaijis=read_all_gaijis()	# 預設改為直接開啟 cvs 的資料庫

read_source()
convert()