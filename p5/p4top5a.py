# -*- coding: utf8 -*-
''' CBETA XML P4 轉 P5a
執行方式
	執行某一冊: p4top5a.py -v t01
	跑大正藏, 從 T02 開始: p4top5a.py -c t -s t02
	執行某一藏經, 例如只跑大正藏: p4top5a.py -c t
	全部, 但從 T02 開始: p4top5a.py -s t02
	執行全部: p4top5a.py
2013.1.3 周邦信 改寫自 cbp4top5.py

Heaven 修改:
2013/08/14 1.所有星號一律使用 <app> 標記, 不要用 <choice>
           2.原書的校勘一律使用 <app> 標記, 不要用 <choice>, 這二者都是因為有ヵ這類的校勘, 再加上有修訂, 之前的版本就變成 <choice> , 應改回 <app>
2013/07/31 修改在 no_normal 的情況下, 通用詞應該只呈現 orig 的內容, 而不是 reg 的內容
2013/07/26 1.將 P4 轉 P5a 的日期指定在 2013/05/20 , 因為後來只是小修改, 也不算是重轉, 因此日期不改, 以利比對新舊版差異.
           2.修改 common/X2R 的目錄至正確的位置
2013/06/09 變數改用設定檔 ../cbwork_bin.ini
'''

import configparser, collections, csv, datetime, glob, os, re, shutil, sys, time
from optparse import OptionParser
from lxml import etree
import zbxxml

# 使用 lxml 3.0.2 的 RelaxNG 在 validate T18n0850 時有問題
#relaxng_doc = etree.parse('D:/git-repos/ddbc-cbeta/schema/cbeta-p5.rng')
#RELAXNG = etree.RelaxNG(relaxng_doc)

time_format='%Y.%m.%d %H:%M'

EMPTY=['anchor', 'lb', 'milestone', 'mulu', 'pb', 'space', 'unclear']

WITS = {
	'A' : '【金藏】',
	'B' : '【補編】',
	'C' : '【中華】',
	'D' : '【國圖】',
	'F' : '【房山】',
	'G' : '【佛教】',
	'H' : '【正史】',
	'I' : '【史】',
	'J' : '【嘉興】',
	'K' : '【麗】',
	'L' : '【龍】',
	'M' : '【卍正】',
	'N' : '【南藏】',
	'P' : '【北藏】',
	'Q' : '【磧砂】',
	'S' : '【宋遺】',
	'T' : '【大】',
	'U' : '【洪武】',
	'W' : '【藏外】',
	'X' : '【卍續】',
}

RESPS = {
	'B' : 'BuBian',
	'D' : 'NCLRareBook',
	'H' : 'Dudoucheng',
	'J' : 'Jiaxing',
	'T' : 'Taisho',
	'W' : 'ZangWai',
	'X' : 'Xuzangjing',
}

LANG_ID = {
	'eng' : 'en',
	'chi' : 'zh',
	'san' : 'sa',
	'pli' : 'pi',
	'san-sd' : 'sa-Sidd',
	'san-rj' : 'sa-x-rj',
	'san-tr' : 'san-tr',
	'chi-yy' : 'zh-x-yy',
	'unknown' : 'x-unknown',
}

RESP2WIT = {
	'Taisho' : '【大】',
}

def resp2wit(resp):
	if '【' in resp:
		return resp
	if resp in RESP2WIT:
		return RESP2WIT[resp]
	else:
		sys.exit('error 73: ' + resp)

def cb2g(cb):
	r = '<g ref="#{}"/>'.format(cb)
	return r

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
		self.counter=collections.Counter()
		#self.apps={}
		self.gaijis={}
		self.char_decl=''
		self.chars = set()

	def handle_text(self, s, mode):
		if s is None: return ''
		r = s
		r=r.replace('&', '&amp;')
		r=r.replace('<', '&lt;')
		return r
		
	def traverse(self, e, mode):
		self.counter['traverse']+=1
		print('\t'*self.counter['traverse']+'traverse', e.tag, ', mode:', mode, file=log)
		if e is None: 
			self.counter['traverse'] -= 1
			return ''
		r=''
		tag=e.tag
		if tag!='change':
			r += self.handle_text(e.text, mode)
		for n in e.iterchildren():
			r+=self.handle_node(n, mode)
			if tag != 'change':
				r += self.handle_text(n.tail, mode)
		print('\t'*self.counter['traverse']+'end traverse', e.tag, ', mode:', mode, file=log)
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
		if type=='no':
			node.tag='cb:docNumber'
			del node.attrib['type']
		if 'body' in mode:
			r = node.open_tag()
			r += self.traverse(e, mode)
			r += node.end_tag()
		else:
			r = self.traverse(e, mode)
		return r
		
	def read_all_gaiji(self):
		ent_file = self.xml_file.replace('.xml', '.ent')
		fi = open(ent_file, 'r', encoding='utf8')
		for line in fi:
			if not line.startswith('<!ENTITY'):
				continue
			mo = re.match('''<!ENTITY (\S+?) "(.*?)" >''', line)
			ent = mo.group(1)
			v = mo.group(2)
			if not v.startswith('<gaiji'):
				self.gaijis[ent] = v
			else:
				e = etree.XML(v)
				cb = e.get('cb', '')
				uni = e.get('uni', '')
				cx = e.get('cx', '')
				nor = e.get('nor', '')
				if uni != '':
					if re.match('[\dA-F]+$', uni):
						r = chr(int(uni, 16))
					elif ';' in uni:
						r = ''
						tokens = uni.split(';')
						for t in tokens:
							if t == '':
								continue
							try:
								r += chr(int(t, 16))
							except:
								sys.exit('error 269: ' + t)
					else:
						r = uni
				elif cx!='':
					self.write_log('246 ' + r)
					dess = re.findall(r'\[[^\]]+?\]', e.get('des'))
					cbs = re.findall('＆(.*?)；', cx)
					count = 0
					r = ''
					for c in cbs:
						r += cb2g(c)
						self.write_log('258 ' + r)
				else:
					r = cb2g(cb)
				self.gaijis[cb] = r
				self.write_log('262 ' + cb + ' => ' + r)
		fi.close()
		
	def handle_note(self, e, mode):
		r=''
		node=MyNode(e)
		# type="orig jie" 轉為 type="orig_jie"
		if 'type' in node.attrib:
			t = e.get('type')
			node.attrib['type'] = t.replace(' ', '_')
		r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
		
	def handle_app_star(self, e, mode):
		# 有星號的部份, 就一定是原書中就有的, 不是 CBETA 自己修改的, 所以不應該用 <choice> , 一定是 <app>
		# 之前產生的 XML 會有 <choice> , 是因為校勘有ヵ這類的校勘及修訂, 所以看起來不像是原書的校勘, 就以為是 CBETA 的修訂了. -- 2013/08/14
		# new_type = app_new_type(e)
		new_type = 'app'
		r = ''
		node = MyNode(e)
		node.attrib['type'] = 'star'
		node.attrib['corresp'] = '#' + e.get('source')
		del node.attrib['source']
		if new_type == 'choice':
			node.tag = 'choice'
			lem = e.find('lem')
			resp = lem.get('resp')
			if resp is not None:
				node.attrib['resp'] = resp
				
			r += node.open_tag()
			
			new_mode = mode.copy()
			new_mode.add('choice')
			r += self.traverse(e, new_mode)
			r += node.end_tag()
		else:
			r += node.open_tag()
			r += self.traverse(e, mode)
			r += node.end_tag()
		return r
		
	def handle_app_nor(self, e, mode):
		self.write_log('handle_app_nor')
		n = e.get('n')
		if n is None:
			node=MyNode(e)
			print(node.open_tag())
			sys.exit()
			
		node=MyNode(e)
		r = node.open_tag()
		r += self.traverse(e, mode)
		r += node.end_tag()
		return r
		
	def handle_app_cb(self, e, mode):
		new_type = app_new_type(e)
		r = ''
		if new_type=='choice':
			node = MyNode(e)
			node.tag = 'choice'
			lem = e.find('lem')
			resp = lem.get('resp')
			if resp is not None:
				node.attrib['resp'] = resp
				
			r += node.open_tag()
			
			new_mode = mode.copy()
			new_mode.add('choice')
			r += self.traverse(e, new_mode)
			r += node.end_tag()
		else:
			node = MyNode(e)
			r += node.open_tag()
			r += self.traverse(e, mode)
			r += node.end_tag()
		return r
		
	def handle_app(self, e, mode):
		self.write_log('handle_app mode:' + str(mode) + ', n:' + e.get('n', ''))
		r=''
		type=e.get('type')
		n=e.get('n')
		if type == '＊':
			r = self.handle_app_star(e, mode)
		elif type=='◎':
			node=MyNode(e)
			print(node.open_tag())
			sys.exit()
		elif n is not None:
			r=self. handle_app_nor(e, mode)
			# 在 2013/2/22 有提到要把一些產生 <app> 的改成 <choice>, 所以上面那一行被 mark 起來, 改成底下的 r=self. handle_app_cb(e, mode)
			# 2013/8/7 我回信說還是改成 <app> 才對, 所以又改用上面的 r=self. handle_app_nor(e, mode) -- 2013/08/14
			#r=self. handle_app_cb(e, mode)
		else:
			r = self.handle_app_cb(e, mode)
		return r
		
	def handle_lem(self, e, mode):
		self.write_log('handle_lem mode:' + str(mode))
		r = ''
		node = MyNode(e)
		if 'choice' in mode: # 如果 app 要改用 choice, 那麼 lem 要改成 corr
			node.tag = 'corr'
			if 'wit' in node.attrib:
				del node.attrib['wit']
			if 'resp' in node.attrib:
				del node.attrib['resp'] # resp 屬性移到 choice
			
		if 'cf1' in node.attrib: del node.attrib['cf1']
		if 'cf2' in node.attrib: del node.attrib['cf2']
		if 'cf3' in node.attrib: del node.attrib['cf3']
		
		r += node.open_tag()
		r += self.traverse(e, mode)
		
		cf1 = e.get('cf1')
		if cf1 is not None: r += '<note type="cf1">' + cf1 + '</note>'
		cf2 = e.get('cf2')
		if cf2 is not None: r += '<note type="cf2">' + cf2 + '</note>'
		cf3 = e.get('cf3')
		if cf3 is not None: r += '<note type="cf3">' + cf3 + '</note>'
		
		r += node.end_tag()
		return r
		
	def handle_rdg(self, e, mode):
		self.write_log('handle_rdg mode:' + str(mode) + ', wit:' + e.get('wit', ''))
		r = ''
		if 'choice' in mode:
			node = MyNode()
			node.tag = 'sic'
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			node=MyNode(e)
			wit = e.get('wit')
			if wit=='【？】':
				node.attrib['resp'] = globals['collection-resp']
				node.attrib['wit'] = resp2wit(e.get('resp'))
				node.attrib['type'] = 'variantRemark'
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
		node = MyNode(e)
		if e.get('place')=='inline':
			if e.get('rend') is None:
				node.attrib['rend'] = 'inline'
				del node.attrib['place']
			else:
				sys.exit('error 441')
		r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
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
		r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
		
	def repl(self, mo):
		k = mo.group(1)
		return self.gaijis[k]

	def attrib_gaiji(self, s):
		s = s.replace('＆unrec；', '<unclear/>')
		s = re.sub('＆(.*?)；', self.repl, s)
		return s
		
	def handle_foreign(self, e, mode):
		node=MyNode(e)
		r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
		
	def handle_sic(self, e, mode):
		n = e.get('n')
		if n is None:
			r = '<app>'
		else:
			r = '<app n="{}">'.format(n)
		node = MyNode()
		node.tag = 'lem'
		node.attrib['resp'] = globals['collection-resp']
		node.attrib['wit'] = globals['collection-wit']
		
		r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		
		node.tag = 'rdg'
		node.attrib['wit'] = resp2wit(e.get('resp'))
		node.attrib['type'] = 'correctionRemark'
		r += node.open_tag() + e.get('corr') + node.end_tag()
		r += '</app>'
		return r
	
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
		r += node.end_tag()
		return r

	def handle_node(self, e, mode):
		global rend_nor
		tag=e.tag
		parent = e.getparent()
		if tag==etree.Comment: return str(e)
		
		# 是否用通用字
		if 'no_nor' in e.get('rend', ''):
			rend_nor.append(False)
		else:
			if rend_nor[-1]:
				rend_nor.append(True)
			else:
				rend_nor.append(False)
		r=''
		if tag=='anchor':
			node = MyNode(e)
			type = e.get('type')
			if type=='◎':
				node.attrib['type'] = 'circle'
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
			d = e.find('date').text
			mo = re.match(r'\d{4}/\d\d/\d\d \d\d:\d\d:\d\d', d)
			if mo is not None:
				d = d.replace('/', '-')
				d = d.replace(' ', 'T')
				node.attrib['when'] = d
			else:
				node.attrib['when'] = d[:4] + '-' + d[4:6] + '-' + d[6:8] + 'T' + d[9:]
			new_mode = change_mode(mode, '', 'change')
			r = node.open_tag() + self.traverse(e, new_mode) + node.end_tag()
		elif tag=='choice':
			#orig = e.find('reg')
			orig = e.find('orig')	# 在不採用通用字的情況下, 對於通用詞應該是用 orig 才對 --2013/07/31
			if orig is None or rend_nor[-1]:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r = self.traverse(orig, mode)
		elif tag=='date':
			if 'change' not in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif re.match('div\d+$', tag):
			node=MyNode(e)
			node.tag = 'cb:div'
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='edition':
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='encodingDesc':
			node = MyNode(e)
			r = node.open_tag() + self.traverse(e, mode)
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
			ent = e.get('entity')[3:]
			r = '<figure>'
			r += '<graphic url="../figures/{}/{}.gif"/>'.format(ent[:1], ent)
			r += '</figure>'
		elif tag=='foreign':
			r = self.handle_foreign(e, mode)
		elif tag=='gaiji':
			cb = e.get('cb')
			if cb is None:
				uni = e.get('uni')
				r = chr(int(uni, 16))
			else:
				r = self.gaijis[cb]
		elif tag=='head':
			r += self.handle_head(e, mode)
		elif tag=='item':
			if 'change' in mode:
				r = self.traverse(e, mode)
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
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='label':
			node = MyNode(e)
			if parent.tag == 'lg':
				node.tag = 'head'
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='language':
			node = MyNode(e)
			id = node.attrib['id']
			node.attrib['ident'] = LANG_ID[id]
			del node.attrib['id']
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='lb':
			n = e.get('n')
			self.write_log('lb ' + n)
			ed = e.get('ed')
			print('lb:', n, file=log)
			if 'body' in mode:
				node=MyNode(e)
				if 'C ' in ed:
					node.attrib['type'] = 'honorific'
					node.attrib['ed'] = ed.replace('C ', '')
				r += node.open_tag()
				if (globals['coll']=='X') and (n not in x2r):
					sys.exit('error 814: ' + n + ' not in x2r')
				if globals['vol'].startswith('X') and 'x' not in x2r[n]:
					r += x2r[n]
		elif tag=='lem':
			r += self.handle_lem(e, mode)
		elif tag=='lg':
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='list':
			node=MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='mulu':
			node = MyNode(e)
			label = e.get('label')
			if label is None:
				label = ''
			else:
				if label == '':
					sys.exit('<mulu label="">')
				label = self.attrib_gaiji(label)
				del node.attrib['label']
			# 2013.4.18 heaven: 樹狀目錄必須以 <mulu n="xx"> 的 xx 來產生, 不能參考 <juan> , 
			# 所以目前 P4 轉 P5a 的 <cb:mulu> 沒有 n 屬性, 這點應該是要麻煩 ray 修改.
			#if 'n' in node.attrib:
			#	del node.attrib['n']
			r += node.open_tag() + label + node.end_tag()
		elif tag=='name':
			if 'change' in mode:
				r = self.traverse(e, mode)
			else:
				node = MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='note':
			r += self.handle_note(e, mode)
		elif tag=='p':
			r += self.handle_p(e, mode)
		elif tag=='pb':
			node = MyNode(e)
			r = node.open_tag()
		elif tag=='rdg':
			r += self.handle_rdg(e, mode)
		elif tag=='ref':
			node = MyNode(e)
			if 'target' in node.attrib:
				node.attrib['target'] = '#' + node.attrib['target']
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='resp':
			if 'change' in mode:
				r = ' (' + self.traverse(e, mode) + ') '
			else:
				node = MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='respStmt':
			if 'change' in mode:
				r = self.traverse(e, mode)
			else:
				node = MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='revisionDesc':
			node=MyNode(e)
			r += node.open_tag()
			#r += '\n\t\t<change when="{}">\n'.format(datetime.date.today()) ?????????????
			r += '\n\t\t<change when="{}">\n'.format("2013-05-20")
			r += '\t\t\t<name>CW</name><name>Ray Chou 周邦信</name>P4 to P5 conversion by p4top5a.py, intended for publication\n'
			r += '\t\t</change>'
			r += self.traverse(e, mode) + node.end_tag()
		elif tag=='sic':
			r = self.handle_sic(e, mode)
		elif tag=='sourceDesc':
			r = self.handle_sourcedesc(e, mode)
		elif tag=='sup':
			r = '<formula rend="vertical-align:super">'
			r += self.traverse(e, mode) + '</formula>'
		elif tag=='t':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='table':
			node = MyNode(e)
			if 'border' in node.attrib:
				node.attrib['rend'] = 'border:' + node.attrib['border']
				del node.attrib['border']
			r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='text':
			node = MyNode(e)
			r += node.open_tag() + self.traverse(e, mode)
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
		rend_nor.pop()
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
			self.tag=e.tag
			self.attrib=collections.OrderedDict(e.attrib)
			
	def open_tag(self):
		# 要歸入 cbeta namespace 的元素
		if self.tag in ('def', 'dialog', 'fan', 'jhead', 'jl_byline', 'jl_juan', 'jl_title', 'juan', 'mulu', 'sg', 't', 'tt', 'yin', 'zi'):
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
				v=LANG_ID[v]
			elif k=='place':
				if self.tag in ('entry', 'foreign', 'lg'):
					k = 'cb:place'
			elif k=='resp':
				if self.tag in ('choice', 'foreign'):
					k = 'cb:resp'
			elif k=='type':
				if self.tag in ('byline', 'choice', 'p', 'sp'):
					k = 'cb:type'
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

####################################################################################

def app_new_type(e):
	''' lem 及 rdg 最多只有 【CBETA】【CB】【大】 , 沒有其他的版本, 就是 choice 
	lem 或 rdg 有出現  【CBETA】【CB】【大】之外其他的版本, 就是 app
	以上是針對大正藏, 若是嘉興, 就是把【大】換成【嘉興】, 其餘類推. '''

	wits=''
	for c in e.iterchildren():
		wits += c.get('wit', '')
	wits = wits.replace('【CBETA】','')
	wits = wits.replace('【CB】','')
	col=globals['vol'][:1]
	wits = wits.replace(WITS[col], '')
	if wits=='':
		return 'choice'
	else:
		return 'app'

############################
# phase1
############################

def phase1(vol,path):
	'''
	CBETA P4 裡有8個非 Big5 標準的字: 碁銹裏墻恒恒粧嫺
	這幾個字, XSLT 不會自動將它轉到對應的 Unicode
	所以在 phase1 將 P4 XML, ent 檔案轉成 UTF8
	'''
	print('phase1',path)
	dest=PHASE1DIR+'/'+vol+'/'+os.path.basename(path)
	fo=open(dest.replace('.xml','.ent'), 'w', encoding='utf8')
	with open(path.replace('.xml','.ent'),'r',encoding='cp950') as fi:
		s=fi.read()
		s=re.sub('^(<\?xml version="1.0" encoding=")big5', r'\1UTF-8', s)
		fo.write(s)
		if 'ENTITY' not in s:
			fo.write('<!ENTITY DUMMY "dummy" >')
	fo.close()
	
	fi=open(path, 'r', encoding='cp950')
	s=fi.read()
	fi.close()
	s=re.sub('^(<\?xml version="1.0" encoding=")cp950(" \?>)', r'\1UTF-8\2', s)
	s=re.sub('^(<\?xml version="1.0" encoding=")big5(" \?>)', r'\1UTF-8\2', s)
	s = s.replace('$ (Big5)<date>', '$<date>')
	s=s.replace('&unrec;', '<unclear/>')
	s=s.replace('&lac;', '<space quantity="0"/>')
	s=s.replace('&lac-space;','<space quantity="1" unit="chars"/>')
	s=s.replace('\r\n<pb ', '<pb ')
	s=s.replace('CBETA.Maha', 'CBETA.maha')
	s=s.replace('CBETA.cp', 'CBETA.pan')
	s = re.sub('([A-Za-z]+?)<sup>([^<]+?)</sup>', r'<formula>\1<hi rend="vertical-align:super">\2</hi></formula>', s, flags=re.DOTALL)
	s = re.sub('&(CI[^;]*?);', replaceTongYongCi, s, flags=re.DOTALL)
	fo=open(dest, 'w', encoding='utf8')
	fo.write(s)
	fo.close()

def replaceTongYongCi(mo):
	ent = mo.group(1)
	r = tongYongCiTable[ent]
	return r

############################
# phase2
############################

def phase2(vol,path):
	''' call cbetap4top5.xsl '''
	print('phase2', path)
	print(path, file=log)
	fn=os.path.basename(path)
	file_id=fn.rpartition('.')[0]
	text = '''<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" xml:id="{}">'''.format(file_id)
	t=MyTransformer(path)
	t.read_all_gaiji()
	text += t.traverse(t.root, mode=set(['body']))
	text += '</TEI>'
	out_fn=os.path.join(PHASE2DIR, vol, fn)
	fo=open(out_fn, 'w', encoding='utf8')
	fo.write(text)
	fo.close()

############################
# phase3
############################

def phase3(vol,p):
	print('phase3 vol=%s p=%s' % (vol,p))
	fi=open(p, 'r', encoding='utf8')
	s=fi.read()
	fi.close()
	
	s=s.replace('＆lac-space；', '<space quantity="1" unit="chars"/>')
	s=s.replace('＆lac；', '<space quantity="0"/>')
	
	# 把 <lg> 下面的文字, 移到第一個 <l> 裏
	#s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(.*?)(<l>|<l [^>]*?>)', r'\1\3\2', s) 
	#s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)((?:<l>|<l [^>]*?>)「)((?:<anchor[^>]*?/>)+)', r'\1\3\2', s)
	
	# 把 <anchor> 前後多餘的換行去掉
	s=re.sub(r'\n+(<anchor )', r'\1', s)
	s=re.sub(r'(<anchor [^>]*>)\n+', r'\1', s)
	
	# lb, pb 之前要換行
	s=re.sub('>(<lb[^>]*?ed="%s)' % vol[0], r'>\n\1', s)
	s=re.sub(r'([^\n])<pb ', r'\1\n<pb ', s)
	
	# 如果 sourceDesc 下有 <p> 的話, listWit 要放在 p 裡面.
	s = re.sub(r'(</p>)\s*(<listWit>.*?</listWit>)', r'\n\2\1', s, flags=re.DOTALL)
	
	fo=open(OUT_P5a+'/'+vol[:1]+'/'+vol+'/'+os.path.basename(p),'w', encoding='utf8')
	fo.write(s)
	fo.close()

def spend_time(secs):
	r='Spend time: '
	if secs<60: r+='%.2f seconds' % secs
	else: r+='%.1f minutes' % (secs/60)
	return r
	
def read_x2r(vol):
	fn = cbwork_dir + '/common/X2R/' + vol + 'R.txt'
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

############################
# 處理一冊
############################

def do1vol(vol):
	global globals, x2r
	globals['vol'] = vol
	coll = vol[:1]
	globals['coll'] = coll
	globals['collection-wit'] = WITS[coll] # 如果冊數 T 開頭, 就是 【大】
	if coll in RESPS:
		globals['collection-resp'] = RESPS[coll] # 如果冊數 T 開頭, 就是 Taisho
	
	time_begin=time.time()
	print(now())
	
	# phase-1 #################################
	
	print(vol,'phase-1')
	os.makedirs(PHASE1DIR+'/'+vol, exist_ok=True)
	for p in glob.iglob(XML_P4+'/'+vol+'/*.xml'):
		phase1(vol,p)
	
	if vol.startswith('X'):
		x2r = read_x2r(vol)
	
	# phase-2 #################################
	
	print(vol, 'phase-2')
	os.makedirs(PHASE2DIR+'/'+vol, exist_ok=True)
	for p in glob.iglob(PHASE1DIR+'/'+vol+'/*.xml'):
		phase2(vol,p)
	
	# phase-3 #################################
	
	print(vol, 'phase-3')
	os.makedirs(OUT_P5a+'/'+vol[:1], exist_ok=True)
	os.makedirs(OUT_P5a+'/'+vol[:1]+'/'+vol, exist_ok=True)
	for p in glob.iglob(PHASE2DIR+'/'+vol+'/*.xml'):
		phase3(vol,p)
	
	# validate #################################
	
	for p in glob.iglob(OUT_P5a+'/'+vol[:1]+'/'+vol+'/*.xml'): 
		print('validate', p)
		if not zbxxml.validate(p, RNC, JING):
			sys.exit(p + ' not vlaid')
		#tree = etree.parse(p)
		#RELAXNG.assertValid(tree)

	s=spend_time(time.time()-time_begin)
	print(vol, s)
	log.write(vol+' '+s+'\n')

############################
# 處理整個目錄
############################

def do1dir(dir):
	vols=os.listdir(dir)
	vols.sort()
	for vol in vols:
		if not re.match(r'[A-Z]\d{2,3}', vol): 
			continue
		if (options.collection is None) or re.match(r'[%s]\d{2,3}' % options.collection, vol): 
			if vol in ('T56', 'T57'): continue
			if options.vol_start is not None:
				if vol<options.vol_start: continue
			do1vol(vol)

def now():
	return time.strftime(time_format)

def tongYongCiToUnicode(s):
	tokens = re.findall('&[^;]*?;|.', s)
	r = ''
	for t in tokens:
		if t.startswith('&CB'):
			t = t[3:-1]
			uni = cb2uni.get(t, '')
			if uni=='':
				r += cb2g('CB'+t)
			else:
				r += '&#x{};'.format(uni)
		else:
			r += t
	return r

def createTongYongCiTable():
	''' 建立通用詞 entity 取代表
	P5a 的版本是內部使用, 所以在文字上直接用 unicode , 通用詞也直接用 <choice> 標記 + unicode文字. 
	P5 是對外的, CBReader 也是使用此版, 文字上在 unicode 1.0 以外的字就使用 <g> 標記, 
	通用詞也是使用 <choice> 標記, 同樣通用詞中 unicode 1.0 以外的字就使用 <g> 標記
	'''
	global cb2uni, cb2gaijiTag
	r = {}
	with open(GAIJI, encoding='utf8') as infile:
		reader = csv.DictReader(infile,  delimiter='\t')
		for row in reader:
			cb = row['cb']
			uni = row['unicode']
			if cb != '' and uni != '':
				cb2uni[cb] = uni
			ent = row['entity']
			if ent.startswith('CI'):
				cx = row['cx']
				s = tongYongCiToUnicode(cx)
				r[ent] = '<choice><orig>{}</orig><reg type="通用詞">{}</reg></choice>'.format(s, row['nor'])
	return r

####################################################################
# 主程式
####################################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option('-c', dest='collection', help='collections (e.g. TXJ...)')
parser.add_option('-s', dest='vol_start', help='start volumn (e.g. x55)')
parser.add_option('-v', dest='volumn', help='volumn (e.g. x55)')
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

XML_P4 = cbwork_dir + '/xml' 			# 從這裡讀 P4 XML
PHASE1DIR = CBTEMP + '/cbetap5a-tmp1'	# 暫存資料夾
PHASE2DIR = CBTEMP + '/cbetap5a-tmp2'	# 暫存資料夾
OUT_P5a = CBTEMP + '/cbetap5a-ok' 		# 最後結果
RNC = cbwork_dir + '/xml-p5a/schema/cbeta-p5a.rnc'
GAIJI = cbwork_dir + '/bin/gaiji-m_u8.txt'

globals={}
cb2uni = {}
cb2gaijiTag = {}
rend_nor = [True]
tongYongCiTable = createTongYongCiTable()

log=open('p4top5a.log', 'w', encoding='utf8')
log.write(now()+'\n')

os.makedirs(PHASE1DIR, exist_ok=True)
dtd_path = os.path.join(PHASE1DIR, 'dtd')
os.makedirs(dtd_path, exist_ok=True)
shutil.copyfile('cbeta.ent', os.path.join(dtd_path, 'cbeta.ent'))
shutil.copyfile('jap.ent', os.path.join(dtd_path, 'jap.ent'))
os.makedirs(PHASE2DIR, exist_ok=True)
os.makedirs(OUT_P5a, exist_ok=True)

if options.volumn is not None:
	do1vol(options.volumn.upper())
else:
	do1dir(XML_P4)
print()
print(now())
log.write(now())