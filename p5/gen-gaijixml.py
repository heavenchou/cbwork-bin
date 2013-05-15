# -*- coding: utf8 -*-
''' 產生 cbetatmp/gaiji/*, cbetatmp/coll/*
改寫自 gen-gaijixml.sh
執行環境: Windows 7, Python 3
'''
import glob,os,re
from optparse import OptionParser

__author__ = 'Ray Chou'
__email__ = 'zhoubx@gmail.com'
__license__ = 'GPL http://www.gnu.org/licenses/gpl.txt'
__date__ = '2011.5.4'

gaijiDir=os.environ['GAIJIDIR']
dataDir=os.environ['DATADIR']
binDir=os.environ['BINDIR']
collDir=os.environ['COLLDIR']
saxon=os.environ['SAXON']
phase1Dir=os.environ['PHASE1DIR']

def phase1(vol,path):
	'''CBETA P4 裡有8個非 Big5 標準的字: 碁銹裏墻恒恒粧嫺
	這幾個字, XSLT 不會自動將它轉到對應的 Unicode
	所以在 phase1 將 P4 XML, ent 檔案轉成 UTF8
	'''
	print('phase1',path)
	fi=open(path,'r',encoding='cp950')
	s=fi.read()
	fi.close()
	s=re.sub('^(<\?xml version="1.0" encoding=")cp950(" \?>)', r'\1utf8\2', s)
	s=s.replace('&unrec;', '<unclear/>')
	s=s.replace('&lac;', '<space quantity="0"/>')
	s=s.replace('&lac-space;','<space quantity="1" unit="chars"/>')
	s=s.replace('\r\n<pb ', '<pb ')
	s=s.replace('CBETA.Maha', 'CBETA.maha')
	s=s.replace('CBETA.cp', 'CBETA.pan')
	destDir=phase1Dir+'/'+vol
	if not os.path.exists(destDir): os.mkdir(destDir)
	dest=destDir+'/'+os.path.basename(path)
	fo=open(dest, 'w', encoding='utf8')
	fo.write(s)
	fo.close()
	with open(path.replace('.xml','.ent'),'r',encoding='cp950') as fi:
		s=fi.read()
		s=re.sub('^(<\?xml version="1.0" encoding=")big5', r'\1utf8', s)
	with open(dest.replace('.xml','.ent'),'w',encoding='utf8') as fo:
		fo.write(s)

parser = OptionParser()
parser.add_option('-c', dest='collection', help='collections (e.g. TXJ...)')
(options, args) = parser.parse_args()

vols=os.listdir(dataDir)
vols.sort()
for vol in vols:
	if re.match(r'[%s]\d{2,3}' % options.collection, vol): 
		p=dataDir+'/'+vol
		fn_out=collDir+'/'+vol+'.xml'
		with open(fn_out, 'w') as fo:
			fo.write("<collection>\n")
			files=os.listdir(p)
			for f in files:
				if f.endswith('.xml'):
					fo.write( '\t<doc href="%s/%s/%s"/>\n' % (phase1Dir,vol,f) )
					phase1(vol,p+'/'+f)
			fo.write("</collection>")

os.chdir(gaijiDir)
vols=os.listdir(collDir)
vols.sort()
for vol in vols:
	if re.match(r'[%s]\d{2,3}' % options.collection, vol): 
		cmd='java -Xms64000k -Xmx1024000k -cp "{0}" net.sf.saxon.Query {1}/gen-gaijixml.xq coll={3}/{2} > {2}'.format(saxon,binDir,vol,collDir)
		print(cmd)
		os.system(cmd)
