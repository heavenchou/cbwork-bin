# -*- coding: utf8 -*-
''' CBETA XML P5a 轉 P5
2013.1.4 周邦信 改寫自 cbp4top5.py
'''
import collections, csv, datetime, glob, os, re, shutil, sys, time
from optparse import OptionParser
from lxml import etree
import zbxxml, siddam, ranjana

CBTEMP = 'c:/temp'
IN_P5a = CBTEMP + '/cbetap5a-ok' # XML P5a 來源資料夾
PHASE1DIR = CBTEMP + '/cbetap5-tmp1' # 暫存資料夾
OUT_P5 = CBTEMP + '/cbetap5-ok' # 最後結果
BINDIR = 'D:/1Projects/1998-CBETA/bin-p4'
GAIJI = '/cbwork/bin/gaiji-m_u8.txt'
JING = '/bin/jing/bin/jing.jar'
RNC = '/cbwork/xml-p5/schema/cbeta-p5.rnc'

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

RESP2WIT = {
	'Taisho' : '【大】',
}

# global variables
resp_id={}
wit_id={}

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

def read_all_resp(root):
	global resp_id
	for e in root.iter(tag=etree.Element):
		resp=e.get('resp', '')
		resps = resp.split()
		for r in resps:
			if r not in resp_id:
					resp_id[r]='resp{}'.format(len(resp_id)+1)
					
def handle_resp(resp):
	resps = resp.split()
	result = []
	for r in resps:
		result.append(resp_id[r])
	return '#' + ' '.join(result)

def read_all_wit(root):
	global wit_id
	for e in root.iter(tag=etree.Element):
		wit=e.get('wit', '')
		wits = re.findall('【.*?】', wit)
		for w in wits:
			if w not in wit_id:
				wit_id[w]='wit{}'.format(len(wit_id)+1)

def handle_wit(wit):
	global wit_id
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
			# Ext-A: U+3400–U+4DFF, 屬於 Unicode 3.0
			if code>0xffff or (code>=0x3400 and code<=0x4DFF):
				hex = '{:X}'.format(code)
				cb = unicode2cb[hex]
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
			r+=self.handle_node(n, mode)
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
		if 'body' in mode:
			r = node.open_tag()
			r += self.traverse(e, mode)
			r += node.end_tag()
		else:
			r = self.traverse(e, mode)
		return r
		
	def prepare_charDecl(self):
		r = ''
		for cb in sorted(self.gaijis):
			r += '<char xml:id="{}">\n'.format(cb)
			r += '\t<charName>CBETA CHARACTER {}</charName>\n'.format(cb)
			attrib = get_gaiji_info(cb)
			for k, v in sorted(attrib.items()):
				if k != 'unicode':
					r += '\t<charProp>\n'
					r += '\t\t<localName>'
					if k == 'des':
						r += 'composition'
					elif k in ('big5', 'uniflag', 'nor_uni', 'rjchar'):
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
			
		new_mode = change_mode(mode, 'body', 'back')
		back = node.open_tag() + self.traverse(e, new_mode) + node.end_tag() + '\n'
		self.write_log('247 back: ' + back)
		self.back_notes[type] += back
		
	def handle_note(self, e, mode):
		r=''
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
			else:
				node=MyNode(e)
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		else:
			if (e.get('place') in ('inline', 'interlinear')) or type in ('cf1', 'cf2', 'cf3'):
				node=MyNode(e)
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		return r
		
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
		if target not in self.anchors:
			self.anchors.append(target)
			r+='<anchor xml:id="{}" n="{}"/>'.format(target, n)
		r += self.traverse(e, mode)
		id = 'end' + n
		if id not in self.anchors:
			self.anchors.append(id)
			r+='<anchor xml:id="{}"/>'.format(id)
			
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
			node.attrib['cb:from'] = 'beg_{}'.format(id)
			node.attrib['cb:to'] = 'end_{}'.format(id)
			lem = e.find('lem')
			resp = lem.get('resp')
			if resp is not None:
				node.attrib['resp'] = resp
			type = e.get('type')
			if type is not None:
				node.attrib['cb:type'] = type
			self.back['app'] += node.open_tag()
			new_mode = change_mode(mode, 'body', 'back')
			new_mode.add('choice')
			self.back['app'] += self.traverse(e, new_mode)
			self.back['app'] += node.end_tag() + '\n'
		else:
			node = MyNode(e)
			node.attrib['from'] = 'beg_{}'.format(id)
			node.attrib['to'] = 'end_{}'.format(id)
			new_mode = change_mode(mode, 'body', 'back')
			self.back['app'] += node.open_tag()
			self.back['app'] += self.traverse(e, new_mode)
			self.back['app'] += node.end_tag() + '\n'
		return r
		
	def handle_app(self, e, mode):
		self.write_log('handle_app mode:' + str(mode) + ', n:' + e.get('n', ''))
		r=''
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
				r=self. handle_app_nor(e, mode)
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
		if 'body' in mode:
			id = self.new_anchor_id()
			r = '<anchor xml:id="beg_{}" type="cb-app"/>'.format(id)
			corr = e.find('corr')
			if corr is None:
				orig = e.find('orig')
				r += self.traverse(orig, mode)
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
		if 'choice' in mode:
			if 'back' in mode:
				node = MyNode()
				node.tag = 'sic'
				r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif 'back' in mode:
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
		r = ''
		if 'body' in mode:
			type=e.get('type', '')
			if type=='app':
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
				node = MyNode(e)
				node.attrib['from'] = 'beg{}'.format(n)
				node.attrib['to'] = 'end{}'.format(n)
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
		else:
			r = self.traverse(e, mode)
		return r
		
	def handle_foreign(self, e, mode):
		r =''
		place = e.get('place', '')
		n = e.get('n')
		node=MyNode(e)
		resp = e.get('resp')
		if place=='foot':
			target = 'beg' + n
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
			if 'body' in mode:
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
				r += self.traverse(e, mode)
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
			self.gaijis.add(cb)
			node = MyNode(e)
			r = node.open_tag() + chr(cb2pua(cb)) + node.end_tag()
		elif tag=='graphic':
			node=MyNode(e)
			r = node.open_tag() + self.traverse(e, mode) + node.end_tag()
		elif tag=='head':
			r += self.handle_head(e, mode)
		elif tag=='item':
			if 'back' in mode:
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
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.traverse(e, mode)
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
			if 'body' in mode:
				node=MyNode(e)
				if 'C ' in ed:
					node.attrib['type'] = 'honorific'
					node.attrib['ed'] = ed.replace('C ', '')
				r += node.open_tag()
				#if (globals['coll']=='X') and (n not in x2r):
				#	sys.exit('error 814: ' + n + ' not in x2r')
				#if globals['vol'].startswith('X') and 'x' not in x2r[n]:
				#	r += x2r[n]
		elif tag=='lem':
			r += self.handle_lem(e, mode)
		elif tag=='lg':
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.traverse(e, mode)
		elif tag=='list':
			if 'body' in mode:
				node=MyNode(e)
				r += node.open_tag() + self.traverse(e, mode) + node.end_tag()
			else:
				r += self.traverse(e, mode)
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

def my_mkdir(p):
	if not os.path.exists(p): os.mkdir(p)

def handle_back(t):
	r = '\n<back>\n'
	if t.back['app']!='':
		r += '<cb:div type="apparatus">\n'
		r += '<head>校勘記</head>\n'
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
		if k=='BuBian':
			r += '<cb:div type="bubian-notes">\n'
			r += '<head>大藏經補編 校勘記</head>\n'
		elif k=='CBETA':
			r += '<cb:div type="cbeta-notes">\n'
			r += '<head>CBETA 校勘記</head>\n'
		elif k=='Dudoucheng':
			r += '<cb:div type=" Dudoucheng-notes">\n'
			r += '<head>正史佛教資料類编 校勘記</head>\n'
		elif k=='ihp':
			r += '<cb:div type="ihp-notes">\n'
			r += '<head>中央研究院歷史語言研究所 校勘記</head>\n'
		elif k=='NCLRareBook':
			r += '<cb:div type="ncl-notes">\n'
			r += '<head>國家圖書館善本佛典 校勘記</head>\n'
		elif k=='Northern Yongle Edition of the Canon':
			r += '<cb:div type="yongle-notes">\n'
			r += '<head>永樂北藏 校勘記</head>\n'
		elif k=='Taisho':
			r += '<cb:div type="taisho-notes">\n'
			r += '<head>大正 校勘記</head>\n'
		elif k=='Xuzangjing':
			r += '<cb:div type="xuzang-notes">\n'
			r += '<head>卍續藏 校勘記</head>\n'
		elif k=='ZangWai':
			r += '<cb:div type="zangwai-notes">\n'
			r += '<head>方廣錩 校勘記</head>\n'
		elif k=='equivalent':
			r += '<cb:div type="equiv-notes">\n'
			r += '<head>相對應巴利文書名</head>\n'
		elif k=='rest':
			if t.back_notes[k] =='':
				continue
			r += '<cb:div type="rest-notes">\n'
			r += '<head>其他註解</head>\n'
		else:
			sys.exit('error 1000: ' + k)
		r += '<p>\n'
		r += t.back_notes[k]
		r += '</p>\n'
		r += '</cb:div>\n'
		
	r += '</back>'
	return r

def phase1(vol,path):
	print('phase1', path)
	print(path, file=log)
	fn=os.path.basename(path)
	file_id=fn.rpartition('.')[0]
	text = '''<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" xml:id="{}">'''.format(file_id)

	t=MyTransformer(path)
	read_all_resp(t.root)
	read_all_wit(t.root)
	text += t.traverse(t.root, mode=set(['body']))
	text += '</TEI>'
	
	char_decl = t.prepare_charDecl()
	text = text.replace('<charDecl></charDecl>', char_decl)

	out_fn=os.path.join(PHASE1DIR, vol[:1], vol, fn)
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

def phase2(vol,p):
	print('phase2 vol=%s p=%s' % (vol,p))
	fi=open(p, 'r', encoding='utf8')
	s=fi.read()
	fi.close()
	
	# 把 <lg> 下面的文字, 移到第一個 <l> 裏
	s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(.*?)(<l[^>]*?>)', r'\1\3\2', s) 
	
	#s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(<l[^>]*?>「)((?:<anchor[^>]*?/>)+)', r'\1\3\2', s)
	s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(.*?)(</lg>)', repl_lg, s, flags=re.DOTALL)
	
	# 把 <anchor> 前後多餘的換行去掉
	s=re.sub(r'\n+(<anchor )', r'\1', s)
	s=re.sub(r'(<anchor [^>]*>)\n+', r'\1', s)
	
	# lb, pb 之前要換行
	s=re.sub('>(<lb[^>]*?ed="%s)' % vol[0], r'>\n\1', s)
	s=re.sub(r'([^\n])<pb ', r'\1\n<pb ', s)
	
	# 如果 sourceDesc 下有 <p> 的話, listWit 要放在 p 裡面.
	s = re.sub(r'(</p>)\s*(<listWit>.*?</listWit>)', r'\n\2\1', s, flags=re.DOTALL)
	
	fo=open(OUT_P5+'/'+vol[:1]+'/'+vol+'/'+os.path.basename(p),'w', encoding='utf8')
	fo.write(s)
	fo.close()

def spend_time(secs):
	r='Spend time: '
	if secs<60: r+='%.2f seconds' % secs
	else: r+='%.1f minutes' % (secs/60)
	return r
	
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
	
	# P5a 已有卍續藏的 R 版行號, 就不需再產生了
	#if vol.startswith('X'):
	#	x2r = read_x2r(vol)
	
	print(vol, 'phase-1')
	my_mkdir(PHASE1DIR+'/'+coll)
	my_mkdir(PHASE1DIR+'/'+coll+'/'+vol)
	for p in glob.iglob(IN_P5a+'/'+coll+'/'+vol+'/*.xml'):
		phase1(vol,p)
	
	print(vol, 'phase-2')
	my_mkdir(OUT_P5+'/'+vol[:1])
	my_mkdir(OUT_P5+'/'+vol[:1]+'/'+vol)
	for p in glob.iglob(PHASE1DIR+'/'+coll+'/'+vol+'/*.xml'): 
		phase2(vol,p)
	
	for p in glob.iglob(OUT_P5+'/'+coll+'/'+vol+'/*.xml'): 
		print('validate', p)
		#tree = etree.parse(p)
		#if not RELAXNG.validate(tree):
		if not zbxxml.validate(p, RNC, JING):
			sys.exit(p + ' is not valid')

	s=spend_time(time.time()-time_begin)
	print(vol, s)
	log.write(vol+' '+s+'\n')

def do1dir(dir):
	colls=os.listdir(dir)
	colls.sort()
	for coll in colls:
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
			if cb != '':
				cb = 'CB' + cb
				r[cb] = {}
				if row['des'] != '':
					r[cb]['des'] = row['des']
				if row['nor'] != '':
					r[cb]['nor'] = row['nor']
				if uni != '':
					r[cb]['unicode'] = uni
			if uni != '':
				unicode2cb[uni] = cb
	return r

# main
parser = OptionParser()
parser.add_option('-c', dest='collection', help='collections (e.g. TXJ...)')
parser.add_option('-s', dest='vol_start', help='start volumn (e.g. x55)')
parser.add_option('-v', dest='volumn', help='volumn (e.g. x55)')
(options, args) = parser.parse_args()

if options.collection is not None:
	options.collection = options.collection.upper()
if options.vol_start is not None:
	options.vol_start = options.vol_start.upper()

globals={}
unicode2cb = {}
all_gaijis=read_all_gaijis()

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