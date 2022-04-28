# -*- coding: utf-8 *-*
'''
u8-b5.py
功能: 
	將目錄下(含子目錄)所有 utf-8 檔案轉為 CP950

使用說明:
	
	u8-b5.py [參數]

	參數 :
	-h 查看參數說明
	-s 指定來源資料來
	-o 指定輸出資料來
	-u 用來處理無法直接轉成 big5 的文字

		-u d : 預設值, 處理順序 1.組字式 2.&#x....; 編碼
		-u n : 處理順序 1.通用字,通用詞 2.組字式 3.&#x....; 編碼
		-u x : 直接轉成 &#x....; 編碼

		日文、俄文 在 -u d 和 -u n 都轉成這種格式 【A】【U0424】
				在 -u x 則轉成 &#x....; 編碼

	-r 用來處理羅馬轉寫字

		-r d : 預設值, 處理順序 1.組字式 2.&#x....; 編碼
		-r n : 處理順序 1.通用字 2.組字式 3.&#x....; 編碼
		-r x : 直接轉成 &#x....; 編碼

		以 Ā 為例，組字式則為 [-/A] , 通用字為 AA

		＊＊＊ 羅馬拼音建議儘量不要轉成通用字, 以免和一般英文字混淆

需求: PythonWin (不需要了)
作者: ray
2011.06.14 Ray: 改用 Python 3.2, 不過 64bit 版好像不能用
2009.12.02 Ray: 從 Unicode 網站取得 Unihan.txt, 取出裏面的異寫字資訊 kCompatibilityVariant, 放在 variant

Heaven 修改:
2022/04/28 cbwork_bin.ini 改成支援 utf8 版
2020/11/24 增加日本長音 'ー' 的處理法
2020/10/16 加上特殊字'々'的處理，這種字 python 認為有 big5 可以轉. 
2017/10/29 取消通用詞
2017/10/29 取消 -n 參數, 加上 -u [dnx] 和 -r [dnx] 參數, 詳見功能說明
2017/10/28 修改缺字的讀取, 原本讀取 MS Access 資料庫改成讀純文字 csv 檔, 速度快很多
2013/11/06 修改缺字的讀取, 由逐字查詢資料庫改成一次讀取全部資料庫.
2013/08/15 python 3.3.1 處理 ext-b 有問題, 所以改成逐字處理, 不用 error handler 了.
2013/07/31 使用通用字參數時同時處理通用詞
2013/07/10 修改遇到 0xFEFF 時寫入 log 檔的小錯誤
2013/06/09 變數改用設定檔 ../cbwork_bin.ini
2013/03/05 增加 -n 使用通用字的參數
'''

import configparser, os, codecs, sys, csv
from optparse import OptionParser
#import win32com.client # 要安裝 PythonWin
import re

#################################################
# 從 Unihan.txt 取出的異寫字資訊
#################################################

variant = {
'F900' : '8C48',
'F901' : '66F4',
'F902' : '8ECA',
'F903' : '8CC8',
'F904' : '6ED1',
'F905' : '4E32',
'F906' : '53E5',
'F907' : '9F9C',
'F908' : '9F9C',
'F909' : '5951',
'F90A' : '91D1',
'F90B' : '5587',
'F90C' : '5948',
'F90D' : '61F6',
'F90E' : '7669',
'F90F' : '7F85',
'F910' : '863F',
'F911' : '87BA',
'F912' : '88F8',
'F913' : '908F',
'F914' : '6A02',
'F915' : '6D1B',
'F916' : '70D9',
'F917' : '73DE',
'F918' : '843D',
'F919' : '916A',
'F91A' : '99F1',
'F91B' : '4E82',
'F91C' : '5375',
'F91D' : '6B04',
'F91E' : '721B',
'F91F' : '862D',
'F920' : '9E1E',
'F921' : '5D50',
'F922' : '6FEB',
'F923' : '85CD',
'F924' : '8964',
'F925' : '62C9',
'F926' : '81D8',
'F927' : '881F',
'F928' : '5ECA',
'F929' : '6717',
'F92A' : '6D6A',
'F92B' : '72FC',
'F92C' : '90CE',
'F92D' : '4F86',
'F92E' : '51B7',
'F92F' : '52DE',
'F930' : '64C4',
'F931' : '6AD3',
'F932' : '7210',
'F933' : '76E7',
'F934' : '8001',
'F935' : '8606',
'F936' : '865C',
'F937' : '8DEF',
'F938' : '9732',
'F939' : '9B6F',
'F93A' : '9DFA',
'F93B' : '788C',
'F93C' : '797F',
'F93D' : '7DA0',
'F93E' : '83C9',
'F93F' : '9304',
'F940' : '9E7F',
'F941' : '8AD6',
'F942' : '58DF',
'F943' : '5F04',
'F944' : '7C60',
'F945' : '807E',
'F946' : '7262',
'F947' : '78CA',
'F948' : '8CC2',
'F949' : '96F7',
'F94A' : '58D8',
'F94B' : '5C62',
'F94C' : '6A13',
'F94D' : '6DDA',
'F94E' : '6F0F',
'F94F' : '7D2F',
'F950' : '7E37',
'F951' : '96FB',
'F952' : '52D2',
'F953' : '808B',
'F954' : '51DC',
'F955' : '51CC',
'F956' : '7A1C',
'F957' : '7DBE',
'F958' : '83F1',
'F959' : '9675',
'F95A' : '8B80',
'F95B' : '62CF',
'F95C' : '6A02',
'F95D' : '8AFE',
'F95E' : '4E39',
'F95F' : '5BE7',
'F960' : '6012',
'F961' : '7387',
'F962' : '7570',
'F963' : '5317',
'F964' : '78FB',
'F965' : '4FBF',
'F966' : '5FA9',
'F967' : '4E0D',
'F968' : '6CCC',
'F969' : '6578',
'F96A' : '7D22',
'F96B' : '53C3',
'F96C' : '585E',
'F96D' : '7701',
'F96E' : '8449',
'F96F' : '8AAA',
'F970' : '6BBA',
'F971' : '8FB0',
'F972' : '6C88',
'F973' : '62FE',
'F974' : '82E5',
'F975' : '63A0',
'F976' : '7565',
'F977' : '4EAE',
'F978' : '5169',
'F979' : '51C9',
'F97A' : '6881',
'F97B' : '7CE7',
'F97C' : '826F',
'F97D' : '8AD2',
'F97E' : '91CF',
'F97F' : '52F5',
'F980' : '5442',
'F981' : '5973',
'F982' : '5EEC',
'F983' : '65C5',
'F984' : '6FFE',
'F985' : '792A',
'F986' : '95AD',
'F987' : '9A6A',
'F988' : '9E97',
'F989' : '9ECE',
'F98A' : '529B',
'F98B' : '66C6',
'F98C' : '6B77',
'F98D' : '8F62',
'F98E' : '5E74',
'F98F' : '6190',
'F990' : '6200',
'F991' : '649A',
'F992' : '6F23',
'F993' : '7149',
'F994' : '7489',
'F995' : '79CA',
'F996' : '7DF4',
'F997' : '806F',
'F998' : '8F26',
'F999' : '84EE',
'F99A' : '9023',
'F99B' : '934A',
'F99C' : '5217',
'F99D' : '52A3',
'F99E' : '54BD',
'F99F' : '70C8',
'F9A0' : '88C2',
'F9A1' : '8AAA',
'F9A2' : '5EC9',
'F9A3' : '5FF5',
'F9A4' : '637B',
'F9A5' : '6BAE',
'F9A6' : '7C3E',
'F9A7' : '7375',
'F9A8' : '4EE4',
'F9A9' : '56F9',
'F9AA' : '5BE7',
'F9AB' : '5DBA',
'F9AC' : '601C',
'F9AD' : '73B2',
'F9AE' : '7469',
'F9AF' : '7F9A',
'F9B0' : '8046',
'F9B1' : '9234',
'F9B2' : '96F6',
'F9B3' : '9748',
'F9B4' : '9818',
'F9B5' : '4F8B',
'F9B6' : '79AE',
'F9B7' : '91B4',
'F9B8' : '96B8',
'F9B9' : '60E1',
'F9BA' : '4E86',
'F9BB' : '50DA',
'F9BC' : '5BEE',
'F9BD' : '5C3F',
'F9BE' : '6599',
'F9BF' : '6A02',
'F9C0' : '71CE',
'F9C1' : '7642',
'F9C2' : '84FC',
'F9C3' : '907C',
'F9C4' : '9F8D',
'F9C5' : '6688',
'F9C6' : '962E',
'F9C7' : '5289',
'F9C8' : '677B',
'F9C9' : '67F3',
'F9CA' : '6D41',
'F9CB' : '6E9C',
'F9CC' : '7409',
'F9CD' : '7559',
'F9CE' : '786B',
'F9CF' : '7D10',
'F9D0' : '985E',
'F9D1' : '516D',
'F9D2' : '622E',
'F9D3' : '9678',
'F9D4' : '502B',
'F9D5' : '5D19',
'F9D6' : '6DEA',
'F9D7' : '8F2A',
'F9D8' : '5F8B',
'F9D9' : '6144',
'F9DA' : '6817',
'F9DB' : '7387',
'F9DC' : '9686',
'F9DD' : '5229',
'F9DE' : '540F',
'F9DF' : '5C65',
'F9E0' : '6613',
'F9E1' : '674E',
'F9E2' : '68A8',
'F9E3' : '6CE5',
'F9E4' : '7406',
'F9E5' : '75E2',
'F9E6' : '7F79',
'F9E7' : '88CF',
'F9E8' : '88E1',
'F9E9' : '91CC',
'F9EA' : '96E2',
'F9EB' : '533F',
'F9EC' : '6EBA',
'F9ED' : '541D',
'F9EE' : '71D0',
'F9EF' : '7498',
'F9F0' : '85FA',
'F9F1' : '96A3',
'F9F2' : '9C57',
'F9F3' : '9E9F',
'F9F4' : '6797',
'F9F5' : '6DCB',
'F9F6' : '81E8',
'F9F7' : '7ACB',
'F9F8' : '7B20',
'F9F9' : '7C92',
'F9FA' : '72C0',
'F9FB' : '7099',
'F9FC' : '8B58',
'F9FD' : '4EC0',
'F9FE' : '8336',
'F9FF' : '523A',
'FA00' : '5207',
'FA01' : '5EA6',
'FA02' : '62D3',
'FA03' : '7CD6',
'FA04' : '5B85',
'FA05' : '6D1E',
'FA06' : '66B4',
'FA07' : '8F3B',
'FA08' : '884C',
'FA09' : '964D',
'FA0A' : '898B',
'FA0B' : '5ED3',
'FA0C' : '5140',
'FA0D' : '55C0',
'FA10' : '585A',
'FA12' : '6674',
'FA15' : '51DE',
'FA16' : '732A',
'FA17' : '76CA',
'FA18' : '793C',
'FA19' : '795E',
'FA1A' : '7965',
'FA1B' : '798F',
'FA1C' : '9756',
'FA1D' : '7CBE',
'FA1E' : '7FBD',
'FA20' : '8612',
'FA22' : '8AF8',
'FA25' : '9038',
'FA26' : '90FD',
'FA2A' : '98EF',
'FA2B' : '98FC',
'FA2C' : '9928',
'FA2D' : '9DB4',
'FA30' : '4FAE',
'FA31' : '50E7',
'FA32' : '514D',
'FA33' : '52C9',
'FA34' : '52E4',
'FA35' : '5351',
'FA36' : '559D',
'FA37' : '5606',
'FA38' : '5668',
'FA39' : '5840',
'FA3A' : '58A8',
'FA3B' : '5C64',
'FA3C' : '5C6E',
'FA3D' : '6094',
'FA3E' : '6168',
'FA3F' : '618E',
'FA40' : '61F2',
'FA41' : '654F',
'FA42' : '65E2',
'FA43' : '6691',
'FA44' : '6885',
'FA45' : '6D77',
'FA46' : '6E1A',
'FA47' : '6F22',
'FA48' : '716E',
'FA49' : '722B',
'FA4A' : '7422',
'FA4B' : '7891',
'FA4C' : '793E',
'FA4D' : '7949',
'FA4E' : '7948',
'FA4F' : '7950',
'FA50' : '7956',
'FA51' : '795D',
'FA52' : '798D',
'FA53' : '798E',
'FA54' : '7A40',
'FA55' : '7A81',
'FA56' : '7BC0',
'FA57' : '7DF4',
'FA58' : '7E09',
'FA59' : '7E41',
'FA5A' : '7F72',
'FA5B' : '8005',
'FA5C' : '81ED',
'FA5D' : '8279',
'FA5E' : '8279',
'FA5F' : '8457',
'FA60' : '8910',
'FA61' : '8996',
'FA62' : '8B01',
'FA63' : '8B39',
'FA64' : '8CD3',
'FA65' : '8D08',
'FA66' : '8FB6',
'FA67' : '9038',
'FA68' : '96E3',
'FA69' : '97FF',
'FA6A' : '983B',
'2F800' : '4E3D',
'2F801' : '4E38',
'2F802' : '4E41',
'2F803' : '20122',
'2F804' : '4F60',
'2F805' : '4FAE',
'2F806' : '4FBB',
'2F807' : '5002',
'2F808' : '507A',
'2F809' : '5099',
'2F80A' : '50E7',
'2F80B' : '50CF',
'2F80C' : '349E',
'2F80D' : '2063A',
'2F80E' : '514D',
'2F80F' : '5154',
'2F810' : '5164',
'2F811' : '5177',
'2F812' : '2051C',
'2F813' : '34B9',
'2F814' : '5167',
'2F815' : '518D',
'2F816' : '2054B',
'2F817' : '5197',
'2F818' : '51A4',
'2F819' : '4ECC',
'2F81A' : '51AC',
'2F81B' : '51B5',
'2F81C' : '291DF',
'2F81D' : '51F5',
'2F81E' : '5203',
'2F81F' : '34DF',
'2F820' : '523B',
'2F821' : '5246',
'2F822' : '5272',
'2F823' : '5277',
'2F824' : '3515',
'2F825' : '52C7',
'2F826' : '52C9',
'2F827' : '52E4',
'2F828' : '52FA',
'2F829' : '5305',
'2F82A' : '5306',
'2F82B' : '5317',
'2F82C' : '5349',
'2F82D' : '5351',
'2F82E' : '535A',
'2F82F' : '5373',
'2F830' : '537D',
'2F831' : '537F',
'2F832' : '537F',
'2F833' : '537F',
'2F834' : '20A2C',
'2F835' : '7070',
'2F836' : '53CA',
'2F837' : '53DF',
'2F838' : '20B63',
'2F839' : '53EB',
'2F83A' : '53F1',
'2F83B' : '5406',
'2F83C' : '549E',
'2F83D' : '5438',
'2F83E' : '5448',
'2F83F' : '5468',
'2F840' : '54A2',
'2F841' : '54F6',
'2F842' : '5510',
'2F843' : '5553',
'2F844' : '5563',
'2F845' : '5584',
'2F846' : '5584',
'2F847' : '5599',
'2F848' : '55AB',
'2F849' : '55B3',
'2F84A' : '55C2',
'2F84B' : '5716',
'2F84C' : '5606',
'2F84D' : '5717',
'2F84E' : '5651',
'2F84F' : '5674',
'2F850' : '5207',
'2F851' : '58EE',
'2F852' : '57CE',
'2F853' : '57F4',
'2F854' : '580D',
'2F855' : '578B',
'2F856' : '5832',
'2F857' : '5831',
'2F858' : '58AC',
'2F859' : '214E4',
'2F85A' : '58F2',
'2F85B' : '58F7',
'2F85C' : '5906',
'2F85D' : '591A',
'2F85E' : '5922',
'2F85F' : '5962',
'2F860' : '216A8',
'2F861' : '216EA',
'2F862' : '59EC',
'2F863' : '5A1B',
'2F864' : '5A27',
'2F865' : '59D8',
'2F866' : '5A66',
'2F867' : '36EE',
'2F868' : '2136A',
'2F869' : '5B08',
'2F86A' : '5B3E',
'2F86B' : '5B3E',
'2F86C' : '219C8',
'2F86D' : '5BC3',
'2F86E' : '5BD8',
'2F86F' : '5BE7',
'2F870' : '5BF3',
'2F871' : '21B18',
'2F872' : '5BFF',
'2F873' : '5C06',
'2F874' : '5F33',
'2F875' : '5C22',
'2F876' : '3781',
'2F877' : '5C60',
'2F878' : '5C6E',
'2F879' : '5CC0',
'2F87A' : '5C8D',
'2F87B' : '21DE4',
'2F87C' : '5D43',
'2F87D' : '21DE6',
'2F87E' : '5D6E',
'2F87F' : '5D6B',
'2F880' : '5D7C',
'2F881' : '5DE1',
'2F882' : '5DE2',
'2F883' : '382F',
'2F884' : '5DFD',
'2F885' : '5E28',
'2F886' : '5E3D',
'2F887' : '5E69',
'2F888' : '3862',
'2F889' : '22183',
'2F88A' : '387C',
'2F88B' : '5EB0',
'2F88C' : '5EB3',
'2F88D' : '5EB6',
'2F88E' : '5ECA',
'2F88F' : '2A392',
'2F890' : '5EFE',
'2F891' : '22331',
'2F892' : '22331',
'2F893' : '8201',
'2F894' : '5F22',
'2F895' : '5F22',
'2F896' : '38C7',
'2F897' : '232B8',
'2F898' : '261DA',
'2F899' : '5F62',
'2F89A' : '5F6B',
'2F89B' : '38E3',
'2F89C' : '5F9A',
'2F89D' : '5FCD',
'2F89E' : '5FD7',
'2F89F' : '5FF9',
'2F8A0' : '6081',
'2F8A1' : '393A',
'2F8A2' : '391C',
'2F8A3' : '6094',
'2F8A4' : '226D4',
'2F8A5' : '60C7',
'2F8A6' : '6148',
'2F8A7' : '614C',
'2F8A8' : '614E',
'2F8A9' : '614C',
'2F8AA' : '617A',
'2F8AB' : '618E',
'2F8AC' : '61B2',
'2F8AD' : '61A4',
'2F8AE' : '61AF',
'2F8AF' : '61DE',
'2F8B0' : '61F2',
'2F8B1' : '61F6',
'2F8B2' : '6210',
'2F8B3' : '621B',
'2F8B4' : '625D',
'2F8B5' : '62B1',
'2F8B6' : '62D4',
'2F8B7' : '6350',
'2F8B8' : '22B0C',
'2F8B9' : '633D',
'2F8BA' : '62FC',
'2F8BB' : '6368',
'2F8BC' : '6383',
'2F8BD' : '63E4',
'2F8BE' : '22BF1',
'2F8BF' : '6422',
'2F8C0' : '63C5',
'2F8C1' : '63A9',
'2F8C2' : '3A2E',
'2F8C3' : '6469',
'2F8C4' : '647E',
'2F8C5' : '649D',
'2F8C6' : '6477',
'2F8C7' : '3A6C',
'2F8C8' : '654F',
'2F8C9' : '656C',
'2F8CA' : '2300A',
'2F8CB' : '65E3',
'2F8CC' : '66F8',
'2F8CD' : '6649',
'2F8CE' : '3B19',
'2F8CF' : '6691',
'2F8D0' : '3B08',
'2F8D1' : '3AE4',
'2F8D2' : '5192',
'2F8D3' : '5195',
'2F8D4' : '6700',
'2F8D5' : '669C',
'2F8D6' : '80AD',
'2F8D7' : '43D9',
'2F8D8' : '6717',
'2F8D9' : '671B',
'2F8DA' : '6721',
'2F8DB' : '675E',
'2F8DC' : '6753',
'2F8DD' : '233C3',
'2F8DE' : '3B49',
'2F8DF' : '67FA',
'2F8E0' : '6785',
'2F8E1' : '6852',
'2F8E2' : '6885',
'2F8E3' : '2346D',
'2F8E4' : '688E',
'2F8E5' : '681F',
'2F8E6' : '6914',
'2F8E7' : '3B9D',
'2F8E8' : '6942',
'2F8E9' : '69A3',
'2F8EA' : '69EA',
'2F8EB' : '6AA8',
'2F8EC' : '236A3',
'2F8ED' : '6ADB',
'2F8EE' : '3C18',
'2F8EF' : '6B21',
'2F8F0' : '238A7',
'2F8F1' : '6B54',
'2F8F2' : '3C4E',
'2F8F3' : '6B72',
'2F8F4' : '6B9F',
'2F8F5' : '6BBA',
'2F8F6' : '6BBB',
'2F8F7' : '23A8D',
'2F8F8' : '21D0B',
'2F8F9' : '23AFA',
'2F8FA' : '6C4E',
'2F8FB' : '23CBC',
'2F8FC' : '6CBF',
'2F8FD' : '6CCD',
'2F8FE' : '6C67',
'2F8FF' : '6D16',
'2F900' : '6D3E',
'2F901' : '6D77',
'2F902' : '6D41',
'2F903' : '6D69',
'2F904' : '6D78',
'2F905' : '6D85',
'2F906' : '23D1E',
'2F907' : '6D34',
'2F908' : '6E2F',
'2F909' : '6E6E',
'2F90A' : '3D33',
'2F90B' : '6ECB',
'2F90C' : '6EC7',
'2F90D' : '23ED1',
'2F90E' : '6DF9',
'2F90F' : '6F6E',
'2F910' : '23F5E',
'2F911' : '23F8E',
'2F912' : '6FC6',
'2F913' : '7039',
'2F914' : '701E',
'2F915' : '701B',
'2F916' : '3D96',
'2F917' : '704A',
'2F918' : '707D',
'2F919' : '7077',
'2F91A' : '70AD',
'2F91B' : '20525',
'2F91C' : '7145',
'2F91D' : '24263',
'2F91E' : '719C',
'2F91F' : '43AB',
'2F920' : '7228',
'2F921' : '7235',
'2F922' : '7250',
'2F923' : '24608',
'2F924' : '7280',
'2F925' : '7295',
'2F926' : '24735',
'2F927' : '24814',
'2F928' : '737A',
'2F929' : '738B',
'2F92A' : '3EAC',
'2F92B' : '73A5',
'2F92C' : '3EB8',
'2F92D' : '3EB8',
'2F92E' : '7447',
'2F92F' : '745C',
'2F930' : '7471',
'2F931' : '7485',
'2F932' : '74CA',
'2F933' : '3F1B',
'2F934' : '7524',
'2F935' : '24C36',
'2F936' : '753E',
'2F937' : '24C92',
'2F938' : '7570',
'2F939' : '2219F',
'2F93A' : '7610',
'2F93B' : '24FA1',
'2F93C' : '24FB8',
'2F93D' : '25044',
'2F93E' : '3FFC',
'2F93F' : '4008',
'2F940' : '76F4',
'2F941' : '250F3',
'2F942' : '250F2',
'2F943' : '25119',
'2F944' : '25133',
'2F945' : '771E',
'2F946' : '771F',
'2F947' : '771F',
'2F948' : '774A',
'2F949' : '4039',
'2F94A' : '778B',
'2F94B' : '4046',
'2F94C' : '4096',
'2F94D' : '2541D',
'2F94E' : '784E',
'2F94F' : '788C',
'2F950' : '78CC',
'2F951' : '40E3',
'2F952' : '25626',
'2F953' : '7956',
'2F954' : '2569A',
'2F955' : '256C5',
'2F956' : '798F',
'2F957' : '79EB',
'2F958' : '412F',
'2F959' : '7A40',
'2F95A' : '7A4A',
'2F95B' : '7A4F',
'2F95C' : '2597C',
'2F95D' : '25AA7',
'2F95E' : '25AA7',
'2F95F' : '7AAE',
'2F960' : '4202',
'2F961' : '25BAB',
'2F962' : '7BC6',
'2F963' : '7BC9',
'2F964' : '4227',
'2F965' : '25C80',
'2F966' : '7CD2',
'2F967' : '42A0',
'2F968' : '7CE8',
'2F969' : '7CE3',
'2F96A' : '7D00',
'2F96B' : '25F86',
'2F96C' : '7D63',
'2F96D' : '4301',
'2F96E' : '7DC7',
'2F96F' : '7E02',
'2F970' : '7E45',
'2F971' : '4334',
'2F972' : '26228',
'2F973' : '26247',
'2F974' : '4359',
'2F975' : '262D9',
'2F976' : '7F7A',
'2F977' : '2633E',
'2F978' : '7F95',
'2F979' : '7FFA',
'2F97A' : '8005',
'2F97B' : '264DA',
'2F97C' : '26523',
'2F97D' : '8060',
'2F97E' : '265A8',
'2F97F' : '8070',
'2F980' : '2335F',
'2F981' : '43D5',
'2F982' : '80B2',
'2F983' : '8103',
'2F984' : '440B',
'2F985' : '813E',
'2F986' : '5AB5',
'2F987' : '267A7',
'2F988' : '267B5',
'2F989' : '23393',
'2F98A' : '2339C',
'2F98B' : '8201',
'2F98C' : '8204',
'2F98D' : '8F9E',
'2F98E' : '446B',
'2F98F' : '8291',
'2F990' : '828B',
'2F991' : '829D',
'2F992' : '52B3',
'2F993' : '82B1',
'2F994' : '82B3',
'2F995' : '82BD',
'2F996' : '82E6',
'2F997' : '26B3C',
'2F998' : '82E5',
'2F999' : '831D',
'2F99A' : '8363',
'2F99B' : '83AD',
'2F99C' : '8323',
'2F99D' : '83BD',
'2F99E' : '83E7',
'2F99F' : '8457',
'2F9A0' : '8353',
'2F9A1' : '83CA',
'2F9A2' : '83CC',
'2F9A3' : '83DC',
'2F9A4' : '26C36',
'2F9A5' : '26D6B',
'2F9A6' : '26CD5',
'2F9A7' : '452B',
'2F9A8' : '84F1',
'2F9A9' : '84F3',
'2F9AA' : '8516',
'2F9AB' : '273CA',
'2F9AC' : '8564',
'2F9AD' : '26F2C',
'2F9AE' : '455D',
'2F9AF' : '4561',
'2F9B0' : '26FB1',
'2F9B1' : '270D2',
'2F9B2' : '456B',
'2F9B3' : '8650',
'2F9B4' : '865C',
'2F9B5' : '8667',
'2F9B6' : '8669',
'2F9B7' : '86A9',
'2F9B8' : '8688',
'2F9B9' : '870E',
'2F9BA' : '86E2',
'2F9BB' : '8779',
'2F9BC' : '8728',
'2F9BD' : '876B',
'2F9BE' : '8786',
'2F9BF' : '4D57',
'2F9C0' : '87E1',
'2F9C1' : '8801',
'2F9C2' : '45F9',
'2F9C3' : '8860',
'2F9C4' : '8863',
'2F9C5' : '27667',
'2F9C6' : '88D7',
'2F9C7' : '88DE',
'2F9C8' : '4635',
'2F9C9' : '88FA',
'2F9CA' : '34BB',
'2F9CB' : '278AE',
'2F9CC' : '27966',
'2F9CD' : '46BE',
'2F9CE' : '46C7',
'2F9CF' : '8AA0',
'2F9D0' : '8AED',
'2F9D1' : '8B8A',
'2F9D2' : '8C55',
'2F9D3' : '27CA8',
'2F9D4' : '8CAB',
'2F9D5' : '8CC1',
'2F9D6' : '8D1B',
'2F9D7' : '8D77',
'2F9D8' : '27F2F',
'2F9D9' : '20804',
'2F9DA' : '8DCB',
'2F9DB' : '8DBC',
'2F9DC' : '8DF0',
'2F9DD' : '208DE',
'2F9DE' : '8ED4',
'2F9DF' : '8F38',
'2F9E0' : '285D2',
'2F9E1' : '285ED',
'2F9E2' : '9094',
'2F9E3' : '90F1',
'2F9E4' : '9111',
'2F9E5' : '2872E',
'2F9E6' : '911B',
'2F9E7' : '9238',
'2F9E8' : '92D7',
'2F9E9' : '92D8',
'2F9EA' : '927C',
'2F9EB' : '93F9',
'2F9EC' : '9415',
'2F9ED' : '28BFA',
'2F9EE' : '958B',
'2F9EF' : '4995',
'2F9F0' : '95B7',
'2F9F1' : '28D77',
'2F9F2' : '49E6',
'2F9F3' : '96C3',
'2F9F4' : '5DB2',
'2F9F5' : '9723',
'2F9F6' : '29145',
'2F9F7' : '2921A',
'2F9F8' : '4A6E',
'2F9F9' : '4A76',
'2F9FA' : '97E0',
'2F9FB' : '2940A',
'2F9FC' : '4AB2',
'2F9FD' : '29496',
'2F9FE' : '980B',
'2F9FF' : '980B',
'2FA00' : '9829',
'2FA01' : '295B6',
'2FA02' : '98E2',
'2FA03' : '4B33',
'2FA04' : '9929',
'2FA05' : '99A7',
'2FA06' : '99C2',
'2FA07' : '99FE',
'2FA08' : '4BCE',
'2FA09' : '29B30',
'2FA0A' : '9B12',
'2FA0B' : '9C40',
'2FA0C' : '9CFD',
'2FA0D' : '4CCE',
'2FA0E' : '4CED',
'2FA0F' : '9D67',
'2FA10' : '2A0CE',
'2FA11' : '4CF8',
'2FA12' : '2A105',
'2FA13' : '2A20E',
'2FA14' : '2A291',
'2FA15' : '9EBB',
'2FA16' : '4D56',
'2FA17' : '9EF9',
'2FA18' : '9EFE',
'2FA19' : '9F05',
'2FA1A' : '9F0F',
'2FA1B' : '9F16',
'2FA1C' : '9F3B',
'2FA1D' : '2A600'
}

#################################################
# 處理日文
#################################################
def trans_jep(line):
	matchObj = re.search( r'[ぁ-ん]', line, re.UNICODE)
	if matchObj:
		line = line.replace('ぁ', "【a】")
		line = line.replace('あ', "【a】")
		line = line.replace('ぃ', "【i】")
		line = line.replace('い', "【i】")
		line = line.replace('ぅ', "【u】")
		line = line.replace('う', "【u】")
		line = line.replace('ぇ', "【e】")
		line = line.replace('え', "【e】")
		line = line.replace('ぉ', "【o】")
		line = line.replace('お', "【o】")
		line = line.replace('か', "【ka】")
		line = line.replace('が', "【ga】")
		line = line.replace('き', "【ki】")
		line = line.replace('ぎ', "【gi】")
		line = line.replace('く', "【ku】")
		line = line.replace('ぐ', "【gu】")
		line = line.replace('け', "【ke】")
		line = line.replace('げ', "【ge】")
		line = line.replace('こ', "【ko】")
		line = line.replace('ご', "【go】")
		line = line.replace('さ', "【sa】")
		line = line.replace('ざ', "【za】")
		line = line.replace('し', "【shi】")
		line = line.replace('じ', "【zi】")
		line = line.replace('す', "【su】")
		line = line.replace('ず', "【zu】")
		line = line.replace('せ', "【se】")
		line = line.replace('ぜ', "【ze】")
		line = line.replace('そ', "【so】")
		line = line.replace('ぞ', "【zo】")
		line = line.replace('た', "【ta】")
		line = line.replace('だ', "【da】")
		line = line.replace('ち', "【chi】")
		line = line.replace('ぢ', "【di】")
		line = line.replace('っ', "【tsu】")
		line = line.replace('つ', "【tsu】")
		line = line.replace('づ', "【du】")
		line = line.replace('て', "【te】")
		line = line.replace('で', "【de】")
		line = line.replace('と', "【to】")
		line = line.replace('ど', "【do】")
		line = line.replace('な', "【na】")
		line = line.replace('に', "【ni】")
		line = line.replace('ぬ', "【nu】")
		line = line.replace('ね', "【ne】")
		line = line.replace('の', "【no】")
		line = line.replace('は', "【ha】")
		line = line.replace('ば', "【ba】")
		line = line.replace('ぱ', "【pa】")
		line = line.replace('ひ', "【hi】")
		line = line.replace('び', "【bi】")
		line = line.replace('ぴ', "【pi】")
		line = line.replace('ふ', "【hu】")
		line = line.replace('ぶ', "【bu】")
		line = line.replace('ぷ', "【pu】")
		line = line.replace('へ', "【he】")
		line = line.replace('べ', "【be】")
		line = line.replace('ぺ', "【pe】")
		line = line.replace('ほ', "【ho】")
		line = line.replace('ぼ', "【bo】")
		line = line.replace('ぽ', "【po】")
		line = line.replace('ま', "【ma】")
		line = line.replace('み', "【mi】")
		line = line.replace('む', "【mu】")
		line = line.replace('め', "【me】")
		line = line.replace('も', "【mo】")
		line = line.replace('ゃ', "【ya】")
		line = line.replace('や', "【ya】")
		line = line.replace('ゅ', "【yu】")
		line = line.replace('ゆ', "【yu】")
		line = line.replace('ょ', "【yo】")
		line = line.replace('よ', "【yo】")
		line = line.replace('ら', "【ra】")
		line = line.replace('り', "【ri】")
		line = line.replace('る', "【ru】")
		line = line.replace('れ', "【re】")
		line = line.replace('ろ', "【ro】")
		line = line.replace('ゎ', "【wa】")
		line = line.replace('わ', "【wa】")
		line = line.replace('ゐ', "【wi】")
		line = line.replace('ゑ', "【we】")
		line = line.replace('を', "【wo】")
		line = line.replace('ん', "【n】")
		
	matchObj = re.search( r'[ァ-ヶ]', line, re.UNICODE)
	if matchObj:
		line = line.replace('ァｰ', "【A-】")
		line = line.replace('アー', "【A-】")
		line = line.replace('ィｰ', "【I-】")
		line = line.replace('イー', "【I-】")
		line = line.replace('ゥｰ', "【U-】")
		line = line.replace('ウー', "【U-】")
		line = line.replace('ェｰ', "【E-】")
		line = line.replace('エー', "【E-】")
		line = line.replace('ォｰ', "【O-】")
		line = line.replace('オー', "【O-】")
		line = line.replace('カー', "【KA-】")
		line = line.replace('ガー', "【GA-】")
		line = line.replace('キー', "【KI-】")
		line = line.replace('ギー', "【GI-】")
		line = line.replace('クー', "【KU-】")
		line = line.replace('グー', "【GU-】")
		line = line.replace('ケー', "【KE-】")
		line = line.replace('ゲー', "【GE-】")
		line = line.replace('コー', "【KO-】")
		line = line.replace('ゴー', "【GO-】")
		line = line.replace('サー', "【SA-】")
		line = line.replace('ザー', "【ZA-】")
		line = line.replace('シー', "【SHI-】")
		line = line.replace('ジー', "【ZI-】")
		line = line.replace('スー', "【SU-】")
		line = line.replace('ズー', "【ZU-】")
		line = line.replace('セー', "【SE-】")
		line = line.replace('ゼー', "【ZE-】")
		line = line.replace('ソー', "【SO-】")
		line = line.replace('ゾー', "【ZO-】")
		line = line.replace('ター', "【TA-】")
		line = line.replace('ダー', "【DA-】")
		line = line.replace('チー', "【CHI-】")
		line = line.replace('ヂー', "【DI-】")
		line = line.replace('ッー', "【TSU-】")
		line = line.replace('ツー', "【TSU-】")
		line = line.replace('ヅー', "【DU-】")
		line = line.replace('テー', "【TE-】")
		line = line.replace('デー', "【DE-】")
		line = line.replace('トー', "【TO-】")
		line = line.replace('ドー', "【DO-】")
		line = line.replace('ナー', "【NA-】")
		line = line.replace('ニー', "【NI-】")
		line = line.replace('ヌー', "【NU-】")
		line = line.replace('ネー', "【NE-】")
		line = line.replace('ノー', "【NO-】")
		line = line.replace('ハー', "【HA-】")
		line = line.replace('バー', "【BA-】")
		line = line.replace('パー', "【PA-】")
		line = line.replace('ヒー', "【HI-】")
		line = line.replace('ビー', "【BI-】")
		line = line.replace('ピー', "【PI-】")
		line = line.replace('フー', "【HU-】")
		line = line.replace('ブー', "【BU-】")
		line = line.replace('プー', "【PU-】")
		line = line.replace('ヘー', "【HE-】")
		line = line.replace('ベー', "【BE-】")
		line = line.replace('ペー', "【PE-】")
		line = line.replace('ホー', "【HO-】")
		line = line.replace('ボー', "【BO-】")
		line = line.replace('ポー', "【PO-】")
		line = line.replace('マー', "【MA-】")
		line = line.replace('ミー', "【MI-】")
		line = line.replace('ムー', "【MU-】")
		line = line.replace('メー', "【ME-】")
		line = line.replace('モー', "【MO-】")
		line = line.replace('ャー', "【YA-】")
		line = line.replace('ヤー', "【YA-】")
		line = line.replace('ュー', "【YU-】")
		line = line.replace('ユー', "【YU-】")
		line = line.replace('ョー', "【YO-】")
		line = line.replace('ヨー', "【YO-】")
		line = line.replace('ラー', "【RA-】")
		line = line.replace('リー', "【RI-】")
		line = line.replace('ルー', "【RU-】")
		line = line.replace('レー', "【RE-】")
		line = line.replace('ロー', "【RO-】")
		line = line.replace('ヮー', "【WA-】")
		line = line.replace('ワー', "【WA-】")
		line = line.replace('ヰー', "【WI-】")
		line = line.replace('ヱー', "【WE-】")
		line = line.replace('ヲー', "【WO-】")
		line = line.replace('ンー', "【N-】")
		line = line.replace('ヴー', "【VU-】")
		line = line.replace('ヵー', "【KA-】")
		line = line.replace('ヶー', "【KE-】")

		line = line.replace('ァ', "【A】")
		line = line.replace('ア', "【A】")
		line = line.replace('ィ', "【I】")
		line = line.replace('イ', "【I】")
		line = line.replace('ゥ', "【U】")
		line = line.replace('ウ', "【U】")
		line = line.replace('ェ', "【E】")
		line = line.replace('エ', "【E】")
		line = line.replace('ォ', "【O】")
		line = line.replace('オ', "【O】")
		line = line.replace('カ', "【KA】")
		line = line.replace('ガ', "【GA】")
		line = line.replace('キ', "【KI】")
		line = line.replace('ギ', "【GI】")
		line = line.replace('ク', "【KU】")
		line = line.replace('グ', "【GU】")
		line = line.replace('ケ', "【KE】")
		line = line.replace('ゲ', "【GE】")
		line = line.replace('コ', "【KO】")
		line = line.replace('ゴ', "【GO】")
		line = line.replace('サ', "【SA】")
		line = line.replace('ザ', "【ZA】")
		line = line.replace('シ', "【SHI】")
		line = line.replace('ジ', "【ZI】")
		line = line.replace('ス', "【SU】")
		line = line.replace('ズ', "【ZU】")
		line = line.replace('セ', "【SE】")
		line = line.replace('ゼ', "【ZE】")
		line = line.replace('ソ', "【SO】")
		line = line.replace('ゾ', "【ZO】")
		line = line.replace('タ', "【TA】")
		line = line.replace('ダ', "【DA】")
		line = line.replace('チ', "【CHI】")
		line = line.replace('ヂ', "【DI】")
		line = line.replace('ッ', "【TSU】")
		line = line.replace('ツ', "【TSU】")
		line = line.replace('ヅ', "【DU】")
		line = line.replace('テ', "【TE】")
		line = line.replace('デ', "【DE】")
		line = line.replace('ト', "【TO】")
		line = line.replace('ド', "【DO】")
		line = line.replace('ナ', "【NA】")
		line = line.replace('ニ', "【NI】")
		line = line.replace('ヌ', "【NU】")
		line = line.replace('ネ', "【NE】")
		line = line.replace('ノ', "【NO】")
		line = line.replace('ハ', "【HA】")
		line = line.replace('バ', "【BA】")
		line = line.replace('パ', "【PA】")
		line = line.replace('ヒ', "【HI】")
		line = line.replace('ビ', "【BI】")
		line = line.replace('ピ', "【PI】")
		line = line.replace('フ', "【HU】")
		line = line.replace('ブ', "【BU】")
		line = line.replace('プ', "【PU】")
		line = line.replace('ヘ', "【HE】")
		line = line.replace('ベ', "【BE】")
		line = line.replace('ペ', "【PE】")
		line = line.replace('ホ', "【HO】")
		line = line.replace('ボ', "【BO】")
		line = line.replace('ポ', "【PO】")
		line = line.replace('マ', "【MA】")
		line = line.replace('ミ', "【MI】")
		line = line.replace('ム', "【MU】")
		line = line.replace('メ', "【ME】")
		line = line.replace('モ', "【MO】")
		line = line.replace('ャ', "【YA】")
		line = line.replace('ヤ', "【YA】")
		line = line.replace('ュ', "【YU】")
		line = line.replace('ユ', "【YU】")
		line = line.replace('ョ', "【YO】")
		line = line.replace('ヨ', "【YO】")
		line = line.replace('ラ', "【RA】")
		line = line.replace('リ', "【RI】")
		line = line.replace('ル', "【RU】")
		line = line.replace('レ', "【RE】")
		line = line.replace('ロ', "【RO】")
		line = line.replace('ヮ', "【WA】")
		line = line.replace('ワ', "【WA】")
		line = line.replace('ヰ', "【WI】")
		line = line.replace('ヱ', "【WE】")
		line = line.replace('ヲ', "【WO】")
		line = line.replace('ン', "【N】")
		line = line.replace('ヴ', "【VU】")
		line = line.replace('ヵ', "【KA】")
		line = line.replace('ヶ', "【KE】")

	return line

#################################################
# 處理日文
#################################################
def trans_jep_x(line):
	matchObj = re.search( r'[ぁ-ん]', line, re.UNICODE)
	if matchObj:
		line = line.replace('ぁ', "&#x3041;")
		line = line.replace('あ', "&#x3042;")
		line = line.replace('ぃ', "&#x3043;")
		line = line.replace('い', "&#x3044;")
		line = line.replace('ぅ', "&#x3045;")
		line = line.replace('う', "&#x3046;")
		line = line.replace('ぇ', "&#x3047;")
		line = line.replace('え', "&#x3048;")
		line = line.replace('ぉ', "&#x3049;")
		line = line.replace('お', "&#x304A;")
		line = line.replace('か', "&#x304B;")
		line = line.replace('が', "&#x304C;")
		line = line.replace('き', "&#x304D;")
		line = line.replace('ぎ', "&#x304E;")
		line = line.replace('く', "&#x304F;")
		line = line.replace('ぐ', "&#x3050;")
		line = line.replace('け', "&#x3051;")
		line = line.replace('げ', "&#x3052;")
		line = line.replace('こ', "&#x3053;")
		line = line.replace('ご', "&#x3054;")
		line = line.replace('さ', "&#x3055;")
		line = line.replace('ざ', "&#x3056;")
		line = line.replace('し', "&#x3057;")
		line = line.replace('じ', "&#x3058;")
		line = line.replace('す', "&#x3059;")
		line = line.replace('ず', "&#x305A;")
		line = line.replace('せ', "&#x305B;")
		line = line.replace('ぜ', "&#x305C;")
		line = line.replace('そ', "&#x305D;")
		line = line.replace('ぞ', "&#x305E;")
		line = line.replace('た', "&#x305F;")
		line = line.replace('だ', "&#x3060;")
		line = line.replace('ち', "&#x3061;")
		line = line.replace('ぢ', "&#x3062;")
		line = line.replace('っ', "&#x3063;")
		line = line.replace('つ', "&#x3064;")
		line = line.replace('づ', "&#x3065;")
		line = line.replace('て', "&#x3066;")
		line = line.replace('で', "&#x3067;")
		line = line.replace('と', "&#x3068;")
		line = line.replace('ど', "&#x3069;")
		line = line.replace('な', "&#x306A;")
		line = line.replace('に', "&#x306B;")
		line = line.replace('ぬ', "&#x306C;")
		line = line.replace('ね', "&#x306D;")
		line = line.replace('の', "&#x306E;")
		line = line.replace('は', "&#x306F;")
		line = line.replace('ば', "&#x3070;")
		line = line.replace('ぱ', "&#x3071;")
		line = line.replace('ひ', "&#x3072;")
		line = line.replace('び', "&#x3073;")
		line = line.replace('ぴ', "&#x3074;")
		line = line.replace('ふ', "&#x3075;")
		line = line.replace('ぶ', "&#x3076;")
		line = line.replace('ぷ', "&#x3077;")
		line = line.replace('へ', "&#x3078;")
		line = line.replace('べ', "&#x3079;")
		line = line.replace('ぺ', "&#x307A;")
		line = line.replace('ほ', "&#x307B;")
		line = line.replace('ぼ', "&#x307C;")
		line = line.replace('ぽ', "&#x307D;")
		line = line.replace('ま', "&#x307E;")
		line = line.replace('み', "&#x307F;")
		line = line.replace('む', "&#x3080;")
		line = line.replace('め', "&#x3081;")
		line = line.replace('も', "&#x3082;")
		line = line.replace('ゃ', "&#x3083;")
		line = line.replace('や', "&#x3084;")
		line = line.replace('ゅ', "&#x3085;")
		line = line.replace('ゆ', "&#x3086;")
		line = line.replace('ょ', "&#x3087;")
		line = line.replace('よ', "&#x3088;")
		line = line.replace('ら', "&#x3089;")
		line = line.replace('り', "&#x308A;")
		line = line.replace('る', "&#x308B;")
		line = line.replace('れ', "&#x308C;")
		line = line.replace('ろ', "&#x308D;")
		line = line.replace('ゎ', "&#x308E;")
		line = line.replace('わ', "&#x308F;")
		line = line.replace('ゐ', "&#x3090;")
		line = line.replace('ゑ', "&#x3091;")
		line = line.replace('を', "&#x3092;")
		line = line.replace('ん', "&#x3093;")
		
	matchObj = re.search( r'[ァ-ヶ]', line, re.UNICODE)
	if matchObj:
		line = line.replace('ァ', "&#x30A1;")
		line = line.replace('ア', "&#x30A2;")
		line = line.replace('ィ', "&#x30A3;")
		line = line.replace('イ', "&#x30A4;")
		line = line.replace('ゥ', "&#x30A5;")
		line = line.replace('ウ', "&#x30A6;")
		line = line.replace('ェ', "&#x30A7;")
		line = line.replace('エ', "&#x30A8;")
		line = line.replace('ォ', "&#x30A9;")
		line = line.replace('オ', "&#x30AA;")
		line = line.replace('カ', "&#x30AB;")
		line = line.replace('ガ', "&#x30AC;")
		line = line.replace('キ', "&#x30AD;")
		line = line.replace('ギ', "&#x30AE;")
		line = line.replace('ク', "&#x30AF;")
		line = line.replace('グ', "&#x30B0;")
		line = line.replace('ケ', "&#x30B1;")
		line = line.replace('ゲ', "&#x30B2;")
		line = line.replace('コ', "&#x30B3;")
		line = line.replace('ゴ', "&#x30B4;")
		line = line.replace('サ', "&#x30B5;")
		line = line.replace('ザ', "&#x30B6;")
		line = line.replace('シ', "&#x30B7;")
		line = line.replace('ジ', "&#x30B8;")
		line = line.replace('ス', "&#x30B9;")
		line = line.replace('ズ', "&#x30BA;")
		line = line.replace('セ', "&#x30BB;")
		line = line.replace('ゼ', "&#x30BC;")
		line = line.replace('ソ', "&#x30BD;")
		line = line.replace('ゾ', "&#x30BE;")
		line = line.replace('タ', "&#x30BF;")
		line = line.replace('ダ', "&#x30C0;")
		line = line.replace('チ', "&#x30C1;")
		line = line.replace('ヂ', "&#x30C2;")
		line = line.replace('ッ', "&#x30C3;")
		line = line.replace('ツ', "&#x30C4;")
		line = line.replace('ヅ', "&#x30C5;")
		line = line.replace('テ', "&#x30C6;")
		line = line.replace('デ', "&#x30C7;")
		line = line.replace('ト', "&#x30C8;")
		line = line.replace('ド', "&#x30C9;")
		line = line.replace('ナ', "&#x30CA;")
		line = line.replace('ニ', "&#x30CB;")
		line = line.replace('ヌ', "&#x30CC;")
		line = line.replace('ネ', "&#x30CD;")
		line = line.replace('ノ', "&#x30CE;")
		line = line.replace('ハ', "&#x30CF;")
		line = line.replace('バ', "&#x30D0;")
		line = line.replace('パ', "&#x30D1;")
		line = line.replace('ヒ', "&#x30D2;")
		line = line.replace('ビ', "&#x30D3;")
		line = line.replace('ピ', "&#x30D4;")
		line = line.replace('フ', "&#x30D5;")
		line = line.replace('ブ', "&#x30D6;")
		line = line.replace('プ', "&#x30D7;")
		line = line.replace('ヘ', "&#x30D8;")
		line = line.replace('ベ', "&#x30D9;")
		line = line.replace('ペ', "&#x30DA;")
		line = line.replace('ホ', "&#x30DB;")
		line = line.replace('ボ', "&#x30DC;")
		line = line.replace('ポ', "&#x30DD;")
		line = line.replace('マ', "&#x30DE;")
		line = line.replace('ミ', "&#x30DF;")
		line = line.replace('ム', "&#x30E0;")
		line = line.replace('メ', "&#x30E1;")
		line = line.replace('モ', "&#x30E2;")
		line = line.replace('ャ', "&#x30E3;")
		line = line.replace('ヤ', "&#x30E4;")
		line = line.replace('ュ', "&#x30E5;")
		line = line.replace('ユ', "&#x30E6;")
		line = line.replace('ョ', "&#x30E7;")
		line = line.replace('ヨ', "&#x30E8;")
		line = line.replace('ラ', "&#x30E9;")
		line = line.replace('リ', "&#x30EA;")
		line = line.replace('ル', "&#x30EB;")
		line = line.replace('レ', "&#x30EC;")
		line = line.replace('ロ', "&#x30ED;")
		line = line.replace('ヮ', "&#x30EE;")
		line = line.replace('ワ', "&#x30EF;")
		line = line.replace('ヰ', "&#x30F0;")
		line = line.replace('ヱ', "&#x30F1;")
		line = line.replace('ヲ', "&#x30F2;")
		line = line.replace('ン', "&#x30F3;")
		line = line.replace('ヴ', "&#x30F4;")
		line = line.replace('ヵ', "&#x30F5;")
		line = line.replace('ヶ', "&#x30F6;")
	return line

#################################################
# 處理通用詞 (有斷行就麻煩了)
#################################################
def normal_words(line):
	line = line.replace('髣髣髴髴', '彷彷彿彿')
	line = line.replace('竛竛竮竮', '伶伶俜俜')
	line = line.replace('礔礰', '霹靂')
	line = line.replace('竛竮', '伶俜')
	line = line.replace('髣髴', '彷彿')
	line = line.replace('䠒跪', '胡跪')
	line = line.replace('搪揬', '唐突')
	line = line.replace('髴髣', '彿彷')
	line = line.replace('鴶䲳', '頡頏')
	line = line.replace('嬰姟', '嬰孩')
	line = line.replace('礕礰', '霹靂')
	line = line.replace('傏𠊲', '唐突')
	line = line.replace('𪄲鴹', '商羊')
	
	line = line.replace('髣髣[髟/弗][髟/弗]', '彷彷彿彿')
	line = line.replace('[立*令][立*令]竮竮', '伶伶俜俜')
	line = line.replace('礔[石*歷]', '霹靂')
	line = line.replace('[立*令]竮', '伶俜')
	line = line.replace('髣[髟/弗]', '彷彿')
	line = line.replace('[跍*月]跪', '胡跪')
	line = line.replace('搪[打-丁+突]', '唐突')
	line = line.replace('[髟/弗]髣', '彿彷')
	line = line.replace('鴶[亢*鳥]', '頡頏')
	line = line.replace('嬰[女*亥]', '嬰孩')
	line = line.replace('[辟/石][石*歷]', '霹靂')
	line = line.replace('[王*頗][王*梨]', '頗梨')
	line = line.replace('[仁-二+唐][仁-二+突]', '唐突')
	line = line.replace('[商*鳥][羊*鳥]', '商羊')
	return line

#################################################
# 處理單檔
#################################################
def trans_file(fn1, fn2):
	global high_word
	high_word=0
	print( fn1 + ' => ' + fn2)
	f1 = open(fn1, "r", encoding="utf-8")
	f2 = open(fn2, "w", encoding="cp950")
	#python 3.3.1 處理 ext-b 有問題, 所以改成逐字處理, 不用 error handler 了 -- 2013/08/15
	#f2=codecs.open(fn2, "w", "cp950", 'cbeta')
	for line in f1:
		#修改版本
		line = line.replace('(UTF-8) 普及版', '(Big5) 普及版')
		line = line.replace('(UTF-8) Normalized', '(Big5) Normalized')
		
		if options.unicode == "x":
			#處理日文
			line=trans_jep_x(line)
			#處理俄文
			line = line.replace('Ф', "&#xU0424;")
			line = line.replace('Д', "&#x0414;")
			line = line.replace('х', "&#x0445;")  			
		else:
			#處理日文
			line=trans_jep(line)
			#處理俄文
			line = line.replace('Ф', "【U0424】")
			line = line.replace('Д', "【U0414】")
			line = line.replace('х', "【U0445】")

		#處理通用詞
		#if options.unicode == "n":
		#	line=normal_words(line)
		
		# python 3.3.1 處理 ext-b 有問題, 所以改成逐字處理, 不用 error handler 了 -- 2013/08/15
		new = ''
		for c in line:
			try:
				if c == '々':
					new += '[?夕]'
				else:
					temp = c.encode('cp950') # 測試能否編碼為 cp950
					new += c
			except:
				new += u8tob5(c)
		f2.write(new)
	f1.close()
	f2.close()

#################################################
# 逐一處理各目錄
#################################################
def trans_dir(source, dest):
	if not os.path.exists(dest): os.makedirs(dest)
	l=os.listdir(source)
	#print l
	#sys.exit()
	for s in l:
		if os.path.isdir(source+'/'+s):
			trans_dir(source+'/'+s, dest+'/'+s)
		else:
			trans_file(source+'/'+s, dest+'/'+s)

#################################################
# 處理無法直接由 utf8 轉 big5 的文字
# (第三代, 因為第二代逐字讀取資料庫太慢了, 所以一次先把資料庫讀入)
#################################################
def u8tob5(c):
	global uni2b5
	
	r = ''
	i = ord(c)
		
	if i==0xFEFF:	#FEFF=65279
		#f3.write('if i==0xFEFF:	\n')
		return ''
	u = '{:04X}'.format(i)
	#f3.write('unicode : ' + u)
	
	if u in uni2b5:
		r = uni2b5[u]
	else:
		r = '&#x{};'.format(u)

	#f3.write(' result: ' + r)
	return (r)
	
#################################################
# 處理無法直接由 utf8 轉 big5 的文字 
# (第二代做法, 適用 python 3.3, 雖然可讀取 ext-b , 但有 bug , 故自行判斷)
#################################################
def u8tob5_old(c):
	global high_word
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	l = [] 
	counter=0
	#	使用UTF-16表達字符。
	#	UTF-16使用16至21位二進制位表達，即從/u0000到 /u10FFFF  0~65535 表示基本的16位字符
	#	/u10000到/u10FFFF表示輔助字符（supplymentary characters）
	#	輔助字符由一個高位替代符（high-surrogate ）和一個低位替代符（low-surrogate ）共同組成。
	#	高位替代符使用一個/uD800到/uDBFF之間的字符表示；	55296~56319
	#	低位替代符使用一個/uDC00到/uDFFF之間的字符表示。	56320~57343
	#	假設：A代表輔助字符（SC）的碼點值； B代表SC的高位替代符的碼點（Unicode code point）值； 
	#	C代表SC的低位替代符的碼點值。
	#	那麼下面的等式成立：A = (B - 0xD800) << 10 + (C - 0xDC00) + 0x10000在將Unicode還原為可閱讀字符的時候，
	#	當且僅當當前字符時高位替代符，下一字符是低位替代符時，此連續的兩個字符被解釋為輔助字符。
	#	<<	左移		把一個數的比特向左移一定數目（每個數在內存中都表示為比特或二進制數字，即0和1）ex:   2 << 2  =       10<<10=1000 得到8。
	#﨟 	&#x64031;
	
#for c in exc.object[exc.start:exc.end]:
	print ("counter: {} , ".format(counter), file=f3)
	counter+=1
	i = ord(c)
		
	if i==0xFEFF:	#FEFF=65279
		f3.write('if i==0xFEFF:	\n')
		return ''
	u = "%04X" % i
	f3.write('unicode : ' + u)
	sql = "SELECT des,cb, nor FROM gaiji WHERE unicode='%s'" % u
	rs.Open('[' + sql + ']', conn, 1, 3)
	
	if rs.RecordCount > 0:
		des = rs.Fields.Item('des').Value
		cb = rs.Fields.Item('cb').Value
		nor = rs.Fields.Item('nor').Value
		if des!=None and len(des)>0 and cb!=None and len(cb)>0:
			if options.gaijiNormalize and nor!=None and len(nor)>0:
				l.append(nor)
			else:
				l.append(des)
		else:
			l.append(nor)
	
	else:
		l.append('&#x%s;' % u)
	r = "".join(l)
	f3.write(' result: ' + r)
	return (r)

#################################################
# 處理無法直接由 utf8 轉 big5 的文字 
# (第一代做法, 適用 python 3.2 , 因為當時還無法直接讀取 ext-b)
#################################################
def my_err_handler(exc):
	global high_word
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	l = [] 
	counter=0
	#	使用UTF-16表達字符。
	#	UTF-16使用16至21位二進制位表達，即從/u0000到 /u10FFFF  0~65535 表示基本的16位字符
	#	/u10000到/u10FFFF表示輔助字符（supplymentary characters）
	#	輔助字符由一個高位替代符（high-surrogate ）和一個低位替代符（low-surrogate ）共同組成。
	#	高位替代符使用一個/uD800到/uDBFF之間的字符表示；	55296~56319
	#	低位替代符使用一個/uDC00到/uDFFF之間的字符表示。	56320~57343
	#	假設：A代表輔助字符（SC）的碼點值； B代表SC的高位替代符的碼點（Unicode code point）值； 
	#	C代表SC的低位替代符的碼點值。
	#	那麼下面的等式成立：A = (B - 0xD800) << 10 + (C - 0xDC00) + 0x10000在將Unicode還原為可閱讀字符的時候，
	#	當且僅當當前字符時高位替代符，下一字符是低位替代符時，此連續的兩個字符被解釋為輔助字符。
	#	<<	左移		把一個數的比特向左移一定數目（每個數在內存中都表示為比特或二進制數字，即0和1）ex:   2 << 2  =       10<<10=1000 得到8。
	#﨟 	&#x64031;
	for c in exc.object[exc.start:exc.end]:
		print ("counter: {} , ".format(counter), file=f3)
		counter+=1
		i = ord(c)
			
		if i==0xFEFF:	#FEFF=65279
			f3.write('if i==0xFEFF:	\n')
			continue
		elif high_word != 0:
			f3.write('high_word != 0:	\n')
			i = (i & 0x3FF) + high_word
			high_word = 0
		elif i >= 0xD800 and i <= 0xDFFF:	#D800=55296  是輔助字元
			f3.write('	i >= 0xD800 and i <= 0xDFFF:	\n')
			f3.write("73 %04X" % i)
			u = "%04X" % i
			if options.convertVariant and u in variant:
				u=variant[u]
				c=unichr(int(u,16))
				l.append(c)
			else:
				high_word = ((i & 0x3FF) + 0x40) << 10	#	(i & 1023) + 64
			continue
		u = "%04X" % i
		f3.write('unicode : ' + u)
		sql = "SELECT des,cb, nor FROM gaiji WHERE unicode='%s'" % u
		rs.Open('[' + sql + ']', conn, 1, 3)
		
		if rs.RecordCount > 0:
			des = rs.Fields.Item('des').Value
			cb = rs.Fields.Item('cb').Value
			nor = rs.Fields.Item('nor').Value
			if des!=None and len(des)>0 and cb!=None and len(cb)>0:
				if options.gaijiNormalize and nor!=None and len(nor)>0:
					l.append(nor)
				else:
					l.append(des)
			else:
				l.append(nor)
		
		else:
			l.append('&#x%s;' % u)
	r = "".join(l)
	f3.write(' result: ' + r)
	return (r, exc.end)
	
#################################################
# 讀取缺字資料庫
# 慢, 不用了
#################################################
def get_gaiji_m_old():
	global uni2b5
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	sql = "SELECT cb, des, unicode, nor FROM gaiji WHERE (((cb Is Null) OR (cb<='99999')) AND (unicode Is Not Null))"
	rs.Open(sql, conn, 1, 3)
	rs.MoveFirst()
	while 1:
		if rs.EOF:
			break
		else:
			cb = rs.Fields.Item('cb').Value			# cb 碼
			des = rs.Fields.Item('des').Value		# 組字式
			uni = rs.Fields.Item('unicode').Value	# unicode
			nor = rs.Fields.Item('nor').Value		# 通用字
			
			uni=uni.upper()
			if des!=None and len(des)>0 and cb!=None and len(cb)>0:
				# 一般組字式缺字
				if options.gaijiNormalize and nor!=None and len(nor)>0:
					uni2b5[uni] = nor
				else:
					uni2b5[uni] = des
			else:
				# 羅馬轉寫字
				uni2b5[uni] = nor
			rs.MoveNext()

#################################################
# 讀取純文字版的缺字資料庫 (速度較快)
#################################################
def get_gaiji_txt():
	global uni2b5
	with open(gaiji_txt, encoding='utf8') as infile:
		reader = csv.DictReader(infile,  delimiter='\t')
		for row in reader:
			cb = row['cb']
			uni = row['unicode']
			nor = row['nor']
			des = row['des']
			uni=uni.upper()

			if des!=None and len(des)>0 and cb!=None and len(cb)>0:
				# 一般組字式缺字
				if options.unicode == "n" and nor!=None and len(nor)>0:
					uni2b5[uni] = nor
				elif options.unicode != "x":
					uni2b5[uni] = des
			else:
				# 羅馬轉寫字
				if options.roma == "n" and nor!=None and len(nor)>0:
					uni2b5[uni] = nor
				elif options.roma != "x":
					if des != None and len(des)>0:
						uni2b5[uni] = des

#################################################
# main 主程式
#################################################

# 讀取 命令列參數
parser = OptionParser()
parser.add_option("-s", dest="source", help="來源資料夾")
parser.add_option("-o", dest="output", help="輸出資料夾")
#parser.add_option("-v", action="store_true", dest="convertVariant", default=False, help="異寫轉換")
#parser.add_option("-n", action="store_true", dest="gaijiNormalize", default=False, help="使用通用字")
parser.add_option("-u", dest="unicode", help="Unicode : -u d 先組字後編碼(預設), -u n 先通用後組字, -u x 編碼", default="d")
parser.add_option("-r", dest="roma", help="羅馬拼音: -r d 先組字後編碼(預設), -r n 先通用後組字, -r x 編碼", default="d")
(options, args) = parser.parse_args()

# 讀取設定檔 cbwork_bin.ini
config = configparser.SafeConfigParser()
config.read('../cbwork_bin.ini', 'UTF-8')
gaiji = config.get('default', 'gaiji-m.mdb_file')
gaiji_txt = gaiji.replace('gaiji-m.mdb', "gaiji-m_u8.txt")

high_word = 0
# python 3.3.1 處理 ext-b 有問題, 所以改成逐字處理, 不用 error handler 了 -- 2013/08/15
#codecs.register_error('cbeta', my_err_handler) 	# 先登記遇到缺字時的 error handler 

# 準備存取 gaiji-m.mdb
#conn = win32com.client.Dispatch(r'ADODB.Connection')
#DSN = 'PROVIDER=Microsoft.JET.OLEDB.4.0;DATA SOURCE=%s;' % gaiji
#conn.Open(DSN)

uni2b5 = {} 	# 宣告用來放 utf8 對應的組字式或通用字
# 讀取缺字資料庫
# get_gaiji_m_old()
# 讀取純文字版的缺字資料庫 (速度較快)
get_gaiji_txt()

# log 檔
f3 = open('u8-b5.log', "w", encoding="utf-8")

trans_dir(options.source, options.output)