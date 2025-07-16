# 使用取代表進行檔案取代
# 使用參數
#
# 用法：ruby replace.rb <輸入檔案或資料夾> <輸出檔案或資料夾> <對照表檔案>
#
# 可以處理單一檔案，例如：
# ruby replace.rb 輸入檔.txt 輸出檔.txt 取代表.txt
#
# 也可以處理整個資料夾，例如：
# ruby replace.rb 輸入目錄 輸出目錄 取代表.txt

# 取代表有一些特殊用法，這裡說明一下。假設取代表如下：
# 
# A=B
# =*
# C*D
# a=b*x=y
# =!
# [金*本]=鉢!鉢
# ==
# X=Y
# 
# 底下逐行說明
# 
# A=B           => 表示 A 要取代成 B
# =*            =>  直接在等號後面放新的符號，表示底下是用新符號 * 區隔
# C*D           =>  表示 C 要取代成 D
# a=b*x=y       =>  表示 a=b 要取代成 x=y，這也就是為什麼取代符號要由 = 換成 *
# =!            =>  直接在等號後面放新的符號，表示底下是用新符號 ! 區隔
# [金*本]=鉢!鉢  =>  表示 [金*本]=鉢 要取代成 鉢，這也就是為什麼要換成 !
# ==            =>  直接在等號後面放新的符號，表示底下是用 = 區隔
# X=Y           =>  表示 X 要取代成 Y

#!/usr/bin/env ruby
# encoding: UTF-8

require 'fileutils'
require 'pathname'

# === 主程式參數 ===
in_path  = ARGV[0]
out_path = ARGV[1]
table_file = ARGV[2]

if !in_path || !out_path || !table_file
  puts "用法：ruby replace.rb <輸入檔案或資料夾> <輸出檔案或資料夾> <對照表檔案>"
  exit
end

# 正規化路徑
in_path = File.expand_path(in_path)
out_path = File.expand_path(out_path)
table_file = File.expand_path(table_file)

# === 讀取對照表 ===
search_list = []
replace_list = []
delimiter = '='

begin
  File.open(table_file, 'r:bom|utf-8') do |file|
    file.each_line do |line|
      line.chomp!
      # line.gsub!("\uFEFF", '')  # 移除 BOM

      if line =~ /^=(.)$/
        delimiter = $1
      elsif line.include?(delimiter)
        parts = line.split(delimiter, 2)  # 只分割成兩部分
        if parts.length == 2
          search_list << parts[0]
          replace_list << parts[1]
        end
      end
    end
  end
rescue => e
  puts "錯誤：無法讀取對照表檔案 #{table_file}: #{e.message}"
  exit
end

# === 檔案取代函數 ===
def process_file(input_file, output_file, search_list, replace_list)
  begin
    content = File.read(input_file, encoding: 'utf-8')
    search_list.each_with_index do |s, i|
      content.gsub!(s, replace_list[i])
    end
    FileUtils.mkdir_p(File.dirname(output_file))
    File.write(output_file, content, encoding: 'utf-8')
    puts "處理完成: #{input_file} -> #{output_file}"
  rescue => e
    puts "錯誤：處理檔案 #{input_file} 時發生錯誤: #{e.message}"
  end
end

# === 處理邏輯 ===
if File.file?(in_path)
  process_file(in_path, out_path, search_list, replace_list)

elsif File.directory?(in_path)
  Dir.glob("#{in_path}/**/*").each do |input_file|
    next unless File.file?(input_file)

    # 建立對應輸出檔路徑 - 修正路徑處理
    relative_path = Pathname.new(input_file).relative_path_from(Pathname.new(in_path))
    output_file = File.join(out_path, relative_path.to_s)

    process_file(input_file, output_file, search_list, replace_list)
  end
else
  puts "錯誤：#{in_path} 不是有效的檔案或資料夾"
end