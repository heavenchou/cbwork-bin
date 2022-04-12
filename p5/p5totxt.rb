# P5 XML 轉成純文字格式     Ray Chou 2022-04-09
# 
# 詳細說明執行 ruby .\p5totxt.rb -h
#
# 版本歷史：
# 2022-04-12 Heaven 修改比對完成
# 2022-04-09 Ray Chou 由 Python 版修改

require 'fileutils'
require 'inifile'
require 'nokogiri'
require 'slop'

COLLECTION_NAME = {
  "A"  => "趙城金藏",
  "B"  => "大藏經補編",
  "C"  => "中華大藏經（中華書局版）",
  "D"  => "國家圖書館善本佛典",
  "DA" => "道安長老全集",
  "F"  => "房山石經",
  "G"  => "佛教大藏經",
  "GA" => "中國佛寺史志彙刊",
  "GB" => "中國佛寺志叢刊",
  "HM" => "惠敏法師著作集",
  "I"  => "北朝佛教石刻拓片百品",
  "J"  => "嘉興大藏經（新文豐版）",
  "K"  => "高麗大藏經（新文豐版）",
  "L"  => "乾隆大藏經（新文豐版）",
  "M"  => "卍正藏經（新文豐版）",
  "N"  => "漢譯南傳大藏經（元亨寺版）",
  "P"  => "永樂北藏",
  "Q"  => "磧砂大藏經（新文豐版）",
  "S"  => "宋藏遺珍（新文豐版）",
  "T"  => "大正新脩大藏經",
  "TX" => "大虛大師全書",
  "U"  => "洪武南藏",
  "X"  => "卍新纂大日本續藏經",
  "Y"  => "印順法師佛學著作集",
  "ZS" => "正史佛教資料類編",
  "ZW" => "藏外佛教文獻",
  "ZY" => "智諭老和尚著作全集",
}

def child_index(e)
  e.xpath('count(preceding-sibling::*)').to_i
end

def chinese_number(num)
  char = [ "", "一", "二", "三", "四", "五", "六", "七", "八", "九" ]

  i = num / 100
  r = char[i]
  r += "百" if i != 0
  
  num = num % 100
  i = num / 10
  if i == 0
    if r != '' and num != 0
      r += "零"
    end
  else
    if i == 1
      if r == ''
        r = "十"
      else 
        r += "一十"
      end
    else
      r += char[i] + "十"
    end
  end
  
  i = num % 10
  r += char[i]
  r.empty? ? '零' : r
end

def e_anchor(e)
  # 如果未指定要顯示校勘符號
  return '' unless $opts[:footnote_anchor]

  jk = get_jk_mark(e)
  return jk unless e.key?('id')
  return jk if jk == '[＊]'

  # 如果跟上一個 anchor 的校勘符號不同才顯示, 重複就不顯示
  return jk if jk != get_jk_mark(e.previous)

  ''
end

def e_g(e)
  ref = e['ref'].sub(/^#(.*)$/, '\1')
  if ref.start_with?('SD') or ref.start_with?('RJ')
    case $opts[:siddham]
    when 0
      # 沒有羅馬轉寫的字只好用 &SDxxxx; 表示
      return $siddham[ref] if $siddham.key?(ref)
      return "&#{ref};"
    when 1
      return "&#{ref};"
    else
      # 有一種悉曇字是有 big5 字的 -- 2013/08/01
      return '◇' # 想想, 還是直接用 ◇ , 未來應該直接用羅馬轉寫字來比對
    end
  end

  if not $opts[:no_nor] and $gaiji_normal.key?(ref) and $no_nor == 0
    return $gaiji_normal[ref]
  end

  if $zuzishi.key?(ref)
    return $zuzishi[ref]
  end

  abort "缺字處理發生錯誤：#{ref}"
end

def e_head(e)
  return '' if e['type'] =='added'
  traverse(e)
end

def e_item(e)
  r = ''
  r += e['n'] if e.key?('n')
  r + traverse(e)
end

def e_lb(e)
  $lb = e['n']

  return '' if e.key?('ed') and e['ed'].start_with?('R')
  return '' if e['type'] == "old"

  r = "\n#{$vol}n#{$sutra_no}"

  r += '_' if $sutra_no.size < 5
  r += "p#{$lb}║"
  r += $next_line_buf
  $next_line_buf = ''

  r
end

def e_lg(e)
  r = traverse(e)

  type = e['subtype']
  return "(#{r})" if type=='note2' or type=='note1'

  r
end

def e_local_name(id, node)
  name = node.text
  value = node.next_element.text
  if id.start_with?('SD') or id.start_with?('RJ')
    if name == 'Romanized form in Unicode transcription'
      # 沒有羅馬轉寫的字怎麼辦? T54n2132.xml 的 SD-CFC3 ??????
      $siddham[id] = value
      # 有一種悉曇字是有 big5 字的 -- 2013/08/01
      # <char xml:id="SD-E347">
      #   <charName>CBETA CHARACTER SD-E347</charName>
      #   <charProp>
      #     <localName>big5</localName>
      #     <value>□</value>
    elsif name == 'big5'
      $siddham_big5[id] = value
    end
  else
    if name == 'composition'
      $zuzishi[id] = value
    elsif name == 'normalized form'
      $gaiji_normal[id] = value
    end
  end
end

def e_milestone(e)
  if e['unit'] == 'juan' and $opts[:split_by_juan]
    return "\njuan #{e['n']}"
  end
  ''
end

def e_note(e)
  place = e['place']

  if e.key?('place')
    return '' if place.include?('foot')
    if place.include?('inline') or place.include?('interlinear')
      return '(' + traverse(e) + ')'
    end
  elsif e.key?('resp') and e['resp'].start_with('CBETA')
    return ''
  end

  traverse(e)
end

def e_ref(e)
  # 漢譯南傳大藏經 : <ref target="#PTS.Vin.3.2"></ref> (舊版)
  # 漢譯南傳大藏經 : <ref cRef="PTS.Vin.3.2"></ref> (新版 2018/08/18)
  if e.key?('cRef')
    e['cRef'].match(/PTS\..*\.(\d+)/) do
      return " #{$1} " + traverse(e)
    end
  end

  # T42n1828.xml : 
  #   <ref rend="margin-left:2em" target="../T30/T30n1579.xml#xpath2(//0279a03)">
  #     論本卷第一
  #   </ref>
  # T49n2035.xml : <ref target="list4">天台智者禪師○</ref>
  traverse(e)
end

def e_t(e)
  content = traverse(e)

  # <cb:tt> 裏面的第一個 <cb:t> 在第一行, 第2個 <cb:t> 要顯示在下一行.
  return content if child_index(e) == 0

  parent = e.parent
  # <cb:tt rend='inline'> <cb:tt rend='normal'> 則不做隔行處理 (舊版)
  # <cb:tt place='inline'> <cb:tt type='single-line'> 則不做隔行處理 (舊版)
  return content if parent['place']=='inline' or parent['type']=='single-line'

  $next_line_buf += content
  ''
end

def e_term(e)
  # <term rend="no_nor"> , 這種的就不要使用通用字
  if e['rend'] == 'no_nor'
    $no_nor += 1
    r = traverse(e)
    $no_nor -= 1
  else
    r = traverse(e)
  end
  r
end

def e_unclear(e)
  # 百品的 <unclear cert="medium" reason="damage">之</unclear>
  # 這種就不理它  - 2013/10/11
  return traverse(e) if e.key?('cert')

  # 一般是 <unclear/> , 直接呈現 ▆
  '▆'
end

def file_header(doc)
  $edition_c = COLLECTION_NAME[$canon]
  v = $vol.sub(/^[A-Z]+(\d+)$/, '\1')
  $vol_c = chinese_number(v.to_i)

  # 注意有些 title 裡面還有缺字的標記
  title_node = doc.at_xpath('//title')
  $title = traverse(title_node)
  $title = $title.split.last

  $ver = 'v.v'            # 非正式版不使用日期與版本
  $encoding = 'UTF-8'
  $c_format = '普及版'
  $date = 'yyyy/mm/dd'        #非正式版不使用日期與版本

  node = doc.at_xpath("//projectDesc/p[@lang='zh-Hant']")
  $ly_zh = traverse(node)

  node = doc.at_xpath("//projectDesc/p[@lang='en']")
  $ly_en = traverse(node)

  $ebib = doc.at_xpath('.//fileDesc/titleStmt/title[1]').text
  $ebib.sub!(', Electronic version'," Vol. #{v}")
  $ebib.sub!(/No\. 0*/, 'No. ')
  $ebib.sub!(/Vol\. 0*(\d)/, 'Vol. \1')

  if $canon == 'T'
    $ebib.sub!(/No\. 220[a-z]/, 'No. 220')
  end

  $ebib.rstrip!

  $e_format = 'Normalized Version'

  return <<~TXT
    【經文資訊】#{$edition_c} 第#{$vol_c}冊 No. #{$sutra_no_0}《#{$title}》
    【版本記錄】CBETA 電子佛典 V#{$ver} (#{$encoding}) #{$c_format}，完成日期：#{$date}
    【編輯說明】本資料庫由中華電子佛典協會（CBETA）依#{$edition_c}所編輯
    【原始資料】#{$ly_zh}
    【其它事項】本資料庫可自由免費流通，詳細內容請參閱【中華電子佛典協會版權宣告】(https://www.cbeta.org/copyright.php)
    =========================================================================
    # #{$ebib}
    # CBETA Chinese Electronic Tripitaka V#{$ver} (#{$encoding}) #{$e_format}, Release Date: #{$date}
    # Distributor: Chinese Buddhist Electronic Text Association (CBETA)
    # Source material obtained from: #{$ly_en}
    # Distributed free of charge. For details please read at https://www.cbeta.org/copyright.php
    =========================================================================
  TXT
end

# 取得校勘符號
def get_jk_mark(e)
  return '' if e.nil?
  return '' if e.name != 'anchor'

  case e['type']
  when 'circle' then return '◎'
  when '＊', 'star' then return '[＊]'
  when 'cb-app' then return '' # 修訂格式
  end

  return '' unless e.key?('id')

  case e['id']
  when /^fx/  then return '[＊]'
  when /^end/ then return ''
  end

  # 只有 "nkr_note_orig" 可以通過, 例如這種的不行 : 
  #   T01n0026.xml => <lb n="0574a12" ed="T"/>眠、調<anchor xml:id="nkr_3f0"/>
  # 2016/05/15 還有一種 "nkr_note_editor" 也可以通過, 例 
  #   B35n0195.xml => <anchor xml:id="nkr_note_editor_0836001" n="0836001"/>
  # 2016/12/06 還有一種 "nkr_note_add" 也可以通過, 這是印順導師全集新增的, 後來查到的校注
  return '' unless e['id'].match?(/^nkr_note_(orig|editor|add)/)
  
  jk = e['id']

  # B06n0003.xml : <anchor xml:id="nkr_note_orig_0004003-n01" n="0004003-n01"/>
  jk.sub!(/\-n\d{1,3}$/, "")

  # 0561001-1  (B13n0080_p0561a14)
  jk.sub!(/\-\d{1,3}$/, "")    

  # jk = jk[-3:]
  # note_orig 也會有 ABC... , 原書有同樣的校勘數字, 所以要大寫英文區分 : X18n0338_p0700a14
  jk.sub!(/.*(.\d\d[A-Z]?-?\d*)$/, '\1')  # -\d* 上一行先移除了, 
  jk.sub!(/0(\d\d)/, '\1')    # 如果有三個數字且<100 , 第一個 0 移除
  
  # 處理 kbj => 【科】 【標】 【解】
  n = jk[1..]
  if jk[0] == 'k'
    jk = "[科#{n}]"
  elsif jk[0] == 'b'
    jk = "[標#{n}]"
  elsif jk[0] == 'j'
    jk = "[解#{n}]"
  else
    jk.sub!(/\D(\d\d)/, '\1')    # 如果前面不是數字則移除
    jk = "A#{jk}" if e['id'].start_with?('nkr_note_add')
    jk = "[#{jk}]"
  end

  jk
end

def handle_node(e)
  return '' if e.comment?
  return handle_text(e) if e.text?

  r = ''

  r = case e.name
  when 'anchor' then e_anchor(e)
  when 'figure' then '【圖】'
  when 'g'      then e_g(e)
  when 'head'   then e_head(e)
  when 'item'   then e_item(e)
  when 'lb'     then e_lb(e)
  when 'lg'     then e_lg(e)
  when 'milestone' then e_milestone(e)
  when 'mulu'   then ''
  when 'note'   then e_note(e)
  when 'sg'     then '(' + traverse(e) + ')'
  when 't'      then e_t(e)
  when 'unclear' then e_unclear(e)
  when 'ref'     then e_ref(e)
  when 'term'    then e_term(e)
  else
    traverse(e)
  end
  r
end

# 處理一經
def handle_sutra(src, dest)
  puts "#{src} => #{dest}"
  basename = File.basename(src, '.*')
  $sutra_no = basename.sub(/^[A-Z]+\d+n(.*)$/, '\1')
  $sutra_no.sub!(/^0220[a-z]$/, '0220') # 大般若經經號後面的 a-z 移除
  $sutra_no_0 = $sutra_no.sub(/^0*/, '')  # sutra_no_0 是前面沒有 0 的經號

  fn_out = "#{basename}.txt"
  path_out = File.join(dest, fn_out)
  
  fo = File.open(path_out, 'w')

  doc = File.open(src) { |f| Nokogiri::XML(f) }
  doc.remove_namespaces!  # 去掉 namespace  
  
  read_char_info(doc)

  if !$opts[:no_file_header]    # 是否要印出卷首資訊    
    if basename.match(/^T07n0220[d-z]/)
      # T07n0220d 之後的不要印出詳細卷首
      tmp = file_header(doc)  # 還是要先執行, 以取得需要的資料
      tmp = short_file_header
      tmp.rstrip!      # 移除最後一個 '換行', 只有 T07 此處才需要
      fo.write(tmp)
    else
      fo.write(file_header(doc))
    end
  end
  
  # 處理 <text rend='no_nor'> 的情況
  $no_nor = 0
  text_node = doc.at_xpath('.//text')
  $no_nor += 1 if text_node['rend'] == 'no_nor'
  
  body = doc.at_xpath('.//body')
  outtxt = traverse(body)

  # 在這裡處理連續悉曇字
  regexp = /
    [（［？…．‧]*
    ◇
    [◇ 　．‧（）［］？…]*
    ◇
    [）］？…．‧]*
  /x
  outtxt.gsub!(regexp, "【◇】")

  fo.write(outtxt)
  fo.close()
  split_by_juan(path_out, dest) if $opts[:split_by_juan] 
end

def handle_text(e)
  s = e.content().chomp
  s.gsub(/\n/, '')
end

# 處理一冊
def handle_vol
  $vol = $opts[:vol].upcase
  puts $vol

  $canon = $vol.sub(/^([A-Z]+)\d+$/, '\1')
  folder_out = File.join($out_base, $canon, $vol)
  FileUtils.makedirs(folder_out)

  folder_in = File.join($xml_base, $canon, $vol)
  puts folder_in
  Dir.entries(folder_in).sort.each do |f|
    next unless f.start_with?($vol)
    src = File.join(folder_in, f)
    handle_sutra(src, folder_out)
  end
end

# 從 teiHeader 中讀入缺字資訊
def read_char_info(doc)
  $zuzishi = {}
  $siddham = {}
  $siddham_big5 = {}
  $gaiji_normal = {}

  doc.xpath('//charDecl/char').each do |e|
    id = e['id']
    e.xpath('.//localName').each do |n|
      e_local_name(id, n)
    end
  end
end

def read_command_line_arguments
  opts = Slop.parse do |o|
    o.bool '-h', '--help', '顯示說明'
    o.bool '-a', '--no-file-header', '檔頭資訊'
    o.bool '-k', '--footnote-anchor', '顯示校勘符號'
    o.bool '-u', '--split-by-juan', "一卷一檔, 預設是一經一檔"
    o.bool '-z', '--no-nor', '不使用通用字'
    o.string '-v', '--vol', "指定要轉換哪一冊"
    o.integer "-x", "--siddham", "悉曇字呈現方法: 0=轉寫(預設), 1=entity &SD-xxxx, 2=◇【◇】", default: 0
  end

  if opts[:help]
    puts opts
    exit
  end

  if opts[:vol].nil?
    puts "請指定冊號"
    puts opts
    exit
  end

  opts
end

def short_file_header
  return <<~TXT
    【經文資訊】#{$edition_c} 第#{$vol_c}冊 No. #{$sutra_no_0}《#{$title}》CBETA 電子佛典 V#{$ver} #{$c_format}
    # #{$ebib}, CBETA Chinese Electronic Tripitaka V#{$ver}, #{$e_format}
    =========================================================================
  TXT
end

# 一卷一檔
def split_by_juan(source, folder_out)
  # 逐行讀入, 若遇到 juan \d+ 表示換卷了(除非是第一次遇到)
  # 遇到新卷時, 先把舊的寫入檔案中
  # 最後再寫入最後一卷
  
  header = ''
  if !$opts[:no_file_header]    # 是否要印出卷首資訊
    header = short_file_header  # 第二卷之後的卷首
  end
  
  juan_pre = ''    # 上一卷的卷數
  juan_txt = ''    # 記錄每一卷的內文
  juan = ''
  File.foreach(source) do |line|
    if line.match(/^juan (\d+)/)
      juan = '%03d' % $1.to_i
      if juan_pre.empty?
        juan_pre = juan
        next
      end
            
      # 在此換卷了, 所以要寫入檔案      
      write_juan(folder_out, juan_pre, juan_txt)

      juan_pre = juan
      juan_txt = header # 新的一卷的起始內容
      next
    else
      juan_txt += line unless line == "\n"
    end
  end
  
  write_juan(folder_out, juan, juan_txt) # 寫入最後一卷
  File.delete(source) # 移除還未分卷的大檔
end

def write_juan(folder, juan, text)
  dest = File.join(folder, "#{$canon}#{$sutra_no}_#{juan}.txt")
  File.write(dest, text)
end

def traverse(e)
  r = ''
  e.children.each { |c| 
    s = handle_node(c)
    puts "handle_node return nil, node: " + c.to_s if s.nil?
    r += s
  }
  r
end

####################################################################
# 主程式
####################################################################

# 讀取 命令列參數
$opts = read_command_line_arguments

# 讀取 設定檔 cbwork_bin.ini
config = IniFile.load('../cbwork_bin.ini')
$xml_base = config['p5totxt']['xml_p5']
$out_base = config['p5totxt']['output_dir']
puts "Input XML P5 Folder: #{$xml_p5}"
puts "Output Normal Folder: #{$out_base}"

$next_line_buf = ''
unless $opts[:vol].nil?
  handle_vol
end