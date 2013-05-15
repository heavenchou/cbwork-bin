# -*- coding: utf-8 *-*
'''
功能: 驗證某個目錄下的 XML 檔
設定檔: valid_vol.ini
	設定檔中放置 jing.jar 的位置
命令列參數:
	valid_vol.py -r 驗證用的 rnc 檔的位置 -d 要驗證的目錄 
	valid_vol.py -h 可以看參數說明
	例 : valid_vol.py -r c:/cbwork/xml-p5/schema/cbeta-p5a.rnc -d c:/cbwork/xml-p5/X/X01
需求: Python 3, 安裝 jing (https://code.google.com/p/jing-trang/)
作者: Heaven Chou (2013/03/11)
$Revision: 1.2 $
$Date: 2013/03/11 09:47:33 $
'''

import os, sys, configparser
from optparse import OptionParser

# 驗證某一檔
def validate(xml_file):
	global JING, RNC
	cmd = 'java -Xms64000k -Xmx512000k -jar "{}" -c {} {}'.format(JING, RNC, xml_file)
	r = os.system(cmd)
	if r==1:
		return False
	else:
		return True

# 執行某一檔
def run_file(xml_file):
	if not validate(xml_file):
		print (xml_file + ' 驗證失敗', file=LOG)
		print (xml_file + ' not valid ................')
	else:
		print (xml_file + ' OK')

# 搜尋子目錄
def search_dir(source_dir):
	l=os.listdir(source_dir)
	for s in l:
		file = source_dir+'\\'+s
		if not os.path.isdir(file):
			if(file[-4:] == '.xml'):
				run_file(file)

####################################################################
# 主程式
####################################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-d", dest="source_dir", help="要驗證的資料夾")
parser.add_option("-r", dest="RNC", help="XML驗證檔")
(options, args) = parser.parse_args()
source_dir = options.source_dir
RNC = options.RNC

# 讀取設定檔 valid_vol.ini
config = configparser.SafeConfigParser()
config.read('valid_vol.ini')
JING=config.get('default', 'JING_FILE')

# 設定 log 檔
LOG=open('valid_vol.log', 'a', encoding='utf8')

# 開始在子目錄中執行
search_dir(source_dir)
