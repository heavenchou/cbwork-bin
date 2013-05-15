# -*- coding: utf-8 *-*
'''
b5-u8.py
功能: 
	將目錄下(含子目錄)所有 big5 檔案轉為 utf-8, 
	若遇組字式, 查 cbeta gaiji-m.mdb, 以 unicode 呈現
	extension-b 仍然維持組字式
使用方法:
	Usage: b5-u8.py [options]

	Options:
	  -h, --help  查看參數說明
	  -s SOURCE   來源資料夾
	  -o OUTPUT   輸出資料夾
	例: b5-u8.py -s d:/temp/J23 -o d:/temp/J23U8
需求: Python 3.2, PythonWin
2011.6.18 改寫使用 python 3
作者: 周邦信 2009.05.26
'''

#################################################

gaiji = '/cbwork/work/bin/gaiji-m.mdb' # 缺字資料庫路徑

import os, codecs, re, sys
from optparse import OptionParser
import win32com.client		# 要安裝 PythonWin

#################################################
# 處理單檔
#################################################
def trans_file(fn1, fn2):
	print( fn1 + ' => ' + fn2)
	f1=codecs.open(fn1, "r", "cp950")
	f2=codecs.open(fn2, "w", "utf-8")
	reo=re.compile(r'\[[^>\[]*?\]') # 組字式
	for line in f1:
		line=reo.sub(repl,line)	# 處理組字式
		line=trans_roma(line)	# 處理羅馬轉寫字
		f2.write(line)
	f1.close()
	f2.close()
	
#################################################
# 逐一處理各目錄
#################################################
def trans_dir(source, dest):
	if not os.path.exists(dest): os.makedirs(dest)
	l=os.listdir(source)
	for s in l:
		if os.path.isdir(source+'/'+s):
			trans_dir(source+'/'+s, dest+'/'+s)
		else:
			trans_file(source+'/'+s, dest+'/'+s)

#################################################
# 處理組字式
#################################################
def repl(mo):
	zuzi=mo.group()
	#print(zuzi)
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	sql = "SELECT unicode FROM gaiji WHERE ((des='%s') AND (cb<='99999'))" % zuzi
	rs.Open(sql, conn, 1, 3)
	if rs.RecordCount > 0:
		u = rs.Fields.Item('unicode').Value
		if u!=None: # and len(u)<5: 	# 大於4碼的 extension-b 仍然用組字式, 這又取消了
			c=chr(int(u,16))
			return c
	return zuzi
	
#################################################
# 讀取全部的羅馬轉寫字
#################################################
def get_roma():
	global romas
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	sql = "SELECT unicode, nor FROM gaiji WHERE ((cb Is Null) AND (nor Is Not Null) AND (unicode Is Not Null))"
	rs.Open(sql, conn, 1, 3)
	rs.MoveFirst()
	while 1:
		if rs.EOF:
			break
		else:
			nor = rs.Fields.Item('nor').Value		# 通用字
			uni = rs.Fields.Item('unicode').Value	# unicode
			romas[nor] = chr(int(uni,16))
			rs.MoveNext()

#################################################
# 轉換羅馬轉寫字成 unicode
#################################################
def trans_roma(line):
	global romas
	for nor in romas:
		line=line.replace(nor, romas[nor])
	return line
	
#################################################
# main 主程式
#################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-s", dest="source", help="來源資料夾")
parser.add_option("-o", dest="output", help="輸出資料夾")
(options, args) = parser.parse_args()

# 準備存取 gaiji-m.mdb
conn = win32com.client.Dispatch(r'ADODB.Connection')
DSN = 'PROVIDER=Microsoft.Jet.OLEDB.4.0;DATA SOURCE=%s;' % gaiji
conn.Open(DSN)

# 先讀取羅馬轉寫字
romas = {}	# 宣告用來放羅馬拼音, ex { '`o' : '00F3' }
get_roma()

trans_dir(options.source, options.output)