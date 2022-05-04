require 'nokogiri'
require 'set'
require_relative 'p5-node'

class P5aToP5Converter
  OPTION = {
    p5b_format: false
  }

  attr_reader :root

  def initialize(args={})
    @config = OPTION.merge args
    @log = args[:log]
    read_all_gaijis
    @unihan = Unihan2.new
    @resp_id = {}
    @p5b_format = args[:p5b_format]
  end

  def convert(xml_file, wit)
    @xml_file = xml_file
    @file_id = File.basename(xml_file, '.*')  #  file_id = N10n0003
    @wit = wit

    doc = File.open(xml_file) { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!

    @root = doc.root
    @back_notes = Hash.new('')
    @back = { app: '', tt: '', equivalent: '' }
    @anchors = []
    @counter = Hash.new(0)
    @gaijis = Set.new

    # 大部份經文的星號都在 app 標記處理, 南傳 note 有星號沒 app, 
    # 這是用來記錄哪些 note 有哪些 star
    # note_star['#nkr_note_orig_0228007'] = ' #note_star_1 #note_star_5 #note_star_12'
    @note_star = {}

    # P5b 不用轉成 #wit #resp 代碼
    unless @config[:p5b_format]
      read_all_resp
      read_all_wit
    end

    text = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" xml:id="#{@file_id}">
    XML

    # mode = body , 表示處理的都在 body 區, 
    # 若遇到校勘, mode 換成 back , 表示接下來的資料都是在 back 區的
    text += traverse(@root, Set.new([:body]))
    text += '</TEI>'

    char_decl = prepare_char_decl(@gaijis)
    text.sub!('<charDecl></charDecl>', char_decl)
    text
  end

  def traverse(e, mode)
    return '' if e.nil?

    @counter[:traverse] += 1

    r = ''
    e.children.each do |c| 
      s = handle_node(c, mode)
      puts "handle_node return nil, node: " + c.to_s if s.nil?
      r += s
    end

    @counter[:traverse] -= 1
    r
  end

  private

  # lem 及 rdg 最多只有 【CBETA】【CB】【大】 , 沒有其他的版本, 就是 choice 
  # lem 或 rdg 有出現  【CBETA】【CB】【大】之外其他的版本, 就是 app
  # 以上是針對大正藏, 若是嘉興, 就是把【大】換成【嘉興】, 其餘類推. '''
  def app_new_type(e)
    wits=''
    e.children.each do |c| 
      wits += c['wit'] if c.key?('wit')
    end

    wits.gsub!('【CBETA】','')
    wits.gsub!('【CB】','')  
    wits.gsub!(@wit, '')

    return 'choice' if wits.empty?

    'app'
  end

  def back_div(k, type, head)
    # 要處理可能有星號的 note
    content = handle_back_note_star(@back_notes[k], @note_star)

    <<~XML
      <cb:div type="#{type}">
      <head>#{head}</head>
      <p>
      #{content}</p>
      </cb:div>
    XML
  end

  def cbdia(s)
    r = s.clone
    r.gsub!('ā', 'aa')
    r.gsub!('ī', 'ii')
    r.gsub!('ū', 'uu')
    r.gsub!('ñ', '~n')
    r.gsub!('ś', '`s')
    r.gsub!('ḍ', '.d')
    r.gsub!('ḥ', '.h')
    r.gsub!('ḹ', '.ll')
    r.gsub!('ḷ', '.l')
    r.gsub!('ṃ', '.m')
    r.gsub!('ṅ', '^n')
    r.gsub!('ṇ', '.n')
    r.gsub!('ṝ', '.rr')
    r.gsub!('ṛ', '.r')
    r.gsub!('ṣ', '.s')
    r.gsub!('ṭ', '.t')
    r
  end

  def change_mode(mode, m1, m2)
    new_mode = mode.clone
    new_mode.delete(m1)
    new_mode << m2
    new_mode
  end

  # convert p5a element to p5
  def convert_e(e, mode, args={})
    opts = { copy_attributes: true }
    opts.merge! args

    if opts[:copy_attributes]
      node = p5_node(e)
    else
      node = p5_node
      node.tag = e.name
    end

    node.content = traverse(e, mode)
    yield node if block_given?
    node.to_s
  end

  def e_anchor(e, mode)
    convert_e(e, mode) do |e2|
      e2['type'] = 'circle' if e['type'] == '◎'
      if mode.include?(:back) and e.key?('id')
        e2['id'] += '_back' # xml:id 的尾部加上 '_back', 以資區別
      end
    end
  end

  def e_annals(e, mode)
    r = '<cb:event>'
    d = e.at_xpath('date')
    r += '<date/>' if d.nil?
      
    new_mode = mode.clone
    new_mode << :event
    r += traverse(e, new_mode)
    r + '</cb:event>'
  end

  def e_app(e, mode)
    @log.puts "handle_app mode: #{mode}, n: #{e['n']}"
    
    # P5b 不把 app 放在 back 區了
    if @p5b_format
      node = p5_node(e)
      node.content = traverse(e, mode)
      return node.to_s
    end

    r = ''
    type = e['type']
    if mode.include?(:body)
      n = e['n']
      return e_app_star(e, mode) if type=='star'
      abort e.to_s if type == '◎'
      return e_app_nor(e, mode) if e.key?('n')
      return e_app_cb(e, mode)
    end

    if mode.include?(:back)
      return e_app_star(e, mode) if type == '＊'
      new_type = app_new_type(e)
      if new_type == 'choice'
        node = p5_node(e)
        node.tag = 'choice'
        new_mode = mode.clone
        new_mode << :choice
        node.content = traverse(e, new_mode)
        return node.to_s
      else
        node = p5_node(e)
        node.content = traverse(e, mode)
        return node.to_s
      end
    end

    return ''
  end

  def e_app_cb(e, mode)
    new_type = app_new_type(e)
    id = new_anchor_id
    r = %(<anchor xml:id="beg_#{id}" type="cb-app"/>)
    lem = e.at_xpath('lem')
    r += traverse(lem, mode)
    r += %(<anchor xml:id="end_#{id}"/>)

    if new_type == 'choice'
      new_mode = change_mode(mode, :body, :back)
      new_mode << :choice

      s = convert_e(e, new_mode) do |e2|
        e2.tag = 'choice'
        e2['cb:from'] = "#beg_#{id}"
        e2['cb:to'] = "#end_#{id}"
        e2['resp'] = lem['resp'] if lem.key?('resp')
      end

      @back[:app] += s + "\n"
      return r
    end

    new_mode = change_mode(mode, :body, :back)
    s = convert_e(e, new_mode) do |e2|
      e2['from'] = "#beg_#{id}"
      e2['to'] = "#end_#{id}"
    end
    @back[:app] += s + "\n"

    return r
  end

  def e_app_nor(e, mode)
    @log.puts 'handle_app_nor'
    n = e['n']
    abort e.to_s if n.nil?

    target = "beg#{n}"
    r = ''

    # 新的 2014/03/20
    end_str = ''
    unless @anchors.include?(target)
      @anchors << target
      r += %(<anchor xml:id="#{target}" n="#{n}"/>)
      id = "end#{n}"
      @anchors << id
      end_str = %(<anchor xml:id="#{id}"/>)
    end

    r += traverse(e, mode)
    r += end_str
    
    new_mode = change_mode(mode, :body, :back)
    s = convert_e(e, new_mode) do |e2|
      e2['from'] = "#beg#{n}"
      e2['to'] = "#end#{n}"
      e2.delete('n')
    end

    @back[:app] += s + "\n"

    return r
  end

  def e_app_star(e, mode)
    if mode.include?(:body)
      id = new_anchor_id
      r = %(<anchor xml:id="beg_#{id}" type="star"/>)
      r += traverse(e, mode)
      r += %(<anchor xml:id="end_#{id}"/>)

      new_mode = change_mode(mode, :body, :back)
      s = convert_e(e, new_mode) do |e2|
        e2['from'] = "#beg_#{id}"
        e2['to']   = "#end_#{id}"

        # corresp 順序 放在最後
        e2.delete('corresp')
        e2['corresp'] = e['corresp']
  
        e2.delete('type')
      end

      @back[:app] += s + "\n"

      return r
    end

    convert_e(e, mode) do |e2|
      e2['type'] = 'star'
    end
  end

  def e_byline(e, mode)
    node = p5_node(e)

    # T19n0945: type="Oral translator" => type="Oral_translator"
    if e.key?('type')
      node['type'] = e['type'].gsub(' ', '_')
    end

    node.content = traverse(e, mode)
    node.to_s
  end

  def e_choice(e, mode)
    # P5b 不把 choice 放在 back 區了
    if @p5b_format
      node = p5_node(e)
      node.content = traverse(e, mode)
      return node.to_s
    end
    
    if mode.include?(:body)
      r = e_choice_body(e, mode)
    else
      node = p5_node(e)
      node.content = traverse(e, mode)
      r = node.to_s
    end

    return r
  end

  def e_choice_body(e, mode)
    id = new_anchor_id
    r = %(<anchor xml:id="beg_#{id}" type="cb-app"/>)

    corr = e.at_xpath('corr')
    if corr.nil?
      reg = e.at_xpath('reg')
      r += traverse(reg, mode)
    else
      r += traverse(corr, mode)
    end
    r += %(<anchor xml:id="end_#{id}"/>)
    
    node = p5_node(e)
    node['cb:from'] = "#beg_#{id}"
    node['cb:to'] = "#end_#{id}"
    unless corr.nil
      node['resp'] = corr['resp'] if corr.key?('resp')
    end

    if e.key?('type')
      node['cb:type'] = e['type']
      node.attributes.delete('type')
    end

    new_mode = change_mode(mode, :body, :back)
    new_mode << :choice
    node.content = traverse(e, new_mode)
    @back[:app] += node.to_s + "\n"
    r
  end

  def e_div(e, mode)
    node = p5_node(e)
    node.tag='cb:div'
    node.content = traverse(e, mode)
    node.to_s
  end

  def e_edition(e, mode)
    r = convert_e(e, mode) do |e2|
      # 把 XML TEI P5a 換成 XML TEI P5
      if @p5b_format
        e2.content.sub!("XML TEI P5a", "XML TEI P5b")
      else
        e2.content.sub!("XML TEI P5a", "XML TEI P5")
      end
    end

    @resp_id.each do |k, v|
      r += %(\n\t\t\t<respStmt xml:id="#{v}"><resp>corrections</resp><name>#{k}</name></respStmt>)
    end

    r
  end

  def e_encoding_desc(e, mode)
    convert_e(e, mode) do |e2|
      e2.content += "<charDecl></charDecl>\t"
    end
  end

  def e_event(e, mode)
    return traverse(e, mode) if mode.include?(:event)
    convert_e(e, mode)
  end

  def e_foreign(e, mode)
    return convert_e(e, mode) unless e['place'] == 'foot'

    n = e['n']
    # 原本為 'beg' , 改成 'nkr_note_foreign_' 2014/03/20
    target = "nkr_note_foreign_#{n}"

    back = %(<note target="##{target}">)
    new_mode = change_mode(mode, :body, :back)
    back += convert_e(e, new_mode)
    back += "</note>\n"
    @back_notes['rest'] += back

    return '' if @anchors.include?(target)

    @anchors << target
    return %(<anchor xml:id="#{target}" n="#{n}"/>)
  end

  def e_g(e, mode)
    id = e['ref'].sub(/^#/, '')
    g = @all_gaijis[id]
    abort "缺字資料不存在: #{id}" if g.nil?

    # 要判斷是不是有 unicode 1.0 的缺字
    if id.start_with?('CB')
      if g.include?('unicode')
        code = g['unicode']
        return g['uni_char'] if @unihan.ver(code) <= 2.0

        @gaijis << id
        node = p5_node(e)
        return node.open_tag[0..-2] + "/>" if @p5b_format

        node.content = g['uni_char']
        return node.to_s
      end
    end

    @gaijis << id
    node = p5_node(e)
    return node.open_tag[0..-2] + "/>" if @p5b_format

    codepoint = g['pua'].sub(/^U\+/, '').hex
    node.content = [codepoint].pack("U")
    node.to_s
  end

  def e_head(e, mode)
    convert_e(e, mode) do |e2|
      e2.tag = 'cb:jhead' if e.parent.name == 'juan'
    end
  end

  def e_item(e, mode)
    return convert_e(e, mode) unless mode.include?(:back)

    convert_e(e, mode) do |e2|
      e2.delete('id')
      e2.delete('xml:id')
    end
  end

  def e_label(e, mode)
    convert_e(e, mode) do |e2|
      e2.tag = 'head' if e.parent.name == 'lg'
    end
  end

  def e_lb(e, mode)
    n = e['n']
    @log.puts "lb #{n}"

    ed = e['ed']

    convert_e(e, mode) do |e2|
      if ed.include?('C ')
        e2['type'] = 'honorific'
        e2['ed'] = ed.replace('C ', '')
      end
    end
  end

  def e_lem(e, mode)
    @log.puts "handle_lem mode: #{mode}"

    # P5b 不把 lem 放在 back 區了
    return convert_e(e, mode) if @p5b_format

    if mode.include?(:choice)
      return convert_e(e, mode, copy_attributes: false) do |e2|
        e2.tag = 'corr'
      end
    end

    return traverse(e, mode) if mode.include?(:body)

    if mode.include?(:back)
      return convert_e(e, mode)
    end

    ''
  end

  def e_lg(e, mode)
    return convert_e(e, mode) if mode.include?(:body)

    convert_e(e, mode) do |e2|
      e2.delete('id')
    end
  end

  def e_list_wit(e, mode)
    # p5b 用一般的方法處理即可
    return convert_e(e, mode) if @p5b_format
      
    node = p5_node(e)
    r = node.open_tag + "\n"
    unless @wit_id.empty?
      wits = @wit_id.sort_by { |_k, v| v }
      wits.each do |k, v|
        r += %(\t\t\t\t\t\t<witness xml:id="#{v}">#{k}</witness>\n)
      end
    end
    r += "\t" * 5
    r += node.end_tag
    r
  end

  def e_note(e, mode)
    # P5b 不把 note 放在 back 區了
    return convert_e(e, mode) if @p5b_format

    return convert_e(e, mode) unless mode.include?(:body)
    
    type = e['type']
    return '' if %w[cf1 cf2 cf3 cf4 cf5 cf6 cf7 cf8 cf9].include?(type)

    n = e['n']
    if not n.nil? and not n.empty?
      return e_note_with_n(e, mode)
    end

    if e.key?('resp') and not e['resp'].empty?
      if e['resp'].start_with?('CBETA')
        id = new_anchor_id
        target = "nkr_#{id}"        
        e_note_back(e, 'CBETA', target, mode)
        return %(<anchor xml:id="#{target}"/>)
      else
        abort "error #{__LINE__}"
      end
    end

    if type == 'star'
      # P5a <note type="star" corresp="#0228007"/> 南傳特有的, 有星號的校勘, 但沒有 app 
      # p5 要做成 <anchor xml:id="note_star_1" type="star"/>
      # 並在 back 區做成 <note n="0228007" resp="#respx" type="orig" place="foot text" target="#nkr_note_orig_0228007 #note_star_1">....</note>
      corresp = e['corresp'] || ''
      new_n = corresp.sub(/^#/, '')
      corresp = "#nkr_note_orig_#{new_n}"
      id = new_anchor_id
      target = "note_star_#{id}"

      # 此時已做出經文區的 <anchor xml:id="note_star_1" n="0228007" type="star"/>
      r = %(<anchor xml:id="#{target}" n="#{new_n}" type="star"/>)

      if @note_star.include?(corresp)
        # 此時要在 note_star[#nkr_note_orig_0228007] 加上 "#note_star_1"
        @note_star[corresp] += " ##{target}"
      else
        @note_star[corresp] = " ##{target}"
      end

      return r
    end
      
    return convert_e(e, mode)
  end

  def e_note_back(e, type, target, mode)      
    # mode 換成 back , 表示接下來的資料都是在 back 區的, 不是在 body 區的
    new_mode = change_mode(mode, :body, :back)

    # 加入 note 判斷, 如 p 在 back 中, 且在 note 中, 就可以呈現, 
    # 但若只在 back 中就不可呈現 (例如在 app 中)  -- 2013/09/29
    new_mode << 'note'

    back = convert_e(e, new_mode) do |e2|
      # type="orig jie" 轉為 type="orig_jie"
      e2['type'] = e['type'].gsub(' ', '_') if e.key?('type')
      e2['target'] = "##{target}"
    end

    back += "\n"
    @log.puts "#{__LINE__} back: #{back}"
    @back_notes[type] += back
  end

  def e_note_with_n(e, mode)
    type = e['type']
    resp = e['resp']
    n    = e['n']

    # <note> 的 n 屬性相同, 但位置可能不同.
    # T02, n0125
    # <note n="0613019" resp="Taisho" place="foot text" type="orig">木蜜＝木櫁【元】【明】＊</note>「木<note n="0613019" resp="CBETA" type="mod">蜜＝櫁【元】【明】＊</note>
    target = "nkr_note_#{type}_#{n}"

    r = ''
    unless @anchors.include?(target)
      @anchors << target
      r = %(<anchor xml:id="#{target}" n="#{n}"/>)
    end

    case type
    when 'equivalent'
      e_note_back(e, type, target, mode)
    when 'rest', 'cf.'
      e_note_back(e, 'rest', target, mode)
    when 'add'
      e_note_back(e, type, target, mode)
    else
      if resp.empty?
        puts "error #{__LINE__}"
      else
        e_note_back(e, resp, target, mode) 
      end
    end

    return r
  end

  def e_p(e, mode)
    parent = e.parent

    if mode.include?(:event)
      if parent.name == 'date'
        return traverse(e, mode)
      else
        return convert_e(e, mode)
      end
    end

    convert_e(e, mode) do |e2|
      if e.key?('id')
        e2['xml:id'] = e['id']
        e2.delete('id')
      end
      if e.key?('rend') # 為了讓 rend 屬性出現在 xml:id 之後
        e2.delete('rend')
        e2['rend'] = e['rend']
      end
      if e.key?('style')
        e2.delete('style')
        e2['style'] = e['style']
      end
      if e.key?('place')
        e2['cb:place'] = e['place']
        e2.delete('place')
      end
      unless mode.include?(:body)
        e2.delete('id')
        e2.delete('xml:id')
      end
    end      
  end

  def e_pb(e, mode)
    return '' unless mode.include?(:body)
    convert_e(e, mode)
  end

  def e_publication_stmt(e, mode)
    # 此日期由 git 取出 p5a 最後提交的日期
    # git log -1 --pretty=format:"%ai" file.xml
    git_date = git_update_date(@xml_file)

    convert_e(e, mode) do |e2|
      # 加上日期 <data>....</date>
      e2.content += "\t<date>#{git_date}</date>\n\t\t"
    end
  end

  def e_rdg(e, mode)
    @log.puts "e_rdg mode: #{mode}, wit: #{e['wit']}"

    r = ''
    # P5b 不把 rdg 放在 back 區了
    return convert_e(e, mode) if @p5b_format

    if mode.include?(:choice)
      if mode.include?(:back)
        return convert_e(e, mode, copy_attributes: false) do |e2|
          e2.tag = 'sic'
        end
      else
        return ''
      end
    end

    return '' unless mode.include?(:back)

    convert_e(e, mode) do |e2|
      e2.delete('cf1')
      e2.delete('cf2')
      %w[cf1 cf2].each do |cf|
        if e.key?(cf)
          e2.content += %(<note type="#{cf}">#{e[cf]}</note>)
        end
      end
    end
  end

  def e_ref(e, mode)
    convert_e(e, mode) do |e2|
      if e.key?('target')
        t = e['target']
        if not t.start_with?('..') and not t.start_with?('#')
          e2['target'] = "##{t}"
        end
      end
    end
  end

  def e_sic(e, mode)
    # P5b 不把 choice 放在 back 區了
    return convert_e(e, mode) if @p5b_format

    return '' unless mode.include(:back)
    convert_e(e, mode)
  end
  
  def e_sup(e, mode)
    r = '<formula rend="vertical-align:super">'
    r += traverse(e, mode) + '</formula>'
    r
  end

  def e_t(e, mode)
    # P5b 不把 t 放在 back 區了
    return convert_e(e, mode) if @p5b_format

    tt = e.parent
    tt_type = tt['type']

    if mode.include?(:body)
      return '' if e['place'] == 'foot'
      if tt_type == 'app'
        return traverse(e, mode)
      else
        return convert_e(e, mode)
      end
    end

    r = ''
    r += "\t" if tt_type == 'app'
    r += convert_e(e, mode) + "\n"
    r
  end

  def e_table(e, mode)
    convert_e(e, mode) do |e2|
      if e.key?('border')
        e2['rend'] = "border:#{e['border']}"
        e2.delete('border')
      end

      if @p5b_format  # P5b 才要改的
        # 把 </row>....<row><cell> 改成 </row><row><cell>....
        e2.content.gsub!(/(<\/row>)(.*?)(<row[^>]*><cell[^>]*>)/m, '\1\3\2')
      end
    end
  end

  def e_text(e, mode)
    convert_e(e, mode) do |e2|
      # p5b 不用處理 back
      e2.content += handle_back unless @p5b_format
    end
  end

  def e_tt(e, mode)
    # P5b 不把 tt 放在 back 區了
    return convert_e(e, mode) if @p5b_format

    unless mode.include?(:body)
      return convert_e(e, mode) do |e2|
        e2.delete('n')
      end
    end

    return convert_e(e, mode) unless e['type'] == 'app'

    n = e['n']
    id = "beg#{n}"
    if @anchors.include?(id)
      r = ''
      end_str = ''
    else
      @anchors << id
      r = %(<anchor xml:id="#{id}" n="#{n}"/>)
      id = "end#{n}"
      @anchors << id
      end_str = %(<anchor xml:id="#{id}"/>)
    end

    r += traverse(e, mode) + end_str
    
    new_mode = change_mode(mode, :body, :back)
    s = convert_e(e, new_mode) do |e2|
      e2.delete('n')
      e2['from'] = "#beg#{n}"
      e2['to'] = "#end#{n}"
      e2.content = "\n" + e2.content
    end
    @back[:tt] += s + "\n"

    return r
  end

  # 2022-04-13 Ray: 查 p5a 似乎未用到 xref 標記
  def e_xref(e, mode)
    doc = e['doc']
    vol = doc[0, 3]

    convert_e(e, mode) do |e2|
      e2.tag = 'ref'
      e2['target'] = "../#{vol}/#{doc}.xml#xpath2(//#{e['loc']})"
      e2.delete('doc')
      e2.delete('loc')
    end
  end

  # 處理缺字資料
  def get_gaiji_info(cb)
    cb.match(/^(SD|RJ)\-/) do
      info = @cbeta_sanskrit[cb]
      r = {}
      r['big5'] = info['symbol'] if info.key?('symbol')
      
      romanized = info['romanized'] 
      unless romanized.nil?
        r['udia'] = romanized
        r['cbdia'] = cbdia(romanized)
      end
      k = cb[0, 2].downcase + 'char'
      r[k] = info['char']

      r['pua'] = info['pua']
      return r
    end

    @all_gaijis[cb]
  end

  #處理最後的 back 區資料
  def handle_back
    r = "\n<back>\n"

    unless @back[:app].empty?
      r += <<~XML
        <cb:div type="apparatus">
        <head>校注</head>
        <p>
        #{@back[:app]}</p>
        </cb:div>
      XML
    end
      
    unless @back[:tt].empty?
      r += <<~XML
        <cb:div type="tt">
        <head>多語詞條對照</head>
        <p>
        #{@back[:tt]}</p>
        </cb:div>
      XML
    end
      
    @back_notes.sort.each do |k, v|
      next if k=='rest' and v.empty?
      r += case k
      when 'add'    then back_div(k, "add-notes", "新增校注")
      when 'BuBian' then back_div(k, "bubian-notes", "大藏經補編 校注")
      when 'CBETA'  then back_div(k, "cbeta-notes", "CBETA 校注")
      when 'Daoan'  then back_div(k, "daoan-notes", "道安長老全集 校注")
      when 'DILA'   then back_div(k, "dila-notes", "法鼓文理學院 校注")
      when 'Dudoucheng' then back_div(k, "dudoucheng-notes", "正史佛教資料類編 校注")
      when 'Huimin'   then back_div(k, "huimin-notes", "惠敏法師著作集 校注")
      when 'ihp'      then back_div(k, "ihp-notes", "中央研究院歷史語言研究所 校注")
      when 'LüCheng'  then back_div(k, "lüCheng-notes", "呂澂佛學著作集 校注")
      when 'NanChuan' then back_div(k, "nanchuan-notes", "漢譯南傳大藏經 校注")
      when 'NCLRareBook' then back_div(k, "ncl-notes", "國家圖書館善本佛典 校注")
      when 'Taisho'      then back_div(k, "taisho-notes", "大正藏 校注")
      when 'TaiXu'      then back_div(k, "taixu-notes", "太虛大師全書 校注")
      when 'Xuzangjing'  then back_div(k, "xuzang-notes", "卍續藏 校注")
      when 'Yonglebei'   then back_div(k, "yongle-notes", "永樂北藏 校注")
      when 'ZangWai'     then back_div(k, "zangwai-notes", "方廣錩 校注")
      when 'Zhiyu'       then back_div(k, "zhiyu-notes", "智諭法師全集 校注")
      when '釋印順'      then back_div(k, "yinshun-notes", "印順法師全集 校注")
      when '正聞出版社'  then back_div(k, "zhengwen-notes", "正聞出版社 校注")
      when 'equivalent'  then back_div(k, "equiv-notes", "相對應巴利文書名")
      when 'rest'        then back_div(k, "rest-notes", "其他校注")
      else
        abort "Error 未知的 back note type: '#{k}', 程式: #{__FILE__}, 行號: #{__LINE__}"
      end
    end
      
    r += '</back>'
    return r
  end

  # 處理南傳校勘星號的問題.
  # 如果有這種資料 note_star['#nkr_note_orig_0228007'] = ' #note_star_1 #note_star_5 #note_star_12'
  # 則要把 back 區的校勘 note
  # <note n="0228007" resp="#respx" type="orig" place="foot text" target="#nkr_note_orig_0228007">........</note>
  # 變成
  # <note n="0228007" resp="#respx" type="orig" place="foot text" target="#nkr_note_orig_0228007 #note_star_1 #note_star_5 #note_star_12">........</note>
  def handle_back_note_star(text, note_star)
    note_star.keys.sort.each do |k|
      key = %(target="#{k}")
      value = %(target="#{k}#{note_star[k]}")
      text.gsub!(key, value)
    end
    text
  end
  
  def handle_node(e, mode)
    return e.to_s if e.comment?
    return handle_text(e, mode) if e.text?

    r = case e.name
    when 'anchor' then e_anchor(e, mode)  
    when 'annals' then e_annals(e, mode)
    when 'app'    then e_app(e, mode)
    when 'byline' then e_byline(e, mode)
    when 'choice' then e_choice(e, mode)
    when 'div'    then convert_e(e, mode)
    when 'docNumber'    then convert_e(e, mode)
    when 'edition'      then e_edition(e, mode)
    when 'encodingDesc' then e_encoding_desc(e, mode)
    when 'event'   then e_event(e, mode)
    when 'foreign' then e_foreign(e, mode)
    when 'g'       then e_g(e, mode)
    when 'head'    then e_head(e, mode)
    when 'item'    then e_item(e, mode)
    when 'label'   then e_label(e, mode)
    when 'lb'      then e_lb(e, mode)      
    when 'lem'     then e_lem(e, mode)
    when 'lg'      then e_lg(e, mode)
    when 'list'    then convert_e(e, mode)
    when 'listWit' then e_list_wit(e, mode)
    when 'note'    then e_note(e, mode)
    when 'p'       then e_p(e, mode)
    when 'pb'      then e_pb(e, mode)
    when 'publicationStmt' then e_publication_stmt(e, mode)
    when 'rdg' then e_rdg(e, mode)
    when 'ref' then e_ref(e, mode)
    when 'sic' then e_sic(e, mode)
    when 'sup' then e_sup(e, mode)
    when 't'   then e_t(e, mode)
    when 'table' then e_table(e, mode)
    when 'text'  then e_text(e, mode)
    when 'todo'  then "<!--CBETA todo type: #{e['type']}-->"
    when 'tt'    then e_tt(e, mode)
    when 'xref'  then e_xref(e, mode)
    else
      convert_e(e, mode)
    end

    return r
  end

  def handle_text(e, mode)
    return '' if e.nil?

    text = e.content
    text.gsub!("\n", '') if mode.include?(:back)
    text.gsub!('&', '&amp;')
    text.gsub!('<', '&lt;')

    r = ''
    i = 0
    # unicode 1.0 以外的字就使用 <g> 標記
    text.each_codepoint do |code|
      c = text[i]
      if @unihan.ver(code) > 2.0
        if code == 0x227  # 特例 ȧ
          r += c
        else
          hex = '%X' % code
          cb = @unicode2cb[hex]
          if @p5b_format
            # P5b 版不可以有 unicode 太高的字, 以免 Mac 版 CBR 無法處理
            r += %(<g ref="##{cb}"/>)
          else
            r += %(<g ref="##{cb}">#{c}</g>)
          end
          @gaijis << cb
        end
      else
        r += c
      end
      i += 1
    end
    return r
  end

  # 取得一個新的 id , 主要是在星號校勘要提供不重複的代號
  def new_anchor_id
    @counter[:anchor] += 1
    '%x' % @counter[:anchor]
  end

  def p5_node(e=nil, args={})
    opts = {
      resp_id: @resp_id,
      p5b_format: @p5b_format,
      wit_id: @wit_id
    }
    opts.merge! args
    P5Node.new(e, opts)
  end

  def prepare_char_decl(gaijis)
    r = ''

    @gaijis.to_a.sort.each do |cb|
      r += prepare_char_decl_char(cb)
    end

    return '' if r.empty?

    "\t<charDecl>\n#{r}\t\t</charDecl>\n"
  end

  def prepare_char_decl_char(cb)
    r = %(\t\t\t<char xml:id="#{cb}">\n)
    r += %(\t\t\t\t<charName>CBETA CHARACTER #{cb}</charName>\n)
    h = get_gaiji_info(cb)
    h.sort.each do |k, v|
      next if %w[uni_char unicode moe_variant_id nor_unicode norm_uni_char norm_unicode pua].include?(k)
      r += "\t\t\t\t<charProp>\n"
      r += "\t\t\t\t\t<localName>"
      r += case k
      when 'des'     then 'composition'
      when 'cb'      then 'entity'
      when 'mojikyo' then 'Mojikyo number'
      when 'mofont'  then 'Mojikyo font name'
      when 'mochar'  then 'Mojikyo character value'
      when 'cbdia'   then 'Romanized form in CBETA transcription'
      when 'udia'    then 'Romanized form in Unicode transcription'
      when 'sdchar'  then 'Character in the Siddham font'
      when 'nor', 'norm_big5_char'
        'normalized form'
      when 'composition', 'big5', 'uniflag', 'rjchar'
        k
      else
        abort "error k: #{k}, File: #{__FILE__}, Line: #{__LINE__}"
      end
      r += "</localName>\n"
      r += "\t\t\t\t\t<value>#{v}</value>\n"
      r += "\t\t\t\t</charProp>\n"
    end

    if h.key?('unicode')
      r += %(\t\t\t\t<mapping type="unicode">U+#{h['unicode']}</mapping>\n)
    end

    if h.key?('norm_unicode')
      r += %(\t\t\t\t<mapping type="normal_unicode">U+#{h['norm_unicode']}</mapping>\n)
    end

    pua = h['pua']
    decimal = pua.sub(/^U\+/, '').hex # 十進位
    r += %(\t\t\t\t<mapping cb:dec="#{decimal}" type="PUA">#{pua}</mapping>\n)
    r += "\t\t\t</char>\n"
    r
  end

  def read_all_gaijis
    fn = File.join(@config[:gaiji_base], 'cbeta_gaiji.json')
    @all_gaijis = JSON.load_file(fn)
  
    @unicode2cb = {}
    @all_gaijis.each do |cb, v|
      uni = v['unicode']
      next if uni.nil?
      @unicode2cb[uni] = cb
    end

    fn = File.join(@config[:gaiji_base], 'cbeta_sanskrit.json')
    @cbeta_sanskrit = JSON.load_file(fn)
    @all_gaijis.merge!(@cbeta_sanskrit)
  end
  
  # 讀取所有的 resp 屬性
  def read_all_resp
    @resp_id = {}      # 先清掉舊的記錄, 免得愈累積愈多  --2013/08/13
    i = 1

    @root.traverse do |e|
      next unless e.key?('resp')

      # 將 resp="【甲】【乙】" 這一類的格式插入空格, 【甲】與【乙】才能分離出來 --2013/07/29
      resp = e['resp'].gsub('】【', '】 【')

      resp.split.each do |resp|
        next if @resp_id.key?(resp)
        @resp_id[resp] = "resp#{i}"
        i += 1
      end
    end
  end

  def read_all_wit
    @wit_id = {}      # 先清掉舊的記錄, 免得愈累積愈多  --2013/08/13
  
    # 找尋原書的 wit 和 CBETA 的 wit, 先加到 wit_id 記錄中
    # <witness xml:id="wit.orig">【龍】</witness>
    # <witness xml:id="wit.cbeta">【CB】</witness>
    @root.xpath("./teiHeader/encodingDesc//witness").each do |e|
      @wit_id[e.text] = e['id']
    end
  
    # 判斷預設的版本和 p5a 記錄的版本是否相同
    if @wit_id[@wit] != "wit.orig"
      abort "error #{__LINE__}, default WITS[ed] is not wit.orig: #{@wit}"
    end
  
    i = 1
    @root.traverse do |e|
      next unless e.key?('wit')
      e['wit'].scan(/【.*?】/) do |w|
        next if @wit_id.include?(w)
        @wit_id[w] = "wit#{i}"
        i += 1
      end
    end
  end  
end