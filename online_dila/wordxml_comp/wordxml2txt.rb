require 'nokogiri'
require 'find'
require 'fileutils'

# 設定來源與輸出根目錄
SRC_ROOT = 'd:/Temp/wordxml_xml/'
OUT_ROOT = 'd:/Temp/wordxml_out_txt/'

# 由 sutra_list.txt 讀取經號與目錄的關係
# 其結構為 T01,T0001_001
# 表示經號 T0001_001 在 T01 目錄下
# 可處理為 $Vol = $Sutra2Vol['T0001_001'] , 傳回 'T01'

$Sutra2Vol = {}
def sutra2vol()
  file_path = File.join(File.dirname(__FILE__), 'sutra_list.txt')
  return unless File.exist?(file_path)
  
  File.foreach(file_path) do |line|
    line = line.strip
    next if line.empty?
    
    parts = line.split(/,/)
    if parts.size >= 2
      vol = parts[0].strip
      sutra = parts[1].strip
      $Sutra2Vol[sutra] = vol
    end
  end
end
#sutra2vol()

# 將檔名轉換為 T0001_001.txt 這種樣式
def convert_filename(xml_filename)
  if xml_filename =~ /([A-Z]{1,2})\d{2,3}n(.*?)_(\d{3})\.xml/i
    "#{$1}#{$2}_#{$3}.txt"
  else
    # 如果不符合規則，直接原名改成txt
    File.basename(xml_filename, '.xml') + '.txt'
  end
end

# 把 body 轉成我們要的純文字格式
def body_to_txt(xml, basename)
  body = xml.at_css('body')
  in_table_tt = false
  return [] unless body

  raw_xml = body.inner_html

  # 保留所有 <!-- lb: ??? -->的資訊
  # 我們要把 <footnote>先換成特殊佔位符，最後再插回去
  footnotes = []
  raw_xml = raw_xml.gsub(/<footnote>(.*?)<\/footnote>/m) do
    footnotes << $1
    #"[__FOOTNOTE_#{footnotes.size - 1}__]"
    ""
  end

  
  # lb 之前的左括號，移到下一行
  # (<!-- lb: X18n0332_p0067b20 --> => <!-- lb: X18n0332_p0067b20 -->(
  raw_xml.gsub!(/\((<!\-\- lb[^>]*>)/,'\1(')
  # raw_xml.gsub!(/<p rend="lg_note[12]">(<!\-\- lb[^>]*>)/,'<p>\1(')
  

  # 根據 <!-- lb: xxx --> 分割
  # (允許一行有多個。前一個片段如果沒 lb 標記，補個首段)
  # <!-- lb: T02n0131_p0854b04 -->
  # <!-- lb: T02n0142ap0863c13 -->
  lines = raw_xml.split(/<!--\s*lb:\s*([a-zA-Z\d_]+)\s*-->/)
  # lines 會是: ["<p>首段內容</p>", "0001a01", "<p>有lb內容</p>", "0001a02", ...]
  result = []
  i = 1
  nextline = '' # 梵漢對照時的下一行

  while i < lines.size
    lb = lines[i].strip # T02n0131_p0854b04
    content = lines[i+1].to_s
    # 移除前面的換行及半型空白
    #content.sub!(/\A[\n ]+/, '')
    content.gsub!(/\n +/, "\n")
    # 有梵漢對照就要接起來
    content = nextline + content
    nextline = ""

    # 有些空白要先移除
    #  <item><p>天帝釋問品</p></item>
    content.gsub!(/^\s+<item/, '<item')
    content.gsub!(/^\s+<\/list/, '</list')
    # <graphic url="T/T45p0794_04.gif"/> 轉成【圖】
    if content.include?('<graphic')
      # 處理悉曇字
      # 把這種 <graphic url="sd-gif/D7/SD-D7C4.gif"/> 換成 &SD-D7C4;
      content.gsub!(/<graphic[^>]*(SD\-....)\.gif"\/>/, '&\1;')
      content.gsub!(/<graphic[^>]*(SD\-....)\.gif[^>]*><\/graphic>/, '&\1;')
      # 把這種 <graphic url="T/T45p0794_04.gif"/> 換成【圖】
      #puts "Found graphic in #{basename}p#{lb}#{content}, replacing with 【圖】"
      content.gsub!(/<graphic.*?\/>/, '【圖】')
      content.gsub!(/<graphic.*?<\/graphic>/, '【圖】')
    end

    # 有一種情況，在 row 前有空格，要去除
    if content.include?('<row')
      content.gsub!(/^\s+<row/, '<row') 
    end

    # 20260413 新版悉曇字要移除
    # <!-- lb: T18n0850_p0083b19 -->
    # 一切諸法影像不可得故。<font name="sidd">介</font>(ja)惹字門，一切諸法
    # 一切諸法影像不可得故。ja惹字門，一切諸法
    #if content.include?('<font name="sidd">')
      #puts "Found sidd font in #{basename}p#{lb}#{content}, removing sidd font"
      #content.gsub!(/<font name="sidd">.*?<\/font>\((.*?)\)/, '\1') 
    #end


    # 梵漢對照在行中會有 <lb/> 標記，這種要留下來，暫時換成 [-lb-]
    # 但偈頌的 <lb/> 標記要去掉
    # <p><!-- lb: 0254a29 -->「traḥ　<lb/>怛𠸪</font>(二合)」　</p>

    # if content =~ /(.|\n){2}<lb\/>(.|\n){2}/
    #   #puts "Found lb in #{basename}p#{lb}#{content}, replacing with lb"
    #   content.gsub!(/((?:.|\n){2})<lb\/>((?:.|\n){2})/, '\1【lb】\2') 
    #   #puts "After replacement: #{content}"
    #   #gets
    # end
    # if content =~ /(.|\n){2}<lb><\/lb>(.|\n){2}/
    #   #puts "Found lb in #{basename}p#{lb}#{content}, replacing with lb"
    #   content.gsub!(/((?:.|\n){2})<lb><\/lb>((?:.|\n){2})/, '\1【lb】\2') 
    #   #puts "After replacement: #{content}"
    #   #gets
    # end

    #######################
    # 2026/11/15
    # 2026.R3 開始，梵漢對照在 XML 已經分成二行了，例如：

    # <lb n="0892c01" ed="T"/><p xml:id="pT10p0892c0101" cb:type="dharani"><cb:tt>
    # <cb:ttr>「<cb:t xml:lang="sa-Sidd"><g ref="#SD-A5A9"/></cb:t>
    # ....
    # <lb n="0892c02" ed="T"/><cb:ttr>
    #   <cb:t xml:lang="zh-Hant">曩</cb:t>

    # 但在 word 中，又將它們合併，用 lb 處理，讓梵字在上，漢字在下，然而其實是在同一行
    # <!-- lb: T10n0299_p0892c01 --><table rend="table_tt">
    # <row><cell>「<font name="sidd">巧</font><lb/>
    # (na)<lb/>
    # 曩</cell>

    # 上面那個「曩」是要移到次行

    # 先判斷是不是在 <table rend="table_tt"> 中
    if content.include? "<table"
      if content =~ /<table [^>]*rend=['"]table_tt['"]/
        in_table_tt = true
      else
        in_table_tt = false
      end
    end

    # table_tt 中的 row，cell 內以 <lb/> 分成 梵字 / (羅馬轉寫) / 漢字 三段，
    # 但順序有兩種，每次都把「在後面的那一半」移到次行 (累積到 nextline)：
    #   A. 梵(羅馬) 在前，漢 在後：漢 (最後一段) 移到次行
    #      <cell><font name="sidd">屹</font><lb/>\n(sa)<lb/>\n三</cell>
    #        => <cell><font name="sidd">屹</font><lb/>\n(sa)<lb/></cell>，nextline += "三"
    #   B. 漢 在前，梵(羅馬) 在後：梵(羅馬) (後面二段) 移到次行
    #      <cell>「唵<lb/>\n<font name="sidd">輆</font><lb/>\n(om̐)</cell>
    #        => <cell>「唵<lb/></cell>，nextline += '<font name="sidd">輆</font><lb/>(om̐)'
    # 是否為梵字，由 <font name="sidd"> 或 <font name="rajn"> 判斷
    # 有些 cell 沒有對應的悉曇字，如 <cell><lb/>\n<lb/>\n金剛王</cell>，
    # 光看這個 cell 無法判斷是 A 還是 B，要參考同一個 row 中其它 cell 的型態
    if in_table_tt && content.include?('<cell')
      # <lb/> 與 <lb></lb> 兩種寫法都要處理 (Nokogiri inner_html 會輸出 <lb></lb>)
      lb_re   = /<lb\s*\/>|<lb><\/lb>/
      sidd_re = /<font\s+name=["'](?:sidd|ranj)["']/
      cell_re = /(<cell[^>]*>)(.*?)(<\/cell>)/m

      # 判斷 cell 的型態：:A 梵(羅馬)在前、:B 漢在前、nil 無法判斷
      classify = lambda do |cell|
        segs = cell.split(lb_re, -1)
        if segs.size >= 3 && segs[0] =~ sidd_re
          :A
        elsif segs.size >= 2 && segs[0] !~ sidd_re && segs[1..-1].any? { |s| s =~ sidd_re }
          :B
        end
      end

      # 先掃過整個 row，由有悉曇字的 cell 決定這個 row 的型態
      row_type = nil
      content.scan(cell_re) do |_open, cell, _close|
        row_type ||= classify.call(cell)
      end

      content = content.gsub(cell_re) do
        open_tag, cell, close_tag = $1, $2, $3
        segs = cell.split(lb_re, -1)    # 以 lb 分成的各段文字
        type = classify.call(cell)
        # 沒有悉曇字的 cell (至少 3 段)，依 row 的型態處理
        type ||= row_type if segs.size >= 3 && cell !~ sidd_re
        # 沒有悉曇字、只有二段的 cell，如 <cell><lb/>速速速速</cell>，
        # 不論 row 的型態，都是把最後一段 (最後一個 lb 之後) 移到次行
        type ||= :A if segs.size == 2 && cell !~ sidd_re

        moved = nil
        if type == :A
          # 最後一個 lb 之後是漢
          pos = cell.enum_for(:scan, lb_re).map { Regexp.last_match }.last.end(0)
          moved = cell[pos..-1]
          cell  = cell[0...pos]
        elsif type == :B
          # 第一個 lb 之後是 梵(羅馬)
          pos = lb_re.match(cell).end(0)
          moved = cell[pos..-1]
          cell  = cell[0...pos]
        end
        if moved
          # 要移走的只剩 lb、沒有文字時 (空的梵/羅馬)，cell 維持原樣
          if moved.gsub(lb_re, '').strip.empty?
            cell = cell + moved
          else
            # 搬到次行的內容：只去掉換行，不能動空白 (<font name=...> 裡有空白)
            nextline << moved.gsub(/[\r\n]+/, '').strip
          end
        end
        "#{open_tag}#{cell}#{close_tag}"
      end
    end

    ##########################################
    # 移除所有 HTML 標籤
		text = Nokogiri::HTML.fragment(content).text
		# 移除 footnote 佔位後，合併多餘空白與換行
		# text.gsub!(/\[__FOOTNOTE_(\d+)__\]/) { "[#{$1.to_i + 1}]" }
		# 下面這一行是加的，把多餘的換行、空白都去掉
		text = text.gsub(/[\r\n]+/, '')
    #【經文資訊】之後的文字都忽略
    text = text.gsub(/【經文資訊】.*/, '')

    # 組合處理
    #line_label = "#{basename}p#{lb}"
    line_label = "#{lb}"

    # 取出這一行所屬的冊號(如 X39、T02)，用來判斷跨冊時該寫到哪個目錄
    # 如果 lb 格式有問題、抓不到冊號，仍然寫入檔案(方便比對時發現問題)，
    # 只是歸類到 UNKNOWN 這個冊號目錄下
    vol = lb[/^([A-Za-z]+\d+)n/, 1]
    if vol.nil?
      puts "Warning: 無法從 lb 取得冊號: #{lb.inspect} (basename=#{basename})，歸類到 UNKNOWN"
      vol = 'UNKNOWN'
    end

    # 一個要改的特例
    # T19n0956_p0316a10║「黽(此是梵本一字之呪)(bhrūṃ)
    # 改成
    # T19n0956_p0316a10║「黽(bhrūṃ)(此是梵本一字之呪)
    
    text.sub!('(此是梵本一字之呪)(bhrūṃ)','(bhrūṃ)(此是梵本一字之呪)')

    result << [vol, "#{line_label}║#{text}"]

    i += 2
  end
  
  result
end

# 取得傳入的參數
$argv = ""

if ARGV.size > 0
  $argv = ARGV[0]
end

# 參數是冊 (如 T01) 時，才需要載入 經_卷 與冊的對照表
if $argv =~ /\A[A-Z]{1,2}\d{2,3}\Z/i
  sutra2vol()
  if $Sutra2Vol.empty?
    puts "找不到 sutra_list.txt 或內容是空的，無法依冊處理: #{$argv}"
    exit 1
  end
end

Find.find(SRC_ROOT) do |path|
  next unless File.file?(path)
  next unless path =~ /\.xml$/i



  # 擷取資料夾 T/T01 與檔名 T01n0001_001.xml
  # d:\Temp\wordxml_xml\T\T01\T01n0001\T01n0001_001.xml
  # m = path.match(%r{wordxml_xml/([A-Z]{1,2})/([^/]+)/([^/]+)/(.+\.xml)}i)
  # d:\Temp\wordxml_xml\T\T0001\T0001_001.xml
  m = path.match(%r{wordxml_xml/([A-Z]{1,2})/([^/]+)/(.+\.xml)}i)
  if ARGV.size > 0
    # 如果有參數，則只處理該參數的資料夾
    # 例如：ruby wordxml2txt.rb T0099
    # 會處理 wordxml_xml/T/T01/ 下的所有檔案
    # d:\Temp\wordxml_xml\T\T01\T01n0001\T01n0001_001.xml
    # m = path.match(%r{wordxml_xml/([A-Z]{1,2})/(#{Regexp.escape($argv)})/([^/]+)/(.+\.xml)}i)
    # d:\Temp\wordxml_xml\T\T0001\T0001_001.xml
    # m = path.match(%r{wordxml_xml/([A-Z]{1,2})/(#{Regexp.escape($argv)})/(.+\.xml)}i)
    if $argv =~ /\A[A-Z]{1,2}\Z/i  # 藏經，如 T
      m = path.match(%r{wordxml_xml/(#{$argv})/([^/]+)/(.+\.xml)}i)
    elsif $argv =~ /\A[A-Z]{1,2}\d{2,3}\Z/i  # 冊，如 T01
      # 來源目錄沒有冊的層次，要靠 sutra_list.txt 查出該 經_卷 屬於哪一冊
      m = path.match(%r{wordxml_xml/([A-Z]{1,2})/([^/]+)/(.+\.xml)}i)
      if m
        vol_of_file = $Sutra2Vol[File.basename(m[3], '.xml')]   # T0001_001 => T01
        m = nil unless vol_of_file && vol_of_file.upcase == $argv.upcase
      end
    else  # 單經，如 T0914
      m = path.match(%r{wordxml_xml/([A-Z]{1,2})/(#{$argv})/(.+\.xml)}i)
    end
  end

  unless m
    # 印出不符合條件的檔案
    # puts "Skip not-matched: #{path}"
    next
  end

  # subdir=T, series=T01, (T01n0001), filename=T01n0001_001.xml
  # subdir, serdir, _, xmlfile = m[1], m[2], m[3], m[4]
  # subdir=T, sernum=T01n0001, filename=T0001_001.xml
  subdir, sernum, xmlfile = m[1], m[2], m[3]

  # 新檔名稱
  outname = convert_filename(xmlfile)
  # 新 basename, 拿掉副檔名如 T01n0001
  basename = File.basename(xmlfile, '.xml')

  # 預期 basename 是 T01n0001_001
  # 預期 basename 是 T02n0128a_001
  if basename =~ /([A-Z]+\d+n)(.*?)_(\d{3})/
    prefix = $1 # T01n
    suffix = $2 # 0128a
    if suffix.size == 4
      basename_txt = "#{prefix}#{suffix}_" # T01n0128a_
    else
      basename_txt = "#{prefix}#{suffix}" # T01n0128a
    end
  else
    basename_txt = basename
  end

  # 讀取、處理、寫出
  xml = Nokogiri::XML(File.read(path))
  lines = body_to_txt(xml, basename_txt) # [[vol, "lb║text"], ...]

  # 依冊號分組(同一卷可能跨冊，例如前半在 X39、後半在 X40)
  # 每個冊號各自組成內容，寫到各自的目錄
  lines.group_by { |vol, _line| vol }.each do |serdir, group|
    content = group.map { |_vol, line| line }.join("\n")

    # 輸出路徑：d:/Temp/wordxml_out_txt/T/T01
    outdir = File.join(OUT_ROOT, subdir, serdir)
    FileUtils.mkdir_p(outdir)

    File.write(File.join(outdir, outname), content)
    puts "Output: #{File.join(outdir, outname)}"
  end
end

puts "All done!"