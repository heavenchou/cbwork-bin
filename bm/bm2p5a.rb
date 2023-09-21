# CBETA BM (簡單標記版 UTF8) 轉為 XML-P5a (UTF8)
# 設定檔: ../cbwork_bin.ini
# 命令列參數:
# 	ruby bm2p5a.rb -o 輸出目錄 -v 冊數
# 範例：ruby bm2p5a.rb -o d:\temp\xmlp5a-ok -v T01
# 作者: 周邦信(Ray Chou) 2022-04-20
#
# Heaven 修改：
# 2023-09-21 1.支援 <date> 後面不再有 <p>，改成 <date> 裡面要自動加 <p>
# 2023-06-12 1.支援 CC、CBETA 選集、CBETA Selected Collection
# 2023-05-16 1.支援 <tag,1,2,bold,sup,..> 處理成 <tag rend="bold sup .." style="margin-left:1em; text-indent:2em;">
# 2023-04-05 1.支援 <c,4> 這種格式，表示此格內縮 4 個字 => <cell rend="pl-4">
#            2.支援 <p,c><p,r><Q1,c><Q1,r> 等格式，c 表示置中 rend="text-center", r 表示靠右 rend="text-right"
#              過去有支援 <p_r>,<p_c>
#            3.支援 <Q1,c><Q1,r><Q1,c m=封面><Q1,c=>，c 表示置中 rend="text-center", r 表示靠右 rend="text-right"
#            4.支援 <[ABCEY],[crl]> 同上, l 是靠左 rend="text-left"
# 2022-12-06 1.支援 <del>,<under>,<over> 標記
#            2.新增Ａ<㊣Ｂ>「正字標記」，表示原書Ａ的正字為Ｂ。xml 作 <orig reg="Ｂ">Ａ</orig>
#            3.組字式優先呈現 unicode，其次才是 <g> 標記
# 2022-08-10 如果行首標記是 Ff3，就要輸出 <table style="margin-left:3em;">
# 2022-05-04 正式使用，找不到的說明可試著找 bm2p5a.py

require 'fileutils'
require 'inifile'
require 'json'
require 'slop'
require_relative '../common'
  
$collection_zh = {
  'B' => '大藏經補編',
  'CC' => 'CBETA 選集',
  'DA' => '道安法師著作全集',
  'GA' => '中國佛寺史志彙刊',
  'GB' => '中國佛寺志叢刊',
  'HM' => '惠敏法師著作集',
  'LC' => '呂澂佛學著作集',
  'N' => '漢譯南傳大藏經（元亨寺版）',
  'TX' => '太虛大師全書',
  'Y' => '印順法師佛學著作集',
  'ZS' => '正史佛教資料類編',
  'ZW' => '藏外佛教文獻',
  'ZY' => '智諭法師著作全集'
}

$collection_en = {
  'A'  => 'Jin Edition of the Canon',
  'B'  => 'Supplement to the Dazangjing',
  'C'  => 'Zhonghua Canon - Zhonghua shuju Edition',
  'CB'  => 'CBETA Test Ver',
  'CC'  => 'CBETA Selected Collection',
  'D'  => 'Selections from the Taipei National Central Library Buddhist Rare Book Collection',
  'DA' => 'the Complete Works of Ven Daoan',
  'F'  => 'Fangshan shijing',
  'G'  => 'Fojiao Canon',
  'GA' => 'Zhongguo Fosi Shizhi Huikan',
  'GB' => 'Zhongguo fosizhi congkan',
  'H'  => 'Passages concerning Buddhism from the Official Histories',
  'HM' => 'the Complete Works of Ven Huimin',
  'I'  => 'Selections of Buddhist Stone Rubbings from the Northern Dynasties',
  'J'  => 'Jiaxing Canon (Shinwenfeng Edition)',
  'K'  => 'Tripiṭaka Koreana (Shinwenfeng Edition)',
  'L'  => 'Qianlong Edition of the Canon (Shinwenfeng Edition)',
  'LC' => 'Corpus of Lü Cheng\'s Buddhist Studies',
  'M'  => 'Manji Daizōkyō (Shinwenfeng Edition)',
  'N'  => 'Chinese Translation of the Pāḷi Tipiṭaka (Yuan Heng Temple Edition)',
  'P'  => 'Northern Yongle Edition of the Canon',
  'Q'  => 'Qisha Edition of the Canon (Shinwenfeng Edition)',
  'R'  => 'Manji Zokuzōkyō (Shinwenfeng Edition)',
  'S'  => 'Songzang yizhen (Shinwenfeng Edition)',
  'T'  => 'Taishō Tripiṭaka',
  'TX' => "Corpus of Venerable Tai Xu's Buddhist Studies",
  'U'  => 'Southern Hongwu Edition of the Canon',
  'W'  => 'Buddhist Texts not contained in the Tripiṭaka',
  'X'  => 'Manji Shinsan Dainihon Zokuzōkyō',
  'Y'  => 'Corpus of Venerable Yin Shun\'s Buddhist Studies',
  'Z'  => 'Manji Dainihon Zokuzōkyō',
  'ZS' => 'Passages concerning Buddhism from the Official Histories',
  'ZW' => 'Buddhist Texts not contained in the Tripiṭaka',
  'ZY' => 'the Complete Works of Ven Zhiyu'
}
  
# ##########################################
# 心得
#
# buf1 是全部資料暫存變數
# buf 是給 <pb><lb> 等儲存變數
#
# 因為有時在行首資訊之後, 才出現 BM 版的 Ｐ 標記, 此時就要在前一行尾端加上 </p> 標記.
# 因此才要先把行首儲存 buf , 等到遇到 p 標記, 才依次做出如下動作:
#
# 1. 將 </p> 加到 buf1 中, 但不處理 buf 中的 <lb> 等標記 (使用 out1() )
# 2. 將 <p> 加到 buf1 中, 但先處理 buf 中的 <lb> 等標記 (使用 out() )
# 3. 這樣就會呈現  </p><lb><p> 的合理順序.
#
# 所以 :
# 經文是交給 out2() 處理, 因為可能有些文字要記錄在 head 中
# 起始標記才直接給 out(), 因為要先處理 buf 中的 <lb> 標記
# 需要保留在前一行的結尾標記就由 out1() 處理, 因為它先不會輸出 buf
#
# ##########################################
  
# 先處理 buf , 再處理傳入的資料至 buf1
def out(s)
  out1($buf)
  $buf = ''
  out1(s)
end

# 處理傳入的資料至 buf1
def out1(s)
  $buf1 << s
end

# 當 $head_start 為真時, div_head 及 buf 都要記錄下來
def out2(s)
  if $head_start 
    $div_head += s
    $buf << s
  elsif s!=''
    out(s)
  end
end

# 處理行首標記, 會變更 text 的內容
def do_line_head(tag, text)
  tag = tag.clone     # 若不 clone，底下改變 tag 的行為會影響傳入原始的 tag
  if tag.include?('W')
    tag.gsub!('W', '')
    if not $inw
      $inw = true
      if not tag.include?('Q') and not tag.include?('x')
        # 如果 W## 接著 <Q , 也不用執行 start_div, 因為 <Q 會執行
        start_div(1, 'w') if not text.match?(/^<Q/)
      end
    end
  elsif $inw
    $inw = false
  end
    
  $inr = false if not tag.include?('r')
  
  case tag
  when /[ABCEY]/ then start_byline(tag)
  when /F/ then text = start_F(tag, text)
  # when /f/ then start_f(tag)    # f 不再處理了，最底下會處理，會交給 start_inline_row
  when /I/
    start_i(tag)
    start_p(tag) if tag.include?('P')
  when /J/ then start_J(tag)
  when /j/ then start_j(tag)
  when /P/ then start_p(tag)
  when /Q/ then start_q(tag)
  when /r/ then start_r(tag)
  when /S/ then start_S(tag)
    # text.gsub!("　　", "</l><l>")
    # text.gsub!("　", "<l>")
    # text << "</l>\n"
  when /s/ then text << "</S>"
    # start_s(tag)
    # text.gsub!("　　", "</l><l>")
    # text.gsub!("　", "<l>")
    # text << "</l></lg>\n"
    # # 把 </Qx> 移到後面, 例: B10n0068_p0839b03s##　能令清淨諸儀軌　　如智者論顯了說</Q1>
    # text.gsub!(/(<\/Q\d*>)(<\/l><\/lg>)$/, '\2\1')
  when /x/ then start_x(tag)
  when /Z/ then start_p(tag)
  else
    tag.gsub!(/[#_kf\d]/, '')
    unless tag.empty?
      puts "#{$old_pb}#{$line_num} 未處理的行首標記: '#{tag}'"
    end
  end

  # $opens['table'] > 0 ，又沒有 <table> or <row> or <F> 則要加入 <row>
  if $opens['table'] > 0
    if !text.match(/<((table)|(row)|(F[,>]))/)
      text = '<row>' + text
    end
  end
  return text
end

# 處理經文中的標記
def inline_tag(tag)
  case tag
  when /^<app/, '</app>', '<corr>', '</corr>', /^<choice/, '</choice>', /^<lem/, '</lem>', /^<note/, '</note>', /^<orig/, '</orig>', '</quote>', /^<rdg/, '</rdg>', '<reg>', '</reg>', '<sic>', '</sic>'
    # 直接輸出, 例：<choice cb:resp="CBETA.maha"><corr>Ｂ</corr><sic>Ａ</sic></choice>
    out(tag)
  when /^<(\[(([\da-zA-Z]{2,3})|＊)\])>/	
    # 在 do_corr_normalize 處理過的校勘數字 , 原來為 <[01]> , 要直接處理成 [01]
    out $1
  when /^\[([\da-zA-Z]+?)\]/	# 處理校勘數字
    out %(<anchor xml:id="fn#{$vol}p#{$old_pb}#{$1}"/>)
  when /^\[[^>\[ ]+?\]/		# 處理組字式
    $char_count += 1
    out2(gaiji(tag))
  when '<□>'							# 未知字
    out('<unclear/>')
  when '('
    out2('<note place="inline">')
  when /^<a>/ then start_inline_a(tag)
  when /<[ABCEY][\s,>]/ then start_inline_byline(tag)
  when '<annals>'
    ## J01nA042_p0793a14_##<Q2 m=哲宗><annals><date><p>哲宗皇帝元祐四年[已>己]巳

    # <date> 後面 <p> 在 BM 移除，改成自動加入
    # J01nA042_p0793a14_##<Q2 m=哲宗><annals><date>哲宗皇帝元祐四年[已>己]巳
    # J01nA042_p0793a15_##<event><p,1>師宣州寧國縣人也姓奚氏其母初夢神人衛一
    # ... </annals>
    # 還有 <Q> <annals> 也可以結束 <annals>
    # <event> 是用來結束 <date> 的
    # 轉成
    # <cb:event><date>ＸＸＸ</date><p,1>ＹＹＹ</p></cb:event>
    start_inline_annals(tag)
  when '</annals>' then close_tags('p', 'date', 'p', 'cb:event')
  when '<bold>'    then out('<hi rend="bold">')
  when '</bold>'   then out('</hi>')
  when '<border>'  then out('<hi rend="border">')
  when '</border>' then out('</hi>')
  when /<c[,\d\s>]/ then start_inline_c(tag) # <c> <c3> <c r3> <c,1> <c,bold>
  when '<d>'       then start_inline_d(tag)
  when '<date>'    then start_inline_date(tag)
  when '<del>'  then out('<hi rend="del">')
  when '</del>' then out('</hi>')
  when '<e>'       then start_inline_e(tag)
  when '</e>'      then close_tags('p', 'cb:def', 'entry')
  when '<event>'   then start_inline_event(tag)
  when /<F[,>]/   then start_inline_table(tag)
  when '</F>'      then close_table(tag)
  when '<formula>' then out('<formula>')
  when '</formula>' then out2("</formula>")
  when '<hei>'    then out('<hi rend="heiti">')
  when '</hei>'   then out('</hi>')
  when /^<h[\d\s,>]/     then start_inline_h(tag)
  when /^<\/h[\d]*>/     then close_h(tag)
  when /<hi[,>]/   then start_inline_hi(tag)
  when '</hi>'     then out('</hi>')
  when /<I\d*[,>]/    then start_i(tag)
  when '<i>('       then out2('<note place="interlinear">')
  when /^\)(<\/i>)?/ then out2('</note>')
  when '<it>'    then out('<hi rend="italic">')
  when '</it>'   then out('</hi>')
  when '<j>'    then start_inline_j(tag)
  when /^<J/      then start_J(tag)
  when '<kai>'    then out('<hi rend="kaiti">')
  when '</kai>'   then out('</hi>')
  when /<L[,>]/    then start_inline_L(tag)
  when /<L_sp/    then start_inline_L(tag)
  when '</l>'     then close_tags('l')  # 行首標記有 S 及 s 時, 會在行中自動將空格變成 <l></l></lg> 等標記
  when '</L>'     then close_L(tag)
  when '<larger>'  then out('<hi rend="larger">')
  when '</larger>' then out('</hi>')
  when '<ming>'    then out('<hi rend="mingti">')
  when '</ming>'   then out('</hi>')
  when /^<mj/      then start_inline_mj(tag)
  when '<no_chg>'  then out('<term cb:behaviour="no-norm">')
  when '</no_chg>' then out('</term>')
  when '<no-bold>'    then out('<hi rend="no-bold">')
  when '</no-bold>'   then out('</hi>')
  when '<no-it>'    then out('<hi rend="no-italic">')
  when '</no-it>'   then out('</hi>')
  when '<nosp>'    then start_inline_space(tag)
  when /^　/       then start_inline_space(tag)
  when /^<n/       then start_inline_n(tag)
  when '</n>'      then close_n(tag)
  when '<o>'       then start_inline_o(tag)
  when '</o>'      then close_div_by_type('orig')
  when '<over>'  then out('<hi rend="over">')
  when '</over>' then out('</hi>')
  when /<PTS./ then start_PTS(tag)
  when /^<p/   then start_inline_p(tag)
  when '</p>'  then close_tags('p')
  when '</P>'  then close_tags('p')
  when /<quote (.*?)>/	
    # 出處連結, 例如 : 
    # ZY01n0001_p0020a02_##...經中說，<quote T09n0262_p0007c07-09>舍利弗！汝等...</quote>
    # 要做成 <quote source="CBETA.T09n0262_p0007c07-09">
    out %(<quote source="CBETA.#{$1}">)
  when /^<Q/   then start_inline_q(tag)
  when /^<\/Q/ then close_q(tag)
  when /<row/   then start_inline_row(tag)
  when /<S[,>]/ then start_inline_S(tag)
  when '</S>'
		$normal_lg = false
		close_tags('l','lg')
  when '<sd>'
    out('<term xml:lang="sa-Sidd">')
    $opens['term'] = 1
  when '</sd>' then close_tags('term')
  when /<seg[,>]/ then start_inline_seg(tag)
  when '</seg>' then out('</seg>')
  when '<smaller>'    then out('<hi rend="smaller">')
  when '</smaller>'   then out('</hi>')
  when '<space quantity="0"/>' then out2(tag)
  when '<sub>'  then out('<hi rend="sub">')
  when '</sub>' then out2("</hi>")
  when '<sup>'  then out('<hi rend="sup">')
  when '</sup>' then out2("</hi>")
  when /<table/ then start_inline_table(tag)
  when '</table>'      then close_table(tag)
  when /<trans-mark/ then start_trans_mark(tag)
  when /^<T[,>]/     then start_inline_T(tag)
  when /^<TL[,>]/    then start_inline_TL(tag)
  when '</T>' , '</TL>' 
    $TL_count = 0
    close_tags('l', 'lg')
  when '<u>'         then start_inline_u(tag)
  when '</u>'        then close_div_by_type('commentary')
  when '<under>'  then out('<hi rend="under">')
  when '</under>' then out('</hi>')
  when /^<w>/ then start_inline_w(tag)
  when '</w>' then close_tags('p','sp','cb:dialog')
  when /^<z/  then start_inline_p(tag)	# 和 <p 一樣的處理法    
  when '</z>' then close_tags('p')
  when /&((SD)|(RJ))\-\w{4};/	then start_inline_SDRJ(tag) # 悉曇字或蘭札字
  when '&' then out2("&")
  else
    puts "#{$old_pb}#{$line_num} 未處理的標記: '#{tag}'"
  end
end

def start_inline_a(tag)
  close_tags('p','sp')
  out('<sp cb:type="answer">')
  $opens['sp'] = 1
end

## J01nA042_p0793a14_##<Q2 m=哲宗><annals><date><p>哲宗皇帝元祐四年[已>己]巳

# <date> 後面 <p> 在 BM 移除，改成自動加入
# J01nA042_p0793a14_##<Q2 m=哲宗><annals><date>哲宗皇帝元祐四年[已>己]巳
# J01nA042_p0793a15_##<event><p,1>師宣州寧國縣人也姓奚氏其母初夢神人衛一
# ... </annals>
# 還有 <Q> <annals> 也可以結束 <annals>
# <event> 是用來結束 <date> 的
# 轉成
# <cb:event><date>ＸＸＸ</date><p,1>ＹＹＹ</p></cb:event>

# <annals> 裡面也可能沒有 <event> , 所以 <annals> 也可以結束 <date>
# <annals><date>......
# <event><p>..........
# <annals><date>......
# <annals><date>......

def start_inline_annals(tag)
  close_head
  close_tags('p', 'date', 'p', 'cb:event')
  out('<cb:event>')
  $opens['cb:event'] = 1
end

def start_byline(tag)
  return if tag.include?('=')

  close_tags('p', 'byline', 'cb:jhead', 'cb:juan')

  type = case tag
  when /A/ then 'author'
  when /B/ then 'other'
  when /C/ then 'collector'
  when /E/ then 'editor'
  when /Y/ then 'translator'
  end
  out %(<byline cb:type="#{type}">)

  $opens['byline'] = 1
end

def start_inline_byline(tag)
  close_tags('byline', 'cb:jhead', 'cb:juan', 'p')
  close_head

  type = case tag
  when /<A/ then "author"
  when /<B/ then "other"
  when /<C/ then "collector"
  when /<E/ then "editor"
  when /<Y/ then "translator"
  end

  out %(<byline cb:type="#{type}")

	# 處理 <A,c> , <B,r> - 2023-04-05
  style, rend = get_style_rend(tag)

  # tag.match(/,c[,>]/) do
  #   out %( rend="text-center")
  # end
  # tag.match(/,r[,>]/) do
  #   out %( rend="text-right")
  # end
  # tag.match(/,l[,>]/) do
  #   out %( rend="text-left")
  # end
  out style
  out rend
  out '>'
  $opens['byline'] = 1
end

# 表格中的 cell , 有這些形式
# <c> => <cell>
# <c3> => <cell cols="3">
# <c r3> , <c,r3> => <cell rows="3">
# <c3 r3> => <cell cols="3" rows="3">
# <c,1><c3,1><c r3,1><c3 r3,1> => <cell rend="pl-1">...<cell cols="3" rows="3" rend="pl-1">
# <c,1><c3,1><c r3,1><c3 r3,1,bold,...> =><cell cols="3" rows="3" rend="pl-1 bold ...">
def start_inline_c(tag)
  close_tags('p', 'cell')

  # 檢查有沒有 c3 這種格式
  cols = ''
  tag.match(/<c(\d+)/) do
    cols = $1
    tag = tag.sub(/<c(\d+)/,'<c')
  end

  # 檢查有沒有 r3 這種格式
  rows = ''
  tag.match(/[\s,]r(\d+)/) do
    rows = $1
    tag = tag.sub(/[\s,]r(\d+)/,'')
  end

  # <c,1> 這種有數字在 cell 處理法不同，會轉成
  # rend="pl-1"

  style, rend = get_style_rend(tag)

  out '<cell'
  out %( cols="#{cols}") unless cols.empty?
  out %( rows="#{rows}") unless rows.empty?
  out style
  out rend
  out('>')
  $opens['cell'] += 1
end
  
def start_inline_d(tag)
  close_tags('form')
  out('<cb:def>')
  $opens['cb:def'] += 1
end

def start_inline_date(tag)
  out('<date>')
  $opens['date'] = 1
  # date 後面要自動加上 <p>
  start_inline_p('<p>')
end

def start_div(level, type)
  close_tags('byline', 'p', 'cb:jhead', 'cb:juan')
  close_div(level)
  close_tags('l', 'lg')
  $opens['div'] = level

  if type == 'other' and $head_tag.include?('W')
    out '<cb:div type="w">'
  else
    out %(<cb:div type="#{type}">)
  end
end

def close_div(level)
  while $opens['div'] >= level
    out1('</cb:div>')
    $opens['div'] -= 1
  end
end

def close_div_by_type(type)
  close_tags('byline','p')
  out1('</cb:div>')
  $opens['div'] -= 1
  $opens[type] -= 1
end

def start_inline_e(tag)
  close_head()
  close_tags('p', 'cb:def', 'entry')
  out('<entry')
  out(' cb:place="inline"') if $char_count > 1  # 若是行中段落, 則加上 inline
  out('><form>')
  $opens['entry'] += 1
  $opens['form'] += 1
end

# 參考 <annals> 標記, 此標記是用來結束 <date> 用的
def start_inline_event(tag)
  close_tags('p', 'date')
end

# 處理表格 F 表格開始
# 20230503 表格有二種處理法，一種是行首標記用 Ff3 這種格式。
#          一種是用 <table,3> 這種格式
#          如果行首有數字，table 無數字，以行首為主。table 有數字則以 table 為主。
#
#          每一行都應該有 f，沒有就表示結束。如果是用 <F> 或 <table> 開始，就可以不用 f ，但一定要有 </table> 或 </F> 

def start_F(tag, text)
  table = ''
  # 先檢查 text 有沒有 <table> 標記
  if text.match(/(<table.*?>)/)
    table = $1
  else
    table = '<table>'
    text = table + text
  end

  # 檢查有沒有行首數字
  if tag.match(/(\d)/)
    space = $1
    if !table.match(/\d/)
      text = text.sub(/<table/,"<table,#{space}")
    end
  end
  return text
end

# 2013/11/15 新增
def start_inline_h(tag)
  close_head()
  close_tags('l', 'lg')
  $div_head = ''

  level = 0
  tag.match(/<h(\d+)/) do
    level = $1.to_i
  end
  
  #start_div(level, 'other')
  close_tags('byline', 'p', 'cb:jhead', 'cb:juan')	# 因為沒有 start_div , 所以要自己執行這一行
  
  mo = tag.match(/m=(.*?)>/)
  if mo.nil?
    out('')					# 因為沒有 start_div , 所以要自己執行這一行
    $mulu_start = true
    $mulu_type = $head_tag.include?('W') ? '附文' : '其他'
  else
    start_inline_h_label($1, level)
  end

  $head_start = true
  $buf << '<head>'
  $opens['head'] = 1
end

def start_inline_h_label(label, level)
  # 標題也可能會有組字式
  label2 = replace_zuzi(label)
  
  unless label2.empty?
    type = $head_tag.include?('W') ? '附文' : '其他'
    out %(<cb:mulu type="#{type}" level="#{level}">#{label2}</cb:mulu>)
  end

  # 取消 cb:mulu 的空標記 2016/04/11
  # else:
  #	out('<cb:mulu type="其他" level="%d"/>' % (level))
  $mulu_start = false
end

# 2013/11/15 新增
def close_h(tag)
  close_tags('cb:jhead', 'cb:juan', 'p')
  close_head()
  #level = int(tag[3:-1])
  #close_div(level)
end

# TEI:<hi> (顯目標示) 標誌其字型外觀上和週遭文字有所區別的字詞，但不指出顯目原因。
def start_inline_hi(tag)
  style, rend = get_style_rend(tag)
  out "<hi#{style}#{rend}>"
end

def start_i(tag)
  level = 1
  tag.match(/(\d+)/) do
    level = $1.to_i
  end

  close_tags('cb:jhead', 'cb:juan', 'p')
  close_head

  while level < $opens['list']
    out1('</item></list>')
    $opens['list'] -= 1
    $opens['item'] -= 1
  end

  if level == $opens['list']
    out1('</item>')
    $opens['item'] -= 1
  end

  # 新的層次，要處理 list 標記
  if level > $opens['list']
    $opens['list'] += 1

    # 先檢查有沒有 list 標記
    if $last_list_tag.empty?
      out '<list>'
    else
      out $last_list_tag
    end
  end

  style, rend = get_style_rend(tag)
  s = %(<item xml:id="item#{$vol}p#{$old_pb}#{$line_num}%02d") % $char_count
  out "#{s}#{style}#{rend}>"
  $opens['item'] += 1
end  

def start_J(tag)
  return if $head_tag.include?('=')

  close_tags('p')

  i = get_number_i(tag)
  $juan_num = i unless i.nil?

  out %(<cb:juan fun="open" n="#{$juan_num}"><cb:jhead>)
  $opens['cb:juan'] += 1
  $opens['cb:jhead'] += 1
end

def start_j(tag)
  close_tags('p')
  out %(<cb:juan fun="close" n="#{$juan_num}"><cb:jhead>)
  $opens['cb:juan'] += 1
  $opens['cb:jhead'] += 1
end

def start_inline_j(tag)
  close_tags('p')
  out('<cb:juan fun="close"><cb:jhead>')
  $opens['cb:juan'] += 1
  $opens['cb:jhead'] += 1
end

# list <L> 的處理法
# 最早期用行首標記 I 來處理，由層次來判斷是否要加 <list>
# 也可以用 <I> 來處理，由層次來判斷是否要加 <list>
# 後來為了在 <list> 加屬性，所以 <L> 也可能會出現
# 規則是，若有 <L>，就不能用 I 行首標記，一定要用 <I> 標記，才不會錯亂。
# 處理法：
# 1. 遇到行首標記 I，表示不會有 <L> 標記，XML 就自行加 <list> 
# 2. 遇到 <L> 標記，就先存在 $last_list_tag 中
# 3. 遇到 <I> 標記，如果是某一層第一個 <I> 就要加 <list>，就檢查有沒有 $last_list_tag，有就用，沒有就用預設 <list>
# 4. 每一層的 list 都使用同一組 <L>
# 5. </L> 結束時，才將 $last_list_tag 清掉。

def start_inline_L(tag)
  #close_head()
  tag = tag.sub(/<L_sp/,'<L,sp')
  
  style, rend = get_style_rend(tag)
  $last_list_tag = "<list#{style}#{rend}>"
end

def close_L(tag)
  close_tags('p')
  $last_list_tag = ''
  while $opens['list'] > 0
    close_tag('item', 'list')
  end
end

def start_inline_mj(tag)
  close_tags('byline', 'cb:jhead', 'cb:juan')

  #n=get_number(tag)
  m = tag.match(/\d+/)
  if !m.nil?
    $juan_num = $&.to_i
  else
    $juan_num += 1
  end

  #out('<milestone unit="juan" n="{}"/>'.format(globals['juan_num']))		# 若用 out() , 會有一堆 </p></cb:div> 標記出現在 <milestone> 後面

  m = $buf.match(/(<pb [^>]*>\n?)?<lb [^>]*>\n?\z/)
  if m.nil?
    abort "milestone must after <pb><lb> #{tag}  Line: #{__LINE__}"
  else
    # <milestone> 要移到 <pb><lb> 之前
    $buf.sub!(/(?:<pb [^>]*>\n?)?<lb [^>]*>\n?\z/) do
      %(<milestone unit="juan" n="#{$juan_num}"/>\n#{$&})
    end
  end

  # 原本 <cb:mulu type="卷" n="{}"/> 是在 <J> 或 Ｊ卷標記處理, 只有南傳在 <mj> 處理, 
  # 現在全部移到 <mj> 處理, 因為有卷沒有卷標記
  unless $canon == 'TX'
    $buf << %(<cb:mulu type="卷" n="#{$juan_num}"/>)
  end
end

def start_inline_n(tag)
  close_tags('p', 'cb:def', 'entry')
  
  # 第一個 n 要加上 <cb:div type="note"><entry><form>...</form><cb:def>...</cb:def>...</div>
  if $div_type_note == 0
    start_div($opens['div']+1, 'note')
    $div_type_note = 1
  end
    
  out('<entry')
  out(' cb:place="inline"') if $char_count > 1 # 若是行中段落, 則加上 inline
  out('><form>')
  $opens['entry'] += 1
  $opens['form'] += 1
end

def close_n(tag)
  close_tags('p', 'cb:def', 'entry')
  close_div($opens['div'])
  $div_type_note = 0
end

def start_inline_o(tag)
  close_tags('p')
  close_head()

  if $opens.key?('commentary') and $opens['commentary'] > 0
    out1('</cb:div>')
    $opens['div'] -= 1
    $opens['commentary'] -= 1
  end

  start_div($opens['div']+1, 'orig')
  $opens['orig'] = 1
end

def start_p(tag)
  close_tags('cb:jhead', 'cb:juan', 'p', 'byline', 'head')
  close_tags('l', 'lg')
  r = get_number(tag)
  out %(<p xml:id="p#{$vol}p#{$old_pb}#{$line_num}01")
  out ' cb:type="pre"' if $head_tag.include?('r')
  out ' cb:type="dharani"' if $head_tag.include?('Z')
  out %( style="margin-left:#{r}em") unless r.empty?
  out '>'
  $opens['p'] = 1
end
# <p=h1,1,2,c,bold>
# <p,h1,1,2,c,it>
# <p,1,2,c> or <p,c,1,2> c 置中，r 靠右，l 靠左
# <p,1,2,c,bold,kai,...> 支援許多格式

def start_inline_p(tag)
  close_tags('cb:jhead', 'cb:juan', 'p', 'byline')
  close_head
  close_tags('l', 'lg')

  s = %(<p xml:id="p#{$vol}p#{$old_pb}#{$line_num}%02d") % $char_count
  
  # 如果 tag 是 <z 開頭的, 就要變成
  #<p xml:id="pxxxxxxxx" cb:type="dharani"
  tag.match(/<z/) do
    s << ' cb:type="dharani"'
  end
    
  # 若都沒有 <p,1 這種格式, 又是在行中, 則用 rend="inline"
  #mo = re.search(r'<[pz],(\-?[\d\.]+)', tag)
  #if mo==None:
  #	if char_count>1: s += ' rend="inline"'  
  s << ' cb:place="inline"' if $char_count > 1
  
	# 處理 <p_c> , <p_r> - 2022-03-29
  # <p_[clr] 換成 <p,[clr]
	
  tag = tag.gsub(/<[pz]_([crl])/,'<p,\1')

  # 處理 <p=h1> 這種格式	- 2013/09/11
  # 處理 <p,h1 這種格式
  tag.match(/[=,]h(\d+)/) do
    s << %( cb:type="head#{$1}")
    tag = tag.sub(/[=,]h(\d+)/,'')
  end

  # 取得 style 和 rend 字串
  style, rend = get_style_rend(tag)
  s << style
  s << rend
  s << '>'
  out(s)
  $opens['p'] = 1
end

# 處理 PTS 標記 BM版:<PTS.Vin.1.101> => XML:<ref cRef="PTS.Vin.1.101"/>
def start_PTS(tag)
  tag.match(/<(PTS.*?)>/) do
    $buf << %(<ref cRef="#{$1}"/>)
  end
  
  # ##################################################################
  # 不可用 out(s) , 也不可用 out1(s), 說明如下:
  #
  # out(s) 會先印出 buf 中的 <lb> 等標記, 會有如下結果
  # <lb ed="N" n="0009a06"/>久住，拘樓孫佛、拘那含牟尼佛、迦葉佛之梵行久住也。」
  # <lb ed="N" n="0009a07"/><ref cRef="PTS.Vin.8.8"/></p></cb:div><cb:div type="other">
  #
  # out1(s) 直接加入 buf1 中, 會有如下結果
  # <lb ed="N" n="0009a06"/>久住，拘樓孫佛、拘那含牟尼佛、迦葉佛之梵行久住也。」<ref cRef="PTS.Vin.8.8"/></p></cb:div>
  # <lb ed="N" n="0009a07"/><cb:div type="other">（二）
  # ##################################################################
end

def start_q(tag)
  return if $head_tag.include?('=')
  
  close_tags('l', 'lg', 'sp', 'cb:dialog', 'form', 'cb:def', 'entry')
  $div_head = ''

  level = 0
  tag.match(/\d+/) do
    level = $&.to_i
  end
      
  $mulu_start = true
  $head_start = true
  
  if $head_tag.include?('W')
    $mulu_type = '附文'
    start_div(level, 'w')
  else
    $mulu_type = '其他'
    start_div(level, 'other')
  end

  $buf << '<head>'
  $opens['head'] = 1
end

# <Q1>
# <Q1 m="abc">
# <Q1=>
# <Q1,c> <Q1,c m="abc"> <Q1,c=> c 表示置中 rend="text-center", r 表示靠右 rend="text-right"
# <Q1,c,bold,it...> <Q1,c,bold,m="abc"> <Q1,c=> c 表示置中 , r 表示靠右

def start_inline_q(tag)
  return if tag.match?(/<Q.*?=>/)	# <Q3=> 這一種的表示是延續上一行的 <Q3>

  close_head
  close_tags('l', 'lg', 'p', 'date', 'p', 'sp', 'cb:dialog', 'cb:event', 'form', 'cb:def', 'entry')
  $div_head = ''

  level = 0
  tag.match(/<Q(\d+)/) do
    level = $1.to_i
  end
  
  start_div(level, 'other')

  mo = tag.match(/[,\s]m=(.*?)[,>]/)
  if mo.nil?
    $mulu_start = true
    $mulu_type = $head_tag.include?('W') ? '附文' : '其他'
  else
    start_inline_q_label($1, level)
    tag = tag.sub(/[,\s]m=(.*?)([,>])/,'\2')
  end

  $head_start = true	

  $buf << '<head'

  # 處理 <Q1,c> , <Q1,r> , <Q1,c m="xxx"> - 2023-04-05
  # 處理 <Q1,c,bold> , <Q1,r,it> , <Q1,c,hei,m="xxx"> - 2023-04-05

  style,rend = get_style_rend(tag)
  $buf << style
  $buf << rend
  $buf << '>'

  $opens['head'] = 1
end

def start_inline_q_label(label, level)
  # 標題也可能會有組字式
  label2 = replace_zuzi(label)
  
  unless label2.empty?
    type = $head_tag.include?('W') ? '附文' : '其他'
    out %(<cb:mulu type="#{type}" level="#{level}">#{label2}</cb:mulu>)
  end

  # 取消 cb:mulu 的空標記 2016/04/11	
  # else:
  # 	out('<cb:mulu type="其他" level="%d"/>' % (level))
  $mulu_start = false
end

def close_q(tag)
  close_tags('byline', 'cb:jhead', 'cb:juan', 'p')
  close_head()

  m = tag.match(/<\/Q(\d+)/)
  if m.nil?
    abort "Error: #{tag}, Line: #{__LINE__}"
  else
    level = m[1].to_i
    close_div(level)
  end
end

def start_r(tag)
  # 第一個 r 才需要處理成 <p xml:id="xxx" cb:type="pre">
  return if $inr

  $inr = true
  start_p(tag) # 依 p 的方式處理
end

def start_inline_row(tag)	
  close_tags('p', 'cell', 'row')
  style,rend = get_style_rend(tag)
  out("<row#{style}#{rend}>")
  $opens['row'] += 1
end

def start_S(tag)
  if $opens['lg'] == 0
    close_tags('cb:jhead', 'cb:juan', 'byline', 'p')
    close_head
    $lg_marginleft = 1
    $opens['lg'] = 1
    $normal_lg = true
    out %(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}01">)
  end
  #close_tags('l')
end

def start_s(tag)
  $opens['lg'] = 0
end

def start_inline_S(tag)	
	if $opens['lg'] == 1
    close_tags('l','lg')
  end
	if $opens['lg'] == 0
		close_tags('cb:jhead', 'cb:juan', 'byline', 'p')
		close_head
		$opens['lg'] = 1
  end
	$lg_marginleft = 1
  $normal_lg = true
  l_text_indent = ''

  # <lg xml:id="..."
  out(%(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}%02d") % $char_count)
  
  # cb:place="..."
  if $char_count > 1
    out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
  end

  tag.match(/\d+,\-?\d+,(\d+)/) do
    l_text_indent = $1
    tag = tag.sub(/(\d+,\-?\d+),\d+/,'\1')  # 移除第三組數字
  end

  style, rend = get_style_rend(tag)

  style.match(/margin-left:\s*(\d+)\s*em/) do
    $lg_marginleft = $1.to_i
  end
  out "#{style}#{rend}>"

  # <l style="...">'
  if l_text_indent != '' and l_text_indent != '0'
    out %(<l style="text-indent:#{l_text_indent}em;">)
  else
    out '<l>'
  end
  $opens['l'] = 1
  $lg_space_count = 1
end

# 悉曇字或蘭札字
# &SD-CFC5; => <g ref="#SD-CFC5"/>
def start_inline_SDRJ(tag)
  tag.match(/&(((SD)|(RJ))\-\w{4});/) do
    out2 %(<g ref="##{$1}"/>)
    $char_count+=1
  end
end

# TEI:<seg> (隨機分割) 包含文件中任何隨機字詞層次的單元 (包括其他分割元素)。
def start_inline_seg(tag)
  style, rend = get_style_rend(tag)
  out "<seg#{style}#{rend}>"
end

# 處理空白, 主要是針對偈頌的空白
# 行首空白換成 <l>, 要考慮偈頌的 left-margin
# 行中空白換成 <caesura>
def start_inline_space(tag)
	if tag == '<nosp>'
    space_length = 0
	else
    space_length = tag.length
  end

	# 在 lg 中才要處理
	if $opens['lg'] == 1
		if $lg_space_count == 0
			# 第一個空白要處理成 <l>
			s = space_length - $lg_marginleft
			if s == 0
				# l 空白和 lg 的移位相同, 就用 <l> 即可
				out('<l>')
      elsif s > 0
				out(%(<l style="text-indent:#{s}em">))
			else
				# 錯誤, s 不可以為負
				out(%(<err 有負數的 text-indent:#{s}em:#{tag}>))
				puts "錯誤 : 算出負數的 text-indent:#{s}:#{tag}:"
      end
			$opens['l'] += 1
			$lg_space_count += 1
		else
			# 其他空白要處理成 <caesura>
			if space_length == 2
				out('<caesura/>')
			else
				out(%(<caesura style="text-indent:#{space_length}em;"/>))
      end
    end
	else
		# 非偈頌空白就交給 do_chars
		do_chars(tag)
  end
end

def start_inline_T(tag)

	# global globals, opens
	# if not 'lg' in opens: opens['lg'] = 0
	# if not 'TL_count' in globals: globals['TL_count'] = 0
	# if not 'lg_marginleft' in globals: globals['lg_marginleft'] = 0

	if $opens['lg'] == 0
	  close_tags('cb:jhead', 'cb:juan', 'byline', 'p')
	  close_head
  end

	moT = tag.match(/<T,?(\d*)>/)
	
  if !moT.nil?
	 	# <T,x>
	 	# <caesura style="..."/>'
	 	if moT[1] == ''
	 		out('<caesura style="text-indent:0em;"/>')
    elsif moT[1] == '2'
	 		out('<caesura/>')
	 	else
	 		out(%(<caesura style="text-indent:#{moT[1]}em;"/>))
    end
	else
	 	out("<err T 標記不合法 #{tag}>")
	 	print "錯誤 : T 標記不合法 #{tag}"
  end
end

def start_inline_T_old(tag)
  if $opens['lg'] == 0
    close_tags('byline', 'p')
    close_head
    n = "%02d" % $char_count
    out %(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}#{n}" type="abnormal")
    out ' cb:place="inline"' if $char_count > 1 # 若是行中段落, 則加上 cb:place="inline"
    out '>'
    $opens['lg'] = 1
  end

  close_tags('l')

  mo = tag.match(/<T,(\-?[\d\.]+),(\-?[\d\.]+)>/)
  if mo.nil?
    tag.match(/\-?[\d\.]+/) do
      out %(<l style="margin-left:#{$&}em">)
    end
  else
    a = []
    a << "margin-left:#{mo[1]}em" unless mo[1] == '0'
    a << "text-indent:#{mo[2]}em" unless mo[2] == '0'
    style = a.join(';')
    out %(<l style="#{style}">)
  end

  $opens['l'] += 1
end

# 處理表格 F 表格開始
# 20230503 表格有二種處理法，一種是行首標記用 Ff3 這種格式。
#          一種是用 <table,3> 這種格式
#          如果行首有數字，table 無數字，以行首為主。table 有數字則以 table 為主。
#
#          每一行都應該有 f，沒有就表示結束。如果是用 <F> 或 <table> 開始，就可以不用 f ，但一定要有 </table> 或 </F> 

def start_inline_table(tag)
  close_tags('byline','p')
  # 計算一行有多少個 c 標記
  i = count_c_from_line($line_text)
  style,rend = get_style_rend(tag)
  out %(<table cols="#{i}"#{style}#{rend}>)
  $opens['table'] += 1

  # <table> 要加上 <row>
  if !$line_text.match(/<row/)
    start_inline_row('<row>')
  end

end

# 計算一行有多少 <c> 標記
# <c>, <c,2> 算 1 個
# <c3> 算 3 個
# <c4 r3> 算 4 個
# <c r3> 算 1 個
def count_c_from_line(text)
  # 算有多少個 <c> 或 或 <c,2> 或 <c r3>
  r = text.scan(/<c[,\s>]/).size
  
  # 算有多少個 <c3> 或 <c3 r3>
  text.scan(/<c(\d+)/) do 
    r += $1.to_i
  end

  r
end 

def close_table(tag)
  close_tags('p', 'cell', 'row', 'table')
end

def start_inline_TL(tag)

	# global globals, opens
	# if not 'lg' in opens: opens['lg'] = 0
	# if not 'TL_count' in globals: globals['TL_count'] = 0
	# if not 'lg_marginleft' in globals: globals['lg_marginleft'] = 0

	if $opens['lg'] == 0
	  close_tags('cb:jhead', 'cb:juan', 'byline', 'p')
	  close_head
  end
  $lg_marginleft = 1
  $opens['lg'] = 1
  l_text_indent = ''

  tag.match(/\d+,\-?\d+,(\d+)/) do
    l_text_indent = $1
    tag = tag.sub(/(\d+,\-?\d+),\d+/,'\1')  # 移除第三組數字
  end
	
  if $TL_count == 0
    # 第一個 TL
      
    # <lg xml:id="..."
    out(%(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}%02d") % $char_count)

    # cb:place="..."
    if $char_count > 1
      out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
    end

    # style="..."  
    style, rend = get_style_rend(tag)

    style.match(/margin-left:\s*(\d+)\s*em/) do
      $lg_marginleft = $1.to_i
    end
    out "#{style}#{rend}>"

    # <l style="...">'
    if l_text_indent != '' and l_text_indent != '0'
      out %(<l style="text-indent:#{l_text_indent}em;">)
    else
      out '<l>'
    end
    $opens['l'] += 1
    $TL_count += 1
  else
    # 第二個 TL
    close_tags('l')
    # <l style="...">'

    # 因為第一個 <TL,x> = <TL,x,0> => <lg x,0><l>
    # 第二個 <TL,x> = <TL,0,x> => <l,x>
    # 所以要把 TL 換成 TL2 才能辨識

    tag = tag.sub('<TL','<TL2')

    style, rend = get_style_rend(tag)
    out "<l#{style}#{rend}>"
    
    $opens['l'] += 1
  end
end

# BM 版 : <trans-mark,a'> => XML P5 版 : <label type="translation-mark">a'</label>
def start_trans_mark(tag)
  tag.match(/<trans-mark,(.*?)>/) do
    out %(<label type="translation-mark">#{$1}</label>)
  end
end

def start_inline_u(tag)
  close_tags('byline', 'p')
  close_head()

  if $opens.key?('orig') and $opens['orig'] > 0
    out1('</cb:div>')
    $opens['div'] -= 1
    $opens['orig'] -= 1
  end

  start_div($opens['div']+1, 'commentary')
  $opens['commentary'] = 1
end

def start_inline_w(tag)
  close_tags('p','sp','cb:dialog')
  out('<cb:dialog type="qa"><sp cb:type="question">')
  $opens['cb:dialog'] = 1
  $opens['sp'] = 1
end

def start_x(tag)
  start_div(1, 'xu')
  $buf << '<head>'
  $opens['head'] = 1
  $mulu_start = True
  $head_start = True
  $div_head = ''
end


# 處理一些屬性
#   二組數字 x,y => margin-left:xem;text-indent:yem;
#   單一數字 x => margin-left:xem;
#   粗體：<bold>
#   斜體：<it>
#   明體：<ming>
#   楷體：<kai>
#   黑體：<hei>
#   上標字：<sup>（不能跨行）
#   下標字：<sub>（不能跨行）
#   上橫線：<over>（不能跨行）
#   下底線：<under>（不能跨行）
#   加外框：<border>（不能跨行）
#   加刪除線：<del>（不能跨行）
# c 置中
# r 靠右
# l 靠左
# t3 => text-indent:3em;
# <c,1> 這種有數字在 cell 處理法不同，會轉成
# rend="pl-1"
# .........還有很多....
# 詳見 https://docs.google.com/document/d/1zPxQRNPUd3tbU69krYT4Zr9i-LkqAfvui0TUu1ZK7K4/edit#
# 及 https://docs.google.com/document/d/1bHSnOvvMqpC-IQoKjaBlUU1dh_muz0khhCJidDHHXbQ/edit#

def get_style_rend(tag)
  tag_name = ''
  tag.match(/<([A-Za-z_\d]+)/) do  # 會有 <TL2>
    tag_name = $1
  end

  style = get_style(tag_name, tag)
  rend = get_rend(tag_name, tag)
  return [style,rend]
end

# 傳入 <p,x,y> 等格式
# 傳回 style="margin-left:xem; text-indent:yem;"
def get_style(tag_name, tag)
  
  # 傳入數字有三種狀況
  # <t> => <t>
  # <t,1> => <t,m1>
  # <t,1,2> => <t,m1,t2>
  # 不可同時存在 數字 及 mx tx，例如不可以用 <t,1,t2> <t,m1,2>，否則不易判斷

  # 預設情況，有 mx 才處理 margin-left:xem;
  #          有 ty 才處理 text-indent:yem;

  # 特殊情況
  # 1. <S> 標記在 m=1 和 t=0 時則不呈現
  # 2. <TL> 標記在 m=0 和 t=0 時則不呈現
  # 3. <TL2>（第二組 TL）,<l> , <hi>, <seg>, 只有一組數字，要轉成 t 而不是 m
  # 4. <c,1> 這種有數字在 cell 處理法不同，會轉成 rend="pl-1"，不在此處理

  if tag_name == "c"
    return ''
  end

  style = ''
  rend = ''
  tag = tag.gsub(/\s*,\s*/,',')  # 移除逗號前後不必要空白

  m_num = ''
  t_num = ''

  # 二組數字 x,y => margin-left:xem;text-indent:yem;
  tag.match(/,(\-?[\d\.]+),(\-?[\d\.]+)/) do
    m_num = $1
    t_num = $2
    tag = tag.sub(/,(\-?[\d\.]+),(\-?[\d\.]+)/,'')
  end
  # 單一數字 x => margin-left:xem;
  # 取出 m
  tag.match(/,m?(\-?[\d\.]+)/) do
    m_num = $1
    tag = tag.sub(/,m?(\-?[\d\.]+)/,'')
  end
  # 取出 t
  tag.match(/,t(\-?[\d\.]+)/) do
    t_num = $1
    tag = tag.sub(/,t(\-?[\d\.]+)/,'')
  end

  # 特殊情況
  # 1. <S> 標記在 m=1 和 t=0 時則不呈現
  if tag_name == "S"
    m_num = '' if m_num == '1'
    t_num = '' if t_num == '0'
  end
  # 2. <TL> 標記在 m=0 和 t=0 時則不呈現
  if tag_name == "TL"
    m_num = '' if m_num == '0'
    t_num = '' if t_num == '0'
  end
  # 3. <TL2>（第二組 TL）,<l> , <hi>, <seg>, 只有一組數字，要轉成 t 而不是 m
  if tag_name == "TL2" || tag_name == "l" || tag_name == "hi" || tag_name == "seg"
    if !m_num.empty? && t_num.empty?
      t_num = m_num
      m_num = ''
    end
    t_num = '' if t_num == '0'
  end

  # margin-left:
  if !m_num.empty?
    style << "margin-left:#{m_num}em;"
  end
  # text-indent
  if !t_num.empty?
    style << "text-indent:#{t_num}em;"
  end

  # 做出結果字串
  if !style.empty?
    style = %( style="#{style}")
  end

  style
end

# 傳入 <p,bold,it> 等格式
# 傳回 rend="bold italic"
def get_rend(tag_name, tag)
  rend = ''
  tag = tag.gsub(/\s*,\s*/,',')  # 移除逗號前後不必要空白

  # 粗體：<bold>
  # 還原粗體：<no-bold>
  tag.match(/,((no\-)?bold)[,>]/) do
    rend << "#{$1} "
  end
  # 斜體：<it>
  # 還原斜體：<no-it>
  tag.match(/,((no\-)?it)[,>]/) do
    rend << "#{$1}alic "
  end
  # 明體：<ming>
  # 楷體：<kai>
  # 黑體：<hei>
  tag.match(/,((ming)|(kai)|(hei))[,>]/) do
    rend << "#{$1}ti "
  end
  # 上標字：<sup>（不能跨行）
  # 下標字：<sub>（不能跨行）
  tag.match(/,((sup)|(sub))[,>]/) do
    rend << "#{$1} "
  end
  # 上橫線：<over>（不能跨行）
  # 下底線：<under>（不能跨行）
  # 刪除線：<del>（不能跨行）
  tag.match(/,((over)|(under)|(del))[,>]/) do
    rend << "#{$1} "
  end
  # 外框：<border>（不能跨行）
  # 表格無框
  tag.match(/,((no\-)?border)[,>]/) do
    rend << "#{$1} "
  end
  # 上框線：border-top（不能跨行）
  # 下框線：border-top（不能跨行）
  # 左框線：border-top（不能跨行）
  # 右框線：border-top（不能跨行）
  tag.match(/,(border\-((top)|(bottom)|(left)|(right)))[,>]/) do
    rend << "#{$1} "
  end
  # l 靠左 
  tag.match(/,l[,>]/) do
    rend << 'text-left '
  end
  # c 置中
  tag.match(/,c[,>]/) do
    rend << 'text-center '
  end
  # r 靠右
  tag.match(/,r[,>]/) do
    rend << 'text-right '
  end
  # 各種字體
  tag.match(/,((larger)|(smaller)|(small)|(medium)|(large))[,>]/) do
    rend << "#{$1} "
  end
  tag.match(/,(xx?\-small)[,>]/) do
    rend << "#{$1} "
  end
  tag.match(/,(xx?\-large)[,>]/) do
    rend << "#{$1} "
  end
  # 列表不使用圓點符號
  tag.match(/,sp[,>]/) do
    rend << 'no-marker '
  end
  # 上方加圈點
  tag.match(/,circle\-above[,>]/) do
    rend << 'circle-above '
  end
  # 表格移位
  # <c,2> 或 <c,m2> 這種有數字在 cell 處理法不同，會轉成 rend="pl-2"
  if tag_name == "c"
    tag.match(/,m?(\d+)[,>]/) do
      rend << "pl-#{$1} "
    end
  end

  # 做出結果字串
  if !rend.empty?
    rend = rend.strip
    rend = %( rend="#{rend}")
  end

  rend
end

def close_tag(*tags)
  tags.each do |t|
    next unless $opens.key?(t)
    out1("</#{t}>")
    $opens[t] -= 1
  end
end  

def close_tags(*tags)
  tags.each do |t|
    next unless $opens.key?(t)
    while $opens[t] > 0
      out1("</#{t}>")
      $opens[t] -= 1
    end
  end
end

def close_head
  return unless $head_start

  if $mulu_start
    unless $div_head.empty?
      out1 %(<cb:mulu type="#{$mulu_type}" level="#{$opens['div']}">#{$div_head}</cb:mulu>)
    end
    # 取消 cb:mulu 的空標記 2016/04/11
    # else:
    #	out1('<cb:mulu type="{}" level="{}"/>'.format(globals['muluType'], opens['div']))
    $mulu_start = false
  end

  out('')
  close_tags('head')
  $head_start = false
end

######################################################################################################

# 計算經文的長度
def my_length(s)
  r = 0
  #s = re.sub(r'\[[^>\]]*?>(.*?)\]', r'\1', s)
  #s = re.sub(r'\[[^>\]]*?\]', '缺', s) # 將組字式取代為單個字

  s.each_char do |c|
    next if '◎。，、；：「」『』（）？！—…《》〈〉．“”　〔〕【】()'.include?(c)
    r += 1
  end

  r
end

def gaiji(zuzi)
  $log.puts "gaiji() #{zuzi}"
  return zuzi if zuzi=='[＊]'
  return zuzi if zuzi.match?(/\[\d+\]/)
  
  if $des2uni.key?(zuzi)
    return $des2uni[zuzi]
  elsif $des2cb.key?(zuzi)
    return %(<g ref="##{$des2cb[zuzi]}"/>)
  else
    puts "組字式找不到: #{zuzi}"
    return ''
  end
end
      
# 處理經文中的文字
def do_chars(s)
  $char_count += my_length(s)
  out2(s)
end

# 先把 [Ａ>Ｂ] 換成
# <note n="0001b0201" resp="CBETA.maha" type="add">念【CB】，忘【大】</note>
# <app n="0001b0201"><lem wit="【CB】" resp="CBETA">念</lem><rdg wit="【大】">忘</rdg></app>
# 因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [[金*本]>[口*兄]] , [[01]>]
# 也把 [Ａ=Ｂ] 換成 
# <note n="0002a0201" resp="CBETA" type="add" subtype="規範字詞">系統【CB】，係統【呂澂】</note>
# <app n="0002a0201"><lem wit="【CB】" resp="CBETA">系統</lem><rdg wit="【呂澂】">係統</rdg></app>
# 因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [千[金*本]=千[金*本]經]
def do_corr_normalize(text)
  # 換掉 []<> 符號
  # 先把 [xxx] 組字或校勘數字變成 :gaiji1:xxx:gaiji2:
  # 先把 <xxx> 組字或校勘數字變成 :gaiji3:xxx:gaiji4:
  text.gsub!(/\[([^>=\[\]]+?)\]/, ':gaiji1:\1:gaiji2:')
  text.gsub!(/<([^<>]+?)>/, ':gaiji3:\1:gaiji4:')

  # 處理 校註
  do_corr_note(text)
  
	# B【CB】，A【xx】若 A 與 B 是空的，要換成 〔－〕【CB】，〔－〕【xx】

	text.gsub!(/(<note[^>]*>)【CB】/, '\1〔－〕【CB】')
	text.gsub!(/【CB】，(【.*?】)/, '【CB】，〔－〕\1')

  # 換回 [] 符號
  # 再把:gaiji1:xxx:gaiji2: 換回 [xxx]
  text.gsub!(":gaiji1:", "[")
  text.gsub!(":gaiji2:", "]")
  
  # 校勘數字或星號換成 <[01]> , <[＊]>
  # <note...>[01]【CB】 改成 <note...><[01]>【CB】
  text.gsub!(/(<note[^>]*>)(\[(([\da-zA-Z]{2,3})|＊)\])【CB】/, '\1<\2>【CB】')

  # ，[01]【xx】 改成 ，<[01]>【xx】
  text.gsub!(/【CB】，(\[(?:(?:[\da-zA-Z]{2,3})|＊)\])(【.*?】)/, '【CB】，<\1>\2')
  
  # 再把 <lem ..>[01]</lem> 這一類換成 <lem ..><[01]></lem> , 而 <[01]> 之後會換成 [01], 
  # 如不這樣處理, [01] 會被變成一般的校勘數字標記
  # note 和 rdg 比照處理.
  text.gsub!(/(<lem[^>]*>)(\[(([\da-zA-Z]{2,3})|＊)\])<\/lem>/, '\1<\2></lem>')
  text.gsub!(/(<rdg[^>]*>)(\[(([\da-zA-Z]{2,3})|＊)\])<\/rdg>/, '\1<\2></rdg>')

  # 沒文字換成 <space quantity="0"/>
  # 再把 <lem ..></lem> 換成 <lem ..><space quantity="0"/></lem>
  # <rdg> 比照處理.
  text.gsub!(/(<lem[^>]*>)<\/lem>/, '\1<space quantity="0"/></lem>')
  text.gsub!(/(<rdg[^>]*>)<\/rdg>/, '\1<space quantity="0"/></rdg>')

  # 換回 <> 符號
  # 再把:gaiji3:xxx:gaiji4: 換回 <xxx>
  text.gsub!(":gaiji3:", "<")
  text.gsub!(":gaiji4:", ">")
end

# 把[Ａ>Ｂ](<resp="xxx">)? 換成
#   <note n="...." resp="CBETA" type="add">B【CB】，A【xx】</note>
#   <app n="...."><lem wit="【CB】" resp="xxx">B</lem><rdg wit="【xx】">A</rdg></app>
#
# 把[Ａ=Ｂ](<resp="xxx">)? 換成
#   <note n="...." resp="CBETA" type="add" subtype="規範字詞">B【CB】，A【xx】</note>
#   <app n="...."><lem wit="【CB】" resp="xxx">B</lem><rdg wit="【xx】">A</rdg></app>
#
# Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [千[金*本]=千[金*本]經]
def do_corr_note(text)
  resp = 'CBETA' # resp 預設為 CBETA
  # 如果是佛寺志版本 (GA or GB) 則 resp = "DILA"
  resp = 'DILA' if $canon == 'GA' or $canon == 'GB'

  note_count = 1

  regexp = /
    \[
      ([^\]]*?)
      ([>=])
      ([^\]]*?)
    \]
    (:gaiji3:resp="(.*?)":gaiji4:)?
  /x

  text.gsub!(regexp) do
    s1    = $1
    type  = $2
    s2    = $3
    resp1 = $4
    resp2 = $5
    
    # [Ａ>Ｂ]<resp="xxx"> 則 resp = "xxx"
    resp = resp1 unless resp2.nil?
    
    if type == "="
      subtype = ' subtype="規範字詞"' 
    else
      subtype = ''
    end

    n = "%02d" % note_count
    note_count += 1

    if $canon == 'TX'
      rend = ' rend="hide"'
      lem = %(<lem wit="#{$wit}">#{s1}</lem>)
      rdg = %(<rdg resp="#{resp}" type="cbetaRemark">#{s2}</rdg>)
    else
      rend = ''
      lem = %(<lem wit="【CB】" resp="#{resp}">#{s2}</lem>)
      rdg = %(<rdg wit="#{$wit}">#{s1}</rdg>)
    end

    %(<note n="#{$old_pb}#{$line_num}#{n}" resp="CBETA" type="add"#{subtype}#{rend}>#{s2}【CB】，#{s1}#{$wit}</note><app n="#{$old_pb}#{$line_num}#{n}">#{lem}#{rdg}</app>)
  end
end

# 把這種
# T04n0213_p0794a23D##[>法集要頌經樂品第三十]<S>　[06]忍勝則怨賊，　　自負則自鄙，
# 把 <S> 後面的空格換成 <l></l>
#def do_tag_s(text)
#  text.gsub!(/(<S>.*)　　/, '\1</l><l>')
#  text.gsub!(/(<S>.*)　/, '\1<l>')
#  text << "</l>\n" if text.match?(/<S>/)
#end
  
# 分析每一行經文
def do_text(s)
  regexp = /
    (?:
      <i>\(
      |
      \)<\/i>
      |
      <.*?>
      |
      \[[^\]]*?>.*?\]
      |
      \[[^>\[\s]+?\]
      |
      \(
      |
      \)
      |
      &SD\-\w{4};
      |
      &RJ\-\w{4};
      |　+|
      .
    )
  /x
  
  $line_text = s    # 整行存起來，有時會用到
  s.scan(regexp) do |t|      
    if t.match?(/[<\(\)\[&　]/)
      inline_tag(t) 
    else
      do_chars(t)
    end
  end
end
  
def get_number(s)
  s.match(/\d+/) do
    return $&
  end

  ''
end

def get_number_i(s)
  s.match(/\d+/) do
    return $&.to_i
  end
  nil
end 

# 結束一部經, 全部印出來
def close_sutra(num)
  # 加上 l, lg -- 2013/09/30 
  # 加上 cb:jhead 2014/06/06
  close_tags('l','lg','byline','cb:jhead','p')

  close_div(1)
  out('')		# 處理最後的 <lb> , 因為 BM 版經文最後可能會有空白行, 也要轉出 XML 來
  
  #最後的要處理一些特例
  #移除 <head></head> 及將 <ref cRef="PTS.Vin.3.110"/></head> 換成 <ref cRef="PTS.Vin.3.110"/>
  $buf1.gsub!(/<head>((?:<ref cRef="PTS.[^>]*>)?)<\/head>/, '\1')
  
  $buf1.gsub!('&', '&amp;')	# 把 & 換成 &amp;  - 2013/09/24
  $buf1.gsub!('&amp;SD-', '&SD-')	# 把 &amp;SD- 換成 &SD-
  $buf1.gsub!('&amp;RJ-', '&RJ-')	# 把 &amp;RJ- 換成 &SD-

  n = num.delete_prefix('n')
  n0 = n.sub(/^0*(.*)$/, '\1')
  title = $sutras[n]['title']

  data = {
    id: "#{$vol}#{num}",
    title_en: "#{$collection_en[$canon]}, Electronic version, No. #{n0} #{title}",
    title_zh: "#{$collection_zh[$canon]}數位版, No. #{n0} #{title}",
    author: $sutras[n]['author'],
    juan: $sutras[n]['juan'],
    idno_canon: $canon,
    idno_vol: $vol.sub(/^\D+0*(\d+)$/, '\1'),
    idno_no: n0,
    bibl_s: $collection_en[$canon],
    bibl_s_zh: $collection_zh[$canon],
    bibl_m: $sutras[n]['title'],
    laiyuan_e: $sutras[n]['laiyuan_e'],
    laiyuan_c: $sutras[n]['laiyuan_c'],
    wit: WITS[$canon],
    today: Time.now.strftime('%Y-%m-%d')
  }  
  
  template = File.read('p5a-template.xml')
  xml = template % data
  xml << $buf1
  $buf1 = ''
  xml << "\n</body></text></TEI>\n"

  out_path = File.join($dir_out, "#{$vol}#{num}.xml")
  puts "out_path: #{out_path}"
  File.write(out_path, xml)  
end
    
# 初值化
def sutra_init(new_sutra_number)
  close_sutra($sutra_number) unless $sutra_number.empty?
  $anchor_count = 0
  $back_app = ''
  $head_start = false
  $inw = false
  $inr = false
  $juan_num = 0
  $mulu_start = false
  $sutra_number = new_sutra_number
end
  
def convert
  bm_jingwen = File.join($bm_dir, $canon, $vol, "new.txt")
  $log.puts "bm_jingwen: #{bm_jingwen}"    
  $sutra_number = ''

  File.foreach(bm_jingwen) do |line|
    convert_line(line)
  end

  close_sutra($sutra_number)
end

def convert_line(s)
  $char_count = 1
  line = s.rstrip
  line.sub!(/　*$/,'')  # python 的 rstrip 會移除全型空白, ruby 不會
  line.delete_prefix!("\ufeff")	# 扣除 utf8 格式有 feff 的檔頭

  i = $opts[:vol].size + 17
  aline = line[0, i]
  text = line[i..]

  mo = aline.match(/([A-Z]+\d{2,3})(n.\d+.)(p.\d{3}[a-z])(\d\d)(.+)$/)
  if mo.nil?
    abort "行首有錯: #{aline}"
  else
    vol, num, pb, $line_num, $head_tag = mo[1..5]
  end

  num.delete_suffix!('_')
  sutra_init(num) if num != $sutra_number

  pb.delete_prefix!('p')
  
  # 換行時, 發現前一行是 head , 而且沒有延續到本行, 就要印出相關文字
  if $head_start and not $head_tag.match?(/Q\d*(,[cr])?=/) and not text.match?(/<Q\d*(,[cr])?=/)
    close_head
  end
  
  # 判斷有沒有換頁
  if pb != $old_pb
    $buf << %(\n<pb ed="#{$canon}" xml:id="#{vol}.#{num[1..]}.#{pb}" n="#{pb}"/>)
    $old_pb = pb
  end
    
  $buf << "\n<lb"
  $buf << ' type="honorific"' if $head_tag.include?('k') # 強迫換行
  $buf << %( ed="#{$canon}" n="#{pb}#{$line_num}"/>)
  
  text = do_line_head($head_tag, text)	

  $lg_space_count = 0	# 每一行的空格數歸0

  # 變數
  # $lg_space_count : 每一行第 n 個 <l>，計數會在每一行歸零, 在偈頌中遇到空白就會 +1
  # $lg_marginleft : 偈頌的整段位移，會在 lg 產生時重設, 通常預設是 1
  # $normal_lg : 表示是使用 S## 或 <S> 的標準偈頌, 不是 <T> 的偈頌
  if $opens['lg'] == 1 and $normal_lg == true
    if text[0] != '　'
      text = "<nosp>" + text
    end
  end

  if ($opens['lg'] == 1 and $normal_lg == true) or text.include?('<S') # <S 會在行中
    if !text.end_with?("</S>")
      text << "</l>"
    end
    # 把 </Qx> 移到後面, 例: 	B10n0068_p0839b03s##　能令清淨諸儀軌　　如智者論顯了說</Q1>
    text.sub!(/(<\/Q\d*>)(<\/S>)$/, '\2\1')
  end

  # 先把 [Ａ>Ｂ] 換成
  # <note n="0001b0201" resp="CBETA.maha" type="add">念【CB】，忘【大】</note>
  # <app n="0001b0201"><lem wit="【CB】" resp="CBETA">念</lem><rdg wit="【大】">忘</rdg></app>
  # 因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [[金*本]>[口*兄]] , [[01]>]
  # 也把 [Ａ=Ｂ] 換成 
  # <note n="0002a0201" resp="CBETA" type="add" subtype="規範字詞">系統【CB】，係統【呂澂】</note>
  # <app n="0002a0201"><lem wit="【CB】" resp="CBETA">系統</lem><rdg wit="【呂澂】">係統</rdg></app>
  # 因為 Ａ 與 Ｂ 也有可能是組字式或校勘數字, 例如 [千[金*本]=千[金*本]經]

  do_corr_normalize(text)

  # 把 Ａ<㊣Ｂ> 換成 <orig reg="Ｂ">Ａ</orig>
  text = text.gsub(/((?:\[[^\]]+\])|(?:[^\]]))<㊣(.*?)>/, '<orig reg="\2">\1</orig>')
      
  '''
  把這種
  T04n0213_p0794a23D##[>法集要頌經樂品第三十]<S>　[06]忍勝則怨賊，　　自負則自鄙，
  把 <S> 後面的空格換成 <l></l>
  '''
  #do_tag_s(text)
  do_text(text)
end
  
def read_source
  bm_laiyuan = File.join($bm_dir, $canon, $vol, "source.txt")
  laiyuan = {}

  puts "read #{bm_laiyuan}"
  File.foreach(bm_laiyuan) do |line|
    line.rstrip!
    line.sub!(/　*$/,'')  # python 的 rstrip 會移除全型空白, ruby 不會

    # 例: 4:北美某大德提供, Text as provided by Anonymous from USA
    m = line.match(/^(.):(.*)$/)
    unless m.nil?
      laiyuan[m[1]] = m[2].split(',')
      next
    end

    read_source_line(line, laiyuan)
  end
end

def read_source_line(line, laiyuan)
  fields = line.split
  return if fields.size < 5

  # 例: T0001-01-p0001
  return unless fields[1].match?(/[A-Z]/)

  # 藏經 ID 後 取5碼
  # ZY0001_01_p0017
  # T0099-02-p0001 or T0128a02-p0835
  n = fields[1].sub(/^#{$canon}(.{5}).*$/, '\1')

  n.delete_suffix!('-')
  n.delete_suffix!('_')

  $sutras[n] = {}
  $sutras[n]['title'] = fields[5]
  $sutras[n]['juan'] = fields[4]

  # 例: 【後秦 佛陀耶舍共竺佛念譯】    K0647-17
  s = fields[6..].join(' ')
  #sutras[n]['author'] = s[1:-1]		# 這樣用有危險, 有時譯者之後還有其他欄位, 例如 T02 有高麗藏的對應 - 2013/08/26
  $sutras[n]['author'] = s.sub(/^.*【(.*?)】.*$/, '\1')

  a1 = []
  a2 = []
  fields[0].each_char do |id|
    a1 << laiyuan[id][0].strip
    a2 << laiyuan[id][1].strip
  end

  $sutras[n]['laiyuan_c'] = a1.join('，')
  $sutras[n]['laiyuan_e'] = a2.join(', ')
end
  
def read_all_gaijis
  base = $config['default']['gaiji']
  if base == nil
    base = File.join($config['default']['cbwork'], 'cbeta_gaiji')
  end
  fn = File.join(base, 'cbeta_gaiji.json')
  $all_gaijis = JSON.load_file(fn)

  # $unicode2cb = {}
  $all_gaijis.each do |cb, v|
    des = v['composition']
    if not des.nil? and not des.empty?
      $des2cb[des] = cb
      uni_char = v['uni_char']
      if not uni_char.nil? and not uni_char.empty?
        $des2uni[des] = uni_char
      end
    end

    # uni = v['unicode']
    # if not uni.nil? and not uni.empty?
    #   $unicode2cb[uni] = cb
    # end
  end
end
  
def read_command_line_arguments  
  r = Slop.parse do |o|
    o.upcase '-v', '--vol', '指定要轉換哪一冊'
    o.string '-o', '--output', '輸出資料夾'
  end
  $vol = r[:vol]
  $canon = $vol.sub(/^([A-Z]+).*$/, '\1')
  r
end

def read_config
  # 讀取 設定檔 cbwork_bin.ini
  $config = IniFile.load('../cbwork_bin.ini')
  $bm_dir = $config['default']['bm']  # 不一定有 bm ，沒有則用預設值
  if $bm_dir == nil
    $bm_dir = File.join($config['default']['cbwork'], 'bm')
  end
  $log = File.open('bm2p5a.log', 'w')

  $dir_out = File.join($opts[:output], $canon, $vol)
  FileUtils.makedirs($dir_out)

  $wit = WITS[$canon]
  $buf = ''  # 似乎是放 <lb> <pb> 及 head 的內容
  $buf1 = ''
  $char_count = 1
  $head_tag = ''
  $div_head = ''
  $des2cb = {}
  $des2uni = {}
  # $unicode2cb = {}
  $last_list_tag = ''
  $line_num = ''
  $opens = Hash.new(0)	# 記錄每一個標記的層次, 預設值為 0
  $opens['div'] = 0
  $old_pb = ''
  $sutras = {}
  $div_type_note = 0 # 記錄是否有在 <cb:div type="note"> 之中
  $TL_count = 0
  $lg_marginleft = 0
end

# 將 組字式 取代為 <g>
def replace_zuzi(s)
  s.gsub(/\[[^>\[ ]+?\]/) do |des|
    gaiji(des)
  end
end

# main

# 讀取 命令列參數
$opts = read_command_line_arguments

# 讀取 設定檔, 並做初始設定
read_config

# 預設改為直接開啟 GitHub 上的 缺字 JSON 資料庫
read_all_gaijis

read_source
convert