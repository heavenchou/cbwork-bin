# 檢查 Table 的 Cols 數字是否正確

# 咒語
# 請幫我完成底下幾件事。
# 1. 找出指定目錄下的 *.xml 檔案。
# 2. 逐檔開啟，要進行表格欄數的檢查。
# 3. 在 XML 中，有這樣的內容
# 
# <lb ed="X" n="0006a05"/><lb ed="R037" n="0536b22"/><p xml:id="pX24p0006a0501">復次，善現！所言菩薩摩訶薩者，於意云何# <note place="inline">入</note></p><table cols="3">
# <lb ed="X" n="0006a06"/><lb ed="R037" n="0536b23"/><row><cell rows="2">即</cell><cell><note place="inline">色</# note></cell><cell rows="2"><note place="inline">廣</note></cell><cell cols="3" rows="2">真如是菩薩摩訶薩不？不也，世尊# </cell></row>
# <lb ed="X" n="0006a07"/><lb ed="R037" n="0536b24"/><row><cell><note place="inline">受、想、行、識</note></cell></row>
# <lb ed="X" n="0006a08"/><lb ed="R037" n="0537a01"/><row><cell rows="2">異</cell><cell><note place="inline">色</# note></cell><cell rows="2"><note place="inline">略</note></cell><cell cols="3" rows="2">真如是菩薩摩訶薩不？不也，世尊# </cell></row>
# 
# 這只是一個例子，首先，在第一行可以看到 <table clos="3"> 表示這是表格的開始。
# <row> 表示每一列
# <cell> 表示每一欄
# 若有 cols="n" 屬性，表示佔有 n 欄
# 若有 rows="n" 屬性，表示佔有 n 列
# 請用程式計算每一列的總欄數，例如：
# 0006a05 ： table 有 3 欄 
# 0006a06 ： 本列有 6 欄
# 直到 </table> 結束時，告知是否每一列欄數都與 table 欄位相同？
# 相同則記錄正確，若有不同，則記錄不正確。
# 
# 如此逐行檢查，直到結束。
# 
# 0006a05 是標記 <lb ed="X" n="0006a05"/> 的 n 值，每一列都有 <lb> 標記，記錄此行是原書的某頁某欄某行。
# 
# 以上，請寫程式處理，謝謝！

require 'nokogiri'
require 'find'


def find_previous_lb_n_deep2(node, ed_prefix = nil)
  while node
    sibling = node.previous_sibling
    while sibling
      if sibling.element? && sibling.name == 'lb'
        ed = sibling['ed']
        if ed_prefix.nil? || (ed && ed.start_with?(ed_prefix))
          return sibling['n']
        end
      end
      sibling = sibling.previous_sibling
    end
    node = node.parent
  end
  'UNKNOWN'
end

def find_previous_lb_n_deep(node, ed_prefix = nil)
  while node
    sibling = node.previous_sibling
    while sibling
      if sibling.element?
        # 自己是 <lb>
        if sibling.name == 'lb'
          ed = sibling['ed']
					if ed[0] != 'R'
          	return sibling['n'] if ed_prefix.nil? || (ed && ed.start_with?(ed_prefix))
					end
        end

        # 遞迴找出內部最後一個符合條件的 <lb>
        lb_inside = sibling.xpath('.//lb').reverse.find do |lb|
          ed = lb['ed']
          (ed_prefix.nil? || (ed && ed.start_with?(ed_prefix))) && ed[0] != 'R'
        end
        return lb_inside['n'] if lb_inside
      end
      sibling = sibling.previous_sibling
    end
    node = node.parent
  end
  'UNKNOWN'
end


def check_table(table_node, file)
  expected_cols = table_node['cols']&.to_i || 0
	#table_lb_X = find_previous_lb_n_deep(table_node,'X')
	#table_lb_R = find_previous_lb_n_deep(table_node,'R')
	table_lb = find_previous_lb_n_deep(table_node)

  results = []
	results << "\n#{file}"
	#results << "R#{table_lb_R}：X#{table_lb_X}：發現 Table ，預期有 #{expected_cols} 欄"
	results << "#{table_lb}：發現 Table ，預期有 #{expected_cols} 欄"
  row_nodes = table_node.xpath('row')
  rowspan_tracker = Hash.new(0)
  row_col_counts = []  # 記錄每一列的總欄數（含被占用的）

  row_nodes.each_with_index do |row, row_index|
    
    occupied_from_above = rowspan_tracker[row_index] || 0
    current_row_cols = 0

    row.xpath('cell').each do |cell|
      colspan = cell['cols'] ? cell['cols'].to_i : 1
      rowspan = cell['rows'] ? cell['rows'].to_i : 1

      current_row_cols += colspan

      # 紀錄未來幾列會被此 cell 佔用的欄數
      (1...rowspan).each do |i|
        rowspan_tracker[row_index + i] += colspan
      end
    end

    total_cols = current_row_cols + occupied_from_above
    row_col_counts << total_cols
    status = total_cols == expected_cols ? '✔️ 正確' : '❌ 不正確'
		#lb_X = find_previous_lb_n_deep(row,'X')
		#lb_R = find_previous_lb_n_deep(row,'R')
		lb = find_previous_lb_n_deep(row)
    #results << "R#{lb_R}：X#{lb_X}：預期 #{expected_cols} 欄，實際 #{total_cols} 欄 → #{status}"
    results << "#{lb}：預期 #{expected_cols} 欄，實際 #{total_cols} 欄 → #{status}"
  end

  # === 檢查表格整體狀態 ===
  unique_counts = row_col_counts.uniq
	result_type = 0
  summary =
    if unique_counts.size == 1
      row_col = unique_counts.first
      if row_col == expected_cols
        #"結果0: R#{table_lb_R}：X#{table_lb_X}： ✅ 此表格為『標準 Table』：所有列均為 #{row_col} 欄，與 table 宣告相符。"
				"結果0: #{table_lb}： ✅ 此表格為『標準 Table』：所有列均為 #{row_col} 欄，與 table 宣告相符。"
      else
				result_type = 1
        #"結果1: R#{table_lb_R}：X#{table_lb_X}： ⚠️ 此表格為『欄數一致但標記錯誤』：所有列均為 #{row_col} 欄，但 table 宣告為 #{expected_cols} 欄。"
        "結果1: #{table_lb}： ⚠️ 此表格為『欄數一致但標記錯誤』：所有列均為 #{row_col} 欄，但 table 宣告為 #{expected_cols} 欄。"
      end
    else
			result_type = 2
      #"結果2: R#{table_lb_R}：X#{table_lb_X}： ❗ 此表格為『欄數不一致 Table』：各列欄數不同，請人工檢查。"
      "結果2: #{table_lb}： ❗ 此表格為『欄數不一致 Table』：各列欄數不同，請人工檢查。"
    end
		
  if result_type == 0
		return []
	end
	
	if result_type == 1
		results = []
	end
	results << summary
	if result_type == 2
		results << ""
	end
  results
end

def process_file(file)
  doc = Nokogiri::XML(File.read(file))
	doc.remove_namespaces!
  tables = doc.xpath('//table')
  results = []
  tables.each do |table|
    results.concat(check_table(table, file))
  end
  results
end

def process_directory(dir)
  Find.find(dir).select { |f| f =~ /\.xml$/ }.flat_map do |file|
    file_header = "======= 開始處理：#{file} ======="
    table_results = process_file(file)
    [file_header] + table_results + ["======= 結束處理：#{file} =======", ""]
		if table_results.size != 0
			puts [file_header] + table_results + ["======= 結束處理：#{file} =======", ""]
		end
  end
end

# === 執行區 ===
if ARGV.empty?
  puts "用法：ruby check_tables.rb /path/to/xml/files"
  exit
end

results = process_directory(ARGV[0])
#puts results
