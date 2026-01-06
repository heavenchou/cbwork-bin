#!/usr/bin/env ruby
# encoding: UTF-8

require 'find'

#=== 使用方式 ===
# ruby count_punctuation.rb /path/to/xml_dir

def run_path(path)

  # 檢查參數
  dir = 'd:/cbeta.www/download/cbreader/bookcase_v096_20250813/Bookcase/CBETA/XML/' + path
  dir = 'd:/cbwork/xml-p5a/' + path
  dir = 'd:/temp/temp/xml-p5a/' + path

  # 統計用 Hash
  result = Hash.new(0)
  total_volumes = 0

  # 掃描所有子目錄下的 XML
  Find.find(dir) do |path|
    next unless path.downcase.end_with?(".xml")

    punctuation_type = nil
    volume_count = 0

    File.foreach(path, chomp: true) do |line|
      # 找卷數
      if line =~ /<extent>(\d+)卷<\/extent>/
        volume_count = $1.to_i
        # volume_count = 1  # 單卷版，每個檔案算一卷
      end

      # 找標點類型
      if line =~ /<punctuation[^>]*><p>([^<]+)<\/p><\/punctuation>/
        punctuation_type = $1.strip
        break
      end
    end

    # 若沒標明標點，歸為「未標明」
    punctuation_type ||= "未標明"

    # 累計
    result[punctuation_type] += volume_count
    $total_result[punctuation_type] += volume_count
    total_volumes += volume_count
    $total_juan += volume_count
  end

  #=== 輸出結果 ===
  puts "標點統計：" + path
  result.each do |k, v|
    puts "#{k}：#{v}卷"
  end
  puts "總共 #{total_volumes} 卷\n======================="
end

$total_juan = 0
$total_新標 = 0
$total_result = Hash.new(0)

# run_path('A')
# run_path('B')
# run_path('C')
# run_path('CC')
# run_path('D')
# run_path('F')
# run_path('G')
# run_path('GA')
# run_path('GB')
# run_path('I')
# run_path('J')
# run_path('K')
# run_path('L')
# run_path('LC')
# run_path('M')
# run_path('N')
# run_path('P')
# run_path('S')
# run_path('T')
run_path('TX')
# run_path('U')
# run_path('X')
# run_path('Y')
# run_path('ZS')
# run_path('ZW')

puts "全部標點統計："
$total_result.each do |k, v|
  puts "#{k}：#{v}卷"
end
puts "總共 #{$total_juan} 卷\n======================="

