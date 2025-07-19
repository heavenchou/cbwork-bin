#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

=begin
b5-u8.rb
功能: 
	將目錄下(含子目錄)所有 big5 檔案轉為 utf-8

使用方法:

	ruby b5-u8.rb [參數]

	參數:
	-h 查看參數說明
	-s 指定來源資料來
	-o 指定輸出資料來

	--roma 要處理 ~n 這種羅馬轉寫通用字
	--nox  不處理 &#x....; 編碼
	--nod  不處理 組字式
	--noj  不處理【A】這種日文格式
	--nor  不處理【U0424】這種俄文格式

	預設是沒有這些 --xxx 參數，也就是會做出和參數相反的動作。

	例: ruby b5-u8.rb -s d:/temp/J23 -o d:/temp/J23U8

2025/07/12 之前是 python 版，之後是 ruby 版

2011.6.18 改寫使用 python 3
作者: 周邦信 2009.05.26

Heaven 修改:
2025/07/20 修正處理羅馬轉寫字 unicode 的問題
2025/07/12 使用 Claude Sonnet 4 改成 ruby 版
2022/10/06 ①~⑩ 及 ⑴~⑽ 這些字 python 認為有 big5 版，所以要另外處理
2022/04/28 cbwork_bin.ini 改成支援 utf8 版
2020/11/24 增加日本長音 'ー' 的處理法
2017/10/29 增加許多參數 --xxx , 控制轉換的內容, 詳見功能說明
2017/10/28 修改缺字的讀取, 原本讀取 MS Access 資料庫改成讀純文字 csv 檔, 速度快很多
2013/10/20 修改缺字的讀取, 由逐字查詢資料庫改成一次讀取全部資料庫
2013/10/16 將日文拼音及 &M 碼轉成日文unicode
2013/06/09 變數改用設定檔 ../cbwork_bin.ini
=end

require 'optparse'
require 'fileutils'
require 'csv'
require 'inifile'

class Big5ToUtf8Converter
  def initialize
    @options = {}
    @des2u8 = {}
    @romas = {}
    parse_options
    load_config
    load_gaiji_data
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "使用方法: ruby b5-u8.rb [參數]"
      
      opts.on("-s", "--source SOURCE", "來源資料夾") do |s|
        @options[:source] = s
      end
      
      opts.on("-o", "--output OUTPUT", "輸出資料夾") do |o|
        @options[:output] = o
      end
      
      opts.on("--roma", "要處理 ~n 這種羅馬轉寫通用字") do
        @options[:roma] = true
      end
      
      opts.on("--nox", "不處理 &#x....; 編碼") do
        @options[:no_x_code] = true
      end
      
      opts.on("--nod", "不處理 組字式") do
        @options[:no_des] = true
      end
      
      opts.on("--noj", "不處理【A】這種日文格式") do
        @options[:no_japan] = true
      end
      
      opts.on("--nor", "不處理【U0424】這種俄文格式") do
        @options[:no_russia] = true
      end
      
      opts.on("-h", "--help", "顯示說明") do
        puts opts
        exit
      end
    end.parse!
  end

  def load_config
    begin
      # 讀取設定檔 cbwork_bin.ini
      config = IniFile.load('../cbwork_bin.ini')
      gaiji = config['default']['gaiji-m.mdb_file']
      @gaiji_txt = gaiji.sub('gaiji-m.mdb', "gaiji-m_u8.txt")
    rescue => e
      puts "警告: 無法讀取設定檔，使用預設值"
      @gaiji_txt = "../gaiji-m_u8.txt"
    end
  end

  def load_gaiji_data
    return unless File.exist?(@gaiji_txt)
    
    begin
      CSV.foreach(@gaiji_txt, headers: true, col_sep: "\t", encoding: 'UTF-8') do |row|
        cb = row['cb']
        uni = row['unicode']
        nor = row['nor']
        des = row['des']
        
        next unless uni && !uni.empty?
        uni = uni.upcase
        
        if cb && !cb.empty?
          # 一般組字式缺字
          if cb <= '99999'
            if des && !des.empty?
              @des2u8[des] = [uni.to_i(16)].pack('U')
            end
          end
        else
          # 羅馬轉寫字
          if nor && !nor.empty?
            @romas[nor] = [uni.to_i(16)].pack('U')
          end
          if des && !des.empty?
            @des2u8[des] = [uni.to_i(16)].pack('U')
          end
        end
      end
    rescue => e
      puts "警告: 無法讀取缺字資料庫: #{e.message}"
    end
  end

  def trans_jap(line)
    if line =~ /【.*?】/
      line.gsub!('【a】' , 'あ')
      line.gsub!('【i】' , 'い')
      line.gsub!('【u】' , 'う')
      line.gsub!('【e】' , 'え')
      line.gsub!('【o】' , 'お')
      line.gsub!('【ka】' , 'か')
      line.gsub!('【ga】' , 'が')
      line.gsub!('【ki】' , 'き')
      line.gsub!('【gi】' , 'ぎ')
      line.gsub!('【ku】' , 'く')
      line.gsub!('【gu】' , 'ぐ')
      line.gsub!('【ke】' , 'け')
      line.gsub!('【ge】' , 'げ')
      line.gsub!('【ko】' , 'こ')
      line.gsub!('【go】' , 'ご')
      line.gsub!('【sa】' , 'さ')
      line.gsub!('【za】' , 'ざ')
      line.gsub!('【shi】' , 'し')
      line.gsub!('【zi】' , 'じ')
      line.gsub!('【su】' , 'す')
      line.gsub!('【zu】' , 'ず')
      line.gsub!('【se】' , 'せ')
      line.gsub!('【ze】' , 'ぜ')
      line.gsub!('【so】' , 'そ')
      line.gsub!('【zo】' , 'ぞ')
      line.gsub!('【ta】' , 'た')
      line.gsub!('【da】' , 'だ')
      line.gsub!('【chi】' , 'ち')
      line.gsub!('【di】' , 'ぢ')
      line.gsub!('【tsu】' , 'つ')
      line.gsub!('【du】' , 'づ')
      line.gsub!('【te】' , 'て')
      line.gsub!('【de】' , 'で')
      line.gsub!('【to】' , 'と')
      line.gsub!('【do】' , 'ど')
      line.gsub!('【na】' , 'な')
      line.gsub!('【ni】' , 'に')
      line.gsub!('【nu】' , 'ぬ')
      line.gsub!('【ne】' , 'ね')
      line.gsub!('【no】' , 'の')
      line.gsub!('【ha】' , 'は')
      line.gsub!('【ba】' , 'ば')
      line.gsub!('【pa】' , 'ぱ')
      line.gsub!('【hi】' , 'ひ')
      line.gsub!('【bi】' , 'び')
      line.gsub!('【pi】' , 'ぴ')
      line.gsub!('【hu】' , 'ふ')
      line.gsub!('【bu】' , 'ぶ')
      line.gsub!('【pu】' , 'ぷ')
      line.gsub!('【he】' , 'へ')
      line.gsub!('【be】' , 'べ')
      line.gsub!('【pe】' , 'ぺ')
      line.gsub!('【ho】' , 'ほ')
      line.gsub!('【bo】' , 'ぼ')
      line.gsub!('【po】' , 'ぽ')
      line.gsub!('【ma】' , 'ま')
      line.gsub!('【mi】' , 'み')
      line.gsub!('【mu】' , 'む')
      line.gsub!('【me】' , 'め')
      line.gsub!('【mo】' , 'も')
      line.gsub!('【ya】' , 'や')
      line.gsub!('【yu】' , 'ゆ')
      line.gsub!('【yo】' , 'よ')
      line.gsub!('【ra】' , 'ら')
      line.gsub!('【ri】' , 'り')
      line.gsub!('【ru】' , 'る')
      line.gsub!('【re】' , 'れ')
      line.gsub!('【ro】' , 'ろ')
      line.gsub!('【wa】' , 'わ')
      line.gsub!('【wi】' , 'ゐ')
      line.gsub!('【we】' , 'ゑ')
      line.gsub!('【wo】' , 'を')
      line.gsub!('【n】' , 'ん')
      line.gsub!('【A】' , 'ア')
      line.gsub!('【I】' , 'イ')
      line.gsub!('【U】' , 'ウ')
      line.gsub!('【E】' , 'エ')
      line.gsub!('【O】' , 'オ')
      line.gsub!('【KA】' , 'カ')
      line.gsub!('【GA】' , 'ガ')
      line.gsub!('【KI】' , 'キ')
      line.gsub!('【GI】' , 'ギ')
      line.gsub!('【KU】' , 'ク')
      line.gsub!('【GU】' , 'グ')
      line.gsub!('【KE】' , 'ケ')
      line.gsub!('【GE】' , 'ゲ')
      line.gsub!('【KO】' , 'コ')
      line.gsub!('【GO】' , 'ゴ')
      line.gsub!('【SA】' , 'サ')
      line.gsub!('【ZA】' , 'ザ')
      line.gsub!('【SHI】' , 'シ')
      line.gsub!('【ZI】' , 'ジ')
      line.gsub!('【SU】' , 'ス')
      line.gsub!('【ZU】' , 'ズ')
      line.gsub!('【SE】' , 'セ')
      line.gsub!('【ZE】' , 'ゼ')
      line.gsub!('【SO】' , 'ソ')
      line.gsub!('【ZO】' , 'ゾ')
      line.gsub!('【TA】' , 'タ')
      line.gsub!('【DA】' , 'ダ')
      line.gsub!('【CHI】' , 'チ')
      line.gsub!('【DI】' , 'ヂ')
      line.gsub!('【TSU】' , 'ツ')
      line.gsub!('【DU】' , 'ヅ')
      line.gsub!('【TE】' , 'テ')
      line.gsub!('【DE】' , 'デ')
      line.gsub!('【TO】' , 'ト')
      line.gsub!('【DO】' , 'ド')
      line.gsub!('【NA】' , 'ナ')
      line.gsub!('【NI】' , 'ニ')
      line.gsub!('【NU】' , 'ヌ')
      line.gsub!('【NE】' , 'ネ')
      line.gsub!('【NO】' , 'ノ')
      line.gsub!('【HA】' , 'ハ')
      line.gsub!('【BA】' , 'バ')
      line.gsub!('【PA】' , 'パ')
      line.gsub!('【HI】' , 'ヒ')
      line.gsub!('【BI】' , 'ビ')
      line.gsub!('【PI】' , 'ピ')
      line.gsub!('【HU】' , 'フ')
      line.gsub!('【BU】' , 'ブ')
      line.gsub!('【PU】' , 'プ')
      line.gsub!('【HE】' , 'ヘ')
      line.gsub!('【BE】' , 'ベ')
      line.gsub!('【PE】' , 'ペ')
      line.gsub!('【HO】' , 'ホ')
      line.gsub!('【BO】' , 'ボ')
      line.gsub!('【PO】' , 'ポ')
      line.gsub!('【MA】' , 'マ')
      line.gsub!('【MI】' , 'ミ')
      line.gsub!('【MU】' , 'ム')
      line.gsub!('【ME】' , 'メ')
      line.gsub!('【MO】' , 'モ')
      line.gsub!('【YA】' , 'ヤ')
      line.gsub!('【YU】' , 'ユ')
      line.gsub!('【YO】' , 'ヨ')
      line.gsub!('【RA】' , 'ラ')
      line.gsub!('【RI】' , 'リ')
      line.gsub!('【RU】' , 'ル')
      line.gsub!('【RE】' , 'レ')
      line.gsub!('【RO】' , 'ロ')
      line.gsub!('【WA】' , 'ワ')
      line.gsub!('【WI】' , 'ヰ')
      line.gsub!('【WE】' , 'ヱ')
      line.gsub!('【WO】' , 'ヲ')
      line.gsub!('【N】' , 'ン')
      line.gsub!('【VU】' , 'ヴ')

      line.gsub!('【A-】' , 'アー')
      line.gsub!('【I-】' , 'イー')
      line.gsub!('【U-】' , 'ウー')
      line.gsub!('【E-】' , 'エー')
      line.gsub!('【O-】' , 'オー')
      line.gsub!('【KA-】' , 'カー')
      line.gsub!('【GA-】' , 'ガー')
      line.gsub!('【KI-】' , 'キー')
      line.gsub!('【GI-】' , 'ギー')
      line.gsub!('【KU-】' , 'クー')
      line.gsub!('【GU-】' , 'グー')
      line.gsub!('【KE-】' , 'ケー')
      line.gsub!('【GE-】' , 'ゲー')
      line.gsub!('【KO-】' , 'コー')
      line.gsub!('【GO-】' , 'ゴー')
      line.gsub!('【SA-】' , 'サー')
      line.gsub!('【ZA-】' , 'ザー')
      line.gsub!('【SHI-】' , 'シー')
      line.gsub!('【ZI-】' , 'ジー')
      line.gsub!('【SU-】' , 'スー')
      line.gsub!('【ZU-】' , 'ズー')
      line.gsub!('【SE-】' , 'セー')
      line.gsub!('【ZE-】' , 'ゼー')
      line.gsub!('【SO-】' , 'ソー')
      line.gsub!('【ZO-】' , 'ゾー')
      line.gsub!('【TA-】' , 'ター')
      line.gsub!('【DA-】' , 'ダー')
      line.gsub!('【CHI-】' , 'チー')
      line.gsub!('【DI-】' , 'ヂー')
      line.gsub!('【TSU-】' , 'ツー')
      line.gsub!('【DU-】' , 'ヅー')
      line.gsub!('【TE-】' , 'テー')
      line.gsub!('【DE-】' , 'デー')
      line.gsub!('【TO-】' , 'トー')
      line.gsub!('【DO-】' , 'ドー')
      line.gsub!('【NA-】' , 'ナー')
      line.gsub!('【NI-】' , 'ニー')
      line.gsub!('【NU-】' , 'ヌー')
      line.gsub!('【NE-】' , 'ネー')
      line.gsub!('【NO-】' , 'ノー')
      line.gsub!('【HA-】' , 'ハー')
      line.gsub!('【BA-】' , 'バー')
      line.gsub!('【PA-】' , 'パー')
      line.gsub!('【HI-】' , 'ヒー')
      line.gsub!('【BI-】' , 'ビー')
      line.gsub!('【PI-】' , 'ピー')
      line.gsub!('【HU-】' , 'フー')
      line.gsub!('【BU-】' , 'ブー')
      line.gsub!('【PU-】' , 'プー')
      line.gsub!('【HE-】' , 'ヘー')
      line.gsub!('【BE-】' , 'ベー')
      line.gsub!('【PE-】' , 'ペー')
      line.gsub!('【HO-】' , 'ホー')
      line.gsub!('【BO-】' , 'ボー')
      line.gsub!('【PO-】' , 'ポー')
      line.gsub!('【MA-】' , 'マー')
      line.gsub!('【MI-】' , 'ミー')
      line.gsub!('【MU-】' , 'ムー')
      line.gsub!('【ME-】' , 'メー')
      line.gsub!('【MO-】' , 'モー')
      line.gsub!('【YA-】' , 'ヤー')
      line.gsub!('【YU-】' , 'ユー')
      line.gsub!('【YO-】' , 'ヨー')
      line.gsub!('【RA-】' , 'ラー')
      line.gsub!('【RI-】' , 'リー')
      line.gsub!('【RU-】' , 'ルー')
      line.gsub!('【RE-】' , 'レー')
      line.gsub!('【RO-】' , 'ロー')
      line.gsub!('【WA-】' , 'ワー')
      line.gsub!('【WI-】' , 'ヰー')
      line.gsub!('【WE-】' , 'ヱー')
      line.gsub!('【WO-】' , 'ヲー')
      line.gsub!('【N-】' , 'ンー')
      line.gsub!('【VU-】' , 'ヴー')

    end
    
    if line =~ /&M/        
      line.gsub!('&M062301;' , 'ぁ')
      line.gsub!('&M062302;' , 'あ')
      line.gsub!('&M062303;' , 'ぃ')
      line.gsub!('&M062304;' , 'い')
      line.gsub!('&M062305;' , 'ぅ')
      line.gsub!('&M062306;' , 'う')
      line.gsub!('&M062307;' , 'ぇ')
      line.gsub!('&M062308;' , 'え')
      line.gsub!('&M062309;' , 'ぉ')
      line.gsub!('&M062310;' , 'お')
      line.gsub!('&M062311;' , 'か')
      line.gsub!('&M062312;' , 'が')
      line.gsub!('&M062313;' , 'き')
      line.gsub!('&M062314;' , 'ぎ')
      line.gsub!('&M062315;' , 'く')
      line.gsub!('&M062316;' , 'ぐ')
      line.gsub!('&M062317;' , 'け')
      line.gsub!('&M062318;' , 'げ')
      line.gsub!('&M062319;' , 'こ')
      line.gsub!('&M062320;' , 'ご')
      line.gsub!('&M062321;' , 'さ')
      line.gsub!('&M062322;' , 'ざ')
      line.gsub!('&M062323;' , 'し')
      line.gsub!('&M062324;' , 'じ')
      line.gsub!('&M062325;' , 'す')
      line.gsub!('&M062326;' , 'ず')
      line.gsub!('&M062327;' , 'せ')
      line.gsub!('&M062328;' , 'ぜ')
      line.gsub!('&M062329;' , 'そ')
      line.gsub!('&M062330;' , 'ぞ')
      line.gsub!('&M062331;' , 'た')
      line.gsub!('&M062332;' , 'だ')
      line.gsub!('&M062333;' , 'ち')
      line.gsub!('&M062334;' , 'ぢ')
      line.gsub!('&M062335;' , 'っ')
      line.gsub!('&M062336;' , 'つ')
      line.gsub!('&M062337;' , 'づ')
      line.gsub!('&M062338;' , 'て')
      line.gsub!('&M062339;' , 'で')
      line.gsub!('&M062340;' , 'と')
      line.gsub!('&M062341;' , 'ど')
      line.gsub!('&M062342;' , 'な')
      line.gsub!('&M062343;' , 'に')
      line.gsub!('&M062344;' , 'ぬ')
      line.gsub!('&M062345;' , 'ね')
      line.gsub!('&M062346;' , 'の')
      line.gsub!('&M062347;' , 'は')
      line.gsub!('&M062348;' , 'ば')
      line.gsub!('&M062349;' , 'ぱ')
      line.gsub!('&M062350;' , 'ひ')
      line.gsub!('&M062351;' , 'び')
      line.gsub!('&M062352;' , 'ぴ')
      line.gsub!('&M062353;' , 'ふ')
      line.gsub!('&M062354;' , 'ぶ')
      line.gsub!('&M062355;' , 'ぷ')
      line.gsub!('&M062356;' , 'へ')
      line.gsub!('&M062357;' , 'べ')
      line.gsub!('&M062358;' , 'ぺ')
      line.gsub!('&M062359;' , 'ほ')
      line.gsub!('&M062360;' , 'ぼ')
      line.gsub!('&M062361;' , 'ぽ')
      line.gsub!('&M062362;' , 'ま')
      line.gsub!('&M062363;' , 'み')
      line.gsub!('&M062364;' , 'む')
      line.gsub!('&M062365;' , 'め')
      line.gsub!('&M062366;' , 'も')
      line.gsub!('&M062367;' , 'ゃ')
      line.gsub!('&M062368;' , 'や')
      line.gsub!('&M062369;' , 'ゅ')
      line.gsub!('&M062370;' , 'ゆ')
      line.gsub!('&M062371;' , 'ょ')
      line.gsub!('&M062372;' , 'よ')
      line.gsub!('&M062373;' , 'ら')
      line.gsub!('&M062374;' , 'り')
      line.gsub!('&M062375;' , 'る')
      line.gsub!('&M062376;' , 'れ')
      line.gsub!('&M062377;' , 'ろ')
      line.gsub!('&M062378;' , 'ゎ')
      line.gsub!('&M062379;' , 'わ')
      line.gsub!('&M062380;' , 'ゐ')
      line.gsub!('&M062381;' , 'ゑ')
      line.gsub!('&M062382;' , 'を')
      line.gsub!('&M062383;' , 'ん')
      line.gsub!('&M062401;' , 'ァ')
      line.gsub!('&M062402;' , 'ア')
      line.gsub!('&M062403;' , 'ィ')
      line.gsub!('&M062404;' , 'イ')
      line.gsub!('&M062405;' , 'ゥ')
      line.gsub!('&M062406;' , 'ウ')
      line.gsub!('&M062407;' , 'ェ')
      line.gsub!('&M062408;' , 'エ')
      line.gsub!('&M062409;' , 'ォ')
      line.gsub!('&M062410;' , 'オ')
      line.gsub!('&M062411;' , 'カ')
      line.gsub!('&M062412;' , 'ガ')
      line.gsub!('&M062413;' , 'キ')
      line.gsub!('&M062414;' , 'ギ')
      line.gsub!('&M062415;' , 'ク')
      line.gsub!('&M062416;' , 'グ')
      line.gsub!('&M062417;' , 'ケ')
      line.gsub!('&M062418;' , 'ゲ')
      line.gsub!('&M062419;' , 'コ')
      line.gsub!('&M062420;' , 'ゴ')
      line.gsub!('&M062421;' , 'サ')
      line.gsub!('&M062422;' , 'ザ')
      line.gsub!('&M062423;' , 'シ')
      line.gsub!('&M062424;' , 'ジ')
      line.gsub!('&M062425;' , 'ス')
      line.gsub!('&M062426;' , 'ズ')
      line.gsub!('&M062427;' , 'セ')
      line.gsub!('&M062428;' , 'ゼ')
      line.gsub!('&M062429;' , 'ソ')
      line.gsub!('&M062430;' , 'ゾ')
      line.gsub!('&M062431;' , 'タ')
      line.gsub!('&M062432;' , 'ダ')
      line.gsub!('&M062433;' , 'チ')
      line.gsub!('&M062434;' , 'ヂ')
      line.gsub!('&M062435;' , 'ッ')
      line.gsub!('&M062436;' , 'ツ')
      line.gsub!('&M062437;' , 'ヅ')
      line.gsub!('&M062438;' , 'テ')
      line.gsub!('&M062439;' , 'デ')
      line.gsub!('&M062440;' , 'ト')
      line.gsub!('&M062441;' , 'ド')
      line.gsub!('&M062442;' , 'ナ')
      line.gsub!('&M062443;' , 'ニ')
      line.gsub!('&M062444;' , 'ヌ')
      line.gsub!('&M062445;' , 'ネ')
      line.gsub!('&M062446;' , 'ノ')
      line.gsub!('&M062447;' , 'ハ')
      line.gsub!('&M062448;' , 'バ')
      line.gsub!('&M062449;' , 'パ')
      line.gsub!('&M062450;' , 'ヒ')
      line.gsub!('&M062451;' , 'ビ')
      line.gsub!('&M062452;' , 'ピ')
      line.gsub!('&M062453;' , 'フ')
      line.gsub!('&M062454;' , 'ブ')
      line.gsub!('&M062455;' , 'プ')
      line.gsub!('&M062456;' , 'ヘ')
      line.gsub!('&M062457;' , 'ベ')
      line.gsub!('&M062458;' , 'ペ')
      line.gsub!('&M062459;' , 'ホ')
      line.gsub!('&M062460;' , 'ボ')
      line.gsub!('&M062461;' , 'ポ')
      line.gsub!('&M062462;' , 'マ')
      line.gsub!('&M062463;' , 'ミ')
      line.gsub!('&M062464;' , 'ム')
      line.gsub!('&M062465;' , 'メ')
      line.gsub!('&M062466;' , 'モ')
      line.gsub!('&M062467;' , 'ャ')
      line.gsub!('&M062468;' , 'ヤ')
      line.gsub!('&M062469;' , 'ュ')
      line.gsub!('&M062470;' , 'ユ')
      line.gsub!('&M062471;' , 'ョ')
      line.gsub!('&M062472;' , 'ヨ')
      line.gsub!('&M062473;' , 'ラ')
      line.gsub!('&M062474;' , 'リ')
      line.gsub!('&M062475;' , 'ル')
      line.gsub!('&M062476;' , 'レ')
      line.gsub!('&M062477;' , 'ロ')
      line.gsub!('&M062478;' , 'ヮ')
      line.gsub!('&M062479;' , 'ワ')
      line.gsub!('&M062480;' , 'ヰ')
      line.gsub!('&M062481;' , 'ヱ')
      line.gsub!('&M062482;' , 'ヲ')
      line.gsub!('&M062483;' , 'ン')
      line.gsub!('&M062484;' , 'ヴ')
      line.gsub!('&M062485;' , 'ヵ')
      line.gsub!('&M062486;' , 'ヶ')
    end
    
    line
  end

  def trans_des(match)
    des = match[0]
    @des2u8[des] || des
  end

  def trans_roma(line)
    @romas.each do |nor, unicode_char|
      line.gsub!(nor, unicode_char)
    end
    line
  end

  def trans_uni(match)
    uni = match[1]
    [uni.to_i(16)].pack('U')
  end

  def trans_file(source_file, dest_file)
    puts "#{source_file} => #{dest_file}"
    
    begin
      # 讀取 Big5 檔案
      content = File.read(source_file, encoding: 'Big5')
      
      # 轉換為 UTF-8
      content = content.encode('UTF-8')
      
      # 各種轉換處理
      unless @options[:no_x_code]
        # 處理 &#x....; 編碼
        content.gsub!(/&#[xX]([0-9A-Fa-f]{4,5});/) { |match| trans_uni($~) }
      end
      
      unless @options[:no_des]
        # 處理組字式 (有先讀入全部的缺字)
        content.gsub!(/\[[^>\[]*?\]/) { |match| trans_des($~) }
      end
      
      if @options[:roma]
        # 處理羅馬轉寫字通用字
        content = trans_roma(content)
      end
      
      unless @options[:no_japan]
        # 處理日文
        content = trans_jap(content)
      end
      
      unless @options[:no_russia]
        content.gsub!("【U0424】", 'Ф')
        content.gsub!("【U0414】", 'Д')
        content.gsub!("【U0445】", 'х')
      end
      
      # 寫入 UTF-8 檔案
      File.write(dest_file, content, encoding: 'UTF-8')
      
    rescue => e
      puts "錯誤: 無法處理檔案 #{source_file}: #{e.message}"
    end
  end

  def trans_dir(source_dir, dest_dir)
    FileUtils.mkdir_p(dest_dir) unless Dir.exist?(dest_dir)
    
    Dir.entries(source_dir).each do |entry|
      next if entry == '.' || entry == '..'
      
      source_path = File.join(source_dir, entry)
      dest_path = File.join(dest_dir, entry)
      
      if File.directory?(source_path)
        trans_dir(source_path, dest_path)
      else
        trans_file(source_path, dest_path)
      end
    end
  end

  def run
    unless @options[:source] && @options[:output]
      puts "錯誤: 請指定來源資料夾 (-s) 和輸出資料夾 (-o)"
      puts "使用 -h 查看說明"
      exit 1
    end
    
    unless Dir.exist?(@options[:source])
      puts "錯誤: 來源資料夾不存在: #{@options[:source]}"
      exit 1
    end
    
    trans_dir(@options[:source], @options[:output])
    puts "轉換完成！"
  end
end

# 主程式執行
if __FILE__ == $0
  converter = Big5ToUtf8Converter.new
  converter.run
end