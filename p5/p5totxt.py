# -*- coding: utf-8 *-*
'''
環境: Python 3.1
使用方法
	轉某一冊: p5totxt.py -v T01
	轉某一冊且含校勘符號: p5totxt.py -v T01 -k
Ray CHOU 周邦信 2011.6.11
'''
import configparser, datetime, os, re, sys
from optparse import OptionParser
from string import Template
from lxml import etree
import zbx_xml

collectionName={
	"T":"大正新脩大藏經",
	"X":"卍新纂續藏經",
	"J":"嘉興大藏經",
	"H":"正史佛教資料類編",
	"ZS":"正史佛教資料類編",
	"W":"藏外佛教文獻",
	"ZW":"藏外佛教文獻",
	"I":"北朝佛教石刻拓片百品",
	"A":"金藏",
	"B":"大藏經補編",
	"C":"中華大藏經",
	"D":"國家圖書館善本佛典",
	"F":"房山石經",
	"G":"佛教大藏經",
	"K":"高麗大藏經",
	"L":"乾隆大藏經",
	"M":"卍正藏經",
	"N":"永樂南藏",
	"P":"永樂北藏",
	"Q":"磧砂大藏經",
	"S":"宋藏遺珍",
	"U":"洪武南藏",
}

def chineseNumber(num):
	char=("","一","二","三","四","五","六","七","八","九");

	i = num//100
	r = char[i];
	if i!=0: r += "百"
	
	num = num % 100
	i = num//10
	if i==0:
		if r!='' and num!=0: r += "零"
	else:
		if i==1:
			if r=='': r = "十"
			else: r += "一十"
		else:
			r += char[i] + "十"
	
	i = num % 10;
	r += char[i];
	return r

def handleText(s):
	if s is None: return ''
	s=s.replace('\n','')
	s=re.sub(r"(◇){2,}","【◇】",s);
	return s

def traverse(e):
	r=handleText(e.text)
	for child in e.iterchildren():
		r+=handleNode(child)
		r+=handleText(child.tail)
	return r

def getJKMark(e):
	''' 取得校勘符號 '''
	if e is None: return ''
	if e.tag!='anchor': return ''
	if e.get('type')=='circle': return '◎'
	if e.get('type')=='＊': return '[＊]'
	if e.get('type')=='star': return '[＊]'
	if e.get('type')=='cb-app': return ''		# 修訂格式
	id = e.get('id')
	if id is None: return ''
	if id.startswith('fx'): return '[＊]'
	if id.startswith('end'): return ''
	jk = id[-3:]
	jk = re.sub("0(\d\d)", r"\g<1>", jk)		# 如果有三個數字且<100 , 第一個 0 移除
	
	# 處理 kbj => 【科】 【標】 【解】
	if jk[0] == 'k': jk = '【科' + jk[1:] + '】'
	elif jk[0] == 'b': jk = '【標' + jk[1:] + '】'
	elif jk[0] == 'j': jk = '【解' + jk[1:] + '】'
	else: jk = '[' + jk + ']'
	return jk

def handle_anchor(e):
	r=''
	# 如果指定要顯示校勘符號
	if options.jk_mark is not None:
			jk = getJKMark(e)
			id = e.get('id')
			if id is None: r+=jk
			# 如果跟上一個 anchor 的校勘符號不同才顯示, 重複就不顯示
			elif (jk!=getJKMark(e.getprevious()) or jk=='[＊]'): r+=jk 
	return r

def handleNode(e):
	position=e.getparent().index(e)
	r=''
	if e.tag==etree.Comment: return ''
	if e.tag=='anchor': r+=handle_anchor(e)
	elif e.tag=='figure': r+='【圖】'
	elif e.tag=='g':
		ref = e.get('ref')
		ref = ref[1:]
		if ref.startswith('SD') or ref.startswith('RJ'):
			if options.siddham==0: r+=globals['siddham'][ref]
			elif options.siddham==1: r+='&'+ref+';'
			else: r+='◇'
		elif options.gaijiNormalize and ref in globals['gaiji-normal']:
			r+=globals['gaiji-normal'][ref]
		elif ref in globals['zuzishi']:
			r+=globals['zuzishi'][ref]
	elif e.tag=='head':
		if e.get('type')=='added': pass
		else: r+=traverse(e)
	elif e.tag=='item':
		if 'n' in e.attrib: r+=e.get('n')
		r+=traverse(e)
	elif e.tag=='lb':
		globals['lb']=e.get('n')
		if 'ed' in e.attrib and e.get('ed').startswith('R'): pass
		else:
			# 處理大般若經經號 T07n0220e => T07n0220_
			if globals['vol'][0] == 'T' and globals['sutra_no'][0:4] == '0220':
				r += '\n'+globals['vol']+'n0220_'
			else:
				r += '\n'+globals['vol']+'n'+globals['sutra_no']
			if len(globals['sutra_no']) < 5:
				r += '_'
			r += 'p'+ globals['lb'] + '║'
			r += globals['nextLineBuf']
			globals['nextLineBuf']=''
	elif e.tag=='lg':
		type=e.get('type')
		if type=='note2' or type=='note1':
			r= '('+traverse(e)+')'
		else: r=traverse(e)
	elif e.tag=='milestone':
		if e.get('unit')=='juan' and options.splitByJuan: 
			r='juan {}\n'.format(e.get('n'))
	elif e.tag=='mulu': pass
	elif e.tag=='note':
		place=e.get('place')
		if place is not None:
			if 'foot' in place: return ''
			elif 'inline' in place or 'interlinear' in place:
				return '(' + traverse(e) + ')'
		elif 'resp' in e.attrib and e.get('resp').startswith('CBETA'):
			return ''
		r+=traverse(e)
	elif e.tag=='sg': r='('+traverse(e)+')'
	elif e.tag=='t':
		# <cb:tt> 裏面的第一個 <cb:t> 在第一行, 第2個 <cb:t> 要顯示在下一行.
		# <cb:tt rend='inline'> <cb:tt rend='normal'> 則不做隔行處理
		if position==0: r=traverse(e)
		else: 
			if e.getparent().get('rend')=='inline' or e.getparent().get('rend')=='normal' :
				r=traverse(e)
			else:
				globals['nextLineBuf']+=traverse(e)
	elif e.tag=='unclear':
		r='▆'
	else: r+=traverse(e)
	return r

def readCharInfo(tree):
	''' 從 teiHeader 中讀入缺字資訊 '''
	globals['zuzishi']={}
	globals['siddham']={}
	globals['gaiji-normal']={}
	for e in tree.iterfind('.//charDecl/char'):
		id=e.get('id')
		for n in e.iterfind('.//localName'):
			next=n.getnext()
			value=next.text
			if id.startswith('SD') or id.startswith('RJ'):
				if n.text=='Romanized form in Unicode transcription':
					globals['siddham'][id]=value
			else:
				if n.text=='composition': 
					globals['zuzishi'][id]=value
				elif n.text=='normalized form':
					globals['gaiji-normal'][id]=value

def splitByJuan(source, folder_out):
	''' 一卷一檔 '''
	fi=open(source, 'r', encoding='utf8')
	
	s=globals['collection'] + globals['sutra_no'] + '_$juan.txt'
	s=os.path.join(folder_out, s)
	fn_template=Template(s)
	
	header=shortFileHeader()
	path_out=fn_template.substitute(juan='001')
	fo=open(path_out, 'w', encoding='utf8')
	for line in fi:
		mo=re.match('(.*?║)juan (\d+)', line)
		if mo is not None:
			juan='{:03d}'.format(int(mo.group(2)))
			if juan=='001': 
				fo.write(mo.group(1))
				continue
			fo.close()
			line=line.rstrip()
			path_out=fn_template.substitute(juan=juan)
			fo=open(path_out, 'w', encoding='utf8')
			fo.write(header)
			fo.write(mo.group(1))
		else: fo.write(line)
	fo.close()
	fi.close()
	os.remove(source)

def shortFileHeader():
	template = Template('''【經文資訊】$edition_c 第${vol_c}冊 No. ${sutra_no_0}《${title}》CBETA 電子佛典 $cFormat
# $ebib $title, CBETA Chinese Electronic Tripitaka, $eFormat
=========================================================================
''')
	return template.substitute(globals)

def fileHeader(tree):
	global globals
	fileHeadTemplate = Template('''【經文資訊】$edition_c 第${vol_c}冊 No. ${sutra_no_0}《${title}》
【版本記錄】CBETA 電子佛典 V${ver} ($encoding) ${cFormat}，完成日期：${date}
【編輯說明】本資料庫由中華電子佛典協會（CBETA）依${edition_c}所編輯
【原始資料】$ly_zh
【其它事項】本資料庫可自由免費流通，詳細內容請參閱【中華電子佛典協會版權宣告】(http://www.cbeta.org/copyright.htm)
=========================================================================
# $ebib $title
# CBETA Chinese Electronic Tripitaka V${ver} ($encoding) $eFormat, Release Date: $date
# Distributor: Chinese Buddhist Electronic Text Association (CBETA)
# Source material obtained from: $ly_en
# Distributed free of charge. For details please read at http://www.cbeta.org/copyright_e.htm
=========================================================================''')
	globals['edition_c']=collectionName[globals['collection']]
	globals['vol_c']=chineseNumber(int(globals['vol'][1:]))
	title=tree.findtext('.//title')
	globals['title']=title[title.rfind(' ')+1:]
	globals['ver']=tree.findtext("//editionStmt/edition")
	globals['ver']=globals['ver'][11:-2]	# $Revision: 1.29 $ ==> 1.72
	globals['encoding']='UTF-8'
	globals['cFormat']='普及版'
	globals['date']=datetime.date.today().strftime('%Y/%m/%d')
	p=tree.xpath("//projectDesc/p[@lang='zh']")
	globals['ly_zh']=p[0].text
	p=tree.xpath("//projectDesc/p[@lang='en']")
	globals['ly_en']=p[0].text
	globals['ebib']=tree.findtext('.//sourceDesc//bibl')	# T08n0236a.xml 在 <bibl> 之前還有 <p> , 故用 //bibl
	globals['ebib']=re.sub("No. 0*","No. ",globals['ebib'])
	globals['ebib']=re.sub("Vol. 0*","Vol. ",globals['ebib'])
	globals['ebib']=re.sub("\s*$","",globals['ebib'])
	globals['eFormat']='Normalized Version'
	return fileHeadTemplate.substitute(globals)

def handle1sutra(xml, folder_out):
	''' 處理一經 '''
	print(xml)
	fn_in=os.path.basename(xml)
	s=fn_in.replace('.xml','')
	globals['sutra_no']=s[s.find('n')+1:]
	globals['sutra_no_0']=re.sub("^0*","",globals['sutra_no'])	# sutra_no_0 是前面沒有 0 的經號
	print('sutra_no:', globals['sutra_no'])
	fn_out=fn_in.replace('.xml','.txt')
	path_out=os.path.join(folder_out, fn_out)
	fo=open(path_out, 'w', encoding='utf8')
	
	tree=etree.parse(xml)
	tree=zbx_xml.stripNamespaces(tree) # 去掉 namespace
	#zbx_xml.stripComments(tree) # 去掉 xml 註解
	
	if options.fileHeader: fo.write(fileHeader(tree))
	readCharInfo(tree)
	
	body=tree.find('.//body')
	fo.write(handleNode(body))
	fo.close()
	if options.splitByJuan: splitByJuan(path_out, folder_out)

def handle1vol(vol):
	''' 處理一冊 '''
	print(vol)
	globals['vol']=vol
	globals['collection']=vol[0]
	folder_out=os.path.join(outBase,vol[0], vol)
	if not os.path.exists(folder_out): os.makedirs(folder_out)
	p=os.path.join(xmlP5Base, vol[0], vol)
	print(p)
	for s in os.listdir(p):
		if not s.startswith(vol): continue
		x=os.path.join(p, s)
		handle1sutra(x, folder_out)

# main

# 讀取 設定檔 p5tonor.ini
config = configparser.SafeConfigParser()
config.read('p5totxt.ini')
xmlP5Base=config.get('default', 'xmlP5Base')
outBase=config.get('default', 'outBase')
print('Input XML P5 Folder:', xmlP5Base)
print('Output Normal Folder:', outBase)

# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-a", action="store_false", dest="fileHeader", default=True, help="不要檔頭資訊")
parser.add_option("-v", dest="volumn", help="指定要轉換哪一冊")
parser.add_option("-k", action="store_true", dest="jk_mark", help="顯示校勘符號")
parser.add_option("-u", action="store_true", dest="splitByJuan", default=False, help="一卷一檔, 預設是一經一檔")
parser.add_option("-x", type='int', dest="siddham", default='0', help="悉曇字呈現方法: 0=轉寫(預設), 1=entity &SD-xxxx, 2=◇【◇】")
parser.add_option("-z", action="store_false", dest="gaijiNormalize", default=True, help="不使用通用字")
(options, args) = parser.parse_args()

globals={}
globals['nextLineBuf']=''
if options.volumn is not None:
	handle1vol(options.volumn.upper())