# -*- coding: utf-8 *-*
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
2013/08/26 處理藏經代碼為二位數的情況, 例如西蓮淨苑的 'SL'
2013/07/20 處理修訂格式中包含組字式、校勘數字的問題, 以及一些小問題.
2013/06/27 1.<T,y> 格式改成 <T,x,y> , 與 <p,x,y> 同步. 
           2.若遇到 <p>, <Q> P, Q 自動結束偈頌, 不一定要用 </T>
2013/06/24 BM 版經文最後的空白行也要轉出 XML 來
2013/06/19 修改漢譯南傳大藏經的中英文
2013/06/09 將設定檔改為 ../cbwork_bin.ini
'''

import collections, configparser, datetime, os, re, struct, sys
from optparse import OptionParser
import win32com.client # 要安裝 PythonWin

wits={
'A': '【金藏】',
'B': '【補編】',
'C': '【中華】',
'D': '【國圖】',
'F': '【房山】',
'G': '【佛教】',
'H': '【正史】',
'J': '【嘉興】',
'K': '【麗】',
'L': '【龍】',
'M': '【卍正】',
'N': '【南傳】',
'P': '【北藏】',
'Q': '【磧砂】',
'S': '【宋遺】',
'SL': '【西蓮】',
'T': '【大】', 
'U': '【洪武】',
'W': '【藏外】',
'X': '【卍續】', 
}

collectionEng={
'A': 'Jin Edition of the Canon',
'B': 'Supplement to the Dazangjing',
'C': 'Zhonghua Canon - Zhonghua shuju Edition',
'D': 'Selections from the Taipei National Central Library Buddhist Rare Book Collection',
'F': 'Fangshan shijing',
'G': 'Fojiao Canon',
'H': 'Passages concerning Buddhism from the Official Histories',
'I': 'Selections of Buddhist Stone Rubbings from the Northern Dynasties',
'J': 'Jiaxing Canon - Xinwenfeng Edition',
'K': 'Tripiṭaka Koreana - Xinwenfeng Edition',
'L': 'Qianlong Edition of the Canon - Xinwenfeng Edition',
'M': 'Manji Daizōkyō - Xinwenfeng Edition',
'N': 'Chinese Translation of the Pali Tipiṭaka',
'P': 'Northern Yongle Edition of the Canon',
'Q': 'Qisha Edition of the Canon - Xinwenfeng Edition',
'R': 'Manji Zokuzōkyō - Xinwenfeng Edition',
'S': 'Songzang yizhen - Xinwenfeng Edition',
'SL': 'the Complete Works of Ven Zhiyu',
'T': 'Taishō Tripiṭaka',
'U': 'Southern Hongwu Edition of the Canon',
'W': 'Buddhist Texts not contained in the Tripiṭaka',
'X': 'Manji Shinsan Dainihon Zokuzōkyō',
'Z': 'Manji Dainihon Zokuzōkyō'
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
	global buf1
	buf1 += s

# 當 globals['head_start'] 為真時, div_head 及 buf 都要記錄下來
def out2(s):
	global div_head, buf
	if globals['head_start']: 
		div_head += s
		buf += s
	elif s!='': 
		out(s)

def start_i(tag):
	level = 1
	mo = re.search(r'\d+', tag)
	if mo!=None: level = int(mo.group())
	if not 'item' in opens: opens['item'] = 0
	if not 'list' in opens: opens['list'] = 0
	closeTags('cb:jhead', 'cb:juan', 'p')
	while level<opens['list']:
		out1('</item></list>')
		opens['list'] -= 1
		opens['item'] -= 1
	if  level==opens['list']:
		out1('</item>')
		opens['item'] -= 1
	if level>opens['list']:
		record_open('list')
		out('<list>')
	s = '<item xml:id="item{}p{}{}{:02d}">'.format(vol, old_pb, line_num, char_count)
	out(s)
	opens['item'] += 1

# 處理 PTS 標記 BM版:<PTS.Vin.1.101> => XML:<ref target="PTS.Vin.1.101"/>
def start_PTS(tag):
	global buf
	mo = re.search(r'<(PTS.*?)>', tag)
	s = '<ref target="%s"/>' % mo.groups()
	buf += s 
	
	''' 
	##################################################################
	不可用 out(s) , 也不可用 out1(s), 說明如下:
	
	out(s) 會先印出 buf 中的 <lb> 等標記, 會有如下結果
	<lb ed="N" n="0009a06"/>久住，拘樓孫佛、拘那含牟尼佛、迦葉佛之梵行久住也。」
	<lb ed="N" n="0009a07"/><ref target="PTS.Vin.8.8"/></p></cb:div><cb:div type="other">
	
	out1(s) 直接加入 buf1 中, 會有如下結果
	<lb ed="N" n="0009a06"/>久住，拘樓孫佛、拘那含牟尼佛、迦葉佛之梵行久住也。」<ref target="PTS.Vin.8.8"/></p></cb:div>
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
	closeTags('p', 'byline', 'head')
	closeTags('l', 'lg')
	r = get_number(tag)
	out('<p xml:id="p%sp%s%s01"' % (vol, old_pb, line_num))
	if 'r' in head_tag:
		out(' type="pre"')
	if r!='':
		out(' rend="margin-left:%sem"' % r)
	out('>')
	opens['p']=1

def start_inline_p(tag):
	closeTags('p')
	close_head()
	closeTags('l', 'lg')
	s = '<p xml:id="p%sp%s%s%02d"' % (vol, old_pb, line_num, char_count)
	if char_count>1: s += ' cb:type="inline"'
	mo = re.search(r'<p,(\d+),(\d+)>', tag)
	if mo!=None:
		s += ' rend="margin-left:%sem;text-indent:%sem"' % mo.groups()
	else:
		mo = re.search(r'\d+', tag)
		if mo!=None:
			s += ' rend="margin-left:%sem"' % mo.group()
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
	global buf, div_head, head_tag, globals
	close_head()
	closeTags('l', 'lg')
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
		globals['muluType']='其他'
	else:
		label=mo.group(1)
		if label != '':
			out('<cb:mulu type="其他" level="%d">%s</cb:mulu>' % (level, label))
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
	
	div_head = ''
	level = 0
	
	mo = re.search(r'\d+', tag)
	if mo!=None:
		level = int(mo.group())
		
	globals['mulu_start'] = True
	globals['head_start'] = True
	globals['muluType']='其他'
	start_div(level, 'other')
	buf += '<head>'
	opens['head'] = 1

# 可能用不上了, 已在 do_corr 處理了.
def choice(tag):
	'''  把 [A>B] 換成 <choice> '''
	mo = re.match(r'\[([^>\]]*?)>(.*?)\]', tag) 
	#globals['anchorCount']+=1
	#id1='anchor{}'.format(globals['anchorCount'])
	#globals['anchorCount']+=1
	#id2='anchor{}'.format(globals['anchorCount'])
	#s = '<choice cb:from="#{}" cb:to="#{}" cb:resp="#resp1">'.format(id1, id2)
	s = '<choice cb:resp="CBETA.maha"><corr>{}</corr>'.format(mo.group(2))
	if mo.group(1)=='':
		s += '<sic/>'
	else:
		s += '<sic>{}</sic>'.format(mo.group(1))
	s += '</choice>'
	return s
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

def close_q(tag):
	closeTags('cb:jhead', 'cb:juan', 'p')
	close_head()
	level = int(tag[3:-1])
	close_div(level)
		
def start_inline_T(tag):
	if not 'lg' in opens: opens['lg'] = 0
	if opens['lg']==0:
		closeTags('p')
		close_head()
		out('<lg xml:id="lg%sp%s%s01" type="abnormal">' % (vol, old_pb, line_num))	#??? lg 一定是在行首的第一個字嗎?
		opens['lg'] = 1
	closeTags('l')
	mo = re.search(r'<T,(\d+),(\d+)>', tag)
	if mo!=None:
		if(mo.group(1) == '0'):
			out('<l rend="text-indent:%sem">' % mo.group(2))
		elif(mo.group(2) == '0'):
			out('<l rend="margin-left:%sem">' % mo.group(1))
		else:
			out('<l rend="margin-left:%sem;text-indent:%sem">' % mo.groups())
	else:
		mo = re.search(r'\d+', tag)
		if mo!=None:
			out('<l rend="margin-left:%sem">' % mo.group())
	record_open('l')

def start_inline_o(tag):
	closeTags('p')
	if 'commentary' in opens and opens['commentary']>0:
		out1('</cb:div>')
		opens['div'] -= 1
	start_div(opens['div']+1, 'orig')
	opens['orig'] = 1
	
def start_inline_u(tag):
	closeTags('p')
	if 'orig' in opens and opens['orig']>0:
		out1('</cb:div>')
		opens['div'] -= 1
	start_div(opens['div']+1, 'commentary')
	opens['commentary'] = 1

# 處理經文中的標記
def inline_tag(tag):
	global char_count, buf
	#print(tag, sep=' ', end='')
	if re.match(r'\[([^>\]]*?)>(.*?)\]', tag):	# 處理修訂 [A>B] # 可能用不上了, 已在 do_corr 處理了.
		out(choice(tag))
	elif re.match(r'<\[(([\da-zA-Z]{2,3})|＊)\]>', tag):	# 在 do_corr 處理過的校勘數字 , 原來為 <[01]> , 要直接處理成 [01]
		out(tag[1:-1])
	elif re.match(r'\[([\da-zA-Z]+?)\]', tag):	# 處理校勘數字
		out('<anchor xml:id="fn%sp%s%s"/>' % (vol, old_pb, tag[1:-1]))
	elif re.match(r'\[[^>\[ ]+?\]', tag):		# 處理組字式
		char_count+=1
		out2(gaiji(tag))
	elif tag=='<□>':							# 未知字
		out('<unclear/>')
	elif re.match(r'<\D+\d+n\d\d\d\d', tag):	# 出處連結, 例如 : SL01n0001_p0020a02_##...佛於經中說，【<T09n0262_p0007c07-09>舍利弗！汝等當一心...
		pass
	elif re.match(r'<I\d+>', tag):
		start_i(tag)
	elif re.match(r'<PTS.', tag):
		start_PTS(tag)
	elif re.match(r'<trans-mark', tag):
		start_trans_mark(tag)
	elif tag=='(':
		out2('<note place="inline">')
	elif tag=='<i>(':
		out2('<note place="interlinear">')
	elif tag==')' or tag==")</i>":
		out2('</note>')
	elif tag =='<j>':
		closeTags('p')
		out('<cb:juan fun="close"><cb:jhead>')
		record_open('cb:juan')
		record_open('cb:jhead')
	#elif tag.startswith('<J'):
	#	start_J(tag)
	elif tag =='</L>':
		closeTags('p')
		while opens['list']>0:
			closeTag('item', 'list')
	elif tag.startswith('<mj'):
		#n=get_number(tag)
		globals['juan_num']+=1
		#out('<milestone unit="juan" n="{}"/>'.format(globals['juan_num']))		# 若用 out() , 會有一堆 </p></cb:div> 標記出現在 <milestone> 後面
		buf += '<milestone unit="juan" n="{}"/>'.format(globals['juan_num'])
		if ed == 'N':
			#out('<cb:mulu type="卷" n="{}"/>'.format(globals['juan_num']))
			buf += '<cb:mulu type="卷" n="{}"/>'.format(globals['juan_num'])
	elif tag=='<o>':
		start_inline_o(tag)
	elif tag.startswith('<p'):
		start_inline_p(tag)
	elif tag.startswith('<Q'):
		start_inline_q(tag)
	elif tag.startswith('</Q'):
		close_q(tag)
	elif tag.startswith('<T'):
		start_inline_T(tag)
	elif tag=='</T>':
		closeTags('l', 'lg')
	elif tag=='<u>':
		start_inline_u(tag)
	elif tag=='</u>':
		closeTags('p')
		out1('</cb:div>')
		opens['div'] -= 1
	#以下這些直接輸出 <choice cb:resp="CBETA.maha"><corr>Ｂ</corr><sic>Ａ</sic></choice>
	elif tag.startswith('<choice'):
		out(tag)
	elif tag=='<corr>':
		out(tag)
	elif tag=='</corr>':
		out(tag)
	elif tag=='<sic>':
		out(tag)
	elif tag=='</sic>':
		out(tag)
	elif tag=='</choice>':
		out(tag)
	else:
		print(old_pb+line_num+'未處理的標記: ' + tag)

def gaiji(zuzi):
	print('gaiji()', zuzi, file=log)
	if zuzi=='[＊]': return zuzi
	if re.match(r'\[\d+\]', zuzi): return zuzi
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
			''' here we add an appropriate PUA character to the g element 
			(strictly speaking, we could then eliminate the g, iff the PUA value is defined in the header) 
			on the other hand, P5 explicitly says, these PUA chars should be removed for exchange. 
			'''
			#c=chr(0xF0000+int(cb))
			#return '<g ref="#CB{}">{}</g>'.format(cb, c)	# 不使用 PUA 了, # 也要移除, 因為無此 id
			return '<g ref="#CB{}"/>'.format(cb)
	else:
		print('組字式找不到: ' + zuzi)
		return ''
		
# 處理經文中的文字
def do_chars(s):
	global buf, char_count, div_head
	#print('char_count:', char_count, file=log)
	#print('chars:', s, file=log)
	char_count += myLength(s)
	out2(s)

'''
先把 [Ａ>Ｂ] 換成 <choice cb:resp="CBETA.maha"><corr>Ｂ</corr><sic>Ａ</sic></choice>
因為 Ａ 與 B 也有可能是組字式或校勘數字, 例如 [[金*本]>[口*兄]] , [[01]>]
'''
def do_corr(text):
	'''
	先把 [xxx] 組字或校勘數字變成 :gaiji1:xxx:gaiji2:
	先把 <xxx> 組字或校勘數字變成 :gaiji3:xxx:gaiji4:
	再把[Ａ>Ｂ] 換成 <choice cb:resp="CBETA.maha"><corr>Ｂ</corr><sic>Ａ</sic></choice>
	再把 <corr>[01]</corr> 這一類換成 <corr><[01]></corr> , 而 <[01]> 之後會換成 [01], 如不這樣處理, [01] 會被變成一般的校勘數字標記
	再把:gaiji1:xxx:gaiji2: 換回 [xxx]
	再把:gaiji3:xxx:gaiji4: 換回 <xxx>
	'''
	text = re.sub(r"\[([^>\[\]]+?)\]", r":gaiji1:\1:gaiji2:", text)
	text = re.sub(r"<([^<>]+?)>", r":gaiji3:\1:gaiji4:", text)
	text = re.sub(r"\[(.*?)>(.*?)\]", r'<choice cb:resp="CBETA.maha"><corr>\2</corr><sic>\1</sic></choice>', text)
	text = re.sub(":gaiji1:", "[", text)
	text = re.sub(":gaiji2:", "]", text)
	text = re.sub(":gaiji3:", "<", text)
	text = re.sub(":gaiji4:", ">", text)
	text = re.sub(r"<corr>(\[(([\da-zA-Z]{2,3})|＊)\])<\/corr>", r'<corr><\1></corr>', text)
	text = re.sub(r"<sic>(\[(([\da-zA-Z]{2,3})|＊)\])<\/sic>", r'<sic><\1></sic>', text)

	return text

# 分析每一行經文
def do_text(s):
	tokens = re.findall(r'(<i>\(|\)</i>|<.*?>|\[[^\]]*?>.*?\]|\[[^>\[ ]+?\]|\(|\)|.)', s)
	for t in tokens:
		if re.match('[<\(\)\[]', t): inline_tag(t)	# 處理經文中的標記
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

def start_J(tag):
	n = get_number(tag)
	out('<cb:juan fun="open" n="%s"><cb:mulu type="卷" n="%s"/><cb:jhead>' % (n, n))
	record_open('cb:juan')
	record_open('cb:jhead')

def start_j(tag):
	out('<cb:juan fun="close" n="{}"><cb:jhead>'.format(globals['juan_num']))
	record_open('cb:juan')
	record_open('cb:jhead')

def start_byline(tag):
	if '=' in tag: return
	closeTags('byline', 'cb:jhead', 'cb:juan')
	if 'A' in tag:
		out('<byline cb:type="author">')
	elif 'B' in tag:
		out('<byline cb:type="other">')
	elif 'C' in tag:
		out('<byline cb:type="collector">')
	elif 'E' in tag:
		out('<byline cb:type="editor">')
	opens['byline'] = 1
	
def start_x(tag):
	global buf, div_head, globals
	start_div(1, 'xu')
	buf += '<head>'
	opens['head'] = 1
	globals['mulu_start'] = True
	globals['head_start'] = True
	div_head = ''

# 處理行首標記
def do_line_head(tag):
	if 'W' in tag:
		tag = tag.replace('W', '')
		if not globals['inw']:
			globals['inw']=True
			if 'Q' not in tag and 'x' not in tag:
				start_div(1, 'w')
	elif globals['inw']:
		globals['inw']=False
	if ('A' in tag) or ('B' in tag) or ('C' in tag) or ('E' in tag):
		start_byline(tag)
	elif 'I' in tag:
		start_i(tag)
		if 'P' in tag: start_p(tag)
	elif 'J' in tag: start_J(tag)
	elif 'j' in tag: start_j(tag)
	elif 'P' in tag: start_p(tag)
	elif 'Q' in tag: start_q(tag)
	elif 'x' in tag: start_x(tag)
	else: 
		tag = tag.replace('#', '')
		tag = tag.replace('_', '')
		tag = tag.replace('k', '')
		tag = tag.replace('r', '')
		tag = re.sub(r'\d*', '', tag)
		if tag!= '': print(old_pb+line_num+'未處理的標記: ' + tag)

# 結束一部經, 全部印出來
def close_sutra(num):
	global buf1, gaijis
	today=datetime.date.today().strftime('%Y-%m-%d')
	out_path = dir_out+'/'+vol+num+'.xml'
	print('out_path:', out_path)
	fo=open(out_path, 'w', encoding='utf8')
	s = """<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" xml:id="%s%s">\n""" % (vol, num)
	n = num[1:]
	s += '''<teiHeader>
	<fileDesc>
		<titleStmt>
			<title>{col}, Electronic version, No. {n} {t}</title>\n'''.format(col=collectionEng[ed], n=n, t=sutras[n]['title'])
	s += '\t\t\t<author>%s</author>\n' % sutras[n]['author']
	s += '''\t\t\t<respStmt>
				<resp>Electronic Version by</resp>
				<name>CBETA</name>
			</respStmt>
		</titleStmt>
		<editionStmt>
			<edition>$Revision:'''
	s += '''$<date>$Date:'''
	s += '''$</date></edition>
		</editionStmt>
		<extent>{juan}卷</extent>\n'''.format(juan=sutras[n]['juan'])
	mo = re.search(r'\D+(\d+)', vol)
	v = mo.group(1)
	v = v.lstrip('0')
	s += '''\t\t<publicationStmt>
			<distributor>
				<name>中華電子佛典協會 (CBETA)</name>
				<address>
					<addrLine>service@cbeta.org</addrLine>
				</address>
			</distributor>
			<availability>
				<p>Available for non-commercial use when distributed with this header intact.</p>
			</availability>
			<date>$Date:'''
	s += '''$</date>
		</publicationStmt>
		<sourceDesc>
			<bibl>{col} Vol. {v}, No. {n} </bibl>
		</sourceDesc>
	</fileDesc>'''.format(col=collectionEng[ed], v=v, n=n)

	s += '''
	<encodingDesc>
		<projectDesc>
			<p xml:lang="en" cb:type="ly">%s</p>
			<p xml:lang="zh" cb:type="ly">%s</p>
		</projectDesc>
	</encodingDesc>''' % (sutras[n]['laiyuan_e'], sutras[n]['laiyuan_c'])
	
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
	
	s += '''\t
	<profileDesc>
		<langUsage>
			<language ident="en">English</language>
			<language ident="zh">Chinese</language>
		</langUsage>
	</profileDesc>
	<revisionDesc>
		<change when="{today}">
			<name>Ray Chou 周邦信</name> Created initial TEI XML P5a version with bm2p5a.py
		</change>
<!--
$Log:'''.format(today=today)
	s += '''$
-->
	</revisionDesc>
</teiHeader>
<text><body>'''
	fo.write(s)
	closeTags('p')
	close_div(1)
	out('')		# 處理最後的 <lb> , 因為 BM 版經文最後可能會有空白行, 也要轉出 XML 來
	
	#最後的要處理一些特例
	#移除 <head></head> 及將 <ref target="PTS.Vin.3.110"/></head> 換成 <ref target="PTS.Vin.3.110"/>
	buf1 = re.sub('<head>((?:<ref target="PTS.[^>]*>)?)</head>',r'\1',buf1)
	
	fo.write(buf1)
	buf1 = ''
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
	gaijis = {}
	
# 初值化
def sutraInit(newSutraNumber):
	if globals['sutraNumber']!='': close_sutra(globals['sutraNumber'])
	globals['anchorCount']=0
	globals['backApp']=''
	globals['head_start'] = False
	globals['inw'] = False
	globals['juan_num'] = 0
	globals['mulu_start'] = False
	globals['sutraNumber'] = newSutraNumber

def convert():
	global buf, char_count, fo, head_tag, line_num, old_pb
	print('BMJingWen:', BMJingWen, file=log)
	f1=open(BMJingWen, "r", encoding="utf8")
	reo=re.compile(r'\[[^>\[]*?\]') # 組字式
	globals['sutraNumber'] = ''
	for line in f1:
		char_count = 1
		line=line.rstrip()
		if (line[:1] == "\ufeff"): line = line[1:]	# 扣除 utf8 格式有 feff 的檔頭
		aline = line[:len(options.vol)+17]
		text = line[len(options.vol)+17:]
		mo=re.match(r'([A-Z]+\d{2,3})(n\d+.)(p\d{4}[a-z])(\d\d)(.+)$', aline)
		(vol, num, pb, line_num, head_tag) = mo.groups()
		#print('line_num:', pb+line_num, file=log)
		num=num.rstrip('_')
		if num!=globals['sutraNumber']:
			sutraInit(num)
		pb=pb.lstrip('p')
		
		# 換行時, 發現前一行是 head , 而且沒有延續到本行, 就要印出相關文字
		if globals['head_start'] and not re.match(r'Q\d?=', head_tag):
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
		
		do_line_head(head_tag)
		'''
		先把 [Ａ>Ｂ] 換成 <choice cb:resp="CBETA.maha"><corr>Ｂ</corr><sic>Ａ</sic></choice>
		因為 Ａ 與 B 也有可能是組字式或校勘數字, 例如 [[金*本]>[口*兄]] , [[01]>]
		'''
		text = do_corr(text)
		
		do_text(text)
	close_sutra(globals['sutraNumber'])
	f1.close()

def close_head():
	if globals['head_start']:
		if globals['mulu_start']:
			if div_head != '':
				out1('<cb:mulu type="{}" level="{}">{}</cb:mulu>'.format(globals['muluType'], opens['div'], div_head))
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
			if len(ed) == 2:		# ex. ed=SL (??? 有大於二位數的就再說了) - 2013/08/26
				n = fields[1][2:7]	# SL0001_01_p0017
			else:
				n = fields[1][1:6]	# T0099-02-p0001 or T0128a02-p0835
			if n[-1:] == '-' or n[-1:] == '_':
				n = n[0:-1]
			sutras[n] = {}
			sutras[n]['title'] = fields[5]
			sutras[n]['juan'] = fields[4]
			s = ' '.join(fields[6:])		
			#sutras[n]['author'] = s[1:-1]		# 這樣用有危險, 有時譯者之後還有其他欄位, 例如 T02 有高麗藏的對應 - 2013/08/26
			mo = re.search(r'【(.*?)】', s)
			sutras[n]['author'] = mo.group(1)
			c = ''
			e = ''
			for s in fields[0]:
				c += laiyuan[s][0].strip() + '，'
				e += laiyuan[s][1].strip() + ', '
			sutras[n]['laiyuan_c'] = c.rstrip('，')
			sutras[n]['laiyuan_e'] = e.rstrip(', ')
	fi.close()
	
# main
# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-v", dest="vol", help="指定要轉換哪一冊")
parser.add_option("-o", action='store', dest="output", help="輸出資料夾")
(options, args) = parser.parse_args()
vol = options.vol.upper()
mo = re.search(r'^\D+', vol)	# 因為會有兩位數以上的代碼, 例如 SL01 - 2013/08/26
ed = mo.group()


# 讀取 設定檔 cbwork_bin.ini
config = configparser.SafeConfigParser()
config.read('../cbwork_bin.ini')
gaijiMdb = config.get('default', 'gaiji-m.mdb_file')
cbwork_dir = config.get('default', 'cbwork')
if(ed == 'SL'):			# 西蓮的來源在 Google Drive 的目錄中, 故要另外處理 - 2013/08/26
	seeland_dir = config.get('default', 'seeland_dir')
	BMLaiYuan = seeland_dir + '/bm/{vol}/source.txt'.format(vol=vol)
	BMJingWen = seeland_dir + '/bm/{vol}/new.txt'.format(vol=vol)
else:
	BMLaiYuan = cbwork_dir + '/bm/{ed}/{vol}/source.txt'.format(vol=vol, ed=ed)
	BMJingWen = cbwork_dir + '/bm/{ed}/{vol}/new.txt'.format(vol=vol, ed=ed)

log=open('bm2p5a.log', 'w', encoding='utf8')

# 準備存取 gaiji-m.mdb
conn = win32com.client.Dispatch(r'ADODB.Connection')
DSN = 'PROVIDER=Microsoft.Jet.OLEDB.4.0;DATA SOURCE=%s;' % gaijiMdb
conn.Open(DSN)

dir_out = os.path.join(options.output, ed, vol)
if not os.path.exists(dir_out): os.makedirs(dir_out)

EditionDate = datetime.date.today();

wit = wits[ed]

debug = True

buf = ''			# 似乎是放 <lb> <pb> 及 head 的內容
buf1 = ''
char_count = 1
fo = ''
head_tag = ''
hold = False
div_head = ''
gaijis = {}
line_num = ''
opens = {}			# 記錄每一個標記的層次
opens['div'] = 0
old_pb = ''
sutras = {}
globals={}

read_source()
convert()