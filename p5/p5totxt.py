# -*- coding: utf-8 *-*
'''
環境: Python 3.1
使用方法
	轉某一冊: p5totxt.py -v T01
	轉某一冊且含校勘符號: p5totxt.py -v T01 -k
Ray CHOU 周邦信 2011.6.11

Heaven 修改:
2016/04/19 增加佛寺志 GA , GB 的全名
2014/06/17 原西蓮代碼 "SL" 改成 智諭 "ZY", 取消西蓮專用目錄
2014/03/12 處理一卷一檔且不呈現檔頭的 bug
2014/03/12 把 XML P5 的來源加入設定檔中
2014/03/09 把呈現的校勘[1-1]改成[01]
2013/10/11 處理百品的 <unclear ...>...</unclear> 標記
2013/10/03 處理大般若經相關的經名問題, 也就是去除 0220 之後的英文字母
2013/10/03 處理 T42n1828.xml 的 <ref>
2013/08/26 處理藏經代碼為二位數的情況, 例如西蓮淨苑的 'SL'
2013/08/16 處理 <term> 卻非 <term rend='no_nor'> 而沒有呈現內容的問題
2013/08/02 處理 <text rend='no_nor'> 及 <term rend='no_nor'> , 讓這二種標記的範圍內不使用通用字
2013/08/01 增加悉曇字有 big5 的呈現字
2013/07/30 normal 版只呈現 <anchor xml:id="nkr_note_orig_xxxxx" 這種格式的校勘數字
2013/07/21 CBETA 自己加上的 note 不需要呈現校勘數字 <anchor xml:id="nkr_3f0"/>
2013/06/28 第二卷之後卷首加上版本資訊
2013/06/25 取消版本與日期的呈現, 非正式版不使用日期與版本
2013/06/24 修改校勘數字呈現, [a01] 改成 [01]
2013/06/09 將設定檔改為 ../cbwork_bin.ini
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
	"DA":"道安長老全集",
	"F":"房山石經",
	"G":"佛教大藏經",
	"GA":"中國佛寺史志彙刊",
	"GB":"中國佛寺志叢刊",
	"K":"高麗大藏經",
	"L":"乾隆大藏經",
	"M":"卍正藏經",
	"N":"漢譯南傳大藏經",
	"P":"永樂北藏",
	"Q":"磧砂大藏經",
	"S":"宋藏遺珍",
	"ZY":"智諭老和尚著作全集",
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
	#s=re.sub(r"(◇){2,}","【◇】",s);	# 最後再處理, 否則在隔行對照的地方無法成功處理
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
	if not id.startswith('nkr_note_orig'): return ''	# 例 T01n0026.xml => <lb n="0574a12" ed="T"/>眠、調<anchor xml:id="nkr_3f0"/>
	jk = id
	jk = re.sub("\-\d{1,3}$", r"", jk)
	jk = jk[-3:]
	jk = re.sub("0(\d\d)", r"\g<1>", jk)		# 如果有三個數字且<100 , 第一個 0 移除
	
	# 處理 kbj => 【科】 【標】 【解】
	if jk[0] == 'k': jk = '【科' + jk[1:] + '】'
	elif jk[0] == 'b': jk = '【標' + jk[1:] + '】'
	elif jk[0] == 'j': jk = '【解' + jk[1:] + '】'
	else:
		jk = re.sub("\D(\d\d)", r"\g<1>", jk)		# 如果前面不是數字則移除
		jk = '[' + jk + ']'
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
			if options.siddham==0: r+=globals['siddham'][ref]	# 沒有羅馬轉寫的字怎麼辦? 這裡會有錯誤 , T54n2132.xml 的 SD-CFC3 ??????
			elif options.siddham==1: r+='&'+ref+';'
			else: 
				#if ref in globals['siddham-big5']:		#有一種悉曇字是有 big5 字的 -- 2013/08/01
				#	r += globals['siddham-big5'][ref]
				#else:
				#	r += '◇'
				r += '◇'								# 想想, 還是直接用 ◇ , 未來應該直接用羅馬轉寫字來比對
		elif options.gaijiNormalize and ref in globals['gaiji-normal'] and globals['no_nor'] == 0:
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
			#if globals['vol'][0] == 'T' and globals['sutra_no'][0:4] == '0220':
			#	r += '\n'+globals['vol']+'n0220_'
			#else:
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
		# 有二種情況
		# 一般是 <unclear/> , 直接呈現 ▆
		# 另一種是百品的 <unclear cert="medium" reason="damage">之</unclear> , 這種就不理它  - 2013/10/11
		cert = e.get('cert')
		if cert : r += traverse(e)
		else : r = '▆'
	elif e.tag=='ref':
		# 漢譯南傳大藏經 : <ref target="#PTS.Vin.3.2"></ref>
		# T42n1828.xml : <ref rend="margin-left:2em" target="../T30/T30n1579.xml#xpath2(//0279a03)">論本卷第一</ref>
		# T49n2035.xml : <ref target="list4">天台智者禪師○</ref>
		target = e.get('target')
		mo=re.match('#PTS\..*\.(\d+)', target)
		if mo is not None:
			r = ' ' + mo.group(1) + ' '
		r += traverse(e)
	elif e.tag=='term':
		# <term rend="no_nor"> , 這種的就不要使用通用字
		if e.get('rend') == 'no_nor':
			globals['no_nor'] += 1
			r += traverse(e)
			globals['no_nor'] -= 1
		else: r+=traverse(e)
	else: r+=traverse(e)
	return r

def readCharInfo(tree):
	''' 從 teiHeader 中讀入缺字資訊 '''
	globals['zuzishi']={}
	globals['siddham']={}
	globals['siddham-big5']={}
	globals['gaiji-normal']={}
	for e in tree.iterfind('.//charDecl/char'):
		id=e.get('id')
		for n in e.iterfind('.//localName'):
			next=n.getnext()
			value=next.text
			if id.startswith('SD') or id.startswith('RJ'):
				if n.text=='Romanized form in Unicode transcription':
					# 沒有羅馬轉寫的字怎麼辦? T54n2132.xml 的 SD-CFC3 ??????
					globals['siddham'][id]=value
				'''
				有一種悉曇字是有 big5 字的 -- 2013/08/01
				<char xml:id="SD-E347">
					<charName>CBETA CHARACTER SD-E347</charName>
					<charProp>
						<localName>big5</localName>
						<value>□</value>
				'''
				if n.text=='big5':
					globals['siddham-big5'][id]=value
			else:
				if n.text=='composition': 
					globals['zuzishi'][id]=value
				elif n.text=='normalized form':
					globals['gaiji-normal'][id]=value

def splitByJuan(source, folder_out):
	''' 一卷一檔 '''
	
	# 逐行讀入, 若遇到 juan \d+ 表示換卷了(除非是第一次遇到)
	# 遇到新卷時, 先把舊的寫入檔案中
	# 最後再寫入最後一卷
	
	fi=open(source, 'r', encoding='utf8')
	
	s=globals['collection'] + globals['sutra_no'] + '_$juan.txt'
	s=os.path.join(folder_out, s)
	fn_template=Template(s)		# 檔名的模版
	
	header = ''
	if options.fileHeader:		# 是否要印出卷首資訊
		header=shortFileHeader()	# 第二卷之後的卷首
	
	juan_pre = ''		# 上一卷的卷數
	juan_txt = ''		# 記錄每一卷的內文
	for line in fi:
		mo=re.match('(.*?║)juan (\d+)', line)
		if mo is not None:
			juan='{:03d}'.format(int(mo.group(2)))
			if juan_pre == '': 
				juan_txt += mo.group(1)
				juan_pre = juan
				continue
			
			# 在此換卷了, 所以要寫入檔案
			
			path_out=fn_template.substitute(juan=juan_pre)
			fo=open(path_out, 'w', encoding='utf8')
			fo.write(juan_txt)
			fo.close()
			juan_pre = juan
			# 新的一卷的起始內容
			juan_txt = header
			juan_txt += mo.group(1)
			line=line.rstrip()
		else: juan_txt += line
	
	# 寫入最後一卷
	path_out=fn_template.substitute(juan=juan)
	fo=open(path_out, 'w', encoding='utf8')
	fo.write(juan_txt)
	fo.close()
	fi.close()
	os.remove(source)	# 移除還未分卷的大檔

def splitByJuan_old(source, folder_out):
	''' 一卷一檔 '''
	fi=open(source, 'r', encoding='utf8')
	
	s=globals['collection'] + globals['sutra_no'] + '_$juan.txt'
	s=os.path.join(folder_out, s)
	fn_template=Template(s)
	
	header=shortFileHeader()
	path_out=fn_template.substitute(juan='001')
	fo=open(path_out, 'w', encoding='utf8')
	juan_counter = 0	# 記錄目前是第幾卷
	for line in fi:
		mo=re.match('(.*?║)juan (\d+)', line)
		if mo is not None:
			juan_counter += 1
			juan='{:03d}'.format(int(mo.group(2)))
			if juan_counter==1: 
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
	os.remove(source)	# 移除還未分卷的大檔

def shortFileHeader():
	template = Template('''【經文資訊】$edition_c 第${vol_c}冊 No. ${sutra_no_0}《${title}》CBETA 電子佛典 V${ver} $cFormat
# $ebib $title, CBETA Chinese Electronic Tripitaka V${ver}, $eFormat
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
	mo=re.search(r'^\D+(\d+)', globals['vol'])
	globals['vol_c']=chineseNumber(int(mo.group(1)))
	#title=tree.findtext('.//title')
	# 不能用上面的方法, 因為有些 title 裡面還有缺字的標記
	title_tag=tree.find('.//title')
	title = handleNode(title_tag)
	globals['title']=title[title.rfind(' ')+1:]
	#globals['ver']=tree.findtext("//editionStmt/edition")
	#globals['ver']=globals['ver'][11:-2]	# $Revision: 1.29 $ ==> 1.72
	globals['ver']='v.v'						# 非正式版不使用日期與版本
	globals['encoding']='UTF-8'
	globals['cFormat']='普及版'
	#globals['date']=datetime.date.today().strftime('%Y/%m/%d')
	globals['date']= 'yyyy/mm/dd'				#非正式版不使用日期與版本
	p=tree.xpath("//projectDesc/p[@lang='zh']")
	globals['ly_zh']=p[0].text
	p=tree.xpath("//projectDesc/p[@lang='en']")
	globals['ly_en']=p[0].text
	globals['ebib']=tree.findtext('.//sourceDesc//bibl')	# T08n0236a.xml 在 <bibl> 之前還有 <p> , 故用 //bibl
	globals['ebib']=re.sub("No. 0*","No. ",globals['ebib'])
	globals['ebib']=re.sub("Vol. 0*","Vol. ",globals['ebib'])
	if globals['collection'] == 'T':
		globals['ebib']=re.sub(r"No. 220[a-z]","No. 220",globals['ebib'])
	globals['ebib']=re.sub("\s*$","",globals['ebib'])
	globals['eFormat']='Normalized Version'
	return fileHeadTemplate.substitute(globals)

def handle1sutra(xml, folder_out):
	''' 處理一經 '''
	print(xml)
	fn_in=os.path.basename(xml)
	s=fn_in.replace('.xml','')
	globals['sutra_no']=s[s.find('n')+1:]
	if globals['collection'] == 'T':
		globals['sutra_no']=re.sub("0220[a-z]","0220",globals['sutra_no'])	# 大般若經經號後面的 a-z 移除
	globals['sutra_no_0']=re.sub("^0*","",globals['sutra_no'])	# sutra_no_0 是前面沒有 0 的經號
	print('sutra_no:', globals['sutra_no'])
	fn_out=fn_in.replace('.xml','.txt')
	path_out=os.path.join(folder_out, fn_out)
	
	fo=open(path_out, 'w', encoding='utf8')

	tree=etree.parse(xml)
	tree=zbx_xml.stripNamespaces(tree) # 去掉 namespace
	#zbx_xml.stripComments(tree) # 去掉 xml 註解
	
	readCharInfo(tree)
	if options.fileHeader:		# 是否要印出卷首資訊		
		mo=re.search(r'T07n0220[d-z]', xml)
		if mo is not None:
			# T07n0220d 之後的不要印出詳細卷首
			tmp=fileHeader(tree)	# 還是要先執行, 以取得需要的資料
			tmp=shortFileHeader()
			tmp=tmp[:-1]			# 移除最後一個 '換行', 只有 T07 此處才需要
			fo.write(tmp)
		else:
			fo.write(fileHeader(tree))
	
	# 處理 <text rend='no_nor'> 的情況
	globals['no_nor'] = 0
	text_tag = tree.find('.//text')
	if text_tag.get('rend') == 'no_nor': globals['no_nor'] += 1
	
	body=tree.find('.//body')
	outtxt = handleNode(body)
	# 在這裡處理連續悉曇字
	outtxt = re.sub(r"((（)|(［)|(？)|(…)|(．)|(‧))*◇((◇)|( )|(　)|(．)|(‧)|(（)|(）)|(［)|(］)|(？)|(…))*◇((）)|(］)|(？)|(…)|(．)|(‧))*","【◇】",outtxt);
	fo.write(outtxt)
	fo.close()
	if options.splitByJuan: splitByJuan(path_out, folder_out)

def handle1vol(vol):
	''' 處理一冊 '''
	print(vol)
	globals['vol']=vol
	mo = re.search(r'^\D+', vol)
	ed = mo.group()
	globals['collection']=ed
	folder_out=os.path.join(outBase, ed, vol)
	if not os.path.exists(folder_out): os.makedirs(folder_out)
	p=os.path.join(xmlP5Base, ed, vol)
	print(p)
	for s in os.listdir(p):
		if not s.startswith(vol): continue
		x=os.path.join(p, s)
		handle1sutra(x, folder_out)

####################################################################
# 主程式
####################################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-a", action="store_false", dest="fileHeader", default=True, help="不要檔頭資訊")
parser.add_option("-v", dest="volumn", help="指定要轉換哪一冊")
parser.add_option("-k", action="store_true", dest="jk_mark", help="顯示校勘符號")
parser.add_option("-u", action="store_true", dest="splitByJuan", default=False, help="一卷一檔, 預設是一經一檔")
parser.add_option("-x", type='int', dest="siddham", default='0', help="悉曇字呈現方法: 0=轉寫(預設), 1=entity &SD-xxxx, 2=◇【◇】")
parser.add_option("-z", action="store_false", dest="gaijiNormalize", default=True, help="不使用通用字")
(options, args) = parser.parse_args()

# 讀取 設定檔 cbwork_bin.ini
config = configparser.SafeConfigParser()
config.read('../cbwork_bin.ini')
xmlP5Base = config.get('p5totxt', 'xml_p5')
outBase = config.get('p5totxt', 'output_dir')

print('Input XML P5 Folder:', xmlP5Base)
print('Output Normal Folder:', outBase)

globals={}
globals['nextLineBuf']=''
if options.volumn is not None:
	handle1vol(options.volumn.upper())