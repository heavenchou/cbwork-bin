require 'nokogiri'
require 'find'
require 'fileutils'

# 設定來源與輸出根目錄
SRC_ROOT = 'd:/Temp/wordxml_xml/'
OUT_ROOT = 'd:/Temp/wordxml_out_txt/'

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
  return '' unless body

  raw_xml = body.inner_html

  # 保留所有 <!-- lb: ??? -->的資訊
  # 我們要把 <footnote>先換成特殊佔位符，最後再插回去
  footnotes = []
  raw_xml = raw_xml.gsub(/<footnote>(.*?)<\/footnote>/m) do
    footnotes << $1
    #"[__FOOTNOTE_#{footnotes.size - 1}__]"
    ""
  end

  # 根據 <!-- lb: xxx --> 分割
  # (允許一行有多個。前一個片段如果沒 lb 標記，補個首段)
  lines = raw_xml.split(/<!--\s*lb:\s*([a-zA-Z\d]+)\s*-->/)
  # lines 會是: ["<p>首段內容</p>", "0001a01", "<p>有lb內容</p>", "0001a02", ...]
  result = []
  i = 1
  while i < lines.size
    lb = lines[i].strip # 0001a01
    content = lines[i+1].to_s
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

    # 移除所有 HTML 標籤
		text = Nokogiri::HTML.fragment(content).text
		# 移除 footnote 佔位後，合併多餘空白與換行
		# text.gsub!(/\[__FOOTNOTE_(\d+)__\]/) { "[#{$1.to_i + 1}]" }
		# 下面這一行是加的，把多餘的換行、空白都去掉
		text = text.gsub(/[\r\n]+/, '')
    #【經文資訊】之後的文字都忽略
    text = text.gsub(/【經文資訊】.*/, '')

    # 組合處理
    line_label = "#{basename}p#{lb}"
    result << "#{line_label}║#{text}"

    i += 2
  end
  result.join("\n")
end

# 取得傳入的參數
$argv = ""

if ARGV.size > 0
  $argv = ARGV[0]
end

Find.find(SRC_ROOT) do |path|
  next unless File.file?(path)
  next unless path =~ /\.xml$/i

  # 擷取資料夾 T/T01 與檔名 T01n0001_001.xml
  m = path.match(%r{wordxml_xml/([A-Z]{1,2})/([^/]+)/([^/]+)/(.+\.xml)}i)
  if ARGV.size > 0
    # 如果有參數，則只處理該參數的資料夾
    # 例如：ruby wordxml2txt.rb T01 
    # 會處理 wordxml_xml/T/T01/ 下的所有檔案
    m = path.match(%r{wordxml_xml/([A-Z]{1,2})/(#{Regexp.escape($argv)})/([^/]+)/(.+\.xml)}i)
  end

  unless m
    puts "Skip not-matched: #{path}"
    next
  end

  # subdir=T, series=T01, (T01n0001), filename=T01n0001_001.xml
  subdir, serdir, _, xmlfile = m[1], m[2], m[3], m[4]
  # 輸出路徑：d:/Temp/wordxml_out_txt/T/T01
  outdir = File.join(OUT_ROOT, subdir, serdir)
  FileUtils.mkdir_p(outdir)

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
  content = body_to_txt(xml, basename_txt)
  File.write(File.join(outdir, outname), content)
  puts "Output: #{File.join(outdir, outname)}"
end

puts "All done!"