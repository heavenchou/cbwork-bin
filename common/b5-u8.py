﻿# -*- coding: utf-8 *-*
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

Heaven 修改:
2013/10/20 修改缺字的讀取, 由逐字查詢資料庫改成一次讀取全部資料庫
2013/10/16 將日文拼音及 &M 碼轉成日文unicode
2013/06/09 變數改用設定檔 ../cbwork_bin.ini
'''

#################################################

import configparser, os, codecs, re, sys
from optparse import OptionParser
import win32com.client		# 要安裝 PythonWin


#################################################
# 處理日文
#################################################
def trans_jap(line):
	matchObj = re.search( r'【.*?】', line, re.UNICODE)
	if matchObj:
		line = line.replace('【a】' , 'あ')
		line = line.replace('【i】' , 'い')
		line = line.replace('【u】' , 'う')
		line = line.replace('【e】' , 'え')
		line = line.replace('【o】' , 'お')
		line = line.replace('【ka】' , 'か')
		line = line.replace('【ga】' , 'が')
		line = line.replace('【ki】' , 'き')
		line = line.replace('【gi】' , 'ぎ')
		line = line.replace('【ku】' , 'く')
		line = line.replace('【gu】' , 'ぐ')
		line = line.replace('【ke】' , 'け')
		line = line.replace('【ge】' , 'げ')
		line = line.replace('【ko】' , 'こ')
		line = line.replace('【go】' , 'ご')
		line = line.replace('【sa】' , 'さ')
		line = line.replace('【za】' , 'ざ')
		line = line.replace('【shi】' , 'し')
		line = line.replace('【zi】' , 'じ')
		line = line.replace('【su】' , 'す')
		line = line.replace('【zu】' , 'ず')
		line = line.replace('【se】' , 'せ')
		line = line.replace('【ze】' , 'ぜ')
		line = line.replace('【so】' , 'そ')
		line = line.replace('【zo】' , 'ぞ')
		line = line.replace('【ta】' , 'た')
		line = line.replace('【da】' , 'だ')
		line = line.replace('【chi】' , 'ち')
		line = line.replace('【di】' , 'ぢ')
		line = line.replace('【tsu】' , 'つ')
		line = line.replace('【du】' , 'づ')
		line = line.replace('【te】' , 'て')
		line = line.replace('【de】' , 'で')
		line = line.replace('【to】' , 'と')
		line = line.replace('【do】' , 'ど')
		line = line.replace('【na】' , 'な')
		line = line.replace('【ni】' , 'に')
		line = line.replace('【nu】' , 'ぬ')
		line = line.replace('【ne】' , 'ね')
		line = line.replace('【no】' , 'の')
		line = line.replace('【ha】' , 'は')
		line = line.replace('【ba】' , 'ば')
		line = line.replace('【pa】' , 'ぱ')
		line = line.replace('【hi】' , 'ひ')
		line = line.replace('【bi】' , 'び')
		line = line.replace('【pi】' , 'ぴ')
		line = line.replace('【hu】' , 'ふ')
		line = line.replace('【bu】' , 'ぶ')
		line = line.replace('【pu】' , 'ぷ')
		line = line.replace('【he】' , 'へ')
		line = line.replace('【be】' , 'べ')
		line = line.replace('【pe】' , 'ぺ')
		line = line.replace('【ho】' , 'ほ')
		line = line.replace('【bo】' , 'ぼ')
		line = line.replace('【po】' , 'ぽ')
		line = line.replace('【ma】' , 'ま')
		line = line.replace('【mi】' , 'み')
		line = line.replace('【mu】' , 'む')
		line = line.replace('【me】' , 'め')
		line = line.replace('【mo】' , 'も')
		line = line.replace('【ya】' , 'や')
		line = line.replace('【yu】' , 'ゆ')
		line = line.replace('【yo】' , 'よ')
		line = line.replace('【ra】' , 'ら')
		line = line.replace('【ri】' , 'り')
		line = line.replace('【ru】' , 'る')
		line = line.replace('【re】' , 'れ')
		line = line.replace('【ro】' , 'ろ')
		line = line.replace('【wa】' , 'わ')
		line = line.replace('【wi】' , 'ゐ')
		line = line.replace('【we】' , 'ゑ')
		line = line.replace('【wo】' , 'を')
		line = line.replace('【n】' , 'ん')
		line = line.replace('【A】' , 'ア')
		line = line.replace('【I】' , 'イ')
		line = line.replace('【U】' , 'ウ')
		line = line.replace('【E】' , 'エ')
		line = line.replace('【O】' , 'オ')
		line = line.replace('【KA】' , 'カ')
		line = line.replace('【GA】' , 'ガ')
		line = line.replace('【KI】' , 'キ')
		line = line.replace('【GI】' , 'ギ')
		line = line.replace('【KU】' , 'ク')
		line = line.replace('【GU】' , 'グ')
		line = line.replace('【KE】' , 'ケ')
		line = line.replace('【GE】' , 'ゲ')
		line = line.replace('【KO】' , 'コ')
		line = line.replace('【GO】' , 'ゴ')
		line = line.replace('【SA】' , 'サ')
		line = line.replace('【ZA】' , 'ザ')
		line = line.replace('【SHI】' , 'シ')
		line = line.replace('【ZI】' , 'ジ')
		line = line.replace('【SU】' , 'ス')
		line = line.replace('【ZU】' , 'ズ')
		line = line.replace('【SE】' , 'セ')
		line = line.replace('【ZE】' , 'ゼ')
		line = line.replace('【SO】' , 'ソ')
		line = line.replace('【ZO】' , 'ゾ')
		line = line.replace('【TA】' , 'タ')
		line = line.replace('【DA】' , 'ダ')
		line = line.replace('【CHI】' , 'チ')
		line = line.replace('【DI】' , 'ヂ')
		line = line.replace('【TSU】' , 'ツ')
		line = line.replace('【DU】' , 'ヅ')
		line = line.replace('【TE】' , 'テ')
		line = line.replace('【DE】' , 'デ')
		line = line.replace('【TO】' , 'ト')
		line = line.replace('【DO】' , 'ド')
		line = line.replace('【NA】' , 'ナ')
		line = line.replace('【NI】' , 'ニ')
		line = line.replace('【NU】' , 'ヌ')
		line = line.replace('【NE】' , 'ネ')
		line = line.replace('【NO】' , 'ノ')
		line = line.replace('【HA】' , 'ハ')
		line = line.replace('【BA】' , 'バ')
		line = line.replace('【PA】' , 'パ')
		line = line.replace('【HI】' , 'ヒ')
		line = line.replace('【BI】' , 'ビ')
		line = line.replace('【PI】' , 'ピ')
		line = line.replace('【HU】' , 'フ')
		line = line.replace('【BU】' , 'ブ')
		line = line.replace('【PU】' , 'プ')
		line = line.replace('【HE】' , 'ヘ')
		line = line.replace('【BE】' , 'ベ')
		line = line.replace('【PE】' , 'ペ')
		line = line.replace('【HO】' , 'ホ')
		line = line.replace('【BO】' , 'ボ')
		line = line.replace('【PO】' , 'ポ')
		line = line.replace('【MA】' , 'マ')
		line = line.replace('【MI】' , 'ミ')
		line = line.replace('【MU】' , 'ム')
		line = line.replace('【ME】' , 'メ')
		line = line.replace('【MO】' , 'モ')
		line = line.replace('【YA】' , 'ヤ')
		line = line.replace('【YU】' , 'ユ')
		line = line.replace('【YO】' , 'ヨ')
		line = line.replace('【RA】' , 'ラ')
		line = line.replace('【RI】' , 'リ')
		line = line.replace('【RU】' , 'ル')
		line = line.replace('【RE】' , 'レ')
		line = line.replace('【RO】' , 'ロ')
		line = line.replace('【WA】' , 'ワ')
		line = line.replace('【WI】' , 'ヰ')
		line = line.replace('【WE】' , 'ヱ')
		line = line.replace('【WO】' , 'ヲ')
		line = line.replace('【N】' , 'ン')
		line = line.replace('【VU】' , 'ヴ')
	matchObj = re.search( r'&M', line, re.UNICODE)
	if matchObj:
		line = line.replace('&M062301;' , 'ぁ')
		line = line.replace('&M062302;' , 'あ')
		line = line.replace('&M062303;' , 'ぃ')
		line = line.replace('&M062304;' , 'い')
		line = line.replace('&M062305;' , 'ぅ')
		line = line.replace('&M062306;' , 'う')
		line = line.replace('&M062307;' , 'ぇ')
		line = line.replace('&M062308;' , 'え')
		line = line.replace('&M062309;' , 'ぉ')
		line = line.replace('&M062310;' , 'お')
		line = line.replace('&M062311;' , 'か')
		line = line.replace('&M062312;' , 'が')
		line = line.replace('&M062313;' , 'き')
		line = line.replace('&M062314;' , 'ぎ')
		line = line.replace('&M062315;' , 'く')
		line = line.replace('&M062316;' , 'ぐ')
		line = line.replace('&M062317;' , 'け')
		line = line.replace('&M062318;' , 'げ')
		line = line.replace('&M062319;' , 'こ')
		line = line.replace('&M062320;' , 'ご')
		line = line.replace('&M062321;' , 'さ')
		line = line.replace('&M062322;' , 'ざ')
		line = line.replace('&M062323;' , 'し')
		line = line.replace('&M062324;' , 'じ')
		line = line.replace('&M062325;' , 'す')
		line = line.replace('&M062326;' , 'ず')
		line = line.replace('&M062327;' , 'せ')
		line = line.replace('&M062328;' , 'ぜ')
		line = line.replace('&M062329;' , 'そ')
		line = line.replace('&M062330;' , 'ぞ')
		line = line.replace('&M062331;' , 'た')
		line = line.replace('&M062332;' , 'だ')
		line = line.replace('&M062333;' , 'ち')
		line = line.replace('&M062334;' , 'ぢ')
		line = line.replace('&M062335;' , 'っ')
		line = line.replace('&M062336;' , 'つ')
		line = line.replace('&M062337;' , 'づ')
		line = line.replace('&M062338;' , 'て')
		line = line.replace('&M062339;' , 'で')
		line = line.replace('&M062340;' , 'と')
		line = line.replace('&M062341;' , 'ど')
		line = line.replace('&M062342;' , 'な')
		line = line.replace('&M062343;' , 'に')
		line = line.replace('&M062344;' , 'ぬ')
		line = line.replace('&M062345;' , 'ね')
		line = line.replace('&M062346;' , 'の')
		line = line.replace('&M062347;' , 'は')
		line = line.replace('&M062348;' , 'ば')
		line = line.replace('&M062349;' , 'ぱ')
		line = line.replace('&M062350;' , 'ひ')
		line = line.replace('&M062351;' , 'び')
		line = line.replace('&M062352;' , 'ぴ')
		line = line.replace('&M062353;' , 'ふ')
		line = line.replace('&M062354;' , 'ぶ')
		line = line.replace('&M062355;' , 'ぷ')
		line = line.replace('&M062356;' , 'へ')
		line = line.replace('&M062357;' , 'べ')
		line = line.replace('&M062358;' , 'ぺ')
		line = line.replace('&M062359;' , 'ほ')
		line = line.replace('&M062360;' , 'ぼ')
		line = line.replace('&M062361;' , 'ぽ')
		line = line.replace('&M062362;' , 'ま')
		line = line.replace('&M062363;' , 'み')
		line = line.replace('&M062364;' , 'む')
		line = line.replace('&M062365;' , 'め')
		line = line.replace('&M062366;' , 'も')
		line = line.replace('&M062367;' , 'ゃ')
		line = line.replace('&M062368;' , 'や')
		line = line.replace('&M062369;' , 'ゅ')
		line = line.replace('&M062370;' , 'ゆ')
		line = line.replace('&M062371;' , 'ょ')
		line = line.replace('&M062372;' , 'よ')
		line = line.replace('&M062373;' , 'ら')
		line = line.replace('&M062374;' , 'り')
		line = line.replace('&M062375;' , 'る')
		line = line.replace('&M062376;' , 'れ')
		line = line.replace('&M062377;' , 'ろ')
		line = line.replace('&M062378;' , 'ゎ')
		line = line.replace('&M062379;' , 'わ')
		line = line.replace('&M062380;' , 'ゐ')
		line = line.replace('&M062381;' , 'ゑ')
		line = line.replace('&M062382;' , 'を')
		line = line.replace('&M062383;' , 'ん')
		line = line.replace('&M062401;' , 'ァ')
		line = line.replace('&M062402;' , 'ア')
		line = line.replace('&M062403;' , 'ィ')
		line = line.replace('&M062404;' , 'イ')
		line = line.replace('&M062405;' , 'ゥ')
		line = line.replace('&M062406;' , 'ウ')
		line = line.replace('&M062407;' , 'ェ')
		line = line.replace('&M062408;' , 'エ')
		line = line.replace('&M062409;' , 'ォ')
		line = line.replace('&M062410;' , 'オ')
		line = line.replace('&M062411;' , 'カ')
		line = line.replace('&M062412;' , 'ガ')
		line = line.replace('&M062413;' , 'キ')
		line = line.replace('&M062414;' , 'ギ')
		line = line.replace('&M062415;' , 'ク')
		line = line.replace('&M062416;' , 'グ')
		line = line.replace('&M062417;' , 'ケ')
		line = line.replace('&M062418;' , 'ゲ')
		line = line.replace('&M062419;' , 'コ')
		line = line.replace('&M062420;' , 'ゴ')
		line = line.replace('&M062421;' , 'サ')
		line = line.replace('&M062422;' , 'ザ')
		line = line.replace('&M062423;' , 'シ')
		line = line.replace('&M062424;' , 'ジ')
		line = line.replace('&M062425;' , 'ス')
		line = line.replace('&M062426;' , 'ズ')
		line = line.replace('&M062427;' , 'セ')
		line = line.replace('&M062428;' , 'ゼ')
		line = line.replace('&M062429;' , 'ソ')
		line = line.replace('&M062430;' , 'ゾ')
		line = line.replace('&M062431;' , 'タ')
		line = line.replace('&M062432;' , 'ダ')
		line = line.replace('&M062433;' , 'チ')
		line = line.replace('&M062434;' , 'ヂ')
		line = line.replace('&M062435;' , 'ッ')
		line = line.replace('&M062436;' , 'ツ')
		line = line.replace('&M062437;' , 'ヅ')
		line = line.replace('&M062438;' , 'テ')
		line = line.replace('&M062439;' , 'デ')
		line = line.replace('&M062440;' , 'ト')
		line = line.replace('&M062441;' , 'ド')
		line = line.replace('&M062442;' , 'ナ')
		line = line.replace('&M062443;' , 'ニ')
		line = line.replace('&M062444;' , 'ヌ')
		line = line.replace('&M062445;' , 'ネ')
		line = line.replace('&M062446;' , 'ノ')
		line = line.replace('&M062447;' , 'ハ')
		line = line.replace('&M062448;' , 'バ')
		line = line.replace('&M062449;' , 'パ')
		line = line.replace('&M062450;' , 'ヒ')
		line = line.replace('&M062451;' , 'ビ')
		line = line.replace('&M062452;' , 'ピ')
		line = line.replace('&M062453;' , 'フ')
		line = line.replace('&M062454;' , 'ブ')
		line = line.replace('&M062455;' , 'プ')
		line = line.replace('&M062456;' , 'ヘ')
		line = line.replace('&M062457;' , 'ベ')
		line = line.replace('&M062458;' , 'ペ')
		line = line.replace('&M062459;' , 'ホ')
		line = line.replace('&M062460;' , 'ボ')
		line = line.replace('&M062461;' , 'ポ')
		line = line.replace('&M062462;' , 'マ')
		line = line.replace('&M062463;' , 'ミ')
		line = line.replace('&M062464;' , 'ム')
		line = line.replace('&M062465;' , 'メ')
		line = line.replace('&M062466;' , 'モ')
		line = line.replace('&M062467;' , 'ャ')
		line = line.replace('&M062468;' , 'ヤ')
		line = line.replace('&M062469;' , 'ュ')
		line = line.replace('&M062470;' , 'ユ')
		line = line.replace('&M062471;' , 'ョ')
		line = line.replace('&M062472;' , 'ヨ')
		line = line.replace('&M062473;' , 'ラ')
		line = line.replace('&M062474;' , 'リ')
		line = line.replace('&M062475;' , 'ル')
		line = line.replace('&M062476;' , 'レ')
		line = line.replace('&M062477;' , 'ロ')
		line = line.replace('&M062478;' , 'ヮ')
		line = line.replace('&M062479;' , 'ワ')
		line = line.replace('&M062480;' , 'ヰ')
		line = line.replace('&M062481;' , 'ヱ')
		line = line.replace('&M062482;' , 'ヲ')
		line = line.replace('&M062483;' , 'ン')
		line = line.replace('&M062484;' , 'ヴ')
		line = line.replace('&M062485;' , 'ヵ')
		line = line.replace('&M062486;' , 'ヶ')
	return line

#################################################
# 處理組字式 (缺字多的時候使用, 有先讀入全部的缺字)
#################################################
def trans_des(mo):
	des=mo.group()
	if des in des2u8:
		return des2u8[des]
	else:
		return des

#################################################
# 轉換羅馬轉寫字成 unicode
#################################################
def trans_roma(line):
	global romas
	for nor in romas:
		line=line.replace(nor, romas[nor])
	return line

#################################################
# 處理單檔
#################################################
def trans_file(fn1, fn2):
	print( fn1 + ' => ' + fn2)
	f1=codecs.open(fn1, "r", "cp950")
	f2=codecs.open(fn2, "w", "utf-8")
	for line in f1:
		line=re.sub(r'\[[^>\[]*?\]', trans_des, line)	# 處理組字式 (有先讀入全部的缺字)
		line=trans_roma(line)	# 處理羅馬轉寫字
		line=trans_jap(line)	# 處理日文
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
# 讀取全部的 組字式與 unicode
#################################################
def get_des2u8():
	global des2u8
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	sql = "SELECT unicode, des FROM gaiji WHERE ((cb Is Not Null) AND (cb<='99999') AND (unicode Is Not Null))"
	rs.Open(sql, conn, 1, 3)
	rs.MoveFirst()
	while 1:
		if rs.EOF:
			break
		else:
			des = rs.Fields.Item('des').Value		# 通用字
			uni = rs.Fields.Item('unicode').Value	# unicode
			des2u8[des] = chr(int(uni,16))
			rs.MoveNext()

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
# main 主程式
#################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-s", dest="source", help="來源資料夾")
parser.add_option("-o", dest="output", help="輸出資料夾")
(options, args) = parser.parse_args()

# 讀取設定檔 cbwork_bin.ini
config = configparser.SafeConfigParser()
config.read('../cbwork_bin.ini')
gaiji = config.get('default', 'gaiji-m.mdb_file')

# 準備存取 gaiji-m.mdb
conn = win32com.client.Dispatch(r'ADODB.Connection')
DSN = 'PROVIDER=Microsoft.Jet.OLEDB.4.0;DATA SOURCE=%s;' % gaiji
conn.Open(DSN)

# 先讀取羅馬轉寫字
romas = {}	# 宣告用來放羅馬拼音, ex { '`o' : '00F3' }
des2u8 = {} # 宣告用來放組字式的 utf8 文字
get_roma()
get_des2u8()

trans_dir(options.source, options.output)