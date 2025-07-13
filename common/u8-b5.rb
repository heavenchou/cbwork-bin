#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

=begin
u8-b5.rb
功能: 
	將目錄下(含子目錄)所有 utf-8 檔案轉為 CP950

使用說明:
	
	ruby u8-b5.rb [參數]

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

2025/07/12 之前是 python 版，之後是 ruby 版

作者: ray
2011.06.14 Ray: 改用 Python 3.2, 不過 64bit 版好像不能用
2009.12.02 Ray: 從 Unicode 網站取得 Unihan.txt, 取出裏面的異寫字資訊 kCompatibilityVariant, 放在 variant

Heaven 修改:
2025/07/12 使用 Claude Sonnet 4 改成 ruby 版
2022/10/06 ①~⑩ 及 ⑴~⑽ 這些字 python 認為有 big5 版，所以要另外處理
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
=end

require 'optparse'
require 'csv'
require 'fileutils'
require 'inifile'

# 從 Unihan.txt 取出的異寫字資訊
# 因為沒有使用，就不處理了，原始資料請看 python 版的 u8-b5.py
VARIANT = {
  'F900' => '8C48',
  '2FA1D' => '2A600'
}

class U8ToB5Converter
  def initialize
    @options = {}
    @uni2b5 = {}
    @high_word = 0
    @log_file = nil
    parse_options
    read_config
    get_gaiji_txt
    @log_file = File.open('u8-b5.log', 'w:utf-8')
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "用法: ruby u8-b5.rb -s 來源資料夾 -o 輸出資料夾 [選項]"
      opts.on('-s SOURCE', '--source SOURCE', '來源資料夾') { |s| @options[:source] = s }
      opts.on('-o OUTPUT', '--output OUTPUT', '輸出資料夾') { |o| @options[:output] = o }
      opts.on('-u UNICODE', '--unicode UNICODE', 'Unicode : -u d 先組字後編碼(預設), -u n 先通用後組字, -u x 編碼') { |u| @options[:unicode] = u }
      opts.on('-r ROMA', '--roma ROMA', '羅馬拼音: -r d 先組字後編碼(預設), -r n 先通用後組字, -r x 編碼') { |r| @options[:roma] = r }
      
      opts.on('-h', '--help', '顯示說明') do
        #puts opts
        puts "用法: ruby u8-b5.rb -s 來源資料夾 -o 輸出資料夾 [選項]
選項:
  -s Source   來源資料夾
  -o Output   輸出資料夾
  -u Unicode  Unicode : -u d 先組字後編碼(預設), -u n 先通用後組字及編碼, -u x 編碼
  -r Roma     羅馬拼音: -r d 先組字後編碼(預設), -r n 先通用後組字及編碼, -r x 編碼
  -h Help     顯示說明"
        exit
      end
    end.parse!
    
    # 設定預設值
    @options[:unicode] ||= 'd'
    @options[:roma] ||= 'd'
  end

  def read_config
    config_file = '../cbwork_bin.ini'
    if File.exist?(config_file)
      ini = IniFile.load(config_file)
      gaiji = ini['default']['gaiji-m.mdb_file']
      @gaiji_txt = gaiji.gsub('gaiji-m.mdb', 'gaiji-m_u8.txt')
    else
      @gaiji_txt = '../gaiji-m_u8.txt'
    end
  end

  def get_gaiji_txt
    return unless File.exist?(@gaiji_txt)
    
    CSV.foreach(@gaiji_txt, headers: true, col_sep: "\t", encoding: 'utf-8') do |row|
      cb = row['cb']
      uni = row['unicode']
      nor = row['nor']
      des = row['des']
      uni = uni.upcase if uni
      
      if des && !des.empty? && cb && !cb.empty?
        # 一般組字式缺字
        if @options[:unicode] == 'n' && nor && !nor.empty?
          @uni2b5[uni] = nor
        elsif @options[:unicode] != 'x'
          @uni2b5[uni] = des
        end
      else
        # 羅馬轉寫字
        if @options[:roma] == 'n' && nor && !nor.empty?
          @uni2b5[uni] = nor
        elsif @options[:roma] != 'x'
          if des && !des.empty?
            @uni2b5[uni] = des
          end
        end
      end
    end
  end

  def trans_jep(line)
    # 處理日文平假名
    if line =~ /[ぁ-ん]/
      line = line.gsub('ぁ', '【a】')
      line = line.gsub('あ', '【a】')
      line = line.gsub('ぃ', '【i】')
      line = line.gsub('い', '【i】')
      line = line.gsub('ぅ', '【u】')
      line = line.gsub('う', '【u】')
      line = line.gsub('ぇ', '【e】')
      line = line.gsub('え', '【e】')
      line = line.gsub('ぉ', '【o】')
      line = line.gsub('お', '【o】')
      line = line.gsub('か', '【ka】')
      line = line.gsub('が', '【ga】')
      line = line.gsub('き', '【ki】')
      line = line.gsub('ぎ', '【gi】')
      line = line.gsub('く', '【ku】')
      line = line.gsub('ぐ', '【gu】')
      line = line.gsub('け', '【ke】')
      line = line.gsub('げ', '【ge】')
      line = line.gsub('こ', '【ko】')
      line = line.gsub('ご', '【go】')
      line = line.gsub('さ', '【sa】')
      line = line.gsub('ざ', '【za】')
      line = line.gsub('し', '【shi】')
      line = line.gsub('じ', '【zi】')
      line = line.gsub('す', '【su】')
      line = line.gsub('ず', '【zu】')
      line = line.gsub('せ', '【se】')
      line = line.gsub('ぜ', '【ze】')
      line = line.gsub('そ', '【so】')
      line = line.gsub('ぞ', '【zo】')
      line = line.gsub('た', '【ta】')
      line = line.gsub('だ', '【da】')
      line = line.gsub('ち', '【chi】')
      line = line.gsub('ぢ', '【di】')
      line = line.gsub('っ', '【tsu】')
      line = line.gsub('つ', '【tsu】')
      line = line.gsub('づ', '【du】')
      line = line.gsub('て', '【te】')
      line = line.gsub('で', '【de】')
      line = line.gsub('と', '【to】')
      line = line.gsub('ど', '【do】')
      line = line.gsub('な', '【na】')
      line = line.gsub('に', '【ni】')
      line = line.gsub('ぬ', '【nu】')
      line = line.gsub('ね', '【ne】')
      line = line.gsub('の', '【no】')
      line = line.gsub('は', '【ha】')
      line = line.gsub('ば', '【ba】')
      line = line.gsub('ぱ', '【pa】')
      line = line.gsub('ひ', '【hi】')
      line = line.gsub('び', '【bi】')
      line = line.gsub('ぴ', '【pi】')
      line = line.gsub('ふ', '【hu】')
      line = line.gsub('ぶ', '【bu】')
      line = line.gsub('ぷ', '【pu】')
      line = line.gsub('へ', '【he】')
      line = line.gsub('べ', '【be】')
      line = line.gsub('ぺ', '【pe】')
      line = line.gsub('ほ', '【ho】')
      line = line.gsub('ぼ', '【bo】')
      line = line.gsub('ぽ', '【po】')
      line = line.gsub('ま', '【ma】')
      line = line.gsub('み', '【mi】')
      line = line.gsub('む', '【mu】')
      line = line.gsub('め', '【me】')
      line = line.gsub('も', '【mo】')
      line = line.gsub('ゃ', '【ya】')
      line = line.gsub('や', '【ya】')
      line = line.gsub('ゅ', '【yu】')
      line = line.gsub('ゆ', '【yu】')
      line = line.gsub('ょ', '【yo】')
      line = line.gsub('よ', '【yo】')
      line = line.gsub('ら', '【ra】')
      line = line.gsub('り', '【ri】')
      line = line.gsub('る', '【ru】')
      line = line.gsub('れ', '【re】')
      line = line.gsub('ろ', '【ro】')
      line = line.gsub('ゎ', '【wa】')
      line = line.gsub('わ', '【wa】')
      line = line.gsub('ゐ', '【wi】')
      line = line.gsub('ゑ', '【we】')
      line = line.gsub('を', '【wo】')
      line = line.gsub('ん', '【n】')

    end
    
    # 處理日文片假名
    if line =~ /[ァ-ヶ]/
      line = line.gsub('ァｰ', '【A-】')
      line = line.gsub('アー', '【A-】')
      line = line.gsub('ィｰ', '【I-】')
      line = line.gsub('イー', '【I-】')
      line = line.gsub('ゥｰ', '【U-】')
      line = line.gsub('ウー', '【U-】')
      line = line.gsub('ェｰ', '【E-】')
      line = line.gsub('エー', '【E-】')
      line = line.gsub('ォｰ', '【O-】')
      line = line.gsub('オー', '【O-】')
      line = line.gsub('カー', '【KA-】')
      line = line.gsub('ガー', '【GA-】')
      line = line.gsub('キー', '【KI-】')
      line = line.gsub('ギー', '【GI-】')
      line = line.gsub('クー', '【KU-】')
      line = line.gsub('グー', '【GU-】')
      line = line.gsub('ケー', '【KE-】')
      line = line.gsub('ゲー', '【GE-】')
      line = line.gsub('コー', '【KO-】')
      line = line.gsub('ゴー', '【GO-】')
      line = line.gsub('サー', '【SA-】')
      line = line.gsub('ザー', '【ZA-】')
      line = line.gsub('シー', '【SHI-】')
      line = line.gsub('ジー', '【ZI-】')
      line = line.gsub('スー', '【SU-】')
      line = line.gsub('ズー', '【ZU-】')
      line = line.gsub('セー', '【SE-】')
      line = line.gsub('ゼー', '【ZE-】')
      line = line.gsub('ソー', '【SO-】')
      line = line.gsub('ゾー', '【ZO-】')
      line = line.gsub('ター', '【TA-】')
      line = line.gsub('ダー', '【DA-】')
      line = line.gsub('チー', '【CHI-】')
      line = line.gsub('ヂー', '【DI-】')
      line = line.gsub('ッー', '【TSU-】')
      line = line.gsub('ツー', '【TSU-】')
      line = line.gsub('ヅー', '【DU-】')
      line = line.gsub('テー', '【TE-】')
      line = line.gsub('デー', '【DE-】')
      line = line.gsub('トー', '【TO-】')
      line = line.gsub('ドー', '【DO-】')
      line = line.gsub('ナー', '【NA-】')
      line = line.gsub('ニー', '【NI-】')
      line = line.gsub('ヌー', '【NU-】')
      line = line.gsub('ネー', '【NE-】')
      line = line.gsub('ノー', '【NO-】')
      line = line.gsub('ハー', '【HA-】')
      line = line.gsub('バー', '【BA-】')
      line = line.gsub('パー', '【PA-】')
      line = line.gsub('ヒー', '【HI-】')
      line = line.gsub('ビー', '【BI-】')
      line = line.gsub('ピー', '【PI-】')
      line = line.gsub('フー', '【HU-】')
      line = line.gsub('ブー', '【BU-】')
      line = line.gsub('プー', '【PU-】')
      line = line.gsub('ヘー', '【HE-】')
      line = line.gsub('ベー', '【BE-】')
      line = line.gsub('ペー', '【PE-】')
      line = line.gsub('ホー', '【HO-】')
      line = line.gsub('ボー', '【BO-】')
      line = line.gsub('ポー', '【PO-】')
      line = line.gsub('マー', '【MA-】')
      line = line.gsub('ミー', '【MI-】')
      line = line.gsub('ムー', '【MU-】')
      line = line.gsub('メー', '【ME-】')
      line = line.gsub('モー', '【MO-】')
      line = line.gsub('ャー', '【YA-】')
      line = line.gsub('ヤー', '【YA-】')
      line = line.gsub('ュー', '【YU-】')
      line = line.gsub('ユー', '【YU-】')
      line = line.gsub('ョー', '【YO-】')
      line = line.gsub('ヨー', '【YO-】')
      line = line.gsub('ラー', '【RA-】')
      line = line.gsub('リー', '【RI-】')
      line = line.gsub('ルー', '【RU-】')
      line = line.gsub('レー', '【RE-】')
      line = line.gsub('ロー', '【RO-】')
      line = line.gsub('ヮー', '【WA-】')
      line = line.gsub('ワー', '【WA-】')
      line = line.gsub('ヰー', '【WI-】')
      line = line.gsub('ヱー', '【WE-】')
      line = line.gsub('ヲー', '【WO-】')
      line = line.gsub('ンー', '【N-】')
      line = line.gsub('ヴー', '【VU-】')
      line = line.gsub('ヵー', '【KA-】')
      line = line.gsub('ヶー', '【KE-】')

      line = line.gsub('ァ', '【A】')
      line = line.gsub('ア', '【A】')
      line = line.gsub('ィ', '【I】')
      line = line.gsub('イ', '【I】')
      line = line.gsub('ゥ', '【U】')
      line = line.gsub('ウ', '【U】')
      line = line.gsub('ェ', '【E】')
      line = line.gsub('エ', '【E】')
      line = line.gsub('ォ', '【O】')
      line = line.gsub('オ', '【O】')
      line = line.gsub('カ', '【KA】')
      line = line.gsub('ガ', '【GA】')
      line = line.gsub('キ', '【KI】')
      line = line.gsub('ギ', '【GI】')
      line = line.gsub('ク', '【KU】')
      line = line.gsub('グ', '【GU】')
      line = line.gsub('ケ', '【KE】')
      line = line.gsub('ゲ', '【GE】')
      line = line.gsub('コ', '【KO】')
      line = line.gsub('ゴ', '【GO】')
      line = line.gsub('サ', '【SA】')
      line = line.gsub('ザ', '【ZA】')
      line = line.gsub('シ', '【SHI】')
      line = line.gsub('ジ', '【ZI】')
      line = line.gsub('ス', '【SU】')
      line = line.gsub('ズ', '【ZU】')
      line = line.gsub('セ', '【SE】')
      line = line.gsub('ゼ', '【ZE】')
      line = line.gsub('ソ', '【SO】')
      line = line.gsub('ゾ', '【ZO】')
      line = line.gsub('タ', '【TA】')
      line = line.gsub('ダ', '【DA】')
      line = line.gsub('チ', '【CHI】')
      line = line.gsub('ヂ', '【DI】')
      line = line.gsub('ッ', '【TSU】')
      line = line.gsub('ツ', '【TSU】')
      line = line.gsub('ヅ', '【DU】')
      line = line.gsub('テ', '【TE】')
      line = line.gsub('デ', '【DE】')
      line = line.gsub('ト', '【TO】')
      line = line.gsub('ド', '【DO】')
      line = line.gsub('ナ', '【NA】')
      line = line.gsub('ニ', '【NI】')
      line = line.gsub('ヌ', '【NU】')
      line = line.gsub('ネ', '【NE】')
      line = line.gsub('ノ', '【NO】')
      line = line.gsub('ハ', '【HA】')
      line = line.gsub('バ', '【BA】')
      line = line.gsub('パ', '【PA】')
      line = line.gsub('ヒ', '【HI】')
      line = line.gsub('ビ', '【BI】')
      line = line.gsub('ピ', '【PI】')
      line = line.gsub('フ', '【HU】')
      line = line.gsub('ブ', '【BU】')
      line = line.gsub('プ', '【PU】')
      line = line.gsub('ヘ', '【HE】')
      line = line.gsub('ベ', '【BE】')
      line = line.gsub('ペ', '【PE】')
      line = line.gsub('ホ', '【HO】')
      line = line.gsub('ボ', '【BO】')
      line = line.gsub('ポ', '【PO】')
      line = line.gsub('マ', '【MA】')
      line = line.gsub('ミ', '【MI】')
      line = line.gsub('ム', '【MU】')
      line = line.gsub('メ', '【ME】')
      line = line.gsub('モ', '【MO】')
      line = line.gsub('ャ', '【YA】')
      line = line.gsub('ヤ', '【YA】')
      line = line.gsub('ュ', '【YU】')
      line = line.gsub('ユ', '【YU】')
      line = line.gsub('ョ', '【YO】')
      line = line.gsub('ヨ', '【YO】')
      line = line.gsub('ラ', '【RA】')
      line = line.gsub('リ', '【RI】')
      line = line.gsub('ル', '【RU】')
      line = line.gsub('レ', '【RE】')
      line = line.gsub('ロ', '【RO】')
      line = line.gsub('ヮ', '【WA】')
      line = line.gsub('ワ', '【WA】')
      line = line.gsub('ヰ', '【WI】')
      line = line.gsub('ヱ', '【WE】')
      line = line.gsub('ヲ', '【WO】')
      line = line.gsub('ン', '【N】')
      line = line.gsub('ヴ', '【VU】')
      line = line.gsub('ヵ', '【KA】')
      line = line.gsub('ヶ', '【KE】')

    end
    
    line
  end

  def trans_jep_x(line)
    # 處理日文平假名
    if line =~ /[ぁ-ん]/
      line = line.gsub('ぁ', '&#x3041;')
      line = line.gsub('あ', '&#x3042;')
      line = line.gsub('ぃ', '&#x3043;')
      line = line.gsub('い', '&#x3044;')
      line = line.gsub('ぅ', '&#x3045;')
      line = line.gsub('う', '&#x3046;')
      line = line.gsub('ぇ', '&#x3047;')
      line = line.gsub('え', '&#x3048;')
      line = line.gsub('ぉ', '&#x3049;')
      line = line.gsub('お', '&#x304A;')
      line = line.gsub('か', '&#x304B;')
      line = line.gsub('が', '&#x304C;')
      line = line.gsub('き', '&#x304D;')
      line = line.gsub('ぎ', '&#x304E;')
      line = line.gsub('く', '&#x304F;')
      line = line.gsub('ぐ', '&#x3050;')
      line = line.gsub('け', '&#x3051;')
      line = line.gsub('げ', '&#x3052;')
      line = line.gsub('こ', '&#x3053;')
      line = line.gsub('ご', '&#x3054;')
      line = line.gsub('さ', '&#x3055;')
      line = line.gsub('ざ', '&#x3056;')
      line = line.gsub('し', '&#x3057;')
      line = line.gsub('じ', '&#x3058;')
      line = line.gsub('す', '&#x3059;')
      line = line.gsub('ず', '&#x305A;')
      line = line.gsub('せ', '&#x305B;')
      line = line.gsub('ぜ', '&#x305C;')
      line = line.gsub('そ', '&#x305D;')
      line = line.gsub('ぞ', '&#x305E;')
      line = line.gsub('た', '&#x305F;')
      line = line.gsub('だ', '&#x3060;')
      line = line.gsub('ち', '&#x3061;')
      line = line.gsub('ぢ', '&#x3062;')
      line = line.gsub('っ', '&#x3063;')
      line = line.gsub('つ', '&#x3064;')
      line = line.gsub('づ', '&#x3065;')
      line = line.gsub('て', '&#x3066;')
      line = line.gsub('で', '&#x3067;')
      line = line.gsub('と', '&#x3068;')
      line = line.gsub('ど', '&#x3069;')
      line = line.gsub('な', '&#x306A;')
      line = line.gsub('に', '&#x306B;')
      line = line.gsub('ぬ', '&#x306C;')
      line = line.gsub('ね', '&#x306D;')
      line = line.gsub('の', '&#x306E;')
      line = line.gsub('は', '&#x306F;')
      line = line.gsub('ば', '&#x3070;')
      line = line.gsub('ぱ', '&#x3071;')
      line = line.gsub('ひ', '&#x3072;')
      line = line.gsub('び', '&#x3073;')
      line = line.gsub('ぴ', '&#x3074;')
      line = line.gsub('ふ', '&#x3075;')
      line = line.gsub('ぶ', '&#x3076;')
      line = line.gsub('ぷ', '&#x3077;')
      line = line.gsub('へ', '&#x3078;')
      line = line.gsub('べ', '&#x3079;')
      line = line.gsub('ぺ', '&#x307A;')
      line = line.gsub('ほ', '&#x307B;')
      line = line.gsub('ぼ', '&#x307C;')
      line = line.gsub('ぽ', '&#x307D;')
      line = line.gsub('ま', '&#x307E;')
      line = line.gsub('み', '&#x307F;')
      line = line.gsub('む', '&#x3080;')
      line = line.gsub('め', '&#x3081;')
      line = line.gsub('も', '&#x3082;')
      line = line.gsub('ゃ', '&#x3083;')
      line = line.gsub('や', '&#x3084;')
      line = line.gsub('ゅ', '&#x3085;')
      line = line.gsub('ゆ', '&#x3086;')
      line = line.gsub('ょ', '&#x3087;')
      line = line.gsub('よ', '&#x3088;')
      line = line.gsub('ら', '&#x3089;')
      line = line.gsub('り', '&#x308A;')
      line = line.gsub('る', '&#x308B;')
      line = line.gsub('れ', '&#x308C;')
      line = line.gsub('ろ', '&#x308D;')
      line = line.gsub('ゎ', '&#x308E;')
      line = line.gsub('わ', '&#x308F;')
      line = line.gsub('ゐ', '&#x3090;')
      line = line.gsub('ゑ', '&#x3091;')
      line = line.gsub('を', '&#x3092;')
      line = line.gsub('ん', '&#x3093;')

    end
    
    # 處理日文片假名
    if line =~ /[ァ-ヶ]/        
      line = line.gsub('ァ', '&#x30A1;')
      line = line.gsub('ア', '&#x30A2;')
      line = line.gsub('ィ', '&#x30A3;')
      line = line.gsub('イ', '&#x30A4;')
      line = line.gsub('ゥ', '&#x30A5;')
      line = line.gsub('ウ', '&#x30A6;')
      line = line.gsub('ェ', '&#x30A7;')
      line = line.gsub('エ', '&#x30A8;')
      line = line.gsub('ォ', '&#x30A9;')
      line = line.gsub('オ', '&#x30AA;')
      line = line.gsub('カ', '&#x30AB;')
      line = line.gsub('ガ', '&#x30AC;')
      line = line.gsub('キ', '&#x30AD;')
      line = line.gsub('ギ', '&#x30AE;')
      line = line.gsub('ク', '&#x30AF;')
      line = line.gsub('グ', '&#x30B0;')
      line = line.gsub('ケ', '&#x30B1;')
      line = line.gsub('ゲ', '&#x30B2;')
      line = line.gsub('コ', '&#x30B3;')
      line = line.gsub('ゴ', '&#x30B4;')
      line = line.gsub('サ', '&#x30B5;')
      line = line.gsub('ザ', '&#x30B6;')
      line = line.gsub('シ', '&#x30B7;')
      line = line.gsub('ジ', '&#x30B8;')
      line = line.gsub('ス', '&#x30B9;')
      line = line.gsub('ズ', '&#x30BA;')
      line = line.gsub('セ', '&#x30BB;')
      line = line.gsub('ゼ', '&#x30BC;')
      line = line.gsub('ソ', '&#x30BD;')
      line = line.gsub('ゾ', '&#x30BE;')
      line = line.gsub('タ', '&#x30BF;')
      line = line.gsub('ダ', '&#x30C0;')
      line = line.gsub('チ', '&#x30C1;')
      line = line.gsub('ヂ', '&#x30C2;')
      line = line.gsub('ッ', '&#x30C3;')
      line = line.gsub('ツ', '&#x30C4;')
      line = line.gsub('ヅ', '&#x30C5;')
      line = line.gsub('テ', '&#x30C6;')
      line = line.gsub('デ', '&#x30C7;')
      line = line.gsub('ト', '&#x30C8;')
      line = line.gsub('ド', '&#x30C9;')
      line = line.gsub('ナ', '&#x30CA;')
      line = line.gsub('ニ', '&#x30CB;')
      line = line.gsub('ヌ', '&#x30CC;')
      line = line.gsub('ネ', '&#x30CD;')
      line = line.gsub('ノ', '&#x30CE;')
      line = line.gsub('ハ', '&#x30CF;')
      line = line.gsub('バ', '&#x30D0;')
      line = line.gsub('パ', '&#x30D1;')
      line = line.gsub('ヒ', '&#x30D2;')
      line = line.gsub('ビ', '&#x30D3;')
      line = line.gsub('ピ', '&#x30D4;')
      line = line.gsub('フ', '&#x30D5;')
      line = line.gsub('ブ', '&#x30D6;')
      line = line.gsub('プ', '&#x30D7;')
      line = line.gsub('ヘ', '&#x30D8;')
      line = line.gsub('ベ', '&#x30D9;')
      line = line.gsub('ペ', '&#x30DA;')
      line = line.gsub('ホ', '&#x30DB;')
      line = line.gsub('ボ', '&#x30DC;')
      line = line.gsub('ポ', '&#x30DD;')
      line = line.gsub('マ', '&#x30DE;')
      line = line.gsub('ミ', '&#x30DF;')
      line = line.gsub('ム', '&#x30E0;')
      line = line.gsub('メ', '&#x30E1;')
      line = line.gsub('モ', '&#x30E2;')
      line = line.gsub('ャ', '&#x30E3;')
      line = line.gsub('ヤ', '&#x30E4;')
      line = line.gsub('ュ', '&#x30E5;')
      line = line.gsub('ユ', '&#x30E6;')
      line = line.gsub('ョ', '&#x30E7;')
      line = line.gsub('ヨ', '&#x30E8;')
      line = line.gsub('ラ', '&#x30E9;')
      line = line.gsub('リ', '&#x30EA;')
      line = line.gsub('ル', '&#x30EB;')
      line = line.gsub('レ', '&#x30EC;')
      line = line.gsub('ロ', '&#x30ED;')
      line = line.gsub('ヮ', '&#x30EE;')
      line = line.gsub('ワ', '&#x30EF;')
      line = line.gsub('ヰ', '&#x30F0;')
      line = line.gsub('ヱ', '&#x30F1;')
      line = line.gsub('ヲ', '&#x30F2;')
      line = line.gsub('ン', '&#x30F3;')
      line = line.gsub('ヴ', '&#x30F4;')
      line = line.gsub('ヵ', '&#x30F5;')
      line = line.gsub('ヶ', '&#x30F6;')

    end
    
    line
  end

  def u8tob5(c)
    return '' if c.ord == 0xFEFF
    
    u = sprintf('%04X', c.ord)
    
    if @uni2b5.key?(u)
      @uni2b5[u]
    else
      "&#x#{u};"
    end
  end

  def can_encode_big5?(char)
    begin
      char.encode('cp950')
      true
    rescue Encoding::UndefinedConversionError
      false
    end
  end

  def trans_file(fn1, fn2)
    @high_word = 0
    puts "#{fn1} => #{fn2}"
    
    File.open(fn1, 'r:utf-8') do |f1|
      File.open(fn2, 'w:cp950') do |f2|
        f1.each_line do |line|
          # 修改版本
          line = line.gsub('(UTF-8) 普及版', '(Big5) 普及版')
          line = line.gsub('(UTF-8) Normalized', '(Big5) Normalized')
          
          if @options[:unicode] == 'x'
            # 處理日文
            line = trans_jep_x(line)
            # 處理俄文
            line = line.gsub('Ф', '&#x0424;')
            line = line.gsub('Д', '&#x0414;')
            line = line.gsub('х', '&#x0445;')
          else
            # 處理日文
            line = trans_jep(line)
            # 處理俄文
            line = line.gsub('Ф', '【U0424】')
            line = line.gsub('Д', '【U0414】')
            line = line.gsub('х', '【U0445】')
          end
          
          # 逐字處理
          new_line = ''
          line.each_char do |c|
            if c == '々'
              new_line += '[?夕]'
            elsif c >= '①' && c <= '⑳'
              new_line += u8tob5(c)
            elsif c >= '⑴' && c <= '⒇'
              new_line += u8tob5(c)
            elsif c >= '㈠' && c <= '㈩'
              new_line += u8tob5(c)
            elsif can_encode_big5?(c)
              new_line += c
            else
              new_line += u8tob5(c)
            end
          end
          
          f2.write(new_line)
        end
      end
    end
  end

  def trans_dir(source, dest)
    FileUtils.mkdir_p(dest) unless File.exist?(dest)
    
    Dir.foreach(source) do |item|
      next if item == '.' || item == '..'
      
      source_path = File.join(source, item)
      dest_path = File.join(dest, item)
      
      if File.directory?(source_path)
        trans_dir(source_path, dest_path)
      else
        trans_file(source_path, dest_path)
      end
    end
  end

  def run
    unless @options[:source] && @options[:output]
      puts "請指定來源資料夾 (-s) 和輸出資料夾 (-o)"
      exit 1
    end
    
    unless File.exist?(@options[:source])
      puts "來源資料夾不存在: #{@options[:source]}"
      exit 1
    end
    
    trans_dir(@options[:source], @options[:output])
  ensure
    @log_file.close if @log_file
  end
end

# 主程式
if __FILE__ == $0
  converter = U8ToB5Converter.new
  converter.run
end