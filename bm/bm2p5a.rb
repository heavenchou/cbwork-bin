# CBETA BM (簡單標記版 UTF8) 轉為 XML-P5a (UTF8)
# 設定檔: ../cbwork_bin.ini
# 命令列參數:
# 	ruby bm2p5a.rb -o 輸出目錄 -v 冊數
# 範例：ruby bm2p5a.rb -o d:\temp\xmlp5a-ok -v T01
# 作者: 周邦信(Ray Chou) 2022-04-20
#
# Heaven 修改：
# 2022-05-04 正式使用，找不到的說明可試著找 bm2p5a.py

require 'fileutils'
require 'inifile'
require 'json'
require 'slop'
require_relative '../common'
  
$collection_zh = {
  'B' => '大藏經補編',
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

  if level > $opens['list']
    $opens['list'] += 1
    if $l_type == 'simple'
      out('<list rend="no-marker">')
    else
      out('<list>')
    end
  end

  s = %(<item xml:id="item#{$vol}p#{$old_pb}#{$line_num}%02d">) % $char_count
  out(s)
  $opens['item'] += 1
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

# BM 版 : <trans-mark,a'> => XML P5 版 : <label type="translation-mark">a'</label>
def start_trans_mark(tag)
  tag.match(/<trans-mark,(.*?)>/) do
    out %(<label type="translation-mark">#{$1}</label>)
  end
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
  
  # 處理 <p,1,2> 這種格式
  tag.match(/<[pz],(\-?[\d\.]+),(\-?[\d\.]+)>/) do
    s << %( style="margin-left:#{$1}em;text-indent:#{$2}em")
  end
  
  # 處理 <p,1> 這種格式
  tag.match(/<[pz],(\-?[\d\.]+)>/) do
    s << %( style="margin-left:#{$1}em")
  end
    
  # 若都沒有 <p,1 這種格式, 又是在行中, 則用 rend="inline"
  #mo = re.search(r'<[pz],(\-?[\d\.]+)', tag)
  #if mo==None:
  #	if char_count>1: s += ' rend="inline"'  
  s << ' cb:place="inline"' if $char_count > 1
  
  # 處理 <p=h1> 這種格式	- 2013/09/11
  tag.match(/<p=h(\d+)>/) do
    s << %( cb:type="head#{$1}")
  end

	# 處理 <p_c> , <p_r> - 2022-03-29
	
  tag.match(/<[pz]_c/) do
    s << %( rend="text-center")
  end
  tag.match(/<[pz]_r/) do
    s << %( rend="text-right")
  end

  s << '>'
  out(s)
  $opens['p'] = 1
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

def start_inline_q(tag)
  return if tag.match?(/<Q\d?=/)	# <Q3=> 這一種的表示是延續上一行的 <Q3>

  close_head
  close_tags('l', 'lg', 'p', 'sp', 'cb:dialog', 'cb:event', 'form', 'cb:def', 'entry')
  $div_head = ''

  level = 0
  tag.match(/<Q(\d+)/) do
    level = $1.to_i
  end
  
  start_div(level, 'other')

  mo = tag.match(/m=(.*?)>/)
  if mo.nil?
    $mulu_start = true
    $mulu_type = $head_tag.include?('W') ? '附文' : '其他'
  else
    start_inline_q_label($1, level)
  end

  $head_start = true
  $buf << '<head>'
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

def close_div(level)
  while $opens['div'] >= level
    out1('</cb:div>')
    $opens['div'] -= 1
  end
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

# 悉曇字或蘭札字
# &SD-CFC5; => <g ref="#SD-CFC5"/>
def start_inline_SDRJ(tag)
  tag.match(/&(((SD)|(RJ))\-\w{4});/) do
    out2 %(<g ref="##{$1}"/>)
    $char_count+=1
  end
end

######################################################
# P5a 的版本在修訂不是傳回 <anchor , 而是直接傳回 <choice
#	globals['backApp'] += s + '\n'
#	r = '<anchor xml:id="{}" type="cb-app"/>'.format(id1)
#	r += mo[2]
#	r += '<anchor xml:id="{}"/>'.format(id2)
#	return r
######################################################
  
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

# 表格中的 cell , 有這些形式
# <c> => <cell>
# <c3> => <cell cols="3">
# <c r3> => <cell rows="3">
# <c3 r3> => <cell cols="3" rows="3">
def start_inline_c(tag)
  close_tags('p', 'cell')

  # 檢查有沒有 c3 這種格式
  cols = ''
  tag.match(/c(\d+)/) do
    cols = $1
  end

  # 檢查有沒有 r3 這種格式
  rows = ''
  tag.match(/r(\d+)/) do
    rows = $1
  end

  out '<cell'
  out %( cols="#{cols}") unless cols.empty?
  out %( rows="#{rows}") unless rows.empty?
  out('>')
  $opens['cell'] += 1
end
  
def start_inline_d(tag)
  close_tags('form')
  out('<cb:def>')
  $opens['cb:def'] += 1
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

def start_r(tag)
  # 第一個 r 才需要處理成 <p xml:id="xxx" cb:type="pre">
  return if $inr

  $inr = true
  start_p(tag) # 依 p 的方式處理
end

def close_annals(tag)
  close_tags('p', 'cb:event')
end

def close_e(tag)
  close_tags('p', 'cb:def', 'entry')
end
  
def close_F(tag)
  close_tags('p', 'cell', 'row', 'table')
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

# 2013/11/15 新增
def close_h(tag)
  close_tags('cb:jhead', 'cb:juan', 'p')
  close_head()
  #level = int(tag[3:-1])
  #close_div(level)
end
  
def start_inline_Lsp(tag)
  close_head()
  $l_type = 'simple'
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
  mo = tag.match(/<S,?(\d*),?(\-?\d*),?(\d*)>/)
	if !mo.nil?
		$normal_lg = true
		# <lg xml:id="..."
		out(%(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}%02d) % $char_count)
		# style="..."
		if(mo[1] != '' and mo[1] != '1') or (mo[2] != '' and mo[2] != '0')
			out(' style="')
			if mo[1] != '' and mo[1] != '1'
				out("margin-left:#{mo[1]}em;")
				$lg_marginleft = mo[1].to_i
      end
			if mo[2] != '' and mo[2] != '0'
				out("text-indent:#{mo[2]}em;")
      end
			out('"')
    end
		# cb:place="..."
		if $char_count > 1
      out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
    end
		out('>')

		# <l style="...">'
		if mo[3] != '' and mo[3] != '0'
			out(%(<l style="text-indent:#{mo[3]}em;">))
		else
			out('<l>')
    end
		$opens['l'] = 1
		$lg_space_count = 1
	else
		out("<err S 標記不合法 #{tag}>")
		puts "錯誤 : S 標記不合法 #{tag}"
  end
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
			# 其他空白要處理成 <casesura>
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

	moTL = tag.match(/<TL,?(\d*),?(\-?\d*),?(\d*)>/)
	moT = tag.match(/<T,?(\d*)>/)
	
	if !moTL.nil?
	 	if $TL_count == 0
	 		# 第一個 TL
				
	 		# <lg xml:id="..."
      n = "%02d" % $char_count
      out(%(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}#{n}"))
	 		# style="..."
	 		if (moTL[1] != '' and moTL[1] != '1') or (moTL[2] != '' and moTL[2] != '0')
	 			out(' style="')
	 			if moTL[1] != '' and moTL[1] != '1'
	 				out("margin-left:#{moTL[1]}em;")
	 				$lg_marginleft = moTL[1].to_i
        end
        if moTL[2] != '' and moTL[2] != '0'
	 				out("text-indent:#{moTL[2]}em;")
        end
	 			out '"'
      end
	 		# cb:place="..."
	 		if $char_count > 1
        out(' cb:place="inline"')		# 若是行中段落, 則加上 cb:place="inline"
      end
	 		out '>'

	 		# <l style="...">'
	 		if moTL[3] != '' and moTL[3] != '0'
	 			out(%(<l style="text-indent:#{moTL[3]}em;">))
	 		else
	 			out('<l>')
      end
	 		$opens['lg'] = 1
      $opens['l'] += 1
	 		$TL_count += 1
	 	else
	 		# 第二個 TL
	 		close_tags('l')
	 		# <l style="...">'
	 		if moTL[1] != '' and moTL[1] != '0'
	 			out(%(<l style="text-indent:#{moTL[1]}em;">))
	 		else
	 			out('<l>')
      end
      $opens['l'] += 1
    end
  elsif !moT.nil?
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

def start_inline_a(tag)
  close_tags('p','sp')
  out('<sp cb:type="answer">')
  $opens['sp'] = 1
end

# 處理經文中的標記
def inline_tag(tag)
  case tag
  when /^<app/, '</app>', '<corr>', '</corr>', /^<choice/, '</choice>', /^<lem/, '</lem>', /^<note/, '</note>', '<orig>', '</orig>', '</quote>', /^<rdg/, '</rdg>', '<reg>', '</reg>', '<sic>', '</sic>'
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
  when '<annals>'
    # J01nA042_p0793a14_##<Q2 m=哲宗><annals><date><p>哲宗皇帝元祐四年[已>己]巳
    # J01nA042_p0793a15_##<event><p,1>師宣州寧國縣人也姓奚氏其母初夢神人衛一
    # ... </annals>
    # 還有 <Q> <annals> 也可以結束 <annals>
    # <event> 是用來結束 <date> 的
    # 轉成
    # <cb:event><date>ＸＸＸ</date><p,1>ＹＹＹ</p></cb:event>
    start_inline_annals(tag)
  when '</annals>' then close_annals(tag)
  when /<[ABCEY]>/ then start_inline_byline(tag)
  when '<bold>'    then out('<seg rend="bold">')
  when '</bold>'   then out('</seg>')
  when '<border>'  then out('<seg rend="border">')
  when '</border>' then out('</seg>')
  when /<c[\d\s>]/ then start_inline_c(tag)
  when '<d>'       then start_inline_d(tag)
  when '<date>'    then start_inline_date(tag)
  when '<e>'       then start_inline_e(tag)
  when '</e>'      then close_e(tag)
  when '<event>'   then start_inline_event(tag)
  when '<formula>' then out('<formula>')
  when '</formula>' then out2("</formula>")
  when '</F>'      then close_F(tag)
  when '<hei>'    then out('<seg rend="heiti">')
  when '</hei>'   then out('</seg>')
  when /^<h/       then start_inline_h(tag)
  when /^<\/h/     then close_h(tag)
  when /<I\d*>/    then start_i(tag)
  when '<i>('       then out2('<note place="interlinear">')
  when /^\)(<\/i>)?/ then out2('</note>')
  when '<it>'    then out('<seg rend="italic">')
  when '</it>'   then out('</seg>')
  when '<j>'
    close_tags('p')
    out('<cb:juan fun="close"><cb:jhead>')
    $opens['cb:juan'] += 1
    $opens['cb:jhead'] += 1
  when /^<J/    then start_J(tag)
  when '<kai>'    then out('<seg rend="kaiti">')
  when '</kai>'   then out('</seg>')
  when '<L_sp>' then start_inline_Lsp(tag)
  when '<l>'
    out('<l>')	# 行首標記有 S 及 s 時, 會在行中自動將空格變成 <l></l></lg> 等標記
  when '</l>' then close_tags('l')  # 行首標記有 S 及 s 時, 會在行中自動將空格變成 <l></l></lg> 等標記
  when '</lg>'
    out('</lg>')	# 行首標記有 S 及 s 時, 會在行中自動將空格變成 <l></l></lg> 等標記
  when '</L>'
    close_tags('p')
    $l_type = ""
    while $opens['list'] > 0
      close_tag('item', 'list')
    end
  when '<ming>'    then out('<seg rend="mingti">')
  when '</ming>'   then out('</seg>')
  when /^<mj/      then start_inline_mj(tag)
  when '<no_chg>'  then out('<term cb:behaviour="no-norm">')
  when '</no_chg>' then out('</term>')
  when '<nosp>'    then start_inline_space(tag)
  when /^　/       then start_inline_space(tag)
  when /^<n/       then start_inline_n(tag)
  when '</n>'      then close_n(tag)
  when '<o>'       then start_inline_o(tag)
  when '</o>'      then close_div_by_type('orig')
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
  when '<S>' then start_inline_S(tag)
  when /<S,/ then start_inline_S(tag)
  when '</S>'
		$normal_lg = false
		close_tags('lg')
  when '<sd>'
    out('<term xml:lang="sa-Sidd">')
    $opens['term'] = 1
  when '</sd>' then close_tags('term')
  when '<space quantity="0"/>' then out2(tag)
  when '<sub>'  then out('<hi style="vertical-align:sub">')
  when '</sub>' then out2("</hi>")
  when '<sup>'  then out('<hi style="vertical-align:super">')
  when '</sup>' then out2("</hi>")
  when /<trans-mark/ then start_trans_mark(tag)
  when /^<T/         then start_inline_T(tag)
  when '</T>' || '</TL>' 
    $TL_count = 0
    close_tags('l', 'lg')
  when '<u>'         then start_inline_u(tag)
  when '</u>'        then close_div_by_type('commentary')
  when /^<w>/ then start_inline_w(tag)
  when /^<a>/ then start_inline_a(tag)
  when '</w>' then close_tags('p','sp','cb:dialog')
  when /^<z/  then start_inline_p(tag)	# 和 <p 一樣的處理法    
  when '</z>' then close_tags('p')
  when /&((SD)|(RJ))\-\w{4};/	then start_inline_SDRJ(tag) # 悉曇字或蘭札字
  when '&' then out2("&")
  else
    puts "#{$old_pb}#{$line_num} 未處理的標記: '#{tag}'"
  end
end

def close_div_by_type(type)
  close_tags('byline','p')
  out1('</cb:div>')
  $opens['div'] -= 1
  $opens[type] -= 1
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

def gaiji(zuzi)
  $log.puts "gaiji() #{zuzi}"
  return zuzi if zuzi=='[＊]'
  return zuzi if zuzi.match?(/\[\d+\]/)
  
  if $des2cb.key?(zuzi)
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
def do_tag_s(text)
  text.gsub!(/(<S>.*)　　/, '\1</l><l>')
  text.gsub!(/(<S>.*)　/, '\1<l>')
  text << "</l>\n" if text.match?(/<S>/)
end
  
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

  s.scan(regexp) do |t|      
    if t.match?(/[<\(\)\[&　]/)
      inline_tag(t) 
    else
      do_chars(t)
    end
  end
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

# J01nA042_p0793a14_##<Q2 m=哲宗><annals><date><p>哲宗皇帝元祐四年[已>己]巳
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
  close_tags('date', 'p', 'cb:event')
  out('<cb:event>')
  $opens['cb:event'] = 1
end

def start_inline_date(tag)
  out('<date>')
  $opens['date'] = 1
end

# 參考 <annals> 標記, 此標記是用來結束 <date> 用的
def start_inline_event(tag)
  close_tags('p', 'date')
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
  when '<A>' then "author"
  when '<B>' then "other"
  when '<C>' then "collector"
  when '<E>' then "editor"
  when '<Y>' then "translator"
  end

  out %(<byline cb:type="#{type}">)
  $opens['byline'] = 1
end

def start_S(tag)
  if $opens['lg'] == 0
    close_tags('cb:jhead', 'cb:juan', 'byline', 'p')
    close_head
    $lg_marginleft = 1
    out %(<lg xml:id="lg#{$vol}p#{$old_pb}#{$line_num}01">)
    $opens['lg'] = 1
    $normal_lg = true
  end
  close_tags('l')
end

def start_s(tag)
  $opens['lg'] = 0
end

def start_x(tag)
  start_div(1, 'xu')
  $buf << '<head>'
  $opens['head'] = 1
  $mulu_start = True
  $head_start = True
  $div_head = ''
end

# 計算一行有多少 <c> 標記
# <c> 算 1 個
# <c3> 算 3 個
# <c4 r3> 算 4 個
# <c r3> 算 1 個
def count_c_from_line(text)
  # 算有多少個 <c> 或 <c r3>
  r = text.scan(/<c[\s>]/).size
  
  # 算有多少個 <c3> 或 <c3 r3>
  text.scan(/<c(\d+)/) do 
    r += $1.to_i
  end

  r
end  

# 處理表格 F 表格開始
def start_F(tag, text)
  close_tags('byline','p')
  # 計算一行有多少個 c 標記
  i = count_c_from_line(text)
  out %(<table cols="#{i}"><row>)
  $opens['table'] += 1
  $opens['row'] += 1
end

# 處理表格 f 表示 <row> 的範圍
def start_f(tag)
  close_tags('p', 'cell', 'row')
  out('<row>')
  $opens['row'] += 1
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
  when /F/ then start_F(tag, text)
  when /f/ then start_f(tag)
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
    tag.gsub!(/[#_k\d]/, '')
    unless tag.empty?
      puts "#{$old_pb}#{$line_num} 未處理的行首標記: '#{tag}'"
    end
  end
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
  if $head_start and not $head_tag.match?(/Q\d?=/) and not text.match?(/<Q\d?=/)
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
  
  # 因為 S 標記會把空格處理成 <l></l>, text 內容 會被變更
  do_line_head($head_tag, text)	

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
    if text.end_with?("</S>")
      text[-4..] = "</l></S>"
    else
      text << "</l>"
    end
    # 把 </Qx> 移到後面, 例: 	B10n0068_p0839b03s##　能令清淨諸儀軌　　如智者論顯了說</Q1>
    text.sub!(/(<\/Q\d*>)(<\/l><\/S>)$/, '\2\1')
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
      
  '''
  把這種
  T04n0213_p0794a23D##[>法集要頌經樂品第三十]<S>　[06]忍勝則怨賊，　　自負則自鄙，
  把 <S> 後面的空格換成 <l></l>
  '''
  #do_tag_s(text)
  
  do_text(text)
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

  $unicode2cb = {}
  $all_gaijis.each do |cb, v|
    des = v['composition']
    if not des.nil? and not des.empty?
      $des2cb[des] = cb
    end

    uni = v['unicode']
    if not uni.nil? and not uni.empty?
      $unicode2cb[uni] = cb
    end
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
  $unicode2cb = {}
  $line_num = ''
  $opens = Hash.new(0)	# 記錄每一個標記的層次, 預設值為 0
  $opens['div'] = 0
  $old_pb = ''
  $sutras = {}
  $l_type = ""		# 記錄 <L> 的type , 若是 <L_sp> 則 L_type="simple"
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