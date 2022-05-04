# CBETA XML P5a 轉 P5
# 設定檔: ../cbwork_bin.ini
# 詳細說明執行 ruby p5totxt.rb -h
# 作者: 周邦信(Ray Chou) 2022-04-15
#
# Heaven 修改：
# 2022-05-04 正式使用，找不到的說明可試著找 p5a2p5.py

require 'fileutils'
require 'inifile'
require 'json'
require 'slop'
require 'unihan2'
require_relative '../common'
require_relative 'p5a2p5-converter'

RESPS = {
  'B' => 'BuBian',
  'D' => 'NCLRareBook',
  'J' => 'Jiaxing',
  'T' => 'Taisho',
  'X' => 'Xuzangjing',
  'ZS' => 'Dudoucheng',
  'ZW' => 'ZangWai'
}

# 處理一冊
def do1vol
  $canon = $vol.sub(/^([A-Z]+).*$/, '\1')
  $wit = WITS[$canon] # 如果冊數 T 開頭, 就是 【大】

  if RESPS.include?($canon)
    $resp = RESPS[$canon] # 如果冊數 T 開頭, 就是 Taisho
  end
  
  time_begin = Time.now
  puts time_begin
  
  # phase- 1 #################################  
  puts "#{$vol} phase-1"

  src = "#{$in_p5a}/#{$canon}/#{$vol}"
  puts "read #{src}/*.xml"

  dest1 = File.join($phase1_base, $canon, $vol)
  FileUtils.makedirs(dest1)

  Dir["#{src}/*.xml"].each { |p| phase1(p) }
    
  # phase- 2 #################################
  puts "#{$vol} phase-2"
  dest2 = File.join($out_p5, $canon, $vol)
  FileUtils.makedirs(dest2)
  Dir["#{dest1}/*.xml"].each { |p| phase2(p, dest2) }
  
  # 驗證 #################################
  unless $opts.dont_validate?
    Dir["#{dest2}/*.xml"].each { |p| validate(p) }
  end

  s = spend_time(Time.now - time_begin)
  s = "#{$vol} #{s}"
  puts s
  $log.puts s
end

def phase1(src)
  puts "phase1 read #{src}"
  $log.puts src      # ex. src = c:/cbwork/xml-p5a/N/N10\N10n0003.xml

  text = $converter.convert(src, $wit)

  canon = $vol.sub(/^([A-Z]+).*$/, '\1')
  fn = File.basename(src)    #  fn = N10n0003.xml
  out_fn = File.join($phase1_base, canon, $vol, fn)

  puts "write #{out_fn}"
  File.write(out_fn, text)
end

# 把 <lg> 下面的文字, 移到第一個 <l> 裏
def move_text_under_lg_to_first_l(s)
  regexp = /
    (
      <lg[^>]*?>
      (?:<head.*?<\/head>)?
      (?:<note.*?<\/note>)?
      (?:<note.*?<\/note>)?
      (?:<app[^>]*?>)?
      (?:<lem[^>]*?>)?
      (?:<cb:tt[^>]*?>)?
      (?:<cb:t[^>]*?>)?
    )
    (.*?)
    (
      (?:<l [^>]*?>)
      |
      (?:<l>)
    )
  /x
  s.gsub(regexp, '\1\3\2')
end

# 開始 anchor 與 結束 anchor 之間維持巢狀
def keep_nested_between_anchors(s)
  regexp = /
    (
      <lg[^>]*?>
      (?:<head.*?<\/head>)?
      (?:<note.*?<\/note>)?
      (?:<note.*?<\/note>)?
      (?:<app[^>]*?>)?
      (?:<lem[^>]*?>)?
      (?:<cb:tt[^>]*?>)?
      (?:<cb:t[^>]*?>)?
    )
    (.*?)
    (<\/lg>)
  /mx

  s.gsub(regexp) do
    s1 = $1
    s2 = $2
    s3 = $3

    regexp2 = /
      .*<l>「
      <anchor xml:id="beg(\d+)"[^>]*\/>
      .*?
      <\/l>
      <anchor xml:id="end\1"\/>
    /mx

    s2.match(regexp2) do
      s2.gsub!(/<l>「(<anchor [^>]*\/>)/, '\1<l>「')
    end
    s1 + s2 + s3
  end
end

def phase2(p, dest)
  puts "phase2 vol=#{$vol} p=#{p}"
  s = File.read(p)

  s.sub!(/\n(<teiHeader>)/, '\1')
  
  # P5b 不要移到 <l> 裡, 不然會有巢狀錯誤
  unless $opts.p5b_format?
    s = move_text_under_lg_to_first_l(s)
    s = keep_nested_between_anchors(s)
  end
  
  # 把 <anchor> 前後多餘的換行去掉
  s.gsub!(/\n+(<anchor )/, '\1')
  s.gsub!(/(<anchor [^>]*>)\n+/, '\1')
  
  # lb, pb 之前要換行
  s.gsub!(/>(<lb[^>]*?ed="#{$canon})/, ">\n\\1")
  s.gsub!(/([^\n])<pb /, "\\1\n<pb ")
  
  # type="old" 的 lb 和 pb 不換行 (印順導師全集才有的)
  s.gsub!(/\n(<[lp]b[^>]*type="old")/, '\1')
  
  # 如果 sourceDesc 下有 <p> 的話, listWit 要放在 p 裡面.
  s.gsub!(/(<\/p>)\s*(<listWit>.*?<\/listWit>)/m, "\n\\2\\1")

  fn = File.join(dest, File.basename(p))
  puts "write #{fn}"
  File.write(fn, s)
end

def read_command_line_arguments  
  Slop.parse do |o|
    o.upcase '-c', '--canon', 'canons (e.g. TXJ...)'
    o.upcase '-s', '--vol-start', 'start volumn (e.g. X55)'
    o.upcase '-v', '--vol', help='volumn (e.g. X55)'
    o.bool   '-b', '--p5b-format', "轉成 P5b 格式 (CBReader 專用)"
    o.bool   '-n', '--dont-validate', "不要執行驗證"
  end
end

def read_config
  # 讀取 設定檔 cbwork_bin.ini
  $config     = IniFile.load('../cbwork_bin.ini')
  cb_temp     = $config['default']['temp']
  cbwork_dir  = $config['default']['cbwork']
  jing        = $config['default']['jing.jar_file']
  $in_p5a     = $config['default']['xml_p5a'] # 不一定有，沒有就用預設
  $in_p5      = $config['default']['xml_p5'] # 不一定有，沒有就用預設
  $gaiji_base = $config['default']['gaiji'] # 不一定有，沒有就用預設
  #gaiji_mdb   = $config['default']['gaiji-m.mdb_file'] # 不用了
  if $in_p5a == nil
    $in_p5a = File.join($config['default']['cbwork'], 'xml-p5a')
  end
  if $in_p5 == nil
    $in_p5 = File.join($config['default']['cbwork'], 'xml-p5')
  end
  if $gaiji_base == nil
    $gaiji_base = File.join($config['default']['cbwork'], 'cbeta_gaiji')
  end

  $empty_elements = %w[anchor lb milestone mulu pb space]

  if $opts.p5b_format?
    $phase1_base = File.join(cb_temp, 'cbetap5b-tmp1')  # 暫存資料夾
    $out_p5 = File.join(cb_temp, 'cbetap5b-ok')      # 最後結果   
    $empty_elements << "g"          # P5b 缺字不能有內容, 完全靠屬性處理
  else
    $phase1_base = File.join(cb_temp, 'cbetap5-tmp1')  # 暫存資料夾
    $out_p5 = File.join(cb_temp, 'cbetap5-ok')      # 最後結果
  end

  $log = File.open('p5a2p5.log', 'w')
  $log.puts Time.now

  args = { 
    p5b_format: $opts.p5b_format?, 
    log: $log, 
    gaiji_base: $gaiji_base
  }
  $converter = P5aToP5Converter.new(args)
end

def validate(xml_path)
  puts "validate #{xml_path}"

  if $opts.p5b_format?
    rng = File.join($in_p5a, 'schema/cbeta-p5a.rng')
  else
    rng = File.join($in_p5, 'schema/cbeta-p5.rng')
  end

  unless File.exist?(rng)
    abort "RNG 檔案不存在: #{rng}"
  end

  schema = Nokogiri::XML::RelaxNG(File.open(rng))
  doc = Nokogiri::XML(File.open(xml_path))
  errors = schema.validate(doc)
  unless errors.empty?
    abort "xml not valid: #{xml_path}"
  end
end

####################################################################
# 主程式
####################################################################

# 讀取 命令列參數
$opts = read_command_line_arguments

# 讀取 設定檔, 並做初始設定
read_config

if $opts[:vol].nil?
  do1dir($in_p5a)
else
  $vol = $opts[:vol]
  do1vol
end

puts
puts Time.now
$log.puts Time.now