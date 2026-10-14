# encoding: UTF-8
# 用法:
#   將程式 統計修訂用字數量.rb 放在經文目錄下，最好是當年最後一版的 p5b，可用來做年度統計。
#
#   ruby 統計修訂用字數量.rb <目錄>   統計指定目錄（例如某一部藏經，如 TX、CC、I）
#   ruby 統計修訂用字數量.rb          不給參數時，處理目前目錄下的每一個子目錄（即一次跑完全部藏經）
#
# 固定規則：統計 <lem wit="..."> 且 wit 屬性內含【CB】的數量，
# 代表 CBETA 選用了此文字修訂（即使同時列出其它版本依據亦算數，
# 例如 wit="【CB】 【麗-CB】"）。
#
# 效能設計：<lem> 標記不會跨行，所以不用 Nokogiri 解析整份 DOM，改用正規式比對即可。
#
# 實測發現：一次讀入整檔再用一個正規式 scan，比 File.foreach 逐行讀取
# 快上不少（逐行讀取在 Ruby 端每行都有一次迭代與方法呼叫的開銷，
# 在檔案量大時反而比整檔一次 scan 慢）。在大正藏（約 9000 檔）上實測：
#   Nokogiri                    約 21 秒
#   File.foreach 逐行 scan       約 41 秒（比 Nokogiri 還慢）
#   File.read 整檔一次 scan      約  7 秒（最快，約為 Nokogiri 的 1/3）
# 所以這裡採用「整檔讀入 + 一次 scan」的作法。

# 是否列出每個子目錄的統計（true: 列出小計 / false: 只列總計）

LIST_EACH_DIR = true

PATTERN = /<lem\b[^>]*\swit="[^"]*【CB】[^"]*"/.freeze

def count_in_file(path)
  File.read(path, encoding: 'UTF-8').scan(PATTERN).size
rescue => e
  warn "讀取失敗: #{path} (#{e.message})"
  0
end

# 統計單一藏經目錄（例如 TX），回傳總數
def process_collection(root)
  total = 0

  Dir.glob(File.join(root, '*')).sort.each do |entry|
    next unless File.directory?(entry)

    xml_files = Dir.glob(File.join(entry, '**', '*.xml')).sort
    next if xml_files.empty?

    subtotal = xml_files.sum { |f| count_in_file(f) }
    total += subtotal

    puts "#{File.basename(entry)}\t#{subtotal}" if LIST_EACH_DIR
  end

  # 若目錄本身就直接放 XML 檔（沒有子目錄分層），一併統計
  direct_xml_files = Dir.glob(File.join(root, '*.xml')).sort
  unless direct_xml_files.empty?
    subtotal = direct_xml_files.sum { |f| count_in_file(f) }
    total += subtotal
    puts "#{File.basename(root)} (直屬檔案)\t#{subtotal}" if LIST_EACH_DIR
  end

  total
end

root = ARGV[0]

if root
  unless Dir.exist?(root)
    warn "目錄不存在: #{root}"
    exit 1
  end

  total = process_collection(root)
  puts '---' if LIST_EACH_DIR
  puts "總計\t#{total}"
else
  # 沒給參數：處理目前目錄下的每一個子目錄
  grand_total = 0

  Dir.glob('*').sort.each do |entry|
    next unless File.directory?(entry)

    total = process_collection(entry)
    grand_total += total

    puts '---' if LIST_EACH_DIR
    puts "#{entry}\t#{total}"
    puts '===' if LIST_EACH_DIR
  end

  puts '---'
  puts "全部總計\t#{grand_total}"
end
