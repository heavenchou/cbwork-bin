#!/usr/bin/python
# -*- coding: utf-8 *-*
"""
Input: CBETA XML P4
Output: CBETA XML P5
Requirement:
	saxon xslt processor
	Dr. Wittern 寫的 p5-pp.xsl
轉換步驟說明: cbwork/bin/p5/index.htm
Author: Ray Chou 2007.2.16
"""
import codecs, dircache, os, re, sys
import datetime, time

current_date = datetime.date.today()
#dir_in = '/cbwork/xml/T09'
dir_in = '/cbwork/xml'
dir_out = '/release/cbeta-p5'
bindir = '/cbwork/bin/p5'
saxdir = '/cbwork/bin/saxon8-5-1/saxon9.jar'

def fix_cb_encoding(fn):
	print 'now run: ' + fn
	fi=codecs.open(fn, 'r', 'cp950')
	fo=codecs.open('tmp.xml', 'w', 'utf-8')
	buf = ''
	for s in fi:
		s=s.replace('encoding="big5"', 'encoding="utf-8"')
		s=re.sub('<!--.*coding:.*-->', '', s)
		buf += s
	reo = re.compile(r'<!\-\-.*?\-\->', re.S)
	buf = reo.sub('', buf)
	fo.write(buf)
	fo.close()
	fi.close()

def do_file(source, dest, fn):
	#print 'source:	'+source	 #source: /release/cbeta-p4/T09/T09n0262.xml
	#print 'dest:	'+dest	#dest:   /release/cbeta-p5/T09/T09n0262.xml
	fix_cb_encoding(source)#進行編碼會在當前的dir中產生一個tmp.xml
	
	cmd = r'java -Xms128m -Xmx512m -jar %s tmp.xml ' % saxdir
	cmd += r'%s/cbetap4top5.xsl current_date=%s docfile=%s > tmp1.xml' % (bindir, current_date, fn)
	print cmd	
#java -Xms128m -Xmx512m -jar /cbwork/bin/saxon8-5-1/saxon9.jar tmp.xml /cbwork/bin/p5/cbetap4top5.xsl current_date=2008-01-30 docfile=T09n0262.xml > tmp1.xml	
#使用tmp.xml(已經由fix_cb_encoding()轉換編碼)  /cbwork/bin/p5/cbetap4top5.xsl(樣式templates)  進行轉換
	os.system(cmd)
	os.remove('tmp.xml')
	
	cmd = 'java -Xms128m -Xmx512m -jar %s tmp1.xml ' % saxdir
	cmd += r'%s/p5-pp.xsl current_date=%s docfile=%s > %s' % (bindir, current_date, fn, dest)
	print cmd
	os.system(cmd)
	os.remove('tmp1.xml')

#遞迴每個xml檔案
def do_dir(source, dest):
	print 'transform '+source, "=>", dest
	if not os.path.exists(dest): os.makedirs(dest)#自動建立folder結構
	if os.path.isdir(source):
		os.chdir(source)
	l=dircache.listdir(source)
	l.sort()
	for s in l:
		if s == 'dtd' or s=='CVS' or s=='tmp.xml':#排除此3個副檔名
			continue
		if os.path.isdir(source+'/'+s):
			do_dir(source+'/'+s, dest+'/'+s)
		elif re.match(r'^[TX]\d\d.*?\.xml$', s, re.I) != None:#擷取副檔名為.xml的檔案執行do_file()最後同步檔名
		#elif re.match(r'^X\d\d.*?\.xml$', s, re.I) != None:
			if s>'T01':
				do_file(source+'/'+s, dest+'/'+s, s)

start_time = time.time() # 記錄開始執行時間
if len(sys.argv)>1:
	vol = sys.argv[1]
	print vol
	do_dir(dir_in+'/'+vol, dir_out+'/'+vol)
else:
	do_dir(dir_in, dir_out)

# 計算花費時間
t=time.gmtime(time.time()-start_time)
fo=codecs.open('/cbwork/bin/p5/p5-log.txt', 'w', 'utf-8')
fo.write(u"Spend Time: %d days %d hours %d minutes %d seconds" % (t[2]-1, t[3], t[4], t[5]))
fo.close()