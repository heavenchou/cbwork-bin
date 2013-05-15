# -*- coding: utf8 -*-
'''
2010.10.16-12.20 Ray Chou
'''
import codecs,datetime,glob,os,re,shutil,sys,time
from optparse import OptionParser

data_dir=os.environ['DATADIR'] 
phase1dir=os.environ['PHASE1DIR']
phase2dir=os.environ['PHASE2DIR']
phase3dir=os.environ['PHASE3DIR']
phase4dir=os.environ['PHASE4DIR']
time_format='%Y.%m.%d %H:%M'

def my_mkdir(p):
	if not os.path.exists(p): os.mkdir(p)

def gen_gaiji(vol):
	print('gen_gaiji', vol)
	os.chdir(os.environ['GAIJIDIR'])
	cmd='java -Xms64000k -Xmx1024000k -cp "%s" ' % os.environ['SAXON']
	cmd+='net.sf.saxon.Query %s/gen-gaijixml.xq ' % os.environ['BINDIR']
	cmd+='coll=%s > %s' % (os.environ['COLLDIR']+'/'+vol+'.xml', vol+'.xml')
	print(cmd)
	os.system(cmd)

def phase1(vol,path):
	'''
	CBETA P4 裡有8個非 Big5 標準的字: 碁銹裏墻恒恒粧嫺
	這幾個字, XSLT 不會自動將它轉到對應的 Unicode
	所以在 phase1 將 P4 XML, ent 檔案轉成 UTF8
	'''
	print('\nphase1',path)
	fi=codecs.open(path,'r','cp950')
	s=fi.read()
	fi.close()
	s=re.sub('^(<\?xml version="1.0" encoding=")cp950(" \?>)', r'\1utf8\2', s)
	s=re.sub('^(<\?xml version="1.0" encoding=")big5(" \?>)', r'\1utf8\2', s)
	s=s.replace('&unrec;', '<unclear/>')
	s=s.replace('&lac;', '<space quantity="0"/>')
	s=s.replace('&lac-space;','<space quantity="1" unit="chars"/>')
	s=s.replace('\r\n<pb ', '<pb ')
	s=s.replace('CBETA.Maha', 'CBETA.maha')
	s=s.replace('CBETA.cp', 'CBETA.pan')
	dest=phase1dir+'/'+vol+'/'+os.path.basename(path)
	fo=codecs.open(dest, 'w', 'utf8')
	fo.write(s)
	fo.close()
	with open(path.replace('.xml','.ent'),'r',encoding='cp950') as fi:
		s=fi.read()
		s=re.sub('^(<\?xml version="1.0" encoding=")big5', r'\1utf8', s)
	with open(dest.replace('.xml','.ent'),'w',encoding='utf8') as fo:
		fo.write(s)

def phase2(vol,path):
	''' call cbetap4top5.xsl '''
	print('\nphase2',path)
	fn=os.path.basename(path)
	cmd='java -Xms64000k -Xmx512000k -jar "%s" ' % os.environ['SAXON'] 
	cmd += path + ' %s/cbetap4top5.xsl ' % os.environ['BINDIR']
	cmd += 'current_date=%s ' % datetime.date.today().strftime('%Y-%m-%d')
	cmd += 'docfile=%s ' % fn
	cmd += 'convtabdir=%s ' % os.environ['CONVTABDIR']
	cmd += '> %s/%s/%s' % (phase2dir, vol, fn)
	log.write(cmd+'\n')
	os.system(cmd)

def phase3(vol,path):
	''' call p5-pp.xsl '''
	print('\nphase3',path)
	cmd='java -Xms64000k -Xmx512000k -jar "%s" ' % os.environ['SAXON']
	cmd+=path
	cmd+=' %s/p5-pp.xsl ' % os.environ['BINDIR']
	cmd+='current_date=%s ' % datetime.date.today().strftime('%Y-%m-%d')
	cmd+='docfile=%s ' % path
	cmd+='gpath=%s ' % os.environ['GAIJIDIR']
	cmd+='> %s/%s/%s' % (phase3dir,vol,os.path.basename(path))
	print(cmd)
	os.system(cmd)

def validate(p):
	print('\nvalidate',p)
	tempFile = os.environ['VALRESDIR'] + '/temp.txt'
	#os.system('echo %s >> %s' % (p, val_log))
	cmd='java -Xms64000k -Xmx512000k -jar "%s" ' % os.environ['JING']
	cmd+='-c  %s/cbeta-p5.rnc ' % os.environ['BINDIR']
	cmd+='%s 2>&1 > %s' % (p, tempFile)
	os.system(cmd)
	with open(tempFile,'r') as fi:
		msg=fi.read()
	if msg!='':
		with open(val_log,'a') as fo:
			fo.write(p+'\n')
			fo.write(msg)

def phase4(vol,p):
	print('\nphase4 vol=%s p=%s' % (vol,p))
	fi=codecs.open(p,'r','utf8')
	s=fi.read()
	fi.close()
	
	s=s.replace('＆lac-space；', '<space quantity="1" unit="chars"/>')
	s=s.replace('＆lac；', '<space quantity="0"/>')
	
	# 把 <lg> 下面的文字, 移到第一個 <l> 裏
	s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(.*?)(<l[^>]*?>)', r'\1\3\2', s) 
	s=re.sub(r'(<lg[^>]*?>(?:<head.*?</head>)?)(<l[^>]*?>「)((?:<anchor[^>]*?/>)+)', r'\1\3\2', s)
	
	# 把 <anchor> 前後多餘的換行去掉
	s=re.sub(r'\n+(<anchor )', r'\1', s)
	s=re.sub(r'(<anchor [^>]*>)\n+', r'\1', s)
	
	# lb, pb 之前要換行
	s=re.sub('>(<lb[^>]*?ed="%s)' % vol[0], r'>\n\1', s)
	s=re.sub(r'([^\n])<pb ', r'\1\n<pb ', s)
	
	fo=codecs.open(phase4dir+'/'+vol[:1]+'/'+vol+'/'+os.path.basename(p),'w','utf8')
	fo.write(s)
	fo.close()

def spend_time(secs):
	r='Spend time: '
	if secs<60: r+='%.1f seconds' % secs
	else: r+='%.1f minutes' % (secs/60)
	return r

def do1vol(vol):
	time_begin=time.time()
	print(now())
	coll_xml=os.environ['COLLDIR']+'/'+vol+'.xml'
	fo=codecs.open(coll_xml, 'w', 'utf8')
	fo.write("<collection>\n")
	print(vol,'phase-1')
	my_mkdir(phase1dir+'/'+vol)
	for p in glob.iglob(data_dir+'/'+vol+'/*.xml'): phase1(vol,p)
	
	print(vol, 'phase-2 cbetap4top5.xsl')
	my_mkdir(phase2dir+'/'+vol)
	for p in glob.iglob(phase1dir+'/'+vol+'/*.xml'):
		f=os.path.basename(p)
		fo.write('<doc href="%s/%s/%s"/>\n' % (phase1dir,vol,f))
		phase2(vol,p)
	fo.write("</collection>\n")
	fo.close()
	gen_gaiji(vol)
	
	print(vol, 'phase-3 p5-pp.xsl')
	my_mkdir(phase3dir+'/'+vol)
	for p in glob.iglob(phase2dir+'/'+vol+'/*.xml'):  phase3(vol,p)
	
	print(vol, 'phase-4')
	my_mkdir(phase4dir+'/'+vol[:1])
	my_mkdir(phase4dir+'/'+vol[:1]+'/'+vol)
	for p in glob.iglob(phase3dir+'/'+vol+'/*.xml'): phase4(vol,p)
	
	print(vol, 'validate')
	for p in glob.iglob(phase4dir+'/'+vol[:1]+'/'+vol+'/*.xml'): validate(p)
	s=spend_time(time.time()-time_begin)
	print(vol, s)
	log.write(vol+' '+s+'\n')

def do1dir(dir):
	vols=os.listdir(dir)
	vols.sort()
	for vol in vols:
		#if re.match(r'[TXJHWI]\d{2,3}', vol): 
		if (options.collection is None) or re.match(r'[%s]\d{2,3}' % options.collection, vol): 
			if vol in ('T56', 'T57'): continue
			if options.vol_start is not None:
				if vol<options.vol_start: continue
			do1vol(vol)
def now():
	return time.strftime(time_format)

# main
parser = OptionParser()
parser.add_option('-c', dest='collection', help='collections (e.g. TXJ...)')
parser.add_option('-s', dest='vol_start', help='start volumn (e.g. x55)')
parser.add_option('-v', dest='volumn', help='volumn (e.g. x55)')
(options, args) = parser.parse_args()

val_log='%s/results-phase2.txt' % os.environ['VALRESDIR']
	
log=codecs.open('cbp4top5.log', 'w', 'utf8')
log.write(now()+'\n')
if os.path.exists(val_log): os.remove(val_log)
my_mkdir(phase1dir)
my_mkdir(phase2dir)
my_mkdir(phase3dir)
my_mkdir(phase4dir)
if options.volumn is not None:
	do1vol(options.volumn.upper())
else:
	do1dir(data_dir)
print()
print(now())
log.write(now())