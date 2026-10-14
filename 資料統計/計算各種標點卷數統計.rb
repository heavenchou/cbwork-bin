#!/usr/bin/env ruby
# encoding: UTF-8

require 'find'

#=== 使用方式 ===
# ruby count_punctuation.rb /path/to/xml_dir

def run_path(path)

  # 檢查參數
  dir = 'd:/cbeta.www/download/cbreader/bookcase_v096_20250813/Bookcase/CBETA/XML/' + path
  dir = 'd:/cbwork/bin/資料統計/2025/' + path
  dir = 'd:/cbwork/xml-p5a/' + path
  dir = 'c:/CBETA/CBReader2X/Bookcase/CBETA/XML/' + path
  

  # 統計用 Hash
  result = Hash.new(0)
  result_sutra = Hash.new(0)
  total_volumes = 0 # 卷數
  total_sutra = 0 # 部數
  sutra_id = "" # T123 這種格式的 ID，不是標準的 T0123
  sutra_ids = Hash.new(0) # 判斷某 id 是否出現過了

  # 掃描所有子目錄下的 XML
  Find.find(dir) do |path|
    next unless path.downcase.end_with?(".xml")

    punctuation_type = nil
    volume_count = 0
    sutra_id = ""

    File.foreach(path, chomp: true) do |line|
      
      # 計算經數
      # <idno type="canon">T</idno>.<idno type="vol">18</idno>.<idno type="no">851</idno>
      if line =~ /<idno type="canon">([A-Z]+)<\/idno>.*<idno type="no">([^<]+)<\/idno>/
        sutra_id = $1 + $2
      end

      # 單卷版，每個檔案算一卷
      # <edition>單卷版 XML TEI P5b</edition>
      # <edition>修訂版一刷<date>Date: 2014/04</date>單卷版 XML TEI P5b</edition>
      if line =~ /<edition>.*單卷版/
        volume_count = 1  # 單卷版，每個檔案算一卷
      end

      # 找卷數
      if line =~ /<extent>(\d+)卷<\/extent>/
        # 若是單卷版，則此變數為 1
        if volume_count == 0
          volume_count = $1.to_i
        end
      end

      # 找標點類型
      # <punctuation resp="CBETA"><p>新式標點</p></punctuation>
      if line =~ /<punctuation([^>]*)><p>([^<]+)<\/p><\/punctuation>/
        punctuation_resp = $1.strip
        punctuation_type = $2.strip
        if punctuation_resp =~ /resp="(.*?)"/
          punctuation_resp = $1
        else
          punctuation_resp = "unknow"
        end
        punctuation_type = punctuation_resp + "_" + punctuation_type
        break
      end
    end

    # 若沒標明標點，歸為「未標明」
    punctuation_type ||= "未標明"

    # 累計卷數
    result[punctuation_type] += volume_count
    $total_result[punctuation_type] += volume_count
    total_volumes += volume_count
    $total_juan += volume_count
    # 累計經數
    if sutra_ids[sutra_id] != 1 # 沒出現過
      result_sutra[punctuation_type] += 1
      $total_result_sutra[punctuation_type] += 1
      total_sutra += 1
      $total_sutra += 1
      sutra_ids[sutra_id] = 1
    end
  end

  #=== 輸出結果 ===
  puts "標點統計：" + path
  result.each do |k, v|
    puts "#{k}：#{result_sutra[k]}部 #{v}卷"
  end
  puts "總共 #{total_sutra} 部 #{total_volumes} 卷\n======================="
end

$total_juan = 0
$total_新標 = 0
$total_sutra = 0
$total_result = Hash.new(0)
$total_result_sutra = Hash.new(0)

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
run_path('J')
# run_path('K')
# run_path('L')
# run_path('LC')
# run_path('M')
# run_path('N')
# run_path('P')
# run_path('S')
# run_path('T')
# run_path('TX')
# run_path('U')
# run_path('X')
# run_path('Y')
# run_path('YP')
# run_path('ZS')
# run_path('ZW')

puts "全部標點統計："
$total_result.each do |k, v|
  puts "#{k}：#{$total_result_sutra[k]}部 #{v}卷"
end
puts "總共 #{$total_sutra} 部 #{$total_juan} 卷\n======================="

